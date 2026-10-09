// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'Invia';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionSearch => 'Cerca';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionDone => 'Fatto';

  @override
  String get actionNext => 'Avanti';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get tabChats => 'Chat';

  @override
  String get tabNews => 'Novità';

  @override
  String get tabCalls => 'Chiamate';

  @override
  String get tabPeers => 'Contatti';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get appearanceAuto => 'Automatico';

  @override
  String get appearanceLight => 'Chiaro';

  @override
  String get appearanceDark => 'Scuro';

  @override
  String get appearanceFooter =>
      'Droplet è pensato per la modalità scura: su uno schermo OLED i pixel neri sono spenti, il che risparmia batteria e non abbaglia al buio. La modalità chiara resta disponibile per leggere in piena luce solare.';

  @override
  String get sectionLanguage => 'Lingua';

  @override
  String get languageAuto => 'Automatica (lingua del telefono)';

  @override
  String get languageFooter =>
      '«Automatica» segue la lingua impostata sul dispositivo. Se quella lingua non è ancora supportata, Droplet resta in francese.';

  @override
  String get chatsTitle => 'Chat';

  @override
  String get chatsSearchHint => 'Cerca';

  @override
  String get chatsFilterAll => 'Tutte';

  @override
  String get chatsFilterUnread => 'Non lette';

  @override
  String get chatsFilterGroups => 'Gruppi';

  @override
  String get chatsFilterPinned => 'Fissate';

  @override
  String get chatsEmptyTitle => 'Nessuna chat';

  @override
  String get chatsEmptySubtitle =>
      'Avvicinati a un dispositivo che usa Droplet: apparirà qui automaticamente.';

  @override
  String get chatsSearchEmptyTitle => 'Nessun risultato';

  @override
  String get chatsSearchEmptySubtitle => 'Prova un altro nome.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatti nelle vicinanze',
      one: '$count contatto nelle vicinanze',
      zero: 'Ricerca di contatti…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'Almeno 3 caratteri';

  @override
  String get obChoosePseudo => 'Scegli un nome per iniziare';

  @override
  String get obRestoreFailed => 'Ripristino non riuscito';

  @override
  String get obPhotoSaveFailed => 'Impossibile salvare la foto';

  @override
  String get obShareUnavailable => 'Condivisione non disponibile';

  @override
  String get obBackupPasswordTitle => 'Password del backup';

  @override
  String get obBackupPasswordMessage =>
      'Quella scelta durante l\'esportazione della tua identità.';

  @override
  String get obBackupPasswordPlaceholder => 'Password';

  @override
  String get obRestore => 'Ripristina';

  @override
  String get obSkipStep => 'Salta questo passaggio';

  @override
  String get obContinue => 'Continua';

  @override
  String get obStart => 'Inizia';

  @override
  String get obAlreadyHaveBackup => 'Ho già un backup';

  @override
  String get obWelcomeTitle => 'Benvenuto in\nDroplet';

  @override
  String get obWelcomeSubtitle =>
      'Una messaggistica che funziona dove non c\'è più rete.';

  @override
  String get obFeatOfflineTitle => 'Senza internet, senza operatore';

  @override
  String get obFeatOfflineText =>
      'I telefoni si parlano direttamente, un salto alla volta. Nessuna antenna, nessuna bolletta.';

  @override
  String get obFeatEncryptedTitle => 'Crittografato end-to-end';

  @override
  String get obFeatEncryptedText =>
      'Nemmeno i telefoni che inoltrano i tuoi messaggi possono leggerli.';

  @override
  String get obFeatLocalTitle => 'Niente lascia il tuo dispositivo';

  @override
  String get obFeatLocalText =>
      'Nessun account, nessun server, nessuna raccolta dati. Le tue conversazioni restano con te.';

  @override
  String get obRelayTitle => 'Passo\ndopo passo';

  @override
  String get obRelaySubtitle =>
      'Il tuo messaggio salta da un telefono all\'altro fino al destinatario, anche se non sei a portata diretta.';

  @override
  String get obFeatCrowdTitle => 'Più siamo, più lontano arriva';

  @override
  String get obFeatCrowdText =>
      'Ogni dispositivo a portata amplia la rete per tutti.';

  @override
  String get obFeatNothingLostTitle => 'Niente va perso';

  @override
  String get obFeatNothingLostText =>
      'Un messaggio per qualcuno assente attende, poi riparte non appena si apre un percorso.';

  @override
  String get obSafetyTitle => 'Ritrovarsi,\nsenza rete';

  @override
  String get obSafetySubtitle =>
      'Quando nient\'altro funziona, sapere dove sono gli altri e che stanno bene diventa l\'informazione più utile.';

  @override
  String get obFeatMapTitle => 'Una mappa che funziona offline';

  @override
  String get obFeatMapText =>
      'Le zone che consulti restano sul telefono. Una volta visualizzate, si mostrano senza internet.';

  @override
  String get obFeatMeshPosTitle => 'Le posizioni arrivano dalla mesh';

  @override
  String get obFeatMeshPosText =>
      'Nessun server: la posizione parte dal telefono del tuo contatto, cifrata, e salta da dispositivo a dispositivo fino al tuo.';

  @override
  String get obFeatCheckinTitle => '«Sto bene», con un gesto';

  @override
  String get obFeatCheckinText =>
      'Un solo tocco diffonde il tuo stato a tutto il vicinato. Scegli se allegare una posizione approssimativa, o no.';

  @override
  String get obStatusTitle => 'Condividere\nnotizie';

  @override
  String get obStatusSubtitle =>
      'Una foto, una parola, un umore: il tuo stato circola da telefono a telefono, come i tuoi messaggi.';

  @override
  String get obFeatStatusMediaTitle => 'Foto, video o testo';

  @override
  String get obFeatStatusMediaText =>
      'Pubblica ciò che vuoi mostrare. Le persone a portata lo ricevono, senza passare da internet.';

  @override
  String get obFeatStatusSeenTitle => 'Vedi chi l\'ha visto';

  @override
  String get obFeatStatusSeenText =>
      'Ogni persona che apre il tuo stato te lo fa sapere, tramite lo stesso percorso.';

  @override
  String get obFeatStatusExpireTitle => 'Scompare dopo un giorno';

  @override
  String get obFeatStatusExpireText =>
      'Ventiquattro ore, poi lo stato si cancella da tutti i telefoni che lo avevano ricevuto.';

  @override
  String get obRemovePhoto => 'Rimuovi la foto';

  @override
  String get obChoosePhoto => 'Scegli una foto';

  @override
  String get obPhotoTitle => 'Un volto,\nse vuoi';

  @override
  String get obPhotoSubtitle =>
      'Aiuta gli altri a riconoscerti in un elenco. Niente ti obbliga ad averne una.';

  @override
  String get obFeatPhotoLocalTitle => 'Resta su questo telefono';

  @override
  String get obFeatPhotoLocalText =>
      'Nessun server la riceve, nessun backup online la conserva. Vive nella cartella dell\'app, e da nessun\'altra parte.';

  @override
  String get obFeatPhotoCompressTitle => 'Ridotta prima di essere salvata';

  @override
  String get obFeatPhotoCompressText =>
      'Droplet conserva solo una miniatura di 320 pixel. La tua foto originale non viene mai copiata.';

  @override
  String get obNetworkTitle => 'Droplet cresce\ncon te';

  @override
  String get obNetworkSubtitle =>
      'Ogni persona che lo installa amplia la rete, per sé e per tutti intorno.';

  @override
  String get obSendToFriend => 'Invia Droplet a una persona cara';

  @override
  String get obFeatShareOfflineTitle =>
      'Anche la condivisione fa a meno di internet';

  @override
  String get obFeatShareOfflineText =>
      'Droplet ti invia il proprio file di installazione. Viaggia via Bluetooth, Wi-Fi Direct o scheda di memoria — nessuna connessione necessaria, da entrambe le parti.';

  @override
  String get obFeatThreeTitle => 'Bastano tre persone per iniziare';

  @override
  String get obFeatThreeText =>
      'In due, vi scrivete a vista. In pochi in un quartiere, i messaggi si inoltrano e la portata diventa molto più grande di ogni singolo telefono.';

  @override
  String get obIdentityTitle => 'Come dobbiamo\nchiamarti?';

  @override
  String get obIdentitySubtitle =>
      'Questo nome apparirà alle persone che incontri. Puoi sceglierne uno che non ti identifichi.';

  @override
  String get obPseudoHint => 'Il tuo nome';

  @override
  String get obFeatKeysTitle => 'Le tue chiavi vengono create qui, ora';

  @override
  String get obFeatKeysText =>
      'Non lasciano mai questo telefono. Ricordati di fare un backup dalle impostazioni: senza di esso, un\'identità persa lo è per sempre.';

  @override
  String get splashCaption => 'Offline. Senza operatore.';

  @override
  String get chatsMeshNetwork => 'Rete mesh';

  @override
  String get chatsNew => 'Nuovo';

  @override
  String get chatsNewGroup => 'Nuovo gruppo';

  @override
  String get chatsAssistant => 'Assistente';

  @override
  String get chatsEmergencyMode => 'Modalità emergenza';

  @override
  String get chatsUnpin => 'Rimuovi fissaggio';

  @override
  String get chatsPin => 'Fissa in alto';

  @override
  String get chatsUnmute => 'Attiva notifiche';

  @override
  String get chatsMute => 'Disattiva audio';

  @override
  String get chatsArchive => 'Archivia';

  @override
  String get swipePin => 'Fissa';

  @override
  String get swipeUnpin => 'Sblocca';

  @override
  String get swipeMute => 'Silenzia';

  @override
  String get swipeUnmute => 'Attiva';

  @override
  String get swipeArchive => 'Archivia';

  @override
  String get fmtBold => 'Grassetto';

  @override
  String get fmtItalic => 'Corsivo';

  @override
  String get fmtStrike => 'Barrato';

  @override
  String get fmtMono => 'Monospazio';

  @override
  String get fmtSpoiler => 'Spoiler';

  @override
  String get vnTranscribing => 'Trascrizione…';

  @override
  String get vnTranscribeFailed =>
      'Trascrizione non disponibile su questo dispositivo';

  @override
  String get vnNoSpeech => 'Nessun parlato riconosciuto';

  @override
  String get msgTranslate => 'Traduci';

  @override
  String get msgShowOriginal => 'Mostra originale';

  @override
  String get msgTranslatedFrom => 'Tradotto automaticamente';

  @override
  String get msgTranslateFailed => 'Traduzione non disponibile';

  @override
  String get msgTranslateModel =>
      'Modello linguistico da scaricare (una volta, in Wi‑Fi)';

  @override
  String get pfWallpapers => 'Sfondi animati';

  @override
  String get pfWallpapersDesc =>
      'Otto sfondi multicolore che vivono dietro le chat e ruotano a ogni messaggio inviato.';

  @override
  String get pfFormatting => 'Formattazione';

  @override
  String get pfFormattingDesc =>
      'Grassetto, corsivo, barrato, codice e spoiler nei tuoi messaggi.';

  @override
  String get pfTranscription => 'Voce in testo';

  @override
  String get pfTranscriptionDesc =>
      'Leggi un messaggio vocale quando non puoi ascoltarlo. Il riconoscimento avviene sul telefono.';

  @override
  String get pfTranslation => 'Traduzione';

  @override
  String get pfTranslationDesc =>
      'Traduci un messaggio ricevuto senza che il contenuto lasci il dispositivo.';

  @override
  String get pfAppIcons => 'Icone dell\'app';

  @override
  String get pfAppIconsDesc =>
      'Cambia l\'icona di Droplet sulla schermata iniziale.';

  @override
  String get pfBadge => 'Distintivo e sostegno';

  @override
  String get pfBadgeDesc =>
      'Un distintivo accanto al tuo nome e il sostegno a un progetto indipendente.';

  @override
  String get pfUnderstood => 'Ho capito';

  @override
  String get pfFeaturesTitle => 'Cosa sblocca il pacchetto';

  @override
  String get chatsUnarchive => 'Rimuovi da archivio';

  @override
  String get chatsArchivedTitle => 'Archiviate';

  @override
  String get chatsNoArchived => 'Nessuna chat archiviata';

  @override
  String get chatsLockedTitle => 'Chat bloccate';

  @override
  String get chatsNoLocked => 'Nessuna chat bloccata';

  @override
  String get chatsCrashTitle => 'Droplet si è chiuso inaspettatamente';

  @override
  String get chatsCrashBody =>
      'Droplet non ha alcun server: senza il tuo invio, questo difetto non esiste per nessun altro. Il rapporto non contiene messaggi, contatti o chiavi.';

  @override
  String get chatsSendReport => 'Invia il rapporto';

  @override
  String get chatsLater => 'Più tardi';

  @override
  String get stTitle => 'Impostazioni';

  @override
  String get stIconHeader => 'Icona';

  @override
  String get stIconFooter =>
      'Tredici icone tra cui scegliere per la schermata principale.';

  @override
  String get stAppIcon => 'Icona dell\'app';

  @override
  String get stVariants13 => '13 varianti';

  @override
  String get stNetworkHeader => 'Rete';

  @override
  String get stNetworkFooter =>
      'L\'inoltro in background permette di trasmettere i messaggi altrui anche a Droplet chiuso.';

  @override
  String get stRequireTor => 'Richiedi Tor online';

  @override
  String get stRequireTorSubtitle => 'Senza Tor, nulla raggiunge i server';

  @override
  String get stRequireTorFooter =>
      'L\'elenco e la casella passano da Tor quando è attivo. Altrimenti Droplet si collega direttamente: il contenuto resta cifrato end-to-end, ma i server vedono il tuo indirizzo IP. Attiva per vietarlo, al prezzo della messaggistica online quando Tor non funziona.';

  @override
  String get stMeshNetwork => 'Rete mesh';

  @override
  String get stPeersTopology => 'Peer connessi e topologia';

  @override
  String get stOfflineMaps => 'Mappe offline';

  @override
  String get stZonesImport => 'Aree salvate e importazione mappe';

  @override
  String get stSecurityHeader => 'Sicurezza';

  @override
  String get stSecurityFooter =>
      'Droplet non conserva alcuna copia della tua identità. Senza backup, va persa con il dispositivo.';

  @override
  String get stBackupIdentity => 'Esegui il backup della mia identità';

  @override
  String get stExportEncrypted => 'Esportazione crittografata con password';

  @override
  String get stEmergencyMode => 'Modalità emergenza';

  @override
  String get stSignalSafe => 'Segnala che stai bene';

  @override
  String get stContributionHeader => 'Contributo';

  @override
  String get stMyContribution => 'Il mio contributo';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'Attivo';

  @override
  String get stProPackUnlocked => 'Pacchetto sbloccato';

  @override
  String get stProIconsThemes => 'Icone e sfondi';

  @override
  String get stCrashLog => 'Registro errori';

  @override
  String get stAbout => 'Informazioni su Droplet';

  @override
  String get stBackgroundRelay => 'Inoltro in background';

  @override
  String get stActiveClosed => 'Attivo anche ad app chiusa';

  @override
  String get stActiveOpenOnly => 'Attivo solo ad app aperta';

  @override
  String get stBatteryOptim => 'Ottimizzazione batteria';

  @override
  String get stAndroidMayLimit => 'Android potrebbe limitare l\'inoltro';

  @override
  String get stFix => 'Correggi';

  @override
  String get stKeepActiveTitle => 'Mantenere Droplet attivo?';

  @override
  String get stKeepActiveBody =>
      'Una notifica permanente indicherà che Droplet sta inoltrando la mesh, anche ad app chiusa. In cambio, la batteria sarà più sollecitata.';

  @override
  String get stEnable => 'Attiva';

  @override
  String get stCancel => 'Annulla';

  @override
  String get stAboutTagline =>
      'Messaggistica e chiamate offline, senza internet né operatore.';

  @override
  String get stAboutDirect => 'Rete diretta tra dispositivi — nessun server';

  @override
  String get stAboutE2E => 'Crittografia end-to-end su tutti i messaggi';

  @override
  String get stAboutNoThirdParty => 'Nessun dato inviato a terzi';

  @override
  String get stAttributionEmoji =>
      'Emoji animate: Noto Animated Emoji © Google, con licenza CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'Assistente: Gemma 3 1B-IT © Google, quantizzato (int4) da litert-community e ripubblicato da Droplet, secondo i termini di utilizzo di Gemma (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'Sfondo chat';

  @override
  String get stChatPatterns => 'Disegni Droplet';

  @override
  String get stChatPatternsSubtitle =>
      'Piccoli disegni a tratto sopra lo sfondo';

  @override
  String get stChatBgFooter =>
      'Il gradiente avanza di un passo a ogni messaggio inviato. Scegli «Nessuno» per uno sfondo unito: così non viene calcolato nulla, risparmiando batteria.';

  @override
  String get stBgFree => 'Gratuiti';

  @override
  String get stBgPremium => 'Premium · animati';

  @override
  String get stBgNone => 'Nessuno';

  @override
  String get stBgDefault => 'Predefinito';

  @override
  String get stBgThisChat => 'Sfondo di questa chat';

  @override
  String get stTextSize => 'Dimensione del testo';

  @override
  String get stBubbleCorners => 'Angoli dei messaggi';

  @override
  String get stAccentHeader => 'Colore principale';

  @override
  String get stAccentFooter =>
      'Colora i tuoi fumetti, i pulsanti e i link in tutta l\'app.';

  @override
  String get stChatListHeader => 'Elenco chat';

  @override
  String get stChatListTwoLines => 'Due righe';

  @override
  String get stChatListThreeLines => 'Tre righe';

  @override
  String get stResetAppearance => 'Ripristina l\'aspetto';

  @override
  String get stPreviewIncoming => 'Ci vediamo stasera?';

  @override
  String get stPreviewOutgoing => 'Sì, volentieri!';

  @override
  String get stAppearanceRow => 'Aspetto';

  @override
  String get stAppearanceSubtitle =>
      'Tema, colore, dimensione del testo, sfondi';

  @override
  String get stBgApply => 'Usa questo sfondo';

  @override
  String get stBgUnlock => 'Sblocca con Premium';

  @override
  String get stBgApplied => 'Sfondo applicato';

  @override
  String get stBgPreviewHint =>
      'Lo sfondo si muove e i colori ruotano a ogni messaggio inviato.';

  @override
  String get stBgPreviewIncoming => 'Hai visto il nuovo sfondo?';

  @override
  String get stBgPreviewOutgoing => 'Sì, è bellissimo ✨';

  @override
  String get stSoundHeader => 'Suoni';

  @override
  String get stSoundToggle => 'Suoni dell\'app';

  @override
  String get stSoundSubtitle => 'Messaggi, connessioni, avvisi';

  @override
  String get stSoundFooter =>
      'Toni brevi, al volume delle notifiche di sistema — silenziosi se il telefono è in silenzioso o modalità Focus.';

  @override
  String get stPacksHeader => 'Assistente — schede offline';

  @override
  String get stPacksToggle => 'Schede di primo soccorso ed emergenza';

  @override
  String get stPacksSubtitle =>
      'L\'assistente vi si appoggia per primo soccorso ed emergenze.';

  @override
  String get stPacksFooter =>
      'Schede di riferimento integrate (primo soccorso, terremoto, alluvione, acqua potabile…). Quando la domanda lo richiede, l\'assistente cita la scheda invece di improvvisare. Non sostituiscono una formazione né una chiamata ai soccorsi.';

  @override
  String get stPrivateModeHeader => 'Modalità privata';

  @override
  String get stTorFooter =>
      'Tor protegge il tuo indirizzo IP e le tue conversazioni facendoli passare attraverso la rete Tor. La mesh locale (BLE/Wi-Fi) continua a funzionare normalmente.';

  @override
  String get stTorActiveAnon => 'Attivo — i tuoi dati sono anonimizzati';

  @override
  String get stTorConnecting => 'Connessione in corso…';

  @override
  String get stTorDisabled => 'Modalità privata disattivata';

  @override
  String get callsTitle => 'Chiamate';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chiamate perse',
      one: '$count chiamata persa',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'Nuova chiamata';

  @override
  String get callsAll => 'Tutte';

  @override
  String get callsMissed => 'Perse';

  @override
  String get callsNoneMissed => 'Nessuna chiamata persa';

  @override
  String get callsNone => 'Nessuna chiamata';

  @override
  String get callsMissedEmptyBody =>
      'Le chiamate a cui non hai risposto appariranno qui.';

  @override
  String get callsEmptyBody =>
      'Le chiamate passano attraverso la rete locale, senza operatore né piano tariffario. La tua cronologia apparirà qui.';

  @override
  String get callsRetained200 =>
      'Le ultime 200 chiamate sono conservate solo su questo dispositivo.';

  @override
  String get callsIncoming => 'In arrivo';

  @override
  String get callsOutgoing => 'In uscita';

  @override
  String get callsMissedLabel => 'Persa';

  @override
  String get callsNoAnswer => 'Nessuna risposta';

  @override
  String get callsConnectionFailed => 'Connessione fallita';

  @override
  String get callsYesterday => 'ieri';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m min $s s';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s s';
  }

  @override
  String get peersTitle => 'Contatti';

  @override
  String get peersSearching => 'Ricerca in corso…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivi a portata',
      one: '$count dispositivo a portata',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'Mappa della rete';

  @override
  String get peersNoneInRange => 'Nessuno a portata';

  @override
  String get peersNoneInRangeBody =>
      'Droplet cerca costantemente dispositivi vicini. Avvicinati a qualcuno con l\'app per stabilire il primo collegamento.';

  @override
  String get peersDirectRange => 'A portata diretta';

  @override
  String get peersDirectRangeFooter =>
      'Questi dispositivi sono raggiungibili senza passare da nessun altro.';

  @override
  String get peersRelayed => 'Tramite inoltro';

  @override
  String get peersRelayedFooter =>
      'Questi dispositivi sono fuori dalla portata diretta: i messaggi li raggiungono passando per altri telefoni.';

  @override
  String get peersRelay => 'Relay';

  @override
  String get peersCall => 'Chiama';

  @override
  String get peersTooSlow => 'Troppo lento per la voce — avvicinati';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'Bluetooth';

  @override
  String get peersUnknownLink => 'Collegamento sconosciuto';

  @override
  String get peersDirect => 'diretto';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salti',
      one: '$count salto',
      zero: 'diretto',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'Questo stato è scaduto';

  @override
  String get svReceiving => 'Ricezione in corso…';

  @override
  String get svReceivingBody => 'Il file arriva tramite la rete locale';

  @override
  String get svProgressLabel => 'Avanzamento dello stato';

  @override
  String get svReplyHint => 'Rispondi…';

  @override
  String get svSendReply => 'Invia risposta';

  @override
  String get svYourStatus => 'Il tuo stato';

  @override
  String get svNoViewsYet =>
      'Nessuno ha ancora visto questo stato.\nContinuerà a circolare finché incontrerai altri dispositivi.';

  @override
  String get svJustNow => 'proprio ora';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min fa',
      one: '$count min fa',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h fa',
      one: '$count h fa',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'Musica';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visualizzazioni',
      one: '$count visualizzazione',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mi piace',
      one: '$count mi piace',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risposte',
      one: '$count risposta',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'Originale';

  @override
  String get cpFilterDark => 'Scuro';

  @override
  String get cpFilterBright => 'Luminoso';

  @override
  String get cpFilterVintage => 'Vintage';

  @override
  String get cpWriteStatusHint => 'Scrivi uno stato';

  @override
  String get cpPreparingVideo => 'Preparazione del video…';

  @override
  String get cpLoadingEllipsis => 'Caricamento…';

  @override
  String cpEndsIn(Object s) {
    return 'Termina tra $s s';
  }

  @override
  String get cpModeVideo => 'Video';

  @override
  String get cpModePhoto => 'Foto';

  @override
  String get cpModeMessage => 'Messaggio';

  @override
  String get cpModeVoice => 'Vocale';

  @override
  String get gcChooseName => 'Scegli un nome per il gruppo';

  @override
  String get gcSelectOneMember => 'Seleziona almeno un membro';

  @override
  String get gcCreationFailed => 'Creazione del gruppo non riuscita';

  @override
  String get gcNewGroup => 'Nuovo gruppo';

  @override
  String get gcGroupName => 'Nome del gruppo';

  @override
  String get gcNameHint => 'es. Squadra sul campo';

  @override
  String get gcMembers => 'Membri';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionati',
      one: '$count selezionato',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'Nessuno a portata';

  @override
  String get gcGetCloserBody =>
      'Avvicinati a un altro dispositivo Droplet: i contatti appaiono qui automaticamente.';

  @override
  String get gcCreateGroup => 'Crea gruppo';

  @override
  String get gcConnected => 'Connesso';

  @override
  String get gcAlreadyMet => 'Già incontrato';

  @override
  String get giRenameGroup => 'Rinomina gruppo';

  @override
  String get giRenameFailed => 'Ridenominazione non riuscita';

  @override
  String get giNoPeerToAdd => 'Nessun contatto disponibile da aggiungere';

  @override
  String get giAddMemberHeader => 'AGGIUNGI UN MEMBRO';

  @override
  String get giAddMemberFailed => 'Aggiunta del membro non riuscita';

  @override
  String get giRemoveMemberTitle => 'Rimuovere questo membro?';

  @override
  String get giRemoveMemberBody =>
      'Non potrà più leggere i messaggi inviati dopo la sua rimozione.';

  @override
  String get giRemove => 'Rimuovi';

  @override
  String get giRemoveMemberFailed => 'Rimozione del membro non riuscita';

  @override
  String get giLeaveGroupTitle => 'Uscire dal gruppo?';

  @override
  String get giLeaveGroupBody =>
      'Non riceverai più i messaggi inviati dopo la tua uscita.';

  @override
  String get giLeave => 'Esci';

  @override
  String get giNoOneReachable =>
      'Nessun membro raggiungibile via Wi-Fi locale al momento';

  @override
  String get giMax4Participants =>
      'Massimo 4 partecipanti per chiamata di gruppo — verranno chiamati solo i primi 3 raggiungibili';

  @override
  String get giGroupNotFound => 'Gruppo non trovato';

  @override
  String get giGroupInfo => 'Info gruppo';

  @override
  String get giGroupCall => 'Chiamata di gruppo';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'Messaggi di gruppo crittografati';

  @override
  String get giAdd => 'Aggiungi';

  @override
  String get giMe => 'io';

  @override
  String get giAdministrator => 'Amministratore';

  @override
  String get giLeaveGroup => 'Esci dal gruppo';

  @override
  String get sfNoLocationShared => 'Posizione non condivisa';

  @override
  String get sfLocationShared => 'Posizione condivisa';

  @override
  String sfDistanceMeters(Object m) {
    return 'a $m m';
  }

  @override
  String sfDistanceKm(Object km) {
    return 'a $km km';
  }

  @override
  String get sfBearingN => 'a nord';

  @override
  String get sfBearingNE => 'a nord-est';

  @override
  String get sfBearingE => 'a est';

  @override
  String get sfBearingSE => 'a sud-est';

  @override
  String get sfBearingS => 'a sud';

  @override
  String get sfBearingSW => 'a sud-ovest';

  @override
  String get sfBearingW => 'a ovest';

  @override
  String get sfBearingNW => 'a nord-ovest';

  @override
  String get sfBroadcastSafeTitle => 'Diffondere \"Sto bene\"?';

  @override
  String get sfBroadcastSafeMessage =>
      'Questo stato sarà visibile a tutta la mesh nel raggio, non solo ai tuoi contatti. Puoi includere una posizione approssimativa (arrotondata, mai esatta).';

  @override
  String get sfWithLocation => 'Con posizione approssimativa';

  @override
  String get sfWithoutLocation => 'Senza posizione';

  @override
  String get sfStatusBroadcast => 'Stato diffuso alla mesh';

  @override
  String get sfBroadcastFailed => 'Diffusione non riuscita';

  @override
  String get sfHelpRequestTitle => 'Diffondere \"Ho bisogno di aiuto\"?';

  @override
  String get sfHelpRequestMessage =>
      'Questo stato segnalerà ai peer nel raggio che hai bisogno di assistenza. Puoi includere una posizione approssimativa.';

  @override
  String get sfHelpRequestBroadcast => 'Richiesta di aiuto diffusa alla mesh';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: '$count giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'Modalità emergenza';

  @override
  String get sfViewOnMap => 'Vedi sulla mappa';

  @override
  String get sfNeedHelp => 'Ho bisogno di aiuto';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Check-in ricevuti ($count)',
      one: 'Check-in ricevuto ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'Nessun check-in ricevuto per ora';

  @override
  String get sfCheckinsAppearHere =>
      'Gli stati \"al sicuro\" diffusi dai peer nel raggio appariranno qui.';

  @override
  String get sfSafeLabel => 'Al sicuro';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'Al sicuro · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'Al sicuro · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'Diffondi il mio stato di sicurezza alla rete mesh';

  @override
  String get sfImSafe => 'Sto bene';

  @override
  String get emSosActive => 'SOS ATTIVO';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'Segnale SOS attivo — diffuso a tutti i dispositivi vicini';

  @override
  String get emPullToSendSignal => 'Tocca per inviare un segnale di emergenza';

  @override
  String get emSignalRelayedDescription =>
      'Il segnale viene inoltrato da peer a peer\nsu tutta la rete mesh.';

  @override
  String get emBroadcasting => 'Diffusione in corso...';

  @override
  String get emSharePosition => 'Condividi la mia posizione';

  @override
  String get emSosActivated => 'Segnale SOS attivato';

  @override
  String get emSafeStatusMessage => '🟢 Sto bene';

  @override
  String get emSafetyStatusBroadcast => 'Stato di sicurezza diffuso';

  @override
  String get pmEnterPayingNumber =>
      'Inserisci il numero che effettuerà il pagamento (9 cifre).';

  @override
  String get pmRequestSent => 'Richiesta inviata…';

  @override
  String get pmPaymentLaunchFailed =>
      'Non è stato possibile avviare il pagamento. Controlla il numero e la tua connessione, oppure paga manualmente qui sotto.';

  @override
  String get pmValidateOnPhone =>
      'Conferma sul tuo telefono: inserisci il tuo codice Mobile Money quando appare la richiesta.';

  @override
  String get pmPaymentNotConfirmed =>
      'Pagamento non confermato. Non è stato sbloccato nulla.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'Il pagamento è andato a buon fine ma la licenza ricevuta non è valida. Scrivici, verrà rifatta: $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro attivato';

  @override
  String get pmPackUnlocked => 'Pacchetto sbloccato';

  @override
  String get pmInvalidCode =>
      'Questo codice non è valido su questo dispositivo. Assicurati di aver inviato il codice dispositivo mostrato sopra.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'Ciò che Droplet\nnon chiederà mai';

  @override
  String get pmNeverAskBody =>
      'Niente pubblicità, niente abbonamento obbligatorio, nessuna rivendita dei tuoi dati — non esiste nemmeno un server per raccoglierli. Il pacchetto e Pro finanziano il resto.';

  @override
  String get pmCommunitySemantics =>
      'Unisciti alla community di oltre 1200 membri attivi';

  @override
  String get pmCommunityText => 'Unisciti a oltre 1200 membri sulla mesh';

  @override
  String get pmProPreviewSemantics =>
      'Anteprima delle funzionalità Pro sbloccate';

  @override
  String get pmAnimatedEmojis => 'Emoji\nanimate';

  @override
  String get pmWallpapers => 'Sfondi\nchat';

  @override
  String get pmAppIcons => 'Icone\ndell\'app';

  @override
  String get pmOnceForLife => 'una tantum, a vita';

  @override
  String get pmProAdvantage1 => 'Le dieci icone e i otto sfondi del pacchetto';

  @override
  String get pmProAdvantage2 => 'Il badge Pro accanto al tuo nome';

  @override
  String get pmProAdvantage3 =>
      'Le funzionalità future, senza costi aggiuntivi';

  @override
  String get pmPackTitle => 'Il pacchetto';

  @override
  String get pmOnce => 'una tantum';

  @override
  String get pmPackAdvantage1 => 'Dieci icone dell\'app aggiuntive';

  @override
  String get pmPackAdvantage2 => 'Otto sfondi per le chat';

  @override
  String get pmPayByHand => 'Oppure paga manualmente';

  @override
  String get pmHowTo => 'Come fare';

  @override
  String get pmIfPromptDoesNotArrive =>
      'Se la richiesta non arriva sul tuo telefono, o se preferisci inviare tu stesso il denaro.';

  @override
  String pmStep1Title(Object montant) {
    return 'Invia $montant F';
  }

  @override
  String get pmStep1Body =>
      'Scegli il tuo operatore: si apre il suo menu, e il numero resta visibile qui mentre lo navighi.';

  @override
  String get pmStep2Title => 'Invia il tuo codice dispositivo';

  @override
  String get pmStep2Body =>
      'Insieme allo screenshot del pagamento. Senza questo codice, la licenza non può essere creata: è valida solo per il tuo telefono.';

  @override
  String get pmStep3Title => 'Ricevi una licenza';

  @override
  String get pmStep3Body =>
      'Una lunga riga che inizia con DROP1. Incollala qui sotto: lo sblocco è immediato e funziona offline, per sempre.';

  @override
  String get pmPayNow => 'Paga ora';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money o Orange Money, da questo telefono o da un altro.';

  @override
  String get pmPhoneNumberSemantics =>
      'Numero di telefono per il pagamento Mobile Money';

  @override
  String get pmWaitingForCode => 'In attesa del tuo codice…';

  @override
  String pmPayAmount(Object montant) {
    return 'Paga $montant F';
  }

  @override
  String get pmRestorePurchaseSemantics => 'Ripristina un acquisto precedente';

  @override
  String get pmAlreadyPaidRestore => 'Hai già pagato? Ripristina';

  @override
  String pmDialCode(Object code) {
    return 'Componi $code dal tuo telefono';
  }

  @override
  String get pmChooseOperatorSemantics => 'Scegli un operatore di pagamento';

  @override
  String get pmNumberAmountFilled =>
      'Numero e importo già compilati — resta solo il tuo codice segreto.';

  @override
  String get pmOrangeMenuInstructions =>
      'Nel menu Orange: trasferimento di denaro, poi il numero e l\'importo qui sotto.';

  @override
  String get pmLabelNumber => 'Numero';

  @override
  String get pmLabelAmount => 'Importo';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return 'Paga $montant franchi con $operator';
  }

  @override
  String get pmMenuOpen => 'Menu aperto';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'Ciao, ho appena pagato per Droplet.\n\nOfferta: $offer\nImporto: $amount F\nCodice dispositivo: $code\n\n(allego lo screenshot del pagamento)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'WhatsApp non trovato — codice copiato. Inviacelo a $contact';
  }

  @override
  String get pmPrepareRequest => 'Prepara la mia richiesta';

  @override
  String get pmReceivedLicense => 'Ho ricevuto la mia licenza';

  @override
  String get pmPaste => 'Incolla';

  @override
  String get pmUnlock => 'Sblocca';

  @override
  String get pmProIsActive => 'Droplet Pro è attivo';

  @override
  String get pmPackIsUnlocked => 'Il pacchetto è sbloccato';

  @override
  String get pmProActiveDescription =>
      'Il badge Pro accompagna il tuo nome, e tutte le icone e tutti gli sfondi sono sbloccati per te.';

  @override
  String get pmPackActiveDescription =>
      'Le dieci icone e i otto sfondi del pacchetto sono sbloccati per te, nelle impostazioni.';

  @override
  String get pmLicenseDeviceBound =>
      'La tua licenza è valida per questo telefono. Se lo cambi, conserva il messaggio che la contiene: verrà rifatta gratuitamente.';

  @override
  String torError(Object e) {
    return 'Errore: $e';
  }

  @override
  String get torEnable => 'Attiva Tor';

  @override
  String get torProtected => 'Protetto';

  @override
  String get torDisabled => 'Disattivato';

  @override
  String get torStateHeader => 'Stato';

  @override
  String get torCircuit => 'Circuito';

  @override
  String get torActive => 'Attivo';

  @override
  String get torInProgress => 'In corso…';

  @override
  String get torInactive => 'Inattivo';

  @override
  String get torFailed => 'Non riuscito';

  @override
  String get torReason => 'Motivo';

  @override
  String get torBannerConnecting => 'Connessione a Tor…';

  @override
  String get torBannerActive => 'Tor attivo';

  @override
  String get torBannerError => 'Tor non disponibile';

  @override
  String get torBannerOff => 'Tor spento';

  @override
  String get torEncryption => 'Crittografia';

  @override
  String get torLatency => 'Latenza';

  @override
  String get torContactsHeader => 'Contatti';

  @override
  String get torScanQrFooter =>
      'Scansiona un codice QR, oppure cerca un nome nella rubrica, per aggiungere un contatto remoto.';

  @override
  String get torScanQrCode => 'Scansiona un codice QR';

  @override
  String get torMyQrCode => 'Il mio codice QR';

  @override
  String get torInformationHeader => 'Informazioni';

  @override
  String get torVersion => 'Versione';

  @override
  String get torHowItWorks => 'Come funziona?';

  @override
  String get torConnecting => 'Connessione in corso…';

  @override
  String get torInactiveTitle => 'Tor inattivo';

  @override
  String get torDataThroughTor => 'I tuoi dati passano attraverso la rete Tor';

  @override
  String get torEstablishingCircuit =>
      'Creazione del circuito in corso (10-30s)';

  @override
  String get torActivateToProtect => 'Attiva per proteggere la tua identità';

  @override
  String get torHowItWorksTitle => 'Come Tor protegge i tuoi dati';

  @override
  String get torEncryptedCircuit => 'Circuito crittografato';

  @override
  String get torEncryptedCircuitDesc =>
      'I tuoi messaggi passano attraverso 3 relay Tor nel mondo.';

  @override
  String get torHiddenIp => 'IP nascosto';

  @override
  String get torHiddenIpDesc => 'Nessun sito può vedere il tuo vero indirizzo.';

  @override
  String get torMeshPreserved => 'Mesh preservata';

  @override
  String get torMeshPreservedDesc =>
      'Bluetooth e Wi-Fi locale continuano a funzionare.';

  @override
  String get torUnderstood => 'Capito';

  @override
  String get qrTorNotActive =>
      'Tor non è attivo. Attivalo in Impostazioni > Tor.';

  @override
  String get qrScanContactCode => 'Scansiona il codice QR di un contatto';

  @override
  String get qrCodeFromContactScreen =>
      'Il codice deve provenire dalla schermata Tor del tuo contatto';

  @override
  String get qrScanAnother => 'Scansiona un altro';

  @override
  String get qrChat => 'Chatta';

  @override
  String get qgScanToConnect => 'Scansiona per connetterti';

  @override
  String get qgCopied => 'Copiato ✓';

  @override
  String get qgCopyCode => 'Copia il codice';

  @override
  String get qgHowItWorks => 'Come funziona';

  @override
  String get qgStep1 => 'Mostra questo codice QR al tuo contatto';

  @override
  String get qgStep2 => 'Lo scansiona dalla sua schermata Tor';

  @override
  String get qgStep3 => 'Siete connessi tramite Tor';

  @override
  String get shShareTo => 'Condividi con…';

  @override
  String get shSearchConversation => 'Cerca una conversazione';

  @override
  String get shNoConversation => 'Nessuna conversazione';

  @override
  String get shOpenChatFirst =>
      'Apri prima una conversazione in Droplet per poterci condividere dei contenuti.';

  @override
  String get shGroup => 'Gruppo';

  @override
  String get shDiscussion => 'Chat';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi da condividere',
      one: '$count elemento da condividere',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'Mappa installata';

  @override
  String get omClearCacheTitle => 'Svuotare la cache?';

  @override
  String get omRemoveZoneTitle => 'Rimuovere questa zona?';

  @override
  String get omClearCacheMessage =>
      'Le zone che hai esplorato non saranno più disponibili offline. Si ricostituiranno consultandole di nuovo con la rete.';

  @override
  String omRemoveZoneMessage(Object name) {
    return '«$name» verrà rimossa da questo dispositivo.';
  }

  @override
  String get omClear => 'Svuota';

  @override
  String get omTitle => 'Mappe';

  @override
  String get omReading => 'Lettura…';

  @override
  String get omNoMapsSaved => 'Nessuna mappa salvata';

  @override
  String omSizeOnDevice(Object size) {
    return '$size su questo dispositivo';
  }

  @override
  String get omBrowseMapHint =>
      'Esplora la mappa con la rete: le zone che visualizzi restano disponibili offline.';

  @override
  String get omOnThisDevice => 'Su questo dispositivo';

  @override
  String get omZonesFillThemselves =>
      'Le zone consultate si riempiono da sole mentre esplori la mappa con la rete.';

  @override
  String get omMbtilesExplainer =>
      'Un file .mbtiles contiene un\'intera regione, preparata in anticipo. È il formato standard delle mappe offline: qualsiasi strumento cartografico sa produrlo.';

  @override
  String get omImportMap => 'Importa una mappa';

  @override
  String get omReadingFile => 'Lettura del file…';

  @override
  String get omMbtilesFromPhone => 'File .mbtiles da questo telefono';

  @override
  String get omAttributionText =>
      'I dati provengono da OpenStreetMap (licenza ODbL), lo sfondo della mappa è fornito da CARTO. Droplet non scarica mai un\'intera regione in anticipo: nessun servizio gratuito lo consente. Viene conservato solo ciò che consulti.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tessere',
      one: '$count tessera',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '${k}k tessere';
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
  String get nwTitle => 'Novità';

  @override
  String get nwStatusesNetwork24h => 'Stati della rete · 24 h';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stati della rete',
      one: '$count stato della rete',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'Pubblica uno stato';

  @override
  String get nwNoNewsYet => 'Nessuna novità al momento';

  @override
  String get nwStatusesAppearHere =>
      'Gli stati pubblicati dalle persone nel raggio appariranno qui, senza passare da internet.';

  @override
  String get nwRecent => 'Recenti';

  @override
  String get nwStatusExpires =>
      'Uno stato scompare da solo 24 ore dopo la pubblicazione.';

  @override
  String get nwPhoto => '📷 Foto';

  @override
  String get nwVideo => '🎥 Video';

  @override
  String get nwVoiceMessage => '🎤 Messaggio vocale';

  @override
  String get nwMusic => '🎵 Musica';

  @override
  String get nwStatusFallback => 'Stato';

  @override
  String get nwMyStatus => 'Il mio stato';

  @override
  String get nwTapToPublish => 'Tocca per pubblicare sulla rete';

  @override
  String get nwNotSeenYet => 'Non ancora visto';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto da $count',
      one: 'Visto da $count',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'Posizione non disponibile — controlla che la localizzazione sia attiva.';

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
    return '$distance da te';
  }

  @override
  String get mpTitle => 'Posizione';

  @override
  String get mpOffline => 'Offline';

  @override
  String get mpOnlineMap => 'Mappa online';

  @override
  String get mpMyPosition => 'La mia posizione';

  @override
  String get mpLayers => 'Livelli';

  @override
  String get mpOfflineToast =>
      'Mappa offline: verranno mostrate solo le zone già salvate.';

  @override
  String get mpOnlineToast =>
      'Mappa online: le zone consultate verranno salvate per dopo.';

  @override
  String get mpMapLabel => 'Mappa';

  @override
  String get mpSatelliteLabel => 'Satellite';

  @override
  String get mpSatelliteMode => 'Modalità satellite';

  @override
  String get mpMapMode => 'Modalità mappa';

  @override
  String get mpWrite => 'Scrivi';

  @override
  String get mpCenter => 'Centra';

  @override
  String get mpNoOneOnMap => 'Nessuno sulla mappa';

  @override
  String get mpPositionsAppearHere =>
      'Le posizioni appaiono qui quando un contatto le condivide dalla modalità Sicurezza.';

  @override
  String get mpYou => 'Tu';

  @override
  String get mnTitle => 'Rete mesh';

  @override
  String get mnPeers => 'Peer';

  @override
  String get mnAvgHops => 'Media salti';

  @override
  String get mnSignal => 'Segnale';

  @override
  String get mnStrong => 'Forte';

  @override
  String get mnMedium => 'Medio';

  @override
  String get mnSearchingPeers => 'Ricerca di peer nel raggio…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peer connessi',
      one: '$count peer connesso',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'Nessun peer connesso al momento';

  @override
  String get mnGetCloserHint =>
      'Avvicinati a un altro dispositivo con Droplet installato — il rilevamento avviene automaticamente, senza configurazione.';

  @override
  String get mnConnectedPeersHeader => 'Peer connessi';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salti',
      one: '$count salto',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'Bluetooth';

  @override
  String get mnWifiLocal => 'Wi-Fi locale';

  @override
  String get mnP2pNative => 'P2P nativo';

  @override
  String get mnActiveGateway => 'Gateway attivo';

  @override
  String get mnPath => 'Percorso';

  @override
  String get mnTransport => 'Trasporto';

  @override
  String get mnBattery => 'Batteria';

  @override
  String get mnScore => 'Punteggio';

  @override
  String get mnReconnecting => 'Riconnessione';

  @override
  String get cnBronze => 'Bronzo';

  @override
  String get cnSilver => 'Argento';

  @override
  String get cnGold => 'Oro';

  @override
  String get cnDiamond => 'Diamante';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punti',
      one: '$count punto',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '$points prima del livello $tier';
  }

  @override
  String get cnRelayedMessages => 'Messaggi inoltrati per altri';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n pt';
  }

  @override
  String get cnGatewayMinutes => 'Minuti in modalità relay (gateway)';

  @override
  String get cnExplanation =>
      'Ogni messaggio che il tuo dispositivo inoltra per altri, e ogni minuto in cui resta disponibile come relay, aiuta la rete mesh a raggiungere più persone, più lontano. Questo badge non ha alcun effetto sull\'app — è solo un riconoscimento del tuo contributo.';

  @override
  String get nmTitle => 'Nuovo messaggio';

  @override
  String get nmNewGroup => 'Nuovo gruppo';

  @override
  String get nmScanCode => 'Scansiona un codice';

  @override
  String get nmVerifyContactIdentity => 'Verifica l\'identità di un contatto';

  @override
  String get nmNoOneInRange => 'Nessuno nel raggio';

  @override
  String get nmNoResult => 'Nessun risultato';

  @override
  String get nmPeopleWillAppearHere =>
      'Le persone rilevate dal tuo dispositivo appariranno qui.';

  @override
  String get nmInRange => 'Nel raggio';

  @override
  String get nmDirectConnection => 'Connessione diretta';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tramite $count relay',
      one: 'Tramite $count relay',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'File troppo grande (max 50 MB)';

  @override
  String get chCannotReadMedia =>
      'Impossibile leggere questo file multimediale';

  @override
  String get chLocationDenied =>
      'Posizione rifiutata — attivala nelle impostazioni del telefono per condividere la tua posizione.';

  @override
  String get chGettingPosition => 'Rilevamento della posizione…';

  @override
  String get chPositionUnavailable =>
      'Posizione non disponibile — riprova all\'aperto.';

  @override
  String get chMicPermissionDenied => 'Permesso microfono negato';

  @override
  String get chCannotStartRecording => 'Impossibile avviare la registrazione';

  @override
  String get chVoiceSendFailed => 'Impossibile inviare il messaggio vocale';

  @override
  String get chFileSendFailed => 'Impossibile inviare il file';

  @override
  String get chAudioNotFullyReceived => 'Audio non ancora ricevuto interamente';

  @override
  String get chVoiceUnreadable =>
      'Questo messaggio vocale non è riproducibile — potrebbe essere arrivato incompleto.';

  @override
  String get chFileNotFullyReceived => 'File non ancora ricevuto interamente';

  @override
  String get chSaveFailed => 'Impossibile salvare';

  @override
  String chSavedIn(Object folder) {
    return 'Salvato in $folder';
  }

  @override
  String get chMessageCopied => 'Messaggio copiato';

  @override
  String get chCallImpossibleRelay =>
      'Chiamata vocale non possibile: questo peer è raggiungibile solo tramite relay o Bluetooth, troppo lento per la voce. Avvicinati per passare al Wi-Fi.';

  @override
  String chUrlCopied(Object url) {
    return 'URL copiato: $url';
  }

  @override
  String get chEditMessageTitle => 'Modifica messaggio';

  @override
  String get chMessageHint => 'Messaggio';

  @override
  String get chNeverMet => 'Mai incontrato';

  @override
  String get chSeenJustNow => 'Visto proprio ora';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto $count minuti fa',
      one: 'Visto $count minuto fa',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto $count ore fa',
      one: 'Visto $count ora fa',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'Visto ieri';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto $count giorni fa',
      one: 'Visto $count giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'Fuori portata';

  @override
  String get chCloseSearchTooltip => 'Chiudi ricerca';

  @override
  String get chNetworkDetailsSemantics => 'Rete Droplet, visualizza dettagli';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membri',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'sta scrivendo…';

  @override
  String get chBroadcastChannel => 'Canale di diffusione';

  @override
  String get chNearby => 'Nelle vicinanze';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Raggiungibile tramite $count relay',
      one: 'Raggiungibile tramite $count relay',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'Riconnessione…';

  @override
  String get chSearchInConversation => 'Cerca nella conversazione';

  @override
  String get chVoiceCall => 'Chiamata vocale';

  @override
  String get chVideoCall => 'Videochiamata';

  @override
  String get chCallImpossibleBtRelay =>
      'Chiamata non possibile: collegamento Bluetooth o tramite relay';

  @override
  String get chGroupInfoTooltip => 'Informazioni sul gruppo';

  @override
  String get chNoneFound => 'Nessuno';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'Risultato precedente';

  @override
  String get chNewerResult => 'Risultato più recente';

  @override
  String get chLoadingOlderMessages => 'Caricamento messaggi precedenti…';

  @override
  String get chToday => 'Oggi';

  @override
  String get chYesterday => 'Ieri';

  @override
  String get chMonday => 'Lunedì';

  @override
  String get chTuesday => 'Martedì';

  @override
  String get chWednesday => 'Mercoledì';

  @override
  String get chThursday => 'Giovedì';

  @override
  String get chFriday => 'Venerdì';

  @override
  String get chSaturday => 'Sabato';

  @override
  String get chSunday => 'Domenica';

  @override
  String get chSayHello => 'Di\' ciao 👋';

  @override
  String get chBroadcastEmptyBody =>
      'I messaggi senza destinatario appaiono qui.';

  @override
  String get chP2pRelayedBody =>
      'I vostri scambi vengono inoltrati da peer a peer, senza Internet.';

  @override
  String get chReply => 'Rispondi';

  @override
  String get chReplyInThread => 'Rispondi nel thread';

  @override
  String get chCopy => 'Copia';

  @override
  String get chAccessibilityMe => 'Io';

  @override
  String get chPhotoLabel => 'Foto';

  @override
  String get chVideoLabel => 'Video';

  @override
  String get chVoiceMessageLabel => 'Messaggio vocale';

  @override
  String chFileLabel(Object name) {
    return 'File $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'Sticker $name';
  }

  @override
  String get chSendingStatus => 'invio in corso';

  @override
  String get chPendingStatus => 'in attesa';

  @override
  String get chFailedStatus => 'invio non riuscito';

  @override
  String get chReadStatus => 'letto';

  @override
  String get chDeliveredStatus => 'consegnato';

  @override
  String get chSentStatus => 'inviato';

  @override
  String get chForwarded => 'Inoltrato';

  @override
  String get chRetrySendLabel => 'Riprova a inviare';

  @override
  String get chTransmissionDetailsLabel => 'Dettagli della trasmissione';

  @override
  String get chEditedBadge => 'modificato';

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
  String get chVideoReceiving => 'Video in fase di ricezione';

  @override
  String get chPreparingVideo => 'Preparazione del video…';

  @override
  String get nmContacts => 'Contatti';

  @override
  String get nmFindByPseudo => 'Cerca per nome';

  @override
  String get nmViaInternet => 'Via Internet';

  @override
  String get nmOutOfRange => 'Fuori portata';

  @override
  String get chatsInvitePerson => 'Invita qualcuno';

  @override
  String get ivTitle => 'Invita i tuoi cari';

  @override
  String get ivSubtitle =>
      'Droplet è meglio quando ci sono le persone che contano, anche senza rete.';

  @override
  String get ivByNumber => 'Con numero di telefono';

  @override
  String get ivNumberHint => 'Numero con prefisso (+39…)';

  @override
  String get ivContacts => 'Contatti';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'Con un link';

  @override
  String get ivCopy => 'Copia';

  @override
  String get ivShare => 'Condividi';

  @override
  String get ivCopied => 'Link copiato';

  @override
  String get ivByQr => 'Con codice QR';

  @override
  String get ivQrHint => 'Fallo scansionare alla persona, di persona.';

  @override
  String get ivScan => 'Scansiona un codice';

  @override
  String get ivPrivacy =>
      'Link e codice contengono solo il tuo ID pubblico e la tua chiave. Nessun numero viene inviato a Droplet.';

  @override
  String get evTitle => 'Modifica video';

  @override
  String evSplit(int n) {
    return 'Dividi in $n stati';
  }

  @override
  String evSplitHint(int s) {
    return 'Ogni parte dura al massimo $s s';
  }

  @override
  String evPublished(int n) {
    return '$n stati pubblicati';
  }

  @override
  String get svReply => 'Rispondi';

  @override
  String get svStatusLabel => 'Stato';

  @override
  String svSeenBy(int n) {
    return 'Visto da $n';
  }

  @override
  String get clMissedVoice => 'Chiamata vocale persa';

  @override
  String get clMissedVideo => 'Videochiamata persa';

  @override
  String get clCallBack => 'Richiama';

  @override
  String get stoTitle => 'Spazio di archiviazione';

  @override
  String get stoSubtitle => 'Foto, video e file';

  @override
  String stoUsed(String taille) {
    return '$taille occupati';
  }

  @override
  String get stoPhotos => 'Foto';

  @override
  String get stoVideos => 'Video';

  @override
  String get stoAudio => 'Vocali e audio';

  @override
  String get stoDocuments => 'Documenti';

  @override
  String get stoOther => 'Altro (stati…)';

  @override
  String get stoByChat => 'Per chat';

  @override
  String get stoEmpty => 'Nessun file su questo telefono';

  @override
  String stoDelete(int n) {
    return 'Elimina ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'Questi file e i relativi messaggi verranno eliminati da questo telefono.';

  @override
  String get tabSelectChat => 'Scegli una chat';

  @override
  String get clConnecting => 'Connessione…';

  @override
  String chUnreadMessages(int n) {
    return '$n messaggi non letti';
  }

  @override
  String get csMessagesSection => 'Messaggi';

  @override
  String chGroupTyping(String noms) {
    return '$noms sta scrivendo…';
  }

  @override
  String get tsReadBy => 'Letto da';

  @override
  String get tsDeliveredTo => 'Consegnato a';

  @override
  String get tsWaitingFor => 'In attesa';

  @override
  String get chSelect => 'Seleziona';

  @override
  String get chForward => 'Inoltra';

  @override
  String get chForwardTo => 'Inoltra a…';

  @override
  String chSelectedCount(int n) {
    return '$n selezionati';
  }

  @override
  String get chForwarded1 => 'Messaggio inoltrato';

  @override
  String get apCaptionHint => 'Aggiungi una didascalia…';

  @override
  String get apValidateCrop => 'Ritaglia';

  @override
  String get chMediaReceiving => 'Ricezione in corso';

  @override
  String get chStickersTooltip => 'Sticker';

  @override
  String get chAttachTooltip => 'Allega';

  @override
  String get chDeleteRecordingTooltip => 'Elimina registrazione';

  @override
  String get chSlideToCancel => 'Scorri per annullare';

  @override
  String chReplyingTo(Object pseudo) {
    return 'In risposta a $pseudo';
  }

  @override
  String get chEffectBoom => 'Boom';

  @override
  String get chEffectLoud => 'Forte';

  @override
  String get chEffectGentle => 'Delicato';

  @override
  String get chEffectInvisibleInk => 'Inchiostro invisibile';

  @override
  String get chEffectConfetti => 'Coriandoli';

  @override
  String get chEffectFireworks => 'Fuochi d\'artificio';

  @override
  String get chEffectHearts => 'Cuori';

  @override
  String get chEffectSheetTitle => 'Effetto del messaggio';

  @override
  String get chEffectSheetSubtitle =>
      'Viene riprodotto una volta, sul tuo schermo e su quello del tuo interlocutore';

  @override
  String get chOnBubble => 'Sulla bolla';

  @override
  String get chFullscreen => 'Schermo intero';

  @override
  String get chTapToReveal => 'Tocca per rivelare';

  @override
  String get chThreadTitle => 'Thread';

  @override
  String get chReplyHint => 'Risposta…';

  @override
  String get chCollapse => 'Comprimi';

  @override
  String get chSeeMore => 'Vedi altro';

  @override
  String get chMessageOptionsSemantics => 'Opzioni del messaggio';

  @override
  String get chLoveReactionSemantics => 'Adoro';

  @override
  String get chBroadcastMesh => 'Diffusione mesh';

  @override
  String get chGroupFallback => 'Gruppo';

  @override
  String get ciSetupBiometrics =>
      'Configura un\'impronta digitale o il Face ID nelle impostazioni del dispositivo.';

  @override
  String get ciEnableLockReason => 'Attiva il blocco per questa conversazione';

  @override
  String get ciInfoTitle => 'Informazioni';

  @override
  String get ciViewConversation => 'Visualizza conversazione';

  @override
  String get ciGatewayOnline => 'Gateway · online';

  @override
  String get ciOnline => 'Online';

  @override
  String get ciOffline => 'Offline';

  @override
  String get ciMessages => 'Messaggi';

  @override
  String get ciMedia => 'Contenuti multimediali';

  @override
  String get ciStart => 'Inizio';

  @override
  String ciPhotosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Foto ($count)',
      one: 'Foto ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciVoiceNotesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Note vocali ($count)',
      one: 'Nota vocale ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'File ($count)',
      one: 'File ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet =>
      'Nessun contenuto multimediale condiviso per ora.';

  @override
  String get ciSecurityCode => 'Codice di sicurezza';

  @override
  String get ciVerified => 'Verificato';

  @override
  String get ciKeyChanged => 'La chiave è cambiata';

  @override
  String get ciNotVerified => 'Non verificato';

  @override
  String get ciConversationLock => 'Blocco della conversazione';

  @override
  String get ciLockEnabled =>
      'Attivato — impronta digitale richiesta per aprire';

  @override
  String get ciDisabled => 'Disattivato';

  @override
  String get ciEphemeralMessages => 'Messaggi effimeri';

  @override
  String get ci30Seconds => '30 secondi';

  @override
  String get ci5Minutes => '5 minuti';

  @override
  String get ci1Hour => '1 ora';

  @override
  String get ci24Hours => '24 ore';

  @override
  String get ciDurationBeforeDisappear => 'Tempo prima della scomparsa';

  @override
  String get ciBlockContactTitle => 'Bloccare questo contatto?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo non potrà più inviarti messaggi. Puoi sbloccarlo in qualsiasi momento.';
  }

  @override
  String get ciBlock => 'Blocca';

  @override
  String get ciUnblock => 'Sblocca';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo è stato bloccato';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo è stato sbloccato';
  }

  @override
  String get ciReportContactTitle => 'Segnalare questo contatto?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'Verrà inviata una segnalazione anonima a Droplet: un identificativo tecnico e il motivo scelto qui sotto, nient\'altro. Nessun messaggio, nessuna conversazione con $pseudo viene mai trasmessa.';
  }

  @override
  String get ciReport => 'Segnala';

  @override
  String get ciReportSent => 'Segnalazione inviata. Grazie.';

  @override
  String get ciReportFailed =>
      'Impossibile inviare la segnalazione — riprova più tardi.';

  @override
  String get ciReportReasonSpam => 'Spam';

  @override
  String get ciReportReasonHarassment => 'Molestie';

  @override
  String get ciReportReasonIllegal => 'Contenuto illegale';

  @override
  String get ciReportReasonOther => 'Altro';

  @override
  String mcReactWith(Object emoji) {
    return 'Reagisci con $emoji';
  }

  @override
  String get nsMeshActive => 'Mesh attiva';

  @override
  String get nsNoDeviceInRange => 'Nessun dispositivo nel raggio';

  @override
  String get nsMessagesCirculate =>
      'I tuoi messaggi circolano da un dispositivo all\'altro, senza passare da Internet.';

  @override
  String get nsGetCloser =>
      'Avvicinati a un altro dispositivo Droplet. I tuoi messaggi vengono conservati e verranno inviati da soli.';

  @override
  String get nsDevicesInRange => 'Dispositivi nel raggio';

  @override
  String get nsReconnectingTitle => 'Riconnessione';

  @override
  String get nsLinkMomentarilyLost =>
      'Collegamento momentaneamente perso, non ancora abbandonato.';

  @override
  String get nsRelaysAvailable => 'Relay disponibili';

  @override
  String get nsNoRelayAvailable =>
      'Al momento nessun dispositivo può inoltrare i tuoi messaggi più lontano.';

  @override
  String get nsViaBluetooth => 'Tramite Bluetooth';

  @override
  String get nsViaLocalWifi => 'Tramite Wi-Fi locale';

  @override
  String get nsWifiCarriesMore =>
      'Il Wi-Fi trasporta file e voce; il Bluetooth trasporta solo testo.';

  @override
  String get scInvalidQrCode => 'Codice QR non valido';

  @override
  String get scWrongCode =>
      'Questo non è il codice giusto — la chiave non corrisponde';

  @override
  String get scCodeVerified => 'Codice verificato';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'Verificato — la chiave di $pseudo corrisponde a questo codice.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'La chiave di $pseudo è cambiata dall\'ultima verifica.';
  }

  @override
  String get scNotVerifiedYet => 'Non ancora verificato.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'Confronta questo codice con quello mostrato sul dispositivo di $pseudo, oppure scansiona direttamente il suo codice QR per verificare automaticamente.';
  }

  @override
  String get scContactKeyUnknown =>
      'La chiave del contatto non è ancora nota — riconnettiti a questo peer sulla mesh.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'Scansiona il codice di $pseudo';
  }

  @override
  String get tsNotDelivered => 'Non consegnato';

  @override
  String get tsRead => 'Letto';

  @override
  String get tsDelivered => 'Consegnato';

  @override
  String get tsSendingInProgress => 'Invio in corso';

  @override
  String get tsWaitingForRelay => 'In attesa di un relay';

  @override
  String get tsSent => 'Inviato';

  @override
  String tsSecondsSingular(Object value) {
    return '$value secondo';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value secondi';
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
      other: '$count giorni',
      one: '$count giorno',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'Trasmissione';

  @override
  String get tsStatus => 'Stato';

  @override
  String get tsDelayUntilRead => 'Tempo fino alla lettura';

  @override
  String get tsRoute => 'Percorso';

  @override
  String get tsRouteDetail =>
      'I dispositivi che hanno inoltrato questo messaggio, in ordine.';

  @override
  String get tsPath => 'Percorso';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Passato attraverso $count dispositivi',
      one: 'Passato attraverso $count dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'Ricevuto direttamente';

  @override
  String get tsIntermediateDevicesDetail =>
      'Dispositivi intermedi hanno inoltrato questo messaggio fino a te.';

  @override
  String get tsUnknown => 'Sconosciuto';

  @override
  String get tsSentRouteNotReturned =>
      'Il percorso di un messaggio inviato non viene comunicato al mittente.';

  @override
  String get tsNetwork => 'Rete';

  @override
  String get tsMeshDroplet => 'Mesh Droplet';

  @override
  String get tsNoServerNoOperator => 'Nessun server, nessun operatore.';

  @override
  String get qsScanSecurityCode => 'Scansiona il codice di sicurezza';

  @override
  String get qsCodeDetected => 'Codice rilevato';

  @override
  String get qsFrameQrCode =>
      'Inquadra il codice QR mostrato sul dispositivo del tuo contatto';

  @override
  String get rmRecentVideo => 'Video recente';

  @override
  String get rmRecentPhoto => 'Foto recente';

  @override
  String get rmSeeAllPhotos => 'Vedi tutte le foto';

  @override
  String get rmSeeAll => 'Vedi tutto';

  @override
  String get aicOriginal => 'Originale';

  @override
  String get aicAzure => 'Azzurro';

  @override
  String get aicNeon => 'Neon';

  @override
  String get aicPaper => 'Carta';

  @override
  String get aicLagoon => 'Laguna';

  @override
  String get aicAmethyst => 'Ametista';

  @override
  String get aicGold => 'Oro';

  @override
  String get aicTide => 'Marea';

  @override
  String get aicDawn => 'Aurora';

  @override
  String get aicGlass => 'Vetro';

  @override
  String get aicConstellation => 'Costellazione';

  @override
  String get aicPrism => 'Prisma';

  @override
  String get aicEmerald => 'Smeraldo';

  @override
  String get aicChangeIconTitle => 'Cambiare l\'icona?';

  @override
  String aicChangeIconMessage(Object name) {
    return 'L\'icona «$name» sostituirà quella della tua schermata Home. Alcuni launcher impiegano qualche secondo a mostrarla, oppure richiedono di tornare alla Home.';
  }

  @override
  String get aicApply => 'Applica';

  @override
  String aicIconApplied(Object name) {
    return 'Icona «$name» applicata';
  }

  @override
  String get aicChangeIconImpossible =>
      'Impossibile cambiare l\'icona su questo dispositivo';

  @override
  String get aicTitle => 'Icona';

  @override
  String get aicCurrentOnHomeScreen =>
      'Quella visibile sulla tua schermata Home';

  @override
  String get aicUnavailablePlatform => 'Non disponibile su questa piattaforma';

  @override
  String get aicAndroidExplanation =>
      'Android fissa l\'icona di un\'app al momento dell\'installazione. Droplet aggira questo limite dichiarando più punti di ingresso, uno per icona, lasciandone attivo solo uno. Il tuo launcher potrebbe impiegare qualche secondo per accorgersene.';

  @override
  String get aicAndroidOnly =>
      'Il cambio dell\'icona è disponibile solo su Android.';

  @override
  String get beWeak => 'Debole';

  @override
  String get beOkay => 'Discreta';

  @override
  String get beStrong => 'Forte';

  @override
  String get bePasswordTooShort =>
      'La password deve contenere almeno 8 caratteri';

  @override
  String get bePasswordsDontMatch => 'Le due password non corrispondono';

  @override
  String get beBackupSubject => 'Backup di Droplet';

  @override
  String get beBackupShareText =>
      'Backup crittografato della mia identità Droplet — conservalo in un luogo sicuro.';

  @override
  String get beBackupCreated => 'Backup creato';

  @override
  String get beBackupFailed => 'Backup non riuscito';

  @override
  String get beBackupMyIdentity => 'Esegui il backup della mia identità';

  @override
  String get beWarningBody =>
      'Chiunque possieda questo file e la password può spacciarsi per te. Conservalo in un luogo sicuro (non inviarlo mai a nessun altro se non a te stesso) e scegli una password che solo tu conosci.';

  @override
  String get bePasswordProtects =>
      'Questa password protegge il tuo backup. Non viene mai salvata: senza di essa, il file diventa definitivamente inutilizzabile.';

  @override
  String get bePassword => 'Password';

  @override
  String get beConfirmPassword => 'Conferma password';

  @override
  String get beIncludeMessageHistory => 'Includi la cronologia dei messaggi';

  @override
  String get beOtherwiseOnlyIdentity =>
      'Altrimenti, verranno salvati solo l\'identità, i contatti e i gruppi';

  @override
  String get beCreateAndShare => 'Crea e condividi il backup';

  @override
  String get jsErrorJournalTitle => 'Registro degli errori';

  @override
  String get jsNoErrorsRecorded =>
      'Nessun errore registrato. È la situazione normale.';

  @override
  String get jsLinesStayOnDevice =>
      'Queste righe restano su questo dispositivo: Droplet non ha alcun server a cui inviarle. Se stai testando l\'app, inviacele — senza di esse, il difetto non esiste per nessuno.';

  @override
  String get jsErase => 'Cancella';

  @override
  String get jsShareSubject => 'Droplet — registro degli errori';

  @override
  String get jsShareText =>
      'Registro degli errori di Droplet. Questo file non contiene messaggi, contatti né chiavi.';

  @override
  String get jsShareUnavailable =>
      'Condivisione non disponibile — registro copiato';

  @override
  String get clOutgoingCall => 'Chiamata in corso…';

  @override
  String get clIncomingCall => 'Chiamata in arrivo…';

  @override
  String get clCallImpossible => 'Chiamata non riuscita';

  @override
  String get clCallEnded => 'Chiamata terminata';

  @override
  String clCallWith(Object pseudo) {
    return 'Chiamata con $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'Crittografato end-to-end';

  @override
  String clCallStatusSemantics(Object status) {
    return 'Stato della chiamata: $status';
  }

  @override
  String get clEnableMic => 'Attiva il microfono';

  @override
  String get clMuteMic => 'Disattiva il microfono';

  @override
  String get clDisableSpeaker => 'Disattiva l\'altoparlante';

  @override
  String get clEnableSpeaker => 'Attiva l\'altoparlante';

  @override
  String get clDisableCamera => 'Disattiva la fotocamera';

  @override
  String get clEnableCamera => 'Attiva la fotocamera';

  @override
  String get clHangUp => 'Riaggancia';

  @override
  String get clIncomingVideoCall => 'Videochiamata in arrivo';

  @override
  String get clSwitchCamera => 'Cambia fotocamera';

  @override
  String get gcGroupCall => 'Chiamata di gruppo';

  @override
  String get gcConnecting => 'Connessione…';

  @override
  String get gcOnline => 'In linea';

  @override
  String get gcFailed => 'Non riuscito';

  @override
  String get gcDisconnected => 'Disconnesso';

  @override
  String get gcReturnToCall => 'Torna alla chiamata';

  @override
  String get gcMinimize => 'Riduci';

  @override
  String get gcVoiceOnly => 'Solo voce';

  @override
  String gcReactWith(String emoji) {
    return 'Reagisci con $emoji';
  }

  @override
  String get gcSpeakingNow => 'Sta parlando';

  @override
  String get gcMicOff => 'Microfono disattivato';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partecipanti · solo voce',
      one: '$count partecipante · solo voce',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'Messaggi';

  @override
  String get ntfChannelMessagesDesc => 'Nuovi messaggi e stati mesh';

  @override
  String get ntfChannelCallsName => 'Chiamate';

  @override
  String get ntfChannelCallsDesc => 'Chiamate in arrivo e perse';

  @override
  String get ntfChannelMeshName => 'Mesh ed emergenza';

  @override
  String get ntfChannelMeshDesc =>
      'Servizio mesh attivo, stati e messaggi di emergenza';

  @override
  String get ntfReply => 'Rispondi';

  @override
  String get ntfYourReply => 'La tua risposta';

  @override
  String get ntfMarkAsRead => 'Segna come letto';

  @override
  String get ntfIncomingCall => 'Chiamata in arrivo';

  @override
  String get ntfAnswer => 'Rispondi';

  @override
  String get ntfDecline => 'Rifiuta';

  @override
  String get ntfMissedCall => 'Chiamata persa';

  @override
  String get ntfSendFailedTitle => 'Invio non riuscito';

  @override
  String get ntfSendFailedBody =>
      'Non è stato possibile inviare un messaggio — nuovo tentativo non appena un peer sarà nel raggio.';

  @override
  String get ntfNewStatusTitle => 'Nuovo stato';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo ha pubblicato uno stato';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ A $pseudo piace il tuo stato';
  }

  @override
  String get ntfTapToView => 'Tocca per vedere';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo ha risposto al tuo stato';
  }

  @override
  String get ntfEmergencyTitle => 'Messaggio di emergenza';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo ha diffuso «Sto bene»';
  }

  @override
  String get mnAccept => 'Accetta';

  @override
  String get mnMeshVoiceCall => 'Chiamata vocale mesh';

  @override
  String get mnGroupCallIncoming => 'Chiamata di gruppo in arrivo';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo ti invita';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chiamata di gruppo · $count altri partecipanti',
      one: 'Chiamata di gruppo · $count altro partecipante',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'Chi può vedere questo stato?';

  @override
  String get asAllContacts => 'Tutti i miei contatti';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatti',
      one: '$count contatto',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => 'Tranne...';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count esclusi',
      one: '$count escluso',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'Escludi contatti';

  @override
  String get asOnlyOption => 'Solo...';

  @override
  String get asShareWithSpecific => 'Condividi con contatti specifici';

  @override
  String get asNoContactsAvailable => 'Nessun contatto disponibile';

  @override
  String get asConfirm => 'Conferma';

  @override
  String get apYourPhoto => 'La tua foto';

  @override
  String get apNoPhotoAccessible =>
      'Nessuna foto accessibile su questo dispositivo.';

  @override
  String get apBrowseFiles => 'Sfoglia i file';

  @override
  String get apRecentPhoto => 'Foto recente';

  @override
  String get bgSkip => 'Salta';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'Passo $rang di $total.';
  }

  @override
  String get csGuideNetworkTitle => 'Nessuno nelle vicinanze? È normale';

  @override
  String get csGuideNetworkText =>
      'Droplet non passa da alcun server: parla con i telefoni nel raggio d\'azione. Qui vedi chi è raggiungibile, e tramite quale radio. Zero peer non significa che non funzioni — solo che ancora nessuno è presente.';

  @override
  String get csGuideWriteTitle => 'Scrivi anche senza nessuno intorno';

  @override
  String get csGuideWriteText =>
      'Un messaggio scritto ora resta in attesa sul tuo telefono e riparte non appena un dispositivo entra nel raggio d\'azione — per strada, in taxi. Non è perso, sta aspettando.';

  @override
  String get csGuideBackupTitle => 'Esegui il backup della tua identità';

  @override
  String get csGuideBackupText =>
      'Senza server, nessuno può restituirti il tuo account. Esporta la tua identità dalle impostazioni: senza questo backup, un telefono perso porta via tutto.';

  @override
  String get csShowLockedChatsReason => 'Mostra le chat bloccate';

  @override
  String get cvlNoBiometricsConfigured =>
      'Nessuna impronta digitale configurata su questo dispositivo';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'Sblocca la conversazione con $pseudo';
  }

  @override
  String get cvlAuthFailed => 'Autenticazione non riuscita';

  @override
  String get cvlAuthError => 'Errore di autenticazione';

  @override
  String get cvlConversationLocked => 'Conversazione bloccata';

  @override
  String get cvlUnlock => 'Sblocca';

  @override
  String get dcAddText => 'Aggiungi testo';

  @override
  String get dcYourTextHint => 'Il tuo testo...';

  @override
  String get pbDropletProBadge => 'Badge Droplet Pro';

  @override
  String get rpReact => 'Reagisci';

  @override
  String get rpSaveToPhone => 'Salva sul telefono';

  @override
  String get chViaTor => 'Via Tor';

  @override
  String get chTorInactive => 'Tor inattivo';

  @override
  String get chViaInternet => 'Via Internet';

  @override
  String get chReachedViaTorSemantic => 'Contatto raggiunto tramite Tor';

  @override
  String get nsTorConnectedTitle => 'Connesso via Tor';

  @override
  String get nsTorInactiveTitle => 'Tor disattivato';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'I tuoi messaggi viaggiano sulla rete Tor e attendono in una casella di posta cifrata finché $pseudo non vi si connette.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'Attiva Tor nelle impostazioni per poter scrivere a $pseudo — senza di esso, i tuoi messaggi resteranno in attesa su questo dispositivo.';
  }

  @override
  String get nsTorMailboxTitle => 'Casella di posta cifrata';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'Né tu né Droplet potete leggere ciò che contiene — solo $pseudo ha la chiave.';
  }

  @override
  String get nsOpenTorSettings => 'Attiva Tor';

  @override
  String get qrInvalidCode => 'Questo codice QR non è un codice Droplet.';

  @override
  String get qrPeerAdded => 'Contatto aggiunto';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'Ora puoi chattare con $pseudo';
  }

  @override
  String get clViaInternet => 'Via Internet';

  @override
  String get tsPathTorDetail =>
      'Questo messaggio non passa attraverso i dispositivi intorno a te: transita tramite una casella di posta cifrata sulla rete Tor, accessibile solo a voi due.';

  @override
  String get tsNetworkTorDetail =>
      'È necessario un server di inoltro per raggiungere questo contatto a distanza — a differenza della mesh locale, qui Droplet non può farne a meno.';

  @override
  String get torSearchDirectory => 'Cerca nella rubrica';

  @override
  String get dvTitle => 'Cerca';

  @override
  String get dvClose => 'Chiudi';

  @override
  String get dvSearchHint => 'Cerca un nome...';

  @override
  String get dvEnableTorToSearch =>
      'Attiva Tor nelle impostazioni per cercare nella rubrica.';

  @override
  String get dvSearching => 'Ricerca in corso...';

  @override
  String get dvNoResults => 'Nessun risultato';

  @override
  String get dvNoUserFound => 'Nessun utente trovato per questa ricerca.';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '$count risultato',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'Invia';

  @override
  String get aiNewConversation => 'Nuova conversazione';

  @override
  String get aiMessageHint => 'Messaggio';

  @override
  String get aiCopied => 'Copiato';

  @override
  String get aiAskQuestion => 'Fai una domanda';

  @override
  String get aiRunsLocally =>
      'Questo assistente funziona interamente sul tuo dispositivo — non viene mai inviato nulla su Internet.';

  @override
  String get aiMemorySaved => 'Me ne ricorderò.';

  @override
  String get aiMemoryForgotten =>
      'Ho dimenticato ciò che mi avevi chiesto di ricordare.';

  @override
  String get aiMemoryTitle => 'Memoria dell\'assistente';

  @override
  String get aiMemoryEmpty =>
      'Ancora niente salvato. Di\' «ricorda che…» per fissare un\'informazione.';

  @override
  String get aiMemoryForget => 'Dimentica tutto';

  @override
  String get aiExpertHint =>
      'Conosco Droplet a fondo: la rete mesh, Tor, le chiamate, la privacy.';

  @override
  String get chAskAssistant => 'Chiedi all\'assistente';

  @override
  String chAskAssistantInvite(Object name) {
    return 'Aiutami a rispondere a $name.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'Preparazione dell\'assistente… $percentage%';
  }

  @override
  String get aiOneTimeDownload =>
      'Solo una volta — resta poi sul tuo dispositivo, senza altri download.';

  @override
  String get aiGenericError => 'Siamo spiacenti, si è verificato un errore.';

  @override
  String get aiNotAvailableYet =>
      'L\'assistente non è ancora disponibile in questa versione di Droplet.';

  @override
  String aiDownloadFailed(Object error) {
    return 'Download non riuscito: $error';
  }

  @override
  String get ntfSomeoneCalling => 'Qualcuno sta cercando di contattarti';

  @override
  String get ntfNewMessageWake => 'Nuovo messaggio — apri Droplet per leggerlo';

  @override
  String get chNearbyAndInternet => 'Nelle vicinanze · Internet';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count relay · Internet',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'In attesa di Internet';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nelle vicinanze · Internet',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nelle vicinanze · senza Internet',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'Nessuno nelle vicinanze · Internet';

  @override
  String get clPathMesh => 'Mesh · Wi-Fi diretto';

  @override
  String get clPathInternetDirect => 'Internet · diretto';

  @override
  String get clPathInternetRelay => 'Internet · relay sicuro';

  @override
  String get clReconnecting => 'Riconnessione…';

  @override
  String get clLabelSpeaker => 'Altoparlante';

  @override
  String get clLabelCamera => 'Fotocamera';

  @override
  String get clLabelMic => 'Microfono';

  @override
  String get clLabelFlip => 'Gira';

  @override
  String get clEncryptedShort => 'Crittografia end-to-end';

  @override
  String clQualitySemantics(int bars) {
    return 'Qualità della chiamata: $bars su 3';
  }

  @override
  String get beOnlineTitle => 'Backup automatico online';

  @override
  String get beOnlineBody =>
      'Ogni giorno una copia cifrata con questa password viene conservata sul server Droplet, che non può leggerla. Su un nuovo telefono bastano lo stesso nome e la stessa password. Foto, video e file ricevuti non sono inclusi.';

  @override
  String get beOnlineSwitch => 'Esegui il backup sul server ogni giorno';

  @override
  String beOnlineLast(String date) {
    return 'Ultimo backup: $date';
  }

  @override
  String get beOnlineNever => 'Ancora nessun backup online';

  @override
  String get beOnlineNow => 'Esegui backup ora';

  @override
  String get beOnlineDone => 'Backup online completato';

  @override
  String get beOnlineFailed => 'Backup online non possibile al momento';

  @override
  String get obRestoreFromServer => 'Ripristina dal server';

  @override
  String get obEnterPseudoFirst => 'Inserisci prima il nome del tuo backup';

  @override
  String get obNoServerBackup =>
      'Nessun backup per questo nome e questa password';

  @override
  String get obTooManyAttempts => 'Troppi tentativi: riprova tra un\'ora';

  @override
  String get chatsInviteLink => 'Invita con un link';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo ti invita su Droplet, la messaggistica cifrata che funziona anche senza rete: $lien';
  }

  @override
  String get invTitle => 'Invito';

  @override
  String invBody(String pseudo) {
    return '$pseudo ti invita a chattare su Droplet.';
  }

  @override
  String get invAdd => 'Aggiungi e scrivi';

  @override
  String get invInvalid => 'Questo link di invito non è valido o è incompleto.';

  @override
  String get invSelf => 'Questo è il tuo link di invito.';
  @override
  String get seAnimationHeader => 'Animazione di invio';

  @override
  String get seAnimationFull => 'Completa';

  @override
  String get seAnimationReduced => 'Ridotta';

  @override
  String get seAnimationOff => 'Disattivata';

  @override
  String get seAnimationFullDesc => 'Plic porta il tuo messaggio, si teletrasporta e ti saluta.';

  @override
  String get seAnimationReducedDesc => 'Una semplice dissolvenza, senza movimento né particelle.';

  @override
  String get seAnimationOffDesc => 'Nessuna animazione dopo l\'invio.';

  @override
  String get seAnimationReplay => 'Tocca per rivedere';

  @override
  String get seAnimationNone => 'Nessuna animazione';

  @override
  String get seAnimationSampleIn => 'Ci vediamo al porto?';

  @override
  String get seAnimationSampleOut => 'A tra poco';

  @override
  String get trTitle => 'Traduzione';

  @override
  String get trOnDevice => 'Traduzione sul dispositivo…';

  @override
  String get trUnknownLang => 'Lingua sconosciuta';

  @override
  String get trOriginal => 'Originale';

  @override
  String get trCopy => 'Copia';

  @override
  String get trInChat => 'Nella chat';

  @override
  String get trRetry => 'Riprova';

  @override
  String get trSame => 'Questo messaggio è già in questa lingua.';

  @override
  String get trModel => 'Il modello di questa lingua non è ancora installato sul dispositivo.';

  @override
  String get trUnavailable => 'Questo dispositivo non ha un motore di traduzione offline.';

  @override
  String get trFailed => 'La traduzione non è riuscita.';

  @override
  String get pfMessage => 'Messaggio';

  @override
  String get pfCall => 'Chiamata';

  @override
  String get pfSecurity => 'Sicurezza';

  @override
  String get aiActCopy => 'Copia';

  @override
  String get aiActRead => 'Leggi ad alta voce';

  @override
  String get aiActStop => 'Interrompi la lettura';

  @override
  String get aiActLike => 'Risposta utile';

  @override
  String get aiActDislike => 'Risposta non utile';

  @override
  String get aiActShare => 'Condividi';

  @override
  String get aiActRegenerate => 'Rigenera';

  @override
  String get aiFeedbackThanks => 'Grazie per il feedback';

  @override
  String get intelOnlineHeader => 'Traduzione e trascrizione';

  @override
  String get intelOnlineTitle => 'Online quando sono connesso';

  @override
  String get intelOnlineSubtitle => 'Gratis — MyMemory, Apple o Google';

  @override
  String get intelOnlineFooter => 'Disattivato, niente passa da Internet. Attivato e connesso: il testo da tradurre va a MyMemory; su iPhone, un vocale che il dispositivo non sa trascrivere va al servizio vocale di Apple. In quei tragitti il contenuto non è più crittografato end-to-end. Su Android si scarica solo il modello vocale: i vocali restano sul telefono. Le anteprime dei link contattano anche il sito in questione.';

  @override
  String get trOnline => 'Traduci online';

  @override
  String get trOnlineNote => 'Il testo verrà inviato a MyMemory, un servizio gratuito. In quel tragitto non è più crittografato end-to-end.';

  @override
  String get trViaOnline => 'Tradotto online da MyMemory';

  @override
  String get vnModelDownloading => 'Il modello vocale di questa lingua si sta scaricando. Riprova tra un attimo.';

  @override
  String get vnModelNeeded => 'Manca il modello vocale di questa lingua. Attiva «Online quando sono connesso» nelle impostazioni per scaricarlo una volta.';

  @override
  String get nwStatusHeader => 'Stato';

  @override
  String get nwAddStatus => 'Aggiungi stato';

  @override
  String get nwStatusNewA11y => 'nuovo';

  @override
  String svReplySent(String name) {
    return 'Risposta inviata a $name';
  }

  @override
  String get blkYouBlocked => 'Hai bloccato questo contatto.';

  @override
  String get blkUnblock => 'Sblocca';

  @override
  String get blkListTitle => 'Contatti bloccati';

  @override
  String get blkNone => 'Nessun contatto bloccato';

  @override
  String get blkFooter => 'Un contatto bloccato non può più scriverti né chiamarti e non riceve più i tuoi stati né la tua foto. Non viene avvisato. Il tuo telefono continua a inoltrare i suoi messaggi destinati ad altri, senza poterli leggere: la rete mesh non dipende da chi blocchi.';

  @override
  String blkUnblockTitle(String name) {
    return 'Sbloccare $name?';
  }

  @override
  String blkUnblockToCall(String name) {
    return 'Sbloccare $name per chiamare?';
  }

  @override
  String get nvDone => 'Fine';

  @override
  String get nvBack => 'Indietro';

  @override
  String get nvForward => 'Avanti';

  @override
  String get nvShare => 'Condividi';

  @override
  String get nvOpenInBrowser => 'Apri nel browser';

  @override
  String get nvReload => 'Ricarica';

  @override
  String get nvCopyLink => 'Copia link';

  @override
  String get nvLinkCopied => 'Link copiato';

  @override
  String get nvOpen => 'Apri';

  @override
  String get nvMore => 'Altro';

  @override
  String get nvNotSecure => 'Non sicuro';

  @override
  String get nvErrorTitle => 'Pagina non disponibile';

  @override
  String get nvErrorBody => 'Droplet non è riuscito a raggiungere questo sito. La rete mesh non trasporta il web: serve una connessione a Internet.';

  @override
  String get nvRetry => 'Riprova';

  @override
  String get ciLinks => 'Link';

  @override
  String get chatsFilterNearby => 'Nelle vicinanze';


  @override
  String get chProxTitle => 'Droplet funziona anche senza Internet';

  @override
  String get chProxActive => 'Ci sono dispositivi Droplet nelle vicinanze';

  @override
  String get chProxBody => 'I telefoni vicini si passano i messaggi. Più siete intorno, più lontano arrivano.';

  @override
  String get chProxSee => 'Guarda chi c\'è intorno';

  @override
  String get chStickerPreview => 'Sticker';

  @override
  String get edCrop => 'Ritaglia';

  @override
  String get edRotate => 'Ruota';

  @override
  String get edFilters => 'Filtri';

  @override
  String get edAdjust => 'Regola';

  @override
  String get edText => 'Testo';

  @override
  String get edDraw => 'Disegno';

  @override
  String get edTrim => 'Taglia';

  @override
  String get edBrightness => 'Luminosità';

  @override
  String get edContrast => 'Contrasto';

  @override
  String get edSaturation => 'Saturazione';

  @override
  String get edWarmth => 'Calore';

  @override
  String get edVignette => 'Vignettatura';

  @override
  String get edIntensity => 'Intensità';

  @override
  String get edUndo => 'Annulla';

  @override
  String get edDone => 'Fine';

  @override
  String get edTextHint => 'Scrivi…';

  @override
  String get edDelete => 'Elimina';

  @override
  String get edOriginal => 'Originale';

  @override
  String get edStyle => 'Stile';

  @override
  String get edBackground => 'Sfondo';

  @override
  String get stNotificationsHeader => 'Notifiche';

  @override
  String get stNotifPreview => 'Anteprima del contenuto';

  @override
  String get stNotifPreviewSubtitle => 'Il testo del messaggio compare nella notifica. Disattivato, la schermata di blocco annuncia solo un nuovo messaggio.';

  @override
  String get stSearchHint => 'Cerca nelle impostazioni';

  @override
  String get stSearchEmpty => 'Nessuna impostazione corrisponde';

  @override
  String get chMentionAllSubtitle => 'Avvisa tutti';

  @override
  String get vuOnce => 'Visualizza una volta';

  @override
  String get vuOpened => 'Aperta';

  @override
  String get vuPhoto => 'Foto';

  @override
  String get vuVideo => 'Video';

  @override
  String get vuMissing => 'Questo contenuto non è ancora arrivato';

  @override
  String get pollClosed => 'Sondaggio chiuso';

  @override
  String pollEndsAt(String quand) {
    return 'Termina alle $quand';
  }

  @override
  String get vuVoice => 'Messaggio vocale';

  @override
  String get apPatternsHeader => 'Motivo dello sfondo';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'Giochi';

  @override
  String get apPatternHome => 'Casa';

  @override
  String get apPatternGarden => 'Giardino';

  @override
  String get imTitle => 'Messaggi importanti';

  @override
  String get imSubtitle => 'Ciò che hai messo da parte';

  @override
  String get imAdd => 'Aggiungi ai preferiti';

  @override
  String get imRemove => 'Togli dai preferiti';

  @override
  String get imAdded => 'Aggiunto ai preferiti';

  @override
  String get imRemoved => 'Rimosso dai preferiti';

  @override
  String get imEmptyBody => 'Tieni premuto un messaggio per aggiungerlo ai preferiti e ritrovarlo qui.';

  @override
  String get imClearAll => 'Rimuovi tutto';

  @override
  String get imClearAllBody => 'I messaggi restano nelle chat; si tolgono solo le stelle.';

  @override
  String get imClear => 'Rimuovi';

  @override
  String get imYou => 'Tu';

  @override
  String get imUnknown => 'Messaggio';

  @override
  String get apPatternsFooter => 'Il motivo resta dietro a tutte le chat.';

  @override
  String get grCreatedNoMessages => 'Gruppo creato · nessun messaggio';

  @override
  String get chatsDelete => 'Elimina chat';

  @override
  String get chatsDeleteBody => 'I messaggi spariscono da questo telefono. Senza server, nessuno può toglierli da quello degli altri.';

  @override
  String get chatsDeleteConfirm => 'Elimina';

  @override
  String get chatsDeleted => 'Chat eliminata';

  @override
  String chatsDeleteTitle(String nom) {
    return 'Eliminare la chat con $nom?';
  }

  @override
  String get chatsDocument => 'Documento';

  @override
  String get epTitle => 'Messaggi effimeri';

  @override
  String get epHeadline => 'Attiva i messaggi effimeri in questa chat';

  @override
  String get epBody => 'I nuovi messaggi porteranno la loro scadenza: spariranno da entrambi i telefoni allo scadere del tempo scelto.';

  @override
  String get epDelayHeader => 'Tempo prima della scomparsa';

  @override
  String get epHours24 => '24 ore';

  @override
  String get epDays7 => '7 giorni';

  @override
  String get epDays90 => '90 giorni';

  @override
  String get epOff => 'No';

  @override
  String get epFooter => 'L\'impostazione non tocca i messaggi già inviati: ognuno conserva la durata con cui è partito.';

  @override
  String get chOnlineNow => 'Online · Internet';

  @override
  String chInternetMinutesAgo(int count) {
    return 'Via internet $count min fa';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'Via internet $count h fa';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'Via internet $count g fa';
  }

  @override
  String get pdfMissing => 'Questo documento non è su questo telefono.';

  @override
  String get pdfUnreadable => 'Questo PDF è illeggibile: forse è arrivato incompleto.';

  @override
  String get giDescription => 'Descrizione';

  @override
  String get giDescriptionAdd => 'Aggiungi una descrizione';

  @override
  String get giDescriptionNone => 'Nessuna descrizione';

  @override
  String get giDescriptionHint => 'Di cosa parla questo gruppo?';

  @override
  String get giOnlyAdminsSend => 'Solo gli amministratori scrivono';

  @override
  String get giOnlyAdminsSendBody => 'Gli altri membri leggono senza poter rispondere.';

  @override
  String get giSearchMembers => 'Cerca un membro';

  @override
  String get chOnlyAdminsCanWrite => 'Solo gli amministratori possono scrivere in questo gruppo';

  @override
  String grCreatedBy(String nom) {
    return '$nom ha creato il gruppo';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom ti ha aggiunto';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom non fa più parte del gruppo';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui ha aggiunto $nom';
  }

  @override
  String get giQrInvite => 'Codice QR';

  @override
  String get giQrRenew => 'Nuovo codice';

  @override
  String get giQrRenewed => 'Nuovo codice creato, il vecchio non vale più';

  @override
  String get giQrExpired => 'Questo codice è scaduto';

  @override
  String get giQrExplainer => 'Questo codice non contiene chiavi. Permette solo di chiedere di entrare: decide il tuo telefono.';

  @override
  String get giQrAlreadyMember => 'Sei già in questo gruppo';

  @override
  String get giQrNeedContact => 'Aggiungi prima la persona che ti invita';

  @override
  String get giQrRequestFailed => 'La richiesta non è potuta partire';

  @override
  String giQrRequestSent(String nom) {
    return 'Richiesta inviata a $nom';
  }

  @override
  String giQrValidHours(int count) {
    return 'Valido ancora $count h';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'Valido ancora $count min';
  }

  @override
  String get cvNearby => 'Vicino';

  @override
  String get cvInternet => 'Internet';

  @override
  String get cvWaiting => 'In attesa';

  @override
  String get cvOutOfReach => 'Fuori portata';

  @override
  String get chWillSendWhenNearby => 'Partirà appena sarà a portata';

  @override
  String cvHops(int count) {
    return '$count salti';
  }

  @override
  String get nwSeenSection => 'Visti';

  @override
  String get nwReceivedHeader => 'Ricevuti';

  @override
  String get avTranslateTitle => 'Traduzione';

  @override
  String get avTranslateShort => 'Capire senza uscire dall\'app';

  @override
  String get avTranslateLong => 'Il messaggio è tradotto sul tuo telefono: il suo contenuto non arriva a nessuno, nemmeno a un traduttore. L\'originale resta a un tocco, perché una traduzione non è mai del tutto il testo.';

  @override
  String get apStickerQ => 'Hai uno sticker per questo?';

  @override
  String get apOnline => 'online';

  @override
  String get apMessage => 'Messaggio';

  @override
  String get apAutoTranslated => 'Tradotto automaticamente';

  @override
  String get apBgSend => 'Guarda lo sfondo 😍';

  @override
  String get apBgA => 'Hai cambiato qualcosa?';

  @override
  String get apBgB => 'Si muove a ogni messaggio 😮';

  @override
  String get apFormatQ => 'Dove ci vediamo?';

  @override
  String get apFormatDemo => 'Ci vediamo **alle 18** davanti al __grande mercato__, codice `4821`. Sorpresa: ||una torta||';

  @override
  String get apVoiceQ => 'Dove sei?';

  @override
  String get apVoiceText => 'Sono davanti alla farmacia, ti aspetto fino alle 18.';

  @override
  String get apTransQ => 'Ehi, è tutto pronto?';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => 'Sì! Ci vediamo domani in aeroporto, gate 12 alle 9.';

  @override
  String get hlpDataOnDevice => 'SUL TUO TELEFONO';

  @override
  String get hlpDataServers => 'COSA PASSA DA UN SERVER';

  @override
  String get hlpDataServersFooter => 'Senza internet nessuno di questi server interviene: i telefoni si parlano direttamente.';

  @override
  String get hlpDataNone => 'COSA DROPLET NON CHIEDE MAI';

  @override
  String get hlpRowKeys => 'La tua identità';

  @override
  String get hlpRowKeysBody => 'Una coppia di chiavi creata qui, mai inviata';

  @override
  String get hlpRowMessages => 'I tuoi messaggi';

  @override
  String get hlpRowMessagesBody => 'Nello spazio privato dell\'app, cancellati alla disinstallazione';

  @override
  String get hlpRowProfile => 'Nome e foto';

  @override
  String get hlpRowProfileBody => 'Arrivano solo a chi scrivi';

  @override
  String get hlpRowSettings => 'Le tue impostazioni';

  @override
  String get hlpRowSettingsBody => 'Sfondo, lingua, notifiche — tutto resta qui';

  @override
  String get hlpRowLog => 'Registro errori';

  @override
  String get hlpRowLogBody => 'Un file locale che non parte mai da solo';

  @override
  String get hlpRowDirectory => 'Elenco';

  @override
  String get hlpRowDirectoryBody => 'Vede un nome e un identificatore pubblico. Richieste via Tor: non il tuo IP reale';

  @override
  String get hlpRowMailbox => 'Casella';

  @override
  String get hlpRowMailboxBody => 'Conserva un messaggio cifrato fino alla consegna. Non può leggerlo';

  @override
  String get hlpRowSignalling => 'Messa in contatto';

  @override
  String get hlpRowSignallingBody => 'Vede due identificatori il tempo di collegare. Nessuna voce ci passa';

  @override
  String get hlpRowRelay => 'Ripetitore';

  @override
  String get hlpRowRelayBody => 'Inoltra l\'audio cifrato quando il collegamento diretto fallisce';

  @override
  String get hlpNonePhone => 'Numero di telefono';

  @override
  String get hlpNoneEmail => 'Indirizzo e-mail';

  @override
  String get hlpNoneContacts => 'La tua rubrica';

  @override
  String get hlpNoneLocation => 'La tua posizione';

  @override
  String get hlpNoneAds => 'Pubblicità e tracciatori';

  @override
  String get hlpNoneAnalytics => 'Analisi d\'uso';

  @override
  String get hlpQOffline => 'Come funziona Droplet senza internet?';

  @override
  String get hlpAOffline => 'I telefoni si parlano direttamente, via Bluetooth e Wi-Fi. Un messaggio può anche saltare di telefono in telefono fino a destinazione, senza passare da alcun server.';

  @override
  String get hlpQCrypto => 'I miei messaggi sono davvero cifrati?';

  @override
  String get hlpACrypto => 'Sì, da un capo all\'altro, con il protocollo Signal. La chiave esiste solo sui due telefoni. Né un ripetitore, né la casella, né noi possiamo aprire un messaggio.';

  @override
  String get hlpQNoAccount => 'Perché Droplet non chiede numero né e-mail?';

  @override
  String get hlpANoAccount => 'Perché non gli servono. La tua identità è una chiave creata sul tuo telefono. Niente da creare, niente da verificare e niente da rubare altrove.';

  @override
  String get hlpQPending => 'Perché il mio messaggio resta in attesa?';

  @override
  String get hlpAPending => 'Nessuno è ancora a portata e internet non c\'è. Il messaggio aspetta nel telefono e parte appena si apre una strada — non devi rifare nulla.';

  @override
  String get hlpQAddSomeone => 'Come aggiungo qualcuno?';

  @override
  String get hlpAAddSomeone => 'Avvicina i telefoni: la persona compare da sola. A distanza, condividi il tuo link d\'invito o scansiona il suo codice QR.';

  @override
  String get hlpQUninstall => 'Cosa succede se disinstallo l\'app?';

  @override
  String get hlpAUninstall => 'Tutto viene cancellato: messaggi, contatti, identità. Non esiste copia altrove, quindi nessun ripristino. Esporta prima le impostazioni se cambi telefono.';

  @override
  String get hlpQBattery => 'Droplet consuma la mia batteria?';

  @override
  String get hlpABattery => 'Cercare dispositivi intorno consuma. Nelle impostazioni puoi ridurlo o attivarlo solo ad app aperta.';

  @override
  String get hlpQReport => 'Come segnalo un problema?';

  @override
  String get hlpAReport => 'Da Contatti e assistenza. Vedrai il testo esatto che verrà inviato prima che parta — niente lascia il tuo telefono senza di te.';

  @override
  String get svLikeStatus => 'Mi piace lo stato';

  @override
  String get svUnlikeStatus => 'Togli il mi piace';

  @override
  String get stAddPhotoSemantics => 'Aggiungere una foto del profilo';

  @override
  String get stChangePhotoSemantics => 'Cambiare la foto del profilo';

  @override
  String get scOverheat => 'Telefono surriscaldato — Android ha spento il codificatore video. Lascialo raffreddare qualche minuto.';

  @override
  String scTooHeavy(int mo) {
    return 'File troppo pesante — massimo $mo MB per attraversare la rete locale.';
  }

  @override
  String get scUnsupported => 'Questo formato non è supportato per uno stato.';

  @override
  String get scUnreadableFile => 'Impossibile leggere questo file';

  @override
  String get scUnreadableTrack => 'Impossibile leggere questo brano';

  @override
  String get scNothingCaptured => 'La registrazione non ha catturato nulla — riprova.';

  @override
  String get scVideoTrimmed => 'Video accorciato a 1 min 30 — viene pubblicato solo l\'inizio.';

  @override
  String get scUnreadableVideo => 'Video illeggibile';

  @override
  String get chAiMe => 'Io';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'Ecco la fine di una conversazione in Droplet tra l\'utente («Io») e $pseudo:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'L\'utente vuole aiuto per rispondere a $pseudo. Proponi una risposta breve e naturale, scritta in $langue, in prima persona, come se la inviasse lui stesso. Dai solo la risposta proposta, senza preamboli.';
  }

  @override
  String get hlpSectionHeader => 'Aiuto e privacy';

  @override
  String get hlpPrivacy => 'Informativa sulla privacy';

  @override
  String get hlpData => 'I tuoi dati';

  @override
  String get hlpDataValue => 'Niente esce';

  @override
  String get hlpContact => 'Contatti e assistenza';

  @override
  String get hlpPrivacyTitle => 'Privacy';

  @override
  String hlpUpdated(String date) {
    return 'Aggiornato il $date';
  }

  @override
  String get hlpOnlyFrEn => 'Questo testo esiste solo in francese e in inglese. Un documento giuridico tradotto approssimativamente impegnerebbe più di quanto aiuti.';

  @override
  String get hlpReadInEnglish => 'Leggi in inglese';

  @override
  String get hlpReadInFrench => 'Leggi in francese';

  @override
  String get hlpDataTitle => 'I tuoi dati';

  @override
  String get hlpDataLead => 'Ciò che Droplet sa di te, riga per riga. Niente qui è una promessa: ogni riga corrisponde a del codice.';

  @override
  String get hlpStays => 'Non lascia mai il dispositivo';

  @override
  String get hlpLeaves => 'Passa da un server';

  @override
  String get hlpNever => 'Non esiste';

  @override
  String get hlpCountTracking => 'dati per tracciarti';

  @override
  String get hlpCountAccount => 'account da creare';

  @override
  String get hlpCountServers => 'server, e diciamo quali';

  @override
  String get hlpHelpTitle => 'Aiuto';

  @override
  String get hlpSearchHint => 'Cerca';

  @override
  String get hlpNoResult => 'Nessuna risposta contiene questa parola. Scrivici: forse è una domanda che manca qui.';

  @override
  String get hlpStillStuckFooter => 'Se la risposta non c\'è, risponde una persona.';

  @override
  String get hlpContactTitle => 'Contatti';

  @override
  String get hlpContactLead => 'Una domanda, un problema, un\'idea. Leggiamo tutto.';

  @override
  String get hlpBeforeWriting => 'Prima di scrivere';

  @override
  String get hlpHelpRowBody => 'Otto risposte, consultabili senza internet';

  @override
  String get hlpWriteUs => 'Scrivici';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'E-mail';

  @override
  String get hlpWhatsAppHello => 'Ciao, uso Droplet e ho una domanda:';

  @override
  String get hlpEmailSubject => 'Droplet — domanda';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'WhatsApp non è installato. Il numero $numero è stato copiato.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'L\'indirizzo $adresse è stato copiato.';
  }

  @override
  String get hlpReportHeader => 'Un problema';

  @override
  String get hlpReport => 'Segnala un problema';

  @override
  String get hlpReportBody => 'Vedrai cosa parte prima che parta';

  @override
  String get hlpReportFooter => 'Droplet non invia alcun rapporto da solo: non ha un server per farlo. Un problema ci arriva solo se lo mandi tu.';

  @override
  String get hlpReportSubject => 'Droplet — segnalazione';

  @override
  String get hlpReportSheetLead => 'Racconta cosa è successo. Il testo esatto che partirà appare qui sotto.';

  @override
  String get hlpReportHint => 'Cosa stavo facendo e cosa è successo…';

  @override
  String get hlpAttachLog => 'Allega il registro errori';

  @override
  String get hlpWhatWillBeSent => 'COSA VERRÀ INVIATO';

  @override
  String get hlpLogExcerpt => 'Registro (fine):';

  @override
  String get hlpCopy => 'Copia';

  @override
  String get hlpCopied => 'Copiato';

  @override
  String get hlpOnePerson => 'Droplet è fatto da una persona, non da un servizio clienti. La risposta può richiedere un giorno o due — arriva.';

  @override
  String get avSectionHeader => 'Cosa porta Pro';

  @override
  String get avUnlock => 'Sblocca Droplet Pro';

  @override
  String get avVoiceTitle => 'Vocali in testo';

  @override
  String get avVoiceShort => 'Leggi un vocale senza ascoltarlo';

  @override
  String get avVoiceLong => 'La trascrizione avviene sul telefono, offline. Il vocale non va da nessuna parte e lo leggi in riunione, sul bus o senza rete.';

  @override
  String get avFormatTitle => 'Formattazione';

  @override
  String get avFormatShort => 'Grassetto, corsivo, codice, spoiler';

  @override
  String get avFormatLong => 'Una parola in grassetto, una riga di codice, un passaggio nascosto da scoprire con un tocco: il messaggio dice esattamente ciò che volevi.';

  @override
  String get avWallpaperTitle => 'Sfondi e motivi';

  @override
  String get avWallpaperShort => 'Tutta la galleria e i quattro pack';

  @override
  String get avWallpaperLong => 'Ogni sfondo è disegnato a mano, ogni motivo verificato prima di entrare nell\'app. Droplet, Giochi, Casa, Giardino: la tua chat non somiglia a nessun\'altra.';

  @override
  String get avStickersTitle => 'Adesivi animati';

  @override
  String get avStickersShort => 'La goccia Droplet, in movimento';

  @override
  String get avStickersLong => 'Adesivi disegnati per Droplet, animati fotogramma per fotogramma e così leggeri da viaggiare nella rete mesh senza internet.';

  @override
  String get avIconTitle => 'Icone dell\'app';

  @override
  String get avIconShort => 'Cambia l\'icona nella schermata home';

  @override
  String get avIconLong => 'Una messaggistica discreta comincia dall\'icona. Scegli quella che ti somiglia, o quella che si nota meno.';

  @override
  String get avBadgeTitle => 'Badge Pro';

  @override
  String get avBadgeShort => 'Accompagna il tuo nome';

  @override
  String get avBadgeLong => 'Non dà alcun potere sugli altri. Dice solo che hai pagato perché Droplet resti senza pubblicità, senza abbonamento obbligatorio e senza rivendita dei dati.';

  @override
  String get sgTitle => 'Spazio del gruppo';

  @override
  String get sgEmpty => 'Nessun file è ancora stato condiviso in questo gruppo.';

  @override
  String get sgByAuthor => 'Chi invia di più';

  @override
  String get sgFiles => 'File';

  @override
  String get sgSortRecent => 'Più recenti';

  @override
  String get sgSortHeavy => 'I più pesanti';

  @override
  String get sgNotOnDevice => 'Non qui';

  @override
  String get giPhotoChanged => 'Foto del gruppo cambiata';

  @override
  String get giPhotoFailed => 'Impossibile salvare questa immagine';

  @override
  String sgTotal(int count) {
    return '$count file condivisi';
  }

  @override
  String get vrTitle => 'Stanza vocale';

  @override
  String get vrJoin => 'Entra';

  @override
  String get vrBack => 'Torna';

  @override
  String get vrStart => 'Apri una stanza vocale';

  @override
  String get vrNeedsInternet => 'Una stanza vocale richiede internet: la rete mesh porta un messaggio che aspetta, non venti voci insieme.';

  @override
  String get vrUnreachable => 'Il server delle chiamate non è raggiungibile al momento.';

  @override
  String vrFull(int count) {
    return 'La stanza è piena: massimo $count persone.';
  }

  @override
  String get vrWaiting => 'In attesa degli altri…';

  @override
  String get vrWaitingBody => 'La stanza è aperta. I membri del gruppo la vedono nella chat ed entrano quando sono liberi.';

  @override
  String vrPeople(int count) {
    return '$count persone dentro';
  }

  @override
  String get cvTitle => 'Conversazioni';

  @override
  String get cvNew => 'Nuova conversazione';

  @override
  String get cvPinned => 'Fissate';

  @override
  String get cvRecent => 'Recenti';

  @override
  String get cvPin => 'Fissa';

  @override
  String get cvUnpin => 'Non fissare';

  @override
  String get cvRename => 'Rinomina';

  @override
  String get cvRenameHint => 'Titolo della conversazione';

  @override
  String get cvUntitled => 'Senza titolo';

  @override
  String get cvYesterday => 'Ieri';

  @override
  String get cvSearchHint => 'Cerca nelle conversazioni';

  @override
  String get cvEmpty => 'Nessuna conversazione. Fai la prima domanda all’assistente.';

  @override
  String get cvDeleteTitle => 'Eliminare questa conversazione?';

  @override
  String get cvDeleteBody => 'Non potrà essere recuperata: esiste solo su questo dispositivo.';

  @override
  String get jaWorking => 'Sto lavorando…';

  @override
  String cvNoResult(String terme) {
    return 'Nessun risultato per «$terme».';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Nessun risultato',
      one: '1 risultato',
      other: '$count risultati',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Nessun passaggio',
      one: '1 passaggio',
      other: '$count passaggi',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'Dove va il tuo messaggio';

  @override
  String get moLocal => 'Sul dispositivo';

  @override
  String get moLocalBody => 'Il modello gira su questo telefono. Nulla esce, anche offline. Le risposte sono più brevi e meno affidabili.';

  @override
  String get moOnline => 'Online';

  @override
  String get moOnlineBody => 'Il tuo messaggio va a Groq, che esegue un modello molto più grande. Serve la rete e il messaggio lascia il telefono.';

  @override
  String get moOnlineNoKey => 'Per parlare con un modello remoto serve una chiave. Tocca per aggiungerne una: è gratis e richiede un minuto.';

  @override
  String get moRetryOnline => 'Rifai online';

  @override
  String get moRetryOnlineWhy => 'Il modello sul dispositivo ha raggiunto i suoi limiti.';

  @override
  String get cpHint => 'Chiedi qualcosa…';

  @override
  String get cpAdd => 'Aggiungi';

  @override
  String get cpPhoto => 'Foto';

  @override
  String get cpCamera => 'Fotocamera';

  @override
  String get cpFile => 'File';

  @override
  String get cpFileHint => 'PDF, testo, codice';

  @override
  String get cpDictate => 'Detta';

  @override
  String get cpSend => 'Invia';

  @override
  String get cpStop => 'Ferma';

  @override
  String get cpThinking => 'Sto pensando…';

  @override
  String get amCopy => 'Copia';

  @override
  String get amCopyMarkdown => 'Copia come Markdown';

  @override
  String get amCopyMarkdownHint => 'Mantiene la formattazione, per un documento';

  @override
  String get amShare => 'Condividi';

  @override
  String get amEdit => 'Modifica la mia domanda';

  @override
  String get amEditHint => 'Tutto ciò che segue sarà eliminato';

  @override
  String get amEditTitle => 'Modificare questa domanda?';

  @override
  String get amEditConfirm => 'Modifica';

  @override
  String get amRegenerate => 'Rigenera';

  @override
  String get amReadAloud => 'Leggi ad alta voce';

  @override
  String get amAsContext => 'Usa come contesto';

  @override
  String get amAsContextHint => 'Riparte da questo messaggio';

  @override
  String get amChapter => 'Segna come capitolo';

  @override
  String get amChapterHint => 'Per ritrovarlo in una conversazione lunga';

  @override
  String get amUnchapter => 'Togli il segno';

  @override
  String get amChapters => 'Capitoli';

  @override
  String get amChaptersEmpty => 'Nessun capitolo. Tieni premuto un messaggio e scegli «Segna come capitolo» per ritrovarlo qui.';

  @override
  String amEditBody(int count) {
    return '$count messaggi successivi saranno eliminati: rispondevano alla vecchia domanda.';
  }

  @override
  String get trAssistant => 'Assistente';

  @override
  String get trArtifacts => 'Artefatti';

  @override
  String get trMemory => 'Memoria';

  @override
  String get trHelp => 'Aiuto';

  @override
  String get arVersions => 'Versioni';

  @override
  String get arLatest => 'La più recente';

  @override
  String get arSource => 'Sorgente';

  @override
  String get arPreview => 'Anteprima';

  @override
  String get arGone => 'Questo artefatto non esiste più.';

  @override
  String get arKindPage => 'Pagina';

  @override
  String get arKindCode => 'Codice';

  @override
  String get arKindDiagram => 'Schema';

  @override
  String get arKindData => 'Dati';

  @override
  String get arKindDoc => 'Documento';

  @override
  String arVersion(int n) {
    return 'Versione $n';
  }

  @override
  String get aiSources => 'Fonti';

  @override
  String get aiToolReading => 'Lettura dell’allegato…';

  @override
  String get aiToolWriting => 'Creazione del file…';

  @override
  String get aiToolRemembering => 'Memorizzazione…';

  @override
  String get arEmpty => 'Nessun artefatto. L’assistente ne crea uno appena produce una pagina, una tabella o del codice abbastanza lungo da intasare la conversazione.';

  @override
  String get raTitle => 'Assistente online';

  @override
  String get raIntro => 'L’assistente sul dispositivo funziona senza configurazione. La modalità online richiede una chiave: paga le risposte e resta su questo telefono.';

  @override
  String get raKey => 'Chiave';

  @override
  String get raKeySaved => 'Chiave salvata';

  @override
  String get raKeyFooter => 'È custodita nel portachiavi di sistema e non viene mai mostrata per intero.';

  @override
  String get raKeyRemove => 'Rimuovi la chiave';

  @override
  String get raWhere => 'Si crea su console.groq.com, in «API Keys». Inizia con gsk_.';

  @override
  String get raPaste => 'Incolla';

  @override
  String get raSaveAndTest => 'Salva e prova';

  @override
  String get raTest => 'Prova la chiave';

  @override
  String get raTesting => 'Prova in corso…';

  @override
  String get raNotTested => 'Non ancora provata';

  @override
  String get raNotTestedBody => 'Basta una chiamata di otto parole. Meglio qui che nel mezzo di una domanda.';

  @override
  String get raWorks => 'La chiave funziona';

  @override
  String get raWorksBody => 'La modalità online è ora disponibile nella conversazione, sulla pillola accanto al campo di testo.';

  @override
  String get raRefused => 'Chiave rifiutata';

  @override
  String get raRefusedBody => 'Il server non la riconosce. Spesso manca un carattere all’incollaggio, o la chiave è stata revocata.';

  @override
  String get raNoNetwork => 'Server irraggiungibile';

  @override
  String get raNoNetworkBody => 'La chiave non c’entra: la richiesta non è mai arrivata. Controlla la connessione e riprova.';

  @override
  String get raModelGone => 'Modello non disponibile';

  @override
  String get raModelGoneBody => 'La chiave è accettata, ma non è tornato nulla. Il modello è probabilmente stato ritirato.';

  @override
  String get raQuota => 'Troppe richieste';

  @override
  String get raQuotaBody => 'La chiave funziona, ma l’account ha raggiunto il limite. Riprova più tardi o controlla il credito.';

  @override
  String get raWhatGoesOut => 'Cosa esce';

  @override
  String get raModel => 'Modello';

  @override
  String get raWhatGoesOutFooter => 'In modalità online, il tuo messaggio e i turni precedenti di questa conversazione vanno a Groq. Nient’altro: né i contatti, né le altre conversazioni, né la posizione.';

  @override
  String get aiDownloadTitle => 'Scaricare il modello sul dispositivo?';

  @override
  String get aiDownloadConfirm => 'Scarica';

  @override
  String get aiDownloading => 'Scaricamento del modello';

  @override
  String aiDownloadBody(int mo) {
    return '$mo MB da scaricare, una volta sola. Poi l’assistente risponde senza rete e nulla lascia il telefono. Puoi continuare a usarlo online durante il download.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo MB da scaricare, una volta sola. Poi risponde senza rete e nulla lascia il telefono.';
  }

  @override
  String get aiGreetingPlain => 'Ciao';

  @override
  String get aiGreetingHint => 'Fai una domanda, allega una foto o chiedi un documento.';

  @override
  String get aiChipExplain => 'Spiegami…';

  @override
  String get aiChipWrite => 'Scrivi un messaggio';

  @override
  String get aiChipSummarize => 'Riassumi questo';

  @override
  String get aiChipTranslate => 'Traduci in…';

  @override
  String aiGreeting(String nom) {
    return 'Ciao, $nom';
  }

  @override
  String get cpNoPhoto => 'Niente foto: il modello online non sa leggere un’immagine. Legge invece i PDF, anche lunghi.';

  @override
  String get mvOpen => 'Modalità vocale';

  @override
  String get mvTapToTalk => 'Tocca per parlare';

  @override
  String get mvHoldToTalk => 'Tieni premuto per parlare';

  @override
  String get mvListening => 'In ascolto…';

  @override
  String get mvTranscribing => 'Trascrizione…';

  @override
  String get mvSpeaking => 'Risposta ad alta voce';

  @override
  String get mvProblem => 'Si è verificato un problema';

  @override
  String get mvHandsFree => 'Mani libere';

  @override
  String get mvHold => 'Tieni premuto';

  @override
  String get mvTalk => 'Parla';

  @override
  String get mvInterrupt => 'Interrompi';

  @override
  String get mvNoMic => 'Droplet non ha accesso al microfono. Concedilo nelle impostazioni del telefono.';

  @override
  String get mvFailed => 'Questo turno non è andato a buon fine. Tocca per riprovare.';

  @override
  String get mvLive => 'In diretta';

  @override
  String get mvCaptions => 'Sottotitoli';

  @override
  String get mvExit => 'Esci dalla modalità vocale';

  @override
  String get mvMute => 'Disattiva il microfono';

  @override
  String get mvUnmute => 'Riattiva il microfono';

  @override
  String get mvMuted => 'Microfono disattivato';

  @override
  String get mvTapToInterrupt => 'Tocca per interrompere';

  @override
  String scCompressing(int percent) {
    return 'Compressione… $percent%';
  }

  @override
  String get scStillHeavy => 'Questo video supera ancora i 2 MB: il trasferimento sarà più lento.';

  @override
  String get baConnecting => 'Connessione…';

  @override
  String get baMute => 'Disattiva microfono';

  @override
  String get baUnmute => 'Riattiva microfono';

  @override
  String get baHangUp => 'Termina chiamata';

  @override
  String baOngoing(String name) {
    return 'Chiamata in corso con $name. Tocca per tornare.';
  }

  @override
  String get ntfOngoingCall => 'Chiamata in corso';

  @override
  String get ntfViaMesh => 'Tramite la rete mesh';

  @override
  String get ntfViaInternet => 'Tramite Internet';

  @override
  String get shSend => 'Invia';

  @override
  String get shRecents => 'Recenti';

  @override
  String get shPickRecipients => 'Scegli uno o più destinatari';

  @override
  String shSendCount(int count) {
    return 'Invia a $count';
  }

  @override
  String shSelected(int count) {
    return '$count selezionato/i';
  }

  @override
  String get apcNothingYet => 'Ancora niente';

  @override
  String get apcOnline => 'Online';

  @override
  String get apcOffline => 'Offline';

  @override
  String get apcPhoto => 'Foto';

  @override
  String get apcVoice => 'Messaggio vocale';

  @override
  String get apcAttachment => 'Allegato';

  @override
  String get chKeyboardTooltip => 'Tastiera';

  @override
  String get asGallery => 'Galleria';

  @override
  String get asFile => 'File';

  @override
  String get asLocation => 'Posizione';

  @override
  String get asSticker => 'Sticker';

  @override
  String get asPoll => 'Sondaggio';

  @override
  String get asNoGalleryAccess => 'Droplet non ha accesso alle tue foto. Concedilo nelle impostazioni del telefono o scegli un\'altra fonte qui sotto.';

  @override
  String asSendCount(int count) {
    return 'Invia $count';
  }

  @override
  String get asEmptyGallery => 'Nessuna foto né video su questo telefono.';

  @override
  String get expAucunPairTitre => 'Nessuno vicino?';

  @override
  String get expAucunPairTexte => 'Non è un guasto. Droplet cerca di continuo; appena passa un dispositivo, il collegamento si crea da solo.';

  @override
  String get expRelaisTitre => 'Passato da un altro';

  @override
  String get expRelaisTexte => 'Questa icona indica che il messaggio ha attraversato uno o più dispositivi prima di arrivare. È la forza della rete.';

  @override
  String get expApercuTitre => 'Sbirciata';

  @override
  String get expApercuTexte => 'Tieni premuta una conversazione per leggerne gli ultimi messaggi senza aprirla né segnarla come letta.';

  @override
  String get expOfficielTitre => 'L\'account Droplet';

  @override
  String get expOfficielTexte => 'Le novità dell\'app arrivano qui. Ogni annuncio è firmato: nessuno può falsificarlo.';

  @override
  String get expMicroTitre => 'Parla tenendo premuto';

  @override
  String get expMicroTexte => 'Tieni premuto per registrare. Scorri a sinistra per annullare, verso l\'alto per continuare senza tenere premuto.';

  @override
  String get expCameraTitre => 'Microfono o fotocamera';

  @override
  String get expCameraTexte => 'Un tocco breve su questo pulsante alterna tra messaggio vocale e videomessaggio rotondo.';

  @override
  String get expVueUniqueTitre => 'Una sola volta';

  @override
  String get expVueUniqueTexte => 'Attiva l\'«1» e il prossimo invio potrà essere aperto una sola volta, poi sparirà.';

  @override
  String get expPiecesTitre => 'Più d\'un colpo';

  @override
  String get expPiecesTexte => 'La graffetta apre la tua galleria nell\'app. Seleziona più foto: il numero indica l\'ordine di invio.';

  @override
  String get expStickersTitre => 'Sticker e tastiera';

  @override
  String get expStickersTexte => 'Questa icona sostituisce la tastiera con gli sticker, e torna tastiera con un solo tocco.';

  @override
  String get expEphemeresTitre => 'Messaggi che spariscono';

  @override
  String get expEphemeresTexte => 'Imposta un tempo e i nuovi messaggi di questa conversazione si cancelleranno da entrambi i telefoni.';

  @override
  String get expVerrouTitre => 'Conversazione bloccata';

  @override
  String get expVerrouTexte => 'Bloccata, una conversazione non mostra più l\'ultimo messaggio nell\'elenco e chiede di essere sbloccata.';

  @override
  String get expCodeTitre => 'Verificare un contatto';

  @override
  String get expCodeTexte => 'Confrontate questo codice fianco a fianco: se è identico, nessuno si è infilato tra voi.';

  @override
  String get expStatutTitre => 'Stati di 24 ore';

  @override
  String get expStatutTexte => 'Uno stato vive un giorno, poi sparisce. Viaggia di telefono in telefono, anche senza internet.';

  @override
  String get expGardeTitre => 'Niente va perso';

  @override
  String get expGardeTexte => 'Un messaggio inviato a chi è assente resta una settimana e riparte da solo appena si apre un percorso.';

  @override
  String get expVoieTitre => 'Da dove passa';

  @override
  String get expVoieTexte => 'Bluetooth, Wi-Fi diretto o internet: Droplet prende ciò che c\'è e cambia strada senza chiederti nulla.';

  @override
  String get cnAnnouncement => 'Novità di Droplet';

  @override
  String get cnClearAll => 'Cancella tutto';

  @override
  String get cnClearAllTitle => 'Cancellare tutte le notifiche?';

  @override
  String get cnClearAllBody => 'Il centro verrà svuotato. Chat e messaggi restano intatti.';

  @override
  String get cnDelete => 'Cancella';

  @override
  String get cnEmptyTitle => 'Niente di nuovo';

  @override
  String get cnEmptyBody => 'Qui compariranno menzioni, reazioni ai tuoi messaggi, chiamate perse e novità di Droplet.';

  @override
  String get cnMentioned => 'ti ha menzionato';

  @override
  String get cnShowLess => 'Mostra meno';

  @override
  String get cnStatusLike => 'ha messo mi piace al tuo stato';

  @override
  String get cnStatusReply => 'ha risposto al tuo stato';

  @override
  String get cnTitle => 'Centro notifiche';

  @override
  String get ncDeliveryHeader => 'Consegna';

  @override
  String get ncMentionsOnly => 'Solo menzioni';

  @override
  String get ncMentionsOnlySub => 'Solo quando qualcuno scrive @il tuo nome o @tutti';

  @override
  String get ncMute1h => '1 ora';

  @override
  String get ncMute8h => '8 ore';

  @override
  String get ncMute1w => '1 settimana';

  @override
  String get ncMuteAlways => 'Sempre';

  @override
  String get ncMuteFooter => 'Nessuna notifica né suono. I messaggi arrivano comunque e ti aspettano.';

  @override
  String get ncMuteFooterGroup => 'Nessuna notifica né suono. Le menzioni ti arrivano comunque.';

  @override
  String get ncMuteHeader => 'Silenzia';

  @override
  String get ncMuteOff => 'Disattivato';

  @override
  String get ncPreviewAlways => 'Sempre';

  @override
  String get ncPreviewFooter => 'Senza anteprima, la notifica dice solo «Nuovo messaggio»: nulla si legge sullo schermo bloccato.';

  @override
  String get ncPreviewHeader => 'Anteprima del messaggio';

  @override
  String get ncPreviewNever => 'Mai';

  @override
  String get ncQuiet => 'Consegna silenziosa';

  @override
  String get ncQuietSub => 'Nella tendina, senza suono né banner';

  @override
  String get ncSampleAuthor => 'Lea';

  @override
  String get ncSampleHidden => 'Nuovo messaggio';

  @override
  String get ncSampleLabel => 'Notifica di esempio';

  @override
  String get ncSampleText => 'Ci vediamo alle 19?';

  @override
  String get ncStateMentions => 'Solo menzioni';

  @override
  String get ncStateMuted => 'Silenziato';

  @override
  String get ncStateOn => 'Attive';

  @override
  String get ncStateQuiet => 'Silenziose';

  @override
  String get ncSystemFooter => 'Suono e bolle di questa chat si impostano in Android.';

  @override
  String get ncSystemSettings => 'Suono e bolle';

  @override
  String get ncTitle => 'Notifiche';

  @override
  String get ntfNewMessage => 'Nuovo messaggio';

  @override
  String get ntfNow => 'ora';

  @override
  String get rnBanners => 'Banner';

  @override
  String get rnBannersSub => 'Quando arriva un messaggio con Droplet aperto';

  @override
  String get rnFocus1h => 'Per 1 ora';

  @override
  String get rnFocusEvening => 'Fino a stasera';

  @override
  String get rnFocusTomorrow => 'Fino a domani mattina';

  @override
  String get rnFocusFooter => 'Droplet resta in silenzio: i messaggi arrivano e ti aspettano. Le chiamate squillano comunque.';

  @override
  String get rnFocusHeader => 'Full immersion';

  @override
  String get rnFocusMentions => 'Consenti menzioni';

  @override
  String get rnFocusMentionsSub => 'Quando qualcuno scrive @il tuo nome in un gruppo';

  @override
  String get rnFocusOff => 'Full immersion disattivata';

  @override
  String get rnFocusOffSub => 'Le notifiche arrivano normalmente';

  @override
  String get rnFocusOn => 'Full immersion attiva';

  @override
  String get rnFocusStop => 'Disattiva full immersion';

  @override
  String get rnFocusStopShort => 'Ferma';

  @override
  String get rnInAppHeader => 'In Droplet';

  @override
  String get rnMutedEmpty => 'Nessuna chat silenziata.';

  @override
  String get rnMutedHeader => 'Silenziate';

  @override
  String get rnPreview => 'Mostra anteprima';

  @override
  String get rnPreviewFooter => 'Il testo dei messaggi nelle notifiche. Ogni chat può fare diversamente.';

  @override
  String get rnSystem => 'Impostazioni Android';

  @override
  String get rnSystemFooter => 'Permessi, suoni e bolle di Droplet nelle impostazioni del telefono.';

  @override
  String get stNotificationsSubtitle => 'Silenzio, anteprime, full immersion';

  @override
  String cnBellUnread(int count) {
    return 'Notifiche, $count nuove';
  }

  @override
  String cnMore(int count) {
    return '+$count altre';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count altri';
  }

  @override
  String cnQuoted(String texte) {
    return '«$texte»';
  }

  @override
  String cnReacted(String emoji) {
    return 'ha reagito $emoji al tuo messaggio';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'Fino alle $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'Predefinito ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return 'Silenzia $nom';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'Fino alle $heure · le chiamate squillano';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n chat';
  }

  @override
  String get chatsNetSearching => 'Ricerca di dispositivi vicini…';

  @override
  String get cfEmptyUnreadTitle => 'Tutto letto';

  @override
  String get cfEmptyUnreadBody => 'Qui compariranno le chat con messaggi non letti.';

  @override
  String get cfEmptyGroupsTitle => 'Ancora nessun gruppo';

  @override
  String get cfEmptyGroupsBody => 'Creane uno con il pulsante + in alto a destra.';

  @override
  String get cfEmptyOtherTitle => 'Ancora niente qui';

  @override
  String get ciLockedWhereHint => 'Bloccata. Per ritrovarla, trascina verso il basso l\'elenco delle chat.';

  @override
  String get chDraftLabel => 'Bozza:';

  @override
  String get rsMorning => 'Buongiorno';

  @override
  String get rsEvening => 'Buonasera';

  @override
  String get rsUnreadOne => '1 messaggio non letto';

  @override
  String get rsChatsOne => 'in 1 chat';

  @override
  String get rsMentionsOne => '1 menzione';

  @override
  String get rsMissedOne => '1 chiamata persa';

  @override
  String get rsSeeUnread => 'Mostra i non letti';

  @override
  String rsUnreadMany(int count) {
    return '$count messaggi non letti';
  }

  @override
  String rsChatsMany(int count) {
    return 'in $count chat';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count menzioni';
  }

  @override
  String rsMissedMany(int count) {
    return '$count chiamate perse';
  }

  @override
  String get camUnavailable => 'Fotocamera non disponibile. Controlla l\'autorizzazione nelle Impostazioni.';

  @override
  String get camTakePhoto => 'Scatta una foto';

  @override
  String get camFlip => 'Cambia fotocamera';

  @override
  String get chE2eNotice => 'I messaggi sono crittografati end-to-end. Nessun altro, nemmeno Droplet, può leggerli.';

  @override
  String chCallUnreachable(String name) {
    return '$name è fuori portata: potrai chiamare quando sarete vicini o online.';
  }

  @override
  String get chPin => 'Fissa';

  @override
  String get chUnpin => 'Sblocca';

  @override
  String get chPinnedMessage => 'Messaggio fissato';

  @override
  String get chVoicePlay => 'Riproduci';

  @override
  String get chVoicePause => 'Pausa';

  @override
  String chPinnedMessageN(String position) {
    return 'Messaggio fissato $position';
  }

  @override
  String get msgInfo => 'Info';

  @override
  String get imSearch => 'Cerca';

  @override
  String get apcVideo => 'Video';
}
