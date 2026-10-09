// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'Senden';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionSearch => 'Suchen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionNext => 'Weiter';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionRetry => 'Erneut versuchen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabNews => 'Neuigkeiten';

  @override
  String get tabCalls => 'Anrufe';

  @override
  String get tabPeers => 'Peers';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sectionAppearance => 'Erscheinungsbild';

  @override
  String get appearanceAuto => 'Automatisch';

  @override
  String get appearanceLight => 'Hell';

  @override
  String get appearanceDark => 'Dunkel';

  @override
  String get appearanceFooter =>
      'Droplet ist für den dunklen Modus konzipiert: Auf einem OLED-Bildschirm sind schwarze Pixel ausgeschaltet, was Akku spart und im Dunkeln nicht blendet. Der helle Modus bleibt zum Lesen bei hellem Sonnenlicht verfügbar.';

  @override
  String get sectionLanguage => 'Sprache';

  @override
  String get languageAuto => 'Automatisch (Sprache des Telefons)';

  @override
  String get languageFooter =>
      '„Automatisch“ folgt der auf dem Gerät eingestellten Sprache. Wird diese Sprache noch nicht unterstützt, bleibt Droplet auf Französisch.';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatsSearchHint => 'Suchen';

  @override
  String get chatsFilterAll => 'Alle';

  @override
  String get chatsFilterUnread => 'Ungelesen';

  @override
  String get chatsFilterGroups => 'Gruppen';

  @override
  String get chatsFilterPinned => 'Angeheftet';

  @override
  String get chatsEmptyTitle => 'Noch keine Chats';

  @override
  String get chatsEmptySubtitle =>
      'Nähere dich einem Gerät, das Droplet verwendet: Es erscheint dann automatisch hier.';

  @override
  String get chatsSearchEmptyTitle => 'Keine Ergebnisse';

  @override
  String get chatsSearchEmptySubtitle => 'Versuche einen anderen Namen.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Peers in der Nähe',
      one: '$count Peer in der Nähe',
      zero: 'Suche nach Peers…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'Mindestens 3 Zeichen';

  @override
  String get obChoosePseudo => 'Wähle einen Namen, um zu beginnen';

  @override
  String get obRestoreFailed => 'Wiederherstellung fehlgeschlagen';

  @override
  String get obPhotoSaveFailed => 'Foto konnte nicht gespeichert werden';

  @override
  String get obShareUnavailable => 'Teilen nicht verfügbar';

  @override
  String get obBackupPasswordTitle => 'Sicherungspasswort';

  @override
  String get obBackupPasswordMessage =>
      'Das Passwort, das du beim Exportieren deiner Identität gewählt hast.';

  @override
  String get obBackupPasswordPlaceholder => 'Passwort';

  @override
  String get obRestore => 'Wiederherstellen';

  @override
  String get obSkipStep => 'Diesen Schritt überspringen';

  @override
  String get obContinue => 'Weiter';

  @override
  String get obStart => 'Loslegen';

  @override
  String get obAlreadyHaveBackup => 'Ich habe bereits ein Backup';

  @override
  String get obWelcomeTitle => 'Willkommen bei\nDroplet';

  @override
  String get obWelcomeSubtitle =>
      'Ein Messenger, der funktioniert, wo es kein Netz mehr gibt.';

  @override
  String get obFeatOfflineTitle => 'Kein Internet, kein Anbieter';

  @override
  String get obFeatOfflineText =>
      'Telefone sprechen direkt miteinander, Sprung für Sprung. Keine Antenne, keine Rechnung.';

  @override
  String get obFeatEncryptedTitle => 'Ende-zu-Ende verschlüsselt';

  @override
  String get obFeatEncryptedText =>
      'Nicht einmal die Telefone, die deine Nachrichten weiterleiten, können sie lesen.';

  @override
  String get obFeatLocalTitle => 'Nichts verlässt dein Gerät';

  @override
  String get obFeatLocalText =>
      'Kein Konto, kein Server, keine Datensammlung. Deine Gespräche bleiben bei dir.';

  @override
  String get obRelayTitle => 'Schritt für\nSchritt';

  @override
  String get obRelaySubtitle =>
      'Deine Nachricht springt von Telefon zu Telefon, bis sie ihr Ziel erreicht — auch wenn du nicht in direkter Reichweite bist.';

  @override
  String get obFeatCrowdTitle => 'Je mehr wir sind, desto weiter reicht es';

  @override
  String get obFeatCrowdText =>
      'Jedes Gerät in Reichweite vergrößert das Netz für alle.';

  @override
  String get obFeatNothingLostTitle => 'Nichts geht verloren';

  @override
  String get obFeatNothingLostText =>
      'Eine Nachricht für jemanden, der gerade nicht da ist, wartet und geht weiter, sobald sich ein Weg öffnet.';

  @override
  String get obSafetyTitle => 'Sich finden,\nohne Netz';

  @override
  String get obSafetySubtitle =>
      'Wenn nichts mehr funktioniert, wird zu wissen, wo die anderen sind und dass es ihnen gut geht, zur wichtigsten Information.';

  @override
  String get obFeatMapTitle => 'Eine Karte, die offline funktioniert';

  @override
  String get obFeatMapText =>
      'Die von dir angesehenen Bereiche bleiben auf dem Telefon. Einmal angesehen, werden sie ohne Internet angezeigt.';

  @override
  String get obFeatMeshPosTitle => 'Standorte kommen aus dem Mesh';

  @override
  String get obFeatMeshPosText =>
      'Kein Server: Der Standort verlässt verschlüsselt das Telefon deines Kontakts und springt von Gerät zu Gerät bis zu deinem.';

  @override
  String get obFeatCheckinTitle => '„Mir geht\'s gut“ mit einer Geste';

  @override
  String get obFeatCheckinText =>
      'Ein einziges Antippen sendet deinen Status an die ganze Nachbarschaft. Du entscheidest, ob du einen ungefähren Standort hinzufügst oder nicht.';

  @override
  String get obStatusTitle => 'Neuigkeiten\nteilen';

  @override
  String get obStatusSubtitle =>
      'Ein Foto, ein Wort, eine Stimmung: dein Status wandert von Telefon zu Telefon, genau wie deine Nachrichten.';

  @override
  String get obFeatStatusMediaTitle => 'Foto, Video oder Text';

  @override
  String get obFeatStatusMediaText =>
      'Poste, was du zeigen möchtest. Personen in Reichweite empfangen es, ohne über das Internet zu gehen.';

  @override
  String get obFeatStatusSeenTitle => 'Du siehst, wer es gesehen hat';

  @override
  String get obFeatStatusSeenText =>
      'Jede Person, die deinen Status öffnet, lässt es dich auf demselben Weg wissen.';

  @override
  String get obFeatStatusExpireTitle => 'Es verschwindet nach einem Tag';

  @override
  String get obFeatStatusExpireText =>
      'Vierundzwanzig Stunden, dann verschwindet der Status von allen Telefonen, die ihn erhalten haben.';

  @override
  String get obRemovePhoto => 'Foto entfernen';

  @override
  String get obChoosePhoto => 'Foto auswählen';

  @override
  String get obPhotoTitle => 'Ein Gesicht,\nwenn du magst';

  @override
  String get obPhotoSubtitle =>
      'Es hilft anderen, dich in einer Liste zu erkennen. Niemand zwingt dich, eins hinzuzufügen.';

  @override
  String get obFeatPhotoLocalTitle => 'Es bleibt auf diesem Telefon';

  @override
  String get obFeatPhotoLocalText =>
      'Kein Server empfängt es, kein Online-Backup speichert es. Es lebt im Ordner der App, und nirgendwo sonst.';

  @override
  String get obFeatPhotoCompressTitle =>
      'Verkleinert, bevor sie gespeichert wird';

  @override
  String get obFeatPhotoCompressText =>
      'Droplet behält nur eine 320-Pixel-Miniatur. Dein Originalfoto wird nie kopiert.';

  @override
  String get obNetworkTitle => 'Droplet wächst\nmit dir';

  @override
  String get obNetworkSubtitle =>
      'Jede Person, die es installiert, vergrößert das Netz — für sich und alle im Umkreis.';

  @override
  String get obSendToFriend => 'Droplet an jemanden senden';

  @override
  String get obFeatShareOfflineTitle =>
      'Sogar das Teilen kommt ohne Internet aus';

  @override
  String get obFeatShareOfflineText =>
      'Droplet sendet dir seine eigene Installationsdatei. Sie reist per Bluetooth, Wi-Fi Direct oder Speicherkarte — keine Verbindung nötig, auf keiner Seite.';

  @override
  String get obFeatThreeTitle => 'Drei Personen reichen zum Start';

  @override
  String get obFeatThreeText =>
      'Zu zweit schreibt ihr euch in Sichtweite. Mit ein paar Leuten im Viertel leiten sich Nachrichten weiter, und die Reichweite wird viel größer als bei einem einzelnen Telefon.';

  @override
  String get obIdentityTitle => 'Wie sollen wir\ndich nennen?';

  @override
  String get obIdentitySubtitle =>
      'Dieser Name wird Personen angezeigt, denen du begegnest. Du kannst einen wählen, der dich nicht identifiziert.';

  @override
  String get obPseudoHint => 'Dein Name';

  @override
  String get obFeatKeysTitle => 'Deine Schlüssel werden hier, jetzt erstellt';

  @override
  String get obFeatKeysText =>
      'Sie verlassen dieses Telefon nie. Denk daran, in den Einstellungen ein Backup zu erstellen: ohne es ist eine verlorene Identität für immer verloren.';

  @override
  String get splashCaption => 'Offline. Ohne Anbieter.';

  @override
  String get chatsMeshNetwork => 'Mesh-Netzwerk';

  @override
  String get chatsNew => 'Neu';

  @override
  String get chatsNewGroup => 'Neue Gruppe';

  @override
  String get chatsAssistant => 'Assistent';

  @override
  String get chatsEmergencyMode => 'Notfallmodus';

  @override
  String get chatsUnpin => 'Lösen';

  @override
  String get chatsPin => 'Oben anheften';

  @override
  String get chatsUnmute => 'Benachrichtigungen aktivieren';

  @override
  String get chatsMute => 'Stummschalten';

  @override
  String get chatsArchive => 'Archivieren';

  @override
  String get swipePin => 'Anheften';

  @override
  String get swipeUnpin => 'Lösen';

  @override
  String get swipeMute => 'Stumm';

  @override
  String get swipeUnmute => 'Ton an';

  @override
  String get swipeArchive => 'Archiv';

  @override
  String get fmtBold => 'Fett';

  @override
  String get fmtItalic => 'Kursiv';

  @override
  String get fmtStrike => 'Durchgestrichen';

  @override
  String get fmtMono => 'Monospace';

  @override
  String get fmtSpoiler => 'Spoiler';

  @override
  String get vnTranscribing => 'Transkription…';

  @override
  String get vnTranscribeFailed =>
      'Transkription auf diesem Gerät nicht verfügbar';

  @override
  String get vnNoSpeech => 'Keine Sprache erkannt';

  @override
  String get msgTranslate => 'Übersetzen';

  @override
  String get msgShowOriginal => 'Original anzeigen';

  @override
  String get msgTranslatedFrom => 'Automatisch übersetzt';

  @override
  String get msgTranslateFailed => 'Übersetzung nicht verfügbar';

  @override
  String get msgTranslateModel =>
      'Sprachmodell muss geladen werden (einmalig, per WLAN)';

  @override
  String get pfWallpapers => 'Animierte Hintergründe';

  @override
  String get pfWallpapersDesc =>
      'Acht bunte Hintergründe, die hinter deinen Chats leben und sich mit jeder gesendeten Nachricht drehen.';

  @override
  String get pfFormatting => 'Textformatierung';

  @override
  String get pfFormattingDesc =>
      'Fett, kursiv, durchgestrichen, Code und Spoiler direkt in deinen Nachrichten.';

  @override
  String get pfTranscription => 'Sprache zu Text';

  @override
  String get pfTranscriptionDesc =>
      'Lies eine Sprachnachricht, wenn du nicht zuhören kannst. Die Erkennung läuft auf deinem Telefon.';

  @override
  String get pfTranslation => 'Übersetzung';

  @override
  String get pfTranslationDesc =>
      'Übersetze eine empfangene Nachricht, ohne dass ihr Inhalt das Gerät verlässt.';

  @override
  String get pfAppIcons => 'App-Symbole';

  @override
  String get pfAppIconsDesc =>
      'Ändere das Droplet-Symbol auf deinem Startbildschirm.';

  @override
  String get pfBadge => 'Abzeichen und Unterstützung';

  @override
  String get pfBadgeDesc =>
      'Ein Abzeichen neben deinem Namen und Unterstützung für ein unabhängiges Projekt.';

  @override
  String get pfUnderstood => 'Verstanden';

  @override
  String get pfFeaturesTitle => 'Was das Paket öffnet';

  @override
  String get chatsUnarchive => 'Aus Archiv holen';

  @override
  String get chatsArchivedTitle => 'Archiviert';

  @override
  String get chatsNoArchived => 'Keine archivierten Chats';

  @override
  String get chatsLockedTitle => 'Gesperrte Chats';

  @override
  String get chatsNoLocked => 'Keine gesperrten Chats';

  @override
  String get chatsCrashTitle => 'Droplet wurde unerwartet beendet';

  @override
  String get chatsCrashBody =>
      'Droplet hat keinen Server: Ohne dein Senden existiert dieser Fehler für niemanden sonst. Der Bericht enthält keine Nachrichten, Kontakte oder Schlüssel.';

  @override
  String get chatsSendReport => 'Bericht senden';

  @override
  String get chatsLater => 'Später';

  @override
  String get stTitle => 'Einstellungen';

  @override
  String get stIconHeader => 'Symbol';

  @override
  String get stIconFooter =>
      'Dreizehn Symbole zur Auswahl für den Startbildschirm.';

  @override
  String get stAppIcon => 'App-Symbol';

  @override
  String get stVariants13 => '13 Varianten';

  @override
  String get stNetworkHeader => 'Netzwerk';

  @override
  String get stNetworkFooter =>
      'Die Weiterleitung im Hintergrund ermöglicht das Weiterleiten fremder Nachrichten, auch wenn Droplet geschlossen ist.';

  @override
  String get stRequireTor => 'Tor online erzwingen';

  @override
  String get stRequireTorSubtitle => 'Ohne Tor geht nichts zu den Servern';

  @override
  String get stRequireTorFooter =>
      'Verzeichnis und Postfach laufen über Tor, sobald es aktiv ist. Sonst verbindet sich Droplet direkt: Inhalte bleiben Ende-zu-Ende verschlüsselt, aber die Server sehen deine IP-Adresse. Aktiviere dies, um das zu verbieten — auf Kosten der Online-Nachrichten, wenn Tor nicht läuft.';

  @override
  String get stMeshNetwork => 'Mesh-Netzwerk';

  @override
  String get stPeersTopology => 'Verbundene Peers und Topologie';

  @override
  String get stOfflineMaps => 'Offline-Karten';

  @override
  String get stZonesImport => 'Gespeicherte Bereiche und Kartenimport';

  @override
  String get stSecurityHeader => 'Sicherheit';

  @override
  String get stSecurityFooter =>
      'Droplet speichert keine Kopie deiner Identität. Ohne Backup geht sie mit dem Gerät verloren.';

  @override
  String get stBackupIdentity => 'Meine Identität sichern';

  @override
  String get stExportEncrypted => 'Passwortverschlüsselter Export';

  @override
  String get stEmergencyMode => 'Notfallmodus';

  @override
  String get stSignalSafe => 'Signalisieren, dass es dir gut geht';

  @override
  String get stContributionHeader => 'Beitrag';

  @override
  String get stMyContribution => 'Mein Beitrag';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'Aktiv';

  @override
  String get stProPackUnlocked => 'Paket freigeschaltet';

  @override
  String get stProIconsThemes => 'Symbole und Hintergründe';

  @override
  String get stCrashLog => 'Fehlerprotokoll';

  @override
  String get stAbout => 'Über Droplet';

  @override
  String get stBackgroundRelay => 'Weiterleitung im Hintergrund';

  @override
  String get stActiveClosed => 'Aktiv, auch wenn die App geschlossen ist';

  @override
  String get stActiveOpenOnly => 'Nur aktiv, wenn die App geöffnet ist';

  @override
  String get stBatteryOptim => 'Akku-Optimierung';

  @override
  String get stAndroidMayLimit => 'Android kann die Weiterleitung einschränken';

  @override
  String get stFix => 'Beheben';

  @override
  String get stKeepActiveTitle => 'Droplet aktiv halten?';

  @override
  String get stKeepActiveBody =>
      'Eine dauerhafte Benachrichtigung zeigt an, dass Droplet das Mesh weiterleitet, auch wenn die App geschlossen ist. Im Gegenzug wird mehr Akku verbraucht.';

  @override
  String get stEnable => 'Aktivieren';

  @override
  String get stCancel => 'Abbrechen';

  @override
  String get stAboutTagline =>
      'Offline-Nachrichten und -Anrufe, ohne Internet oder Anbieter.';

  @override
  String get stAboutDirect =>
      'Direktes Netzwerk zwischen Geräten — kein Server';

  @override
  String get stAboutE2E => 'Ende-zu-Ende-Verschlüsselung für alle Nachrichten';

  @override
  String get stAboutNoThirdParty => 'Keine Daten an Dritte übermittelt';

  @override
  String get stAttributionEmoji =>
      'Animierte Emojis: Noto Animated Emoji © Google, lizenziert unter CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'Assistent: Gemma 3 1B-IT © Google, quantisiert (int4) von litert-community und von Droplet neu veröffentlicht, gemäß den Gemma-Nutzungsbedingungen (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'Chat-Hintergrund';

  @override
  String get stChatPatterns => 'Droplet-Muster';

  @override
  String get stChatPatternsSubtitle =>
      'Kleine Strichzeichnungen über dem Hintergrund';

  @override
  String get stChatBgFooter =>
      'Der Farbverlauf rückt bei jeder gesendeten Nachricht einen Schritt weiter. Wähle „Kein“ für einen einfarbigen Hintergrund: Dann wird nichts berechnet, was den Akku schont.';

  @override
  String get stBgFree => 'Kostenlos';

  @override
  String get stBgPremium => 'Premium · animiert';

  @override
  String get stBgNone => 'Kein';

  @override
  String get stBgDefault => 'Standard';

  @override
  String get stBgThisChat => 'Hintergrund dieses Chats';

  @override
  String get stTextSize => 'Textgröße';

  @override
  String get stBubbleCorners => 'Ecken der Nachrichten';

  @override
  String get stAccentHeader => 'Akzentfarbe';

  @override
  String get stAccentFooter =>
      'Sie färbt deine Sprechblasen, Schaltflächen und Links in der ganzen App.';

  @override
  String get stChatListHeader => 'Chatliste';

  @override
  String get stChatListTwoLines => 'Zwei Zeilen';

  @override
  String get stChatListThreeLines => 'Drei Zeilen';

  @override
  String get stResetAppearance => 'Darstellung zurücksetzen';

  @override
  String get stPreviewIncoming => 'Sehen wir uns heute Abend?';

  @override
  String get stPreviewOutgoing => 'Ja, sehr gern!';

  @override
  String get stAppearanceRow => 'Darstellung';

  @override
  String get stAppearanceSubtitle => 'Thema, Farbe, Textgröße, Hintergründe';

  @override
  String get stBgApply => 'Diesen Hintergrund verwenden';

  @override
  String get stBgUnlock => 'Mit Premium freischalten';

  @override
  String get stBgApplied => 'Hintergrund übernommen';

  @override
  String get stBgPreviewHint =>
      'Der Hintergrund bewegt sich, und seine Farben drehen sich mit jeder gesendeten Nachricht.';

  @override
  String get stBgPreviewIncoming => 'Hast du den neuen Hintergrund gesehen?';

  @override
  String get stBgPreviewOutgoing => 'Ja, wunderschön ✨';

  @override
  String get stSoundHeader => 'Töne';

  @override
  String get stSoundToggle => 'App-Töne';

  @override
  String get stSoundSubtitle => 'Nachrichten, Verbindungen, Warnungen';

  @override
  String get stSoundFooter =>
      'Kurze Töne in der Lautstärke der Systembenachrichtigungen — stumm, wenn das Telefon lautlos ist oder im Fokusmodus.';

  @override
  String get stPacksHeader => 'Assistent — Offline-Merkblätter';

  @override
  String get stPacksToggle => 'Erste-Hilfe- und Notfall-Merkblätter';

  @override
  String get stPacksSubtitle =>
      'Der Assistent stützt sich darauf bei Erster Hilfe und Notfällen.';

  @override
  String get stPacksFooter =>
      'Integrierte Referenz-Merkblätter (Erste Hilfe, Erdbeben, Hochwasser, Trinkwasser…). Passt die Frage dazu, zitiert der Assistent das Merkblatt, statt zu raten. Sie ersetzen weder eine Ausbildung noch einen Notruf.';

  @override
  String get stPrivateModeHeader => 'Privater Modus';

  @override
  String get stTorFooter =>
      'Tor schützt deine IP-Adresse und Gespräche, indem sie über das Tor-Netzwerk geleitet werden. Das lokale Mesh (BLE/WLAN) funktioniert weiterhin normal.';

  @override
  String get stTorActiveAnon => 'Aktiv – deine Daten sind anonymisiert';

  @override
  String get stTorConnecting => 'Verbindung wird hergestellt…';

  @override
  String get stTorDisabled => 'Privater Modus deaktiviert';

  @override
  String get callsTitle => 'Anrufe';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verpasste Anrufe',
      one: '$count verpasster Anruf',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'Neuer Anruf';

  @override
  String get callsAll => 'Alle';

  @override
  String get callsMissed => 'Verpasst';

  @override
  String get callsNoneMissed => 'Keine verpassten Anrufe';

  @override
  String get callsNone => 'Keine Anrufe';

  @override
  String get callsMissedEmptyBody =>
      'Anrufe, die du nicht angenommen hast, erscheinen hier.';

  @override
  String get callsEmptyBody =>
      'Anrufe laufen über das lokale Netzwerk, ohne Anbieter oder Tarif. Dein Verlauf erscheint hier.';

  @override
  String get callsRetained200 =>
      'Die letzten 200 Anrufe werden nur auf diesem Gerät gespeichert.';

  @override
  String get callsIncoming => 'Eingehend';

  @override
  String get callsOutgoing => 'Ausgehend';

  @override
  String get callsMissedLabel => 'Verpasst';

  @override
  String get callsNoAnswer => 'Keine Antwort';

  @override
  String get callsConnectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get callsYesterday => 'gestern';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m Min. $s s';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s s';
  }

  @override
  String get peersTitle => 'Peers';

  @override
  String get peersSearching => 'Suche läuft…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Geräte in Reichweite',
      one: '$count Gerät in Reichweite',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'Netzwerkkarte';

  @override
  String get peersNoneInRange => 'Niemand in Reichweite';

  @override
  String get peersNoneInRangeBody =>
      'Droplet sucht ständig nach Geräten in der Nähe. Nähere dich jemandem mit der App, um die erste Verbindung herzustellen.';

  @override
  String get peersDirectRange => 'In direkter Reichweite';

  @override
  String get peersDirectRangeFooter =>
      'Diese Geräte sind erreichbar, ohne über jemand anderen zu gehen.';

  @override
  String get peersRelayed => 'Weitergeleitet';

  @override
  String get peersRelayedFooter =>
      'Diese Geräte sind außer direkter Reichweite: Nachrichten erreichen sie über andere Telefone.';

  @override
  String get peersRelay => 'Relais';

  @override
  String get peersCall => 'Anrufen';

  @override
  String get peersTooSlow => 'Zu langsam für Sprache — komm näher';

  @override
  String get peersWifi => 'WLAN';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'Bluetooth';

  @override
  String get peersUnknownLink => 'Unbekannte Verbindung';

  @override
  String get peersDirect => 'direkt';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sprünge',
      one: '$count Sprung',
      zero: 'direkt',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'Dieser Status ist abgelaufen';

  @override
  String get svReceiving => 'Wird empfangen…';

  @override
  String get svReceivingBody => 'Die Datei kommt über das lokale Netzwerk an';

  @override
  String get svProgressLabel => 'Statusfortschritt';

  @override
  String get svReplyHint => 'Antworten…';

  @override
  String get svSendReply => 'Antwort senden';

  @override
  String get svYourStatus => 'Dein Status';

  @override
  String get svNoViewsYet =>
      'Noch hat niemand diesen Status gesehen.\nEr wird weiter zirkulieren, solange du auf Geräte triffst.';

  @override
  String get svJustNow => 'gerade eben';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Min.',
      one: 'vor $count Min.',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Std.',
      one: 'vor $count Std.',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'Musik';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufrufe',
      one: '$count Aufruf',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count „Gefällt mir“',
      one: '$count Gefällt mir',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Antworten',
      one: '$count Antwort',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'Original';

  @override
  String get cpFilterDark => 'Dunkel';

  @override
  String get cpFilterBright => 'Hell';

  @override
  String get cpFilterVintage => 'Vintage';

  @override
  String get cpWriteStatusHint => 'Status schreiben';

  @override
  String get cpPreparingVideo => 'Video wird vorbereitet…';

  @override
  String get cpLoadingEllipsis => 'Wird geladen…';

  @override
  String cpEndsIn(Object s) {
    return 'Endet in $s s';
  }

  @override
  String get cpModeVideo => 'Video';

  @override
  String get cpModePhoto => 'Foto';

  @override
  String get cpModeMessage => 'Nachricht';

  @override
  String get cpModeVoice => 'Sprachnachricht';

  @override
  String get gcChooseName => 'Wähle einen Namen für die Gruppe';

  @override
  String get gcSelectOneMember => 'Wähle mindestens ein Mitglied';

  @override
  String get gcCreationFailed => 'Gruppe konnte nicht erstellt werden';

  @override
  String get gcNewGroup => 'Neue Gruppe';

  @override
  String get gcGroupName => 'Gruppenname';

  @override
  String get gcNameHint => 'z. B. Außendienst-Team';

  @override
  String get gcMembers => 'Mitglieder';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '$count ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'Niemand in Reichweite';

  @override
  String get gcGetCloserBody =>
      'Nähere dich einem anderen Droplet-Gerät: Peers erscheinen hier automatisch.';

  @override
  String get gcCreateGroup => 'Gruppe erstellen';

  @override
  String get gcConnected => 'Verbunden';

  @override
  String get gcAlreadyMet => 'Bereits getroffen';

  @override
  String get giRenameGroup => 'Gruppe umbenennen';

  @override
  String get giRenameFailed => 'Umbenennen fehlgeschlagen';

  @override
  String get giNoPeerToAdd => 'Keine Peers zum Hinzufügen verfügbar';

  @override
  String get giAddMemberHeader => 'MITGLIED HINZUFÜGEN';

  @override
  String get giAddMemberFailed => 'Mitglied konnte nicht hinzugefügt werden';

  @override
  String get giRemoveMemberTitle => 'Dieses Mitglied entfernen?';

  @override
  String get giRemoveMemberBody =>
      'Es kann Nachrichten, die nach der Entfernung gesendet werden, nicht mehr lesen.';

  @override
  String get giRemove => 'Entfernen';

  @override
  String get giRemoveMemberFailed => 'Mitglied konnte nicht entfernt werden';

  @override
  String get giLeaveGroupTitle => 'Gruppe verlassen?';

  @override
  String get giLeaveGroupBody =>
      'Du erhältst keine Nachrichten mehr, die nach deinem Austritt gesendet werden.';

  @override
  String get giLeave => 'Verlassen';

  @override
  String get giNoOneReachable =>
      'Derzeit ist kein Mitglied über lokales WLAN erreichbar';

  @override
  String get giMax4Participants =>
      'Maximal 4 Teilnehmer pro Gruppenanruf — nur die ersten 3 erreichbaren werden angerufen';

  @override
  String get giGroupNotFound => 'Gruppe nicht gefunden';

  @override
  String get giGroupInfo => 'Gruppeninfo';

  @override
  String get giGroupCall => 'Gruppenanruf';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '$count Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'Gruppennachrichten verschlüsselt';

  @override
  String get giAdd => 'Hinzufügen';

  @override
  String get giMe => 'ich';

  @override
  String get giAdministrator => 'Administrator';

  @override
  String get giLeaveGroup => 'Gruppe verlassen';

  @override
  String get sfNoLocationShared => 'Standort nicht geteilt';

  @override
  String get sfLocationShared => 'Standort geteilt';

  @override
  String sfDistanceMeters(Object m) {
    return '$m m entfernt';
  }

  @override
  String sfDistanceKm(Object km) {
    return '$km km entfernt';
  }

  @override
  String get sfBearingN => 'im Norden';

  @override
  String get sfBearingNE => 'im Nordosten';

  @override
  String get sfBearingE => 'im Osten';

  @override
  String get sfBearingSE => 'im Südosten';

  @override
  String get sfBearingS => 'im Süden';

  @override
  String get sfBearingSW => 'im Südwesten';

  @override
  String get sfBearingW => 'im Westen';

  @override
  String get sfBearingNW => 'im Nordwesten';

  @override
  String get sfBroadcastSafeTitle => '„Mir geht es gut“ senden?';

  @override
  String get sfBroadcastSafeMessage =>
      'Dieser Status ist für das gesamte Mesh in Reichweite sichtbar, nicht nur für deine Kontakte. Du kannst einen ungefähren Standort angeben (gerundet, nie exakt).';

  @override
  String get sfWithLocation => 'Mit ungefährem Standort';

  @override
  String get sfWithoutLocation => 'Ohne Standort';

  @override
  String get sfStatusBroadcast => 'Status an das Mesh gesendet';

  @override
  String get sfBroadcastFailed => 'Senden fehlgeschlagen';

  @override
  String get sfHelpRequestTitle => '„Ich brauche Hilfe“ senden?';

  @override
  String get sfHelpRequestMessage =>
      'Dieser Status signalisiert Peers in Reichweite, dass du Hilfe benötigst. Du kannst einen ungefähren Standort angeben.';

  @override
  String get sfHelpRequestBroadcast => 'Hilferuf an das Mesh gesendet';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor $count Tag',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'Notfallmodus';

  @override
  String get sfViewOnMap => 'Auf der Karte anzeigen';

  @override
  String get sfNeedHelp => 'Ich brauche Hilfe';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Check-ins erhalten ($count)',
      one: 'Check-in erhalten ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'Noch keine Check-ins erhalten';

  @override
  String get sfCheckinsAppearHere =>
      '„Sicher“-Status, die von Peers in Reichweite gesendet werden, erscheinen hier.';

  @override
  String get sfSafeLabel => 'Sicher';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'Sicher · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'Sicher · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'Meinen Sicherheitsstatus an das Mesh-Netzwerk senden';

  @override
  String get sfImSafe => 'Mir geht es gut';

  @override
  String get emSosActive => 'SOS AKTIV';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'SOS-Signal aktiv – wird an alle Geräte in der Nähe gesendet';

  @override
  String get emPullToSendSignal => 'Tippen, um ein Notsignal zu senden';

  @override
  String get emSignalRelayedDescription =>
      'Das Signal wird von Peer zu Peer weitergeleitet\nüber das gesamte Mesh-Netzwerk.';

  @override
  String get emBroadcasting => 'Wird gesendet …';

  @override
  String get emSharePosition => 'Meinen Standort teilen';

  @override
  String get emSosActivated => 'SOS-Signal aktiviert';

  @override
  String get emSafeStatusMessage => '🟢 Mir geht es gut';

  @override
  String get emSafetyStatusBroadcast => 'Sicherheitsstatus gesendet';

  @override
  String get pmEnterPayingNumber =>
      'Gib die Nummer ein, die bezahlen wird (9 Ziffern).';

  @override
  String get pmRequestSent => 'Anfrage gesendet …';

  @override
  String get pmPaymentLaunchFailed =>
      'Die Zahlung konnte nicht gestartet werden. Überprüfe die Nummer und deine Verbindung, oder zahle unten manuell.';

  @override
  String get pmValidateOnPhone =>
      'Bestätige auf deinem Telefon: Gib deinen Mobile-Money-Code ein, sobald die Aufforderung erscheint.';

  @override
  String get pmPaymentNotConfirmed =>
      'Zahlung nicht bestätigt. Es wurde nichts freigeschaltet.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'Die Zahlung ist durchgegangen, aber die erhaltene Lizenz ist ungültig. Schreib uns, sie wird neu erstellt: $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro aktiviert';

  @override
  String get pmPackUnlocked => 'Paket freigeschaltet';

  @override
  String get pmInvalidCode =>
      'Dieser Code ist auf diesem Gerät nicht gültig. Stelle sicher, dass du den oben angezeigten Gerätecode gesendet hast.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'Was Droplet\nniemals verlangen wird';

  @override
  String get pmNeverAskBody =>
      'Keine Werbung, kein Zwangsabo, kein Weiterverkauf deiner Daten – es gibt nicht einmal einen Server, um sie zu sammeln. Das Paket und Pro finanzieren den Rest.';

  @override
  String get pmCommunitySemantics =>
      'Werde Teil der Community mit über 1.200 aktiven Mitgliedern';

  @override
  String get pmCommunityText => 'Werde Teil von über 1.200 Mitgliedern im Mesh';

  @override
  String get pmProPreviewSemantics =>
      'Vorschau der freigeschalteten Pro-Funktionen';

  @override
  String get pmAnimatedEmojis => 'Animierte\nEmojis';

  @override
  String get pmWallpapers => 'Chat-\nHintergründe';

  @override
  String get pmAppIcons => 'App-\nSymbole';

  @override
  String get pmOnceForLife => 'einmalig, lebenslang';

  @override
  String get pmProAdvantage1 =>
      'Die zehn Symbole und acht Hintergründe des Pakets';

  @override
  String get pmProAdvantage2 => 'Das Pro-Abzeichen neben deinem Namen';

  @override
  String get pmProAdvantage3 => 'Zukünftige Funktionen, ohne Aufpreis';

  @override
  String get pmPackTitle => 'Das Paket';

  @override
  String get pmOnce => 'einmalig';

  @override
  String get pmPackAdvantage1 => 'Zehn zusätzliche App-Symbole';

  @override
  String get pmPackAdvantage2 => 'Acht Chat-Hintergründe';

  @override
  String get pmPayByHand => 'Oder manuell bezahlen';

  @override
  String get pmHowTo => 'So funktioniert\'s';

  @override
  String get pmIfPromptDoesNotArrive =>
      'Falls die Aufforderung nicht auf deinem Telefon ankommt, oder wenn du das Geld lieber selbst überweist.';

  @override
  String pmStep1Title(Object montant) {
    return 'Sende $montant F';
  }

  @override
  String get pmStep1Body =>
      'Wähle deinen Anbieter: Sein Menü öffnet sich, und die Nummer bleibt hier sichtbar, während du dich hindurch navigierst.';

  @override
  String get pmStep2Title => 'Sende deinen Gerätecode';

  @override
  String get pmStep2Body =>
      'Zusammen mit dem Screenshot der Zahlung. Ohne diesen Code kann die Lizenz nicht erstellt werden – sie gilt nur für dein Telefon.';

  @override
  String get pmStep3Title => 'Du erhältst eine Lizenz';

  @override
  String get pmStep3Body =>
      'Eine lange Zeile, die mit DROP1 beginnt. Füge sie unten ein: Die Freischaltung erfolgt sofort und funktioniert für immer offline.';

  @override
  String get pmPayNow => 'Jetzt bezahlen';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money oder Orange Money, von diesem Telefon oder einem anderen.';

  @override
  String get pmPhoneNumberSemantics =>
      'Telefonnummer für die Mobile-Money-Zahlung';

  @override
  String get pmWaitingForCode => 'Warten auf deinen Code …';

  @override
  String pmPayAmount(Object montant) {
    return '$montant F bezahlen';
  }

  @override
  String get pmRestorePurchaseSemantics =>
      'Einen früheren Kauf wiederherstellen';

  @override
  String get pmAlreadyPaidRestore => 'Schon bezahlt? Wiederherstellen';

  @override
  String pmDialCode(Object code) {
    return 'Wähle $code von deinem Telefon aus';
  }

  @override
  String get pmChooseOperatorSemantics => 'Einen Zahlungsanbieter auswählen';

  @override
  String get pmNumberAmountFilled =>
      'Nummer und Betrag sind bereits ausgefüllt – nur dein Geheimcode fehlt noch.';

  @override
  String get pmOrangeMenuInstructions =>
      'Im Orange-Menü: Geldtransfer, dann die Nummer und den Betrag unten.';

  @override
  String get pmLabelNumber => 'Nummer';

  @override
  String get pmLabelAmount => 'Betrag';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return '$montant Francs mit $operator bezahlen';
  }

  @override
  String get pmMenuOpen => 'Menü geöffnet';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'Hallo, ich habe gerade für Droplet bezahlt.\n\nAngebot: $offer\nBetrag: $amount F\nGerätecode: $code\n\n(ich hänge den Zahlungs-Screenshot an)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'WhatsApp nicht gefunden – Code kopiert. Sende ihn an $contact';
  }

  @override
  String get pmPrepareRequest => 'Meine Anfrage vorbereiten';

  @override
  String get pmReceivedLicense => 'Ich habe meine Lizenz erhalten';

  @override
  String get pmPaste => 'Einfügen';

  @override
  String get pmUnlock => 'Freischalten';

  @override
  String get pmProIsActive => 'Droplet Pro ist aktiv';

  @override
  String get pmPackIsUnlocked => 'Das Paket ist freigeschaltet';

  @override
  String get pmProActiveDescription =>
      'Das Pro-Abzeichen begleitet deinen Namen, und alle Symbole und Hintergründe sind für dich freigeschaltet.';

  @override
  String get pmPackActiveDescription =>
      'Die zehn Symbole und acht Hintergründe des Pakets sind für dich in den Einstellungen freigeschaltet.';

  @override
  String get pmLicenseDeviceBound =>
      'Deine Lizenz gilt für dieses Telefon. Wenn du das Telefon wechselst, bewahre die Nachricht auf, die sie enthält: Sie wird kostenlos neu erstellt.';

  @override
  String torError(Object e) {
    return 'Fehler: $e';
  }

  @override
  String get torEnable => 'Tor aktivieren';

  @override
  String get torProtected => 'Geschützt';

  @override
  String get torDisabled => 'Deaktiviert';

  @override
  String get torStateHeader => 'Status';

  @override
  String get torCircuit => 'Schaltkreis';

  @override
  String get torActive => 'Aktiv';

  @override
  String get torInProgress => 'Läuft …';

  @override
  String get torInactive => 'Inaktiv';

  @override
  String get torFailed => 'Fehlgeschlagen';

  @override
  String get torReason => 'Grund';

  @override
  String get torBannerConnecting => 'Verbinde mit Tor…';

  @override
  String get torBannerActive => 'Tor aktiv';

  @override
  String get torBannerError => 'Tor nicht verfügbar';

  @override
  String get torBannerOff => 'Tor aus';

  @override
  String get torEncryption => 'Verschlüsselung';

  @override
  String get torLatency => 'Latenz';

  @override
  String get torContactsHeader => 'Kontakte';

  @override
  String get torScanQrFooter =>
      'Scanne einen QR-Code oder suche einen Namen im Verzeichnis, um einen entfernten Kontakt hinzuzufügen.';

  @override
  String get torScanQrCode => 'QR-Code scannen';

  @override
  String get torMyQrCode => 'Mein QR-Code';

  @override
  String get torInformationHeader => 'Informationen';

  @override
  String get torVersion => 'Version';

  @override
  String get torHowItWorks => 'Wie funktioniert das?';

  @override
  String get torConnecting => 'Verbindung wird hergestellt …';

  @override
  String get torInactiveTitle => 'Tor inaktiv';

  @override
  String get torDataThroughTor => 'Deine Daten laufen über das Tor-Netzwerk';

  @override
  String get torEstablishingCircuit => 'Schaltkreis wird aufgebaut (10-30s)';

  @override
  String get torActivateToProtect =>
      'Aktivieren, um deine Identität zu schützen';

  @override
  String get torHowItWorksTitle => 'Wie Tor deine Daten schützt';

  @override
  String get torEncryptedCircuit => 'Verschlüsselter Schaltkreis';

  @override
  String get torEncryptedCircuitDesc =>
      'Deine Nachrichten laufen über 3 Tor-Relays weltweit.';

  @override
  String get torHiddenIp => 'Versteckte IP';

  @override
  String get torHiddenIpDesc => 'Keine Website kann deine echte Adresse sehen.';

  @override
  String get torMeshPreserved => 'Mesh bleibt erhalten';

  @override
  String get torMeshPreservedDesc =>
      'Bluetooth und lokales WLAN funktionieren weiterhin.';

  @override
  String get torUnderstood => 'Verstanden';

  @override
  String get qrTorNotActive =>
      'Tor ist nicht aktiv. Aktiviere es unter Einstellungen > Tor.';

  @override
  String get qrScanContactCode => 'Scanne den QR-Code eines Kontakts';

  @override
  String get qrCodeFromContactScreen =>
      'Der Code muss vom Tor-Bildschirm deines Kontakts stammen';

  @override
  String get qrScanAnother => 'Weiteren scannen';

  @override
  String get qrChat => 'Chatten';

  @override
  String get qgScanToConnect => 'Zum Verbinden scannen';

  @override
  String get qgCopied => 'Kopiert ✓';

  @override
  String get qgCopyCode => 'Code kopieren';

  @override
  String get qgHowItWorks => 'So funktioniert\'s';

  @override
  String get qgStep1 => 'Zeige diesen QR-Code deinem Kontakt';

  @override
  String get qgStep2 => 'Er scannt ihn von seinem Tor-Bildschirm aus';

  @override
  String get qgStep3 => 'Ihr seid über Tor verbunden';

  @override
  String get shShareTo => 'Teilen mit …';

  @override
  String get shSearchConversation => 'Konversation suchen';

  @override
  String get shNoConversation => 'Keine Konversation';

  @override
  String get shOpenChatFirst =>
      'Öffne zunächst eine Konversation in Droplet, um dort Inhalte teilen zu können.';

  @override
  String get shGroup => 'Gruppe';

  @override
  String get shDiscussion => 'Chat';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente zum Teilen',
      one: '$count Element zum Teilen',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'Karte installiert';

  @override
  String get omClearCacheTitle => 'Cache leeren?';

  @override
  String get omRemoveZoneTitle => 'Diesen Bereich entfernen?';

  @override
  String get omClearCacheMessage =>
      'Die von dir erkundeten Bereiche sind offline nicht mehr verfügbar. Sie werden neu aufgebaut, sobald du sie mit Netzverbindung erneut ansiehst.';

  @override
  String omRemoveZoneMessage(Object name) {
    return '„$name“ wird von diesem Gerät entfernt.';
  }

  @override
  String get omClear => 'Leeren';

  @override
  String get omTitle => 'Karten';

  @override
  String get omReading => 'Wird gelesen …';

  @override
  String get omNoMapsSaved => 'Keine Karte gespeichert';

  @override
  String omSizeOnDevice(Object size) {
    return '$size auf diesem Gerät';
  }

  @override
  String get omBrowseMapHint =>
      'Erkunde die Karte mit Netzverbindung: Die von dir angesehenen Bereiche bleiben offline verfügbar.';

  @override
  String get omOnThisDevice => 'Auf diesem Gerät';

  @override
  String get omZonesFillThemselves =>
      'Angesehene Bereiche füllen sich von selbst, während du die Karte mit Netzverbindung erkundest.';

  @override
  String get omMbtilesExplainer =>
      'Eine .mbtiles-Datei enthält eine ganze, im Voraus vorbereitete Region. Es ist das Standardformat für Offline-Karten: Jedes Kartografie-Tool kann es erzeugen.';

  @override
  String get omImportMap => 'Karte importieren';

  @override
  String get omReadingFile => 'Datei wird gelesen …';

  @override
  String get omMbtilesFromPhone => '.mbtiles-Datei von diesem Telefon';

  @override
  String get omAttributionText =>
      'Die Daten stammen von OpenStreetMap (ODbL-Lizenz), die Kartenkacheln werden von CARTO bereitgestellt. Droplet lädt niemals eine ganze Region im Voraus herunter: Kein kostenloser Dienst erlaubt das. Nur das, was du ansiehst, wird gespeichert.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kacheln',
      one: '$count Kachel',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '${k}k Kacheln';
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
  String get nwTitle => 'Neuigkeiten';

  @override
  String get nwStatusesNetwork24h => 'Netzwerk-Status · 24 Std.';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Netzwerk-Status',
      one: '$count Netzwerk-Status',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'Status veröffentlichen';

  @override
  String get nwNoNewsYet => 'Momentan keine Neuigkeiten';

  @override
  String get nwStatusesAppearHere =>
      'Von Personen in Reichweite veröffentlichte Status erscheinen hier, ohne über das Internet zu laufen.';

  @override
  String get nwRecent => 'Kürzlich';

  @override
  String get nwStatusExpires =>
      'Ein Status verschwindet von selbst 24 Stunden nach seiner Veröffentlichung.';

  @override
  String get nwPhoto => '📷 Foto';

  @override
  String get nwVideo => '🎥 Video';

  @override
  String get nwVoiceMessage => '🎤 Sprachnachricht';

  @override
  String get nwMusic => '🎵 Musik';

  @override
  String get nwStatusFallback => 'Status';

  @override
  String get nwMyStatus => 'Mein Status';

  @override
  String get nwTapToPublish => 'Tippen, um im Netzwerk zu veröffentlichen';

  @override
  String get nwNotSeenYet => 'Noch nicht gesehen';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gesehen von $count',
      one: 'Gesehen von $count',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'Standort nicht verfügbar — überprüfe, ob die Standortdienste aktiviert sind.';

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
    return '$distance von dir entfernt';
  }

  @override
  String get mpTitle => 'Standort';

  @override
  String get mpOffline => 'Offline';

  @override
  String get mpOnlineMap => 'Online-Karte';

  @override
  String get mpMyPosition => 'Mein Standort';

  @override
  String get mpLayers => 'Ebenen';

  @override
  String get mpOfflineToast =>
      'Offline-Karte: Es werden nur bereits gespeicherte Bereiche angezeigt.';

  @override
  String get mpOnlineToast =>
      'Online-Karte: Die von dir angesehenen Bereiche werden für später gespeichert.';

  @override
  String get mpMapLabel => 'Karte';

  @override
  String get mpSatelliteLabel => 'Satellit';

  @override
  String get mpSatelliteMode => 'Satellitenmodus';

  @override
  String get mpMapMode => 'Kartenmodus';

  @override
  String get mpWrite => 'Schreiben';

  @override
  String get mpCenter => 'Zentrieren';

  @override
  String get mpNoOneOnMap => 'Niemand auf der Karte';

  @override
  String get mpPositionsAppearHere =>
      'Standorte erscheinen hier, wenn ein Kontakt sie über den Sicherheitsmodus teilt.';

  @override
  String get mpYou => 'Du';

  @override
  String get mnTitle => 'Mesh-Netzwerk';

  @override
  String get mnPeers => 'Peers';

  @override
  String get mnAvgHops => 'Ø Hops';

  @override
  String get mnSignal => 'Signal';

  @override
  String get mnStrong => 'Stark';

  @override
  String get mnMedium => 'Mittel';

  @override
  String get mnSearchingPeers => 'Suche nach Peers in Reichweite …';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Peers verbunden',
      one: '$count Peer verbunden',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'Momentan kein Peer verbunden';

  @override
  String get mnGetCloserHint =>
      'Nähere dich einem anderen Gerät mit installiertem Droplet — die Erkennung erfolgt automatisch, ohne Einrichtung.';

  @override
  String get mnConnectedPeersHeader => 'Verbundene Peers';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Hops',
      one: '$count Hop',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'Bluetooth';

  @override
  String get mnWifiLocal => 'Lokales WLAN';

  @override
  String get mnP2pNative => 'Natives P2P';

  @override
  String get mnActiveGateway => 'Aktives Gateway';

  @override
  String get mnPath => 'Pfad';

  @override
  String get mnTransport => 'Übertragung';

  @override
  String get mnBattery => 'Akku';

  @override
  String get mnScore => 'Punktzahl';

  @override
  String get mnReconnecting => 'Wird neu verbunden';

  @override
  String get cnBronze => 'Bronze';

  @override
  String get cnSilver => 'Silber';

  @override
  String get cnGold => 'Gold';

  @override
  String get cnDiamond => 'Diamant';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Punkte',
      one: '$count Punkt',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return 'Noch $points bis zur Stufe $tier';
  }

  @override
  String get cnRelayedMessages => 'Für andere weitergeleitete Nachrichten';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n Pkt.';
  }

  @override
  String get cnGatewayMinutes => 'Minuten im Relais-Modus (Gateway)';

  @override
  String get cnExplanation =>
      'Jede Nachricht, die dein Gerät für andere weiterleitet, und jede Minute, die es als Relais verfügbar bleibt, hilft dem Mesh-Netzwerk, mehr Menschen und größere Entfernungen zu erreichen. Dieses Abzeichen hat keine Auswirkung auf die App — es ist nur eine Anerkennung deines Beitrags.';

  @override
  String get nmTitle => 'Neue Nachricht';

  @override
  String get nmNewGroup => 'Neue Gruppe';

  @override
  String get nmScanCode => 'Code scannen';

  @override
  String get nmVerifyContactIdentity =>
      'Die Identität eines Kontakts überprüfen';

  @override
  String get nmNoOneInRange => 'Niemand in Reichweite';

  @override
  String get nmNoResult => 'Keine Ergebnisse';

  @override
  String get nmPeopleWillAppearHere =>
      'Personen, die dein Gerät erkennt, erscheinen hier.';

  @override
  String get nmInRange => 'In Reichweite';

  @override
  String get nmDirectConnection => 'Direkte Verbindung';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Über $count Relais',
      one: 'Über $count Relais',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'Datei zu groß (max. 50 MB)';

  @override
  String get chCannotReadMedia => 'Diese Mediendatei kann nicht gelesen werden';

  @override
  String get chLocationDenied =>
      'Standortzugriff verweigert – aktiviere ihn in den Telefoneinstellungen, um deinen Standort zu teilen.';

  @override
  String get chGettingPosition => 'Standort wird ermittelt …';

  @override
  String get chPositionUnavailable =>
      'Standort nicht verfügbar – versuche es im Freien erneut.';

  @override
  String get chMicPermissionDenied => 'Mikrofonberechtigung verweigert';

  @override
  String get chCannotStartRecording => 'Aufnahme kann nicht gestartet werden';

  @override
  String get chVoiceSendFailed => 'Sprachnachricht kann nicht gesendet werden';

  @override
  String get chFileSendFailed => 'Datei kann nicht gesendet werden';

  @override
  String get chAudioNotFullyReceived =>
      'Audio noch nicht vollständig empfangen';

  @override
  String get chVoiceUnreadable =>
      'Diese Sprachnachricht kann nicht abgespielt werden – sie ist möglicherweise unvollständig angekommen.';

  @override
  String get chFileNotFullyReceived => 'Datei noch nicht vollständig empfangen';

  @override
  String get chSaveFailed => 'Speichern nicht möglich';

  @override
  String chSavedIn(Object folder) {
    return 'In $folder gespeichert';
  }

  @override
  String get chMessageCopied => 'Nachricht kopiert';

  @override
  String get chCallImpossibleRelay =>
      'Sprachanruf nicht möglich: Dieser Peer ist nur über Relais oder Bluetooth erreichbar, zu langsam für Sprache. Komme näher, um zu WLAN zu wechseln.';

  @override
  String chUrlCopied(Object url) {
    return 'URL kopiert: $url';
  }

  @override
  String get chEditMessageTitle => 'Nachricht bearbeiten';

  @override
  String get chMessageHint => 'Nachricht';

  @override
  String get chNeverMet => 'Noch nie getroffen';

  @override
  String get chSeenJustNow => 'Gerade eben gesehen';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Minuten gesehen',
      one: 'Vor $count Minute gesehen',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Stunden gesehen',
      one: 'Vor $count Stunde gesehen',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'Gestern gesehen';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vor $count Tagen gesehen',
      one: 'Vor $count Tag gesehen',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'Außer Reichweite';

  @override
  String get chCloseSearchTooltip => 'Suche schließen';

  @override
  String get chNetworkDetailsSemantics => 'Droplet-Netzwerk, Details anzeigen';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '$count Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'tippt gerade …';

  @override
  String get chBroadcastChannel => 'Broadcast-Kanal';

  @override
  String get chNearby => 'In der Nähe';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Erreichbar über $count Relais',
      one: 'Erreichbar über $count Relais',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'Wird neu verbunden …';

  @override
  String get chSearchInConversation => 'In der Konversation suchen';

  @override
  String get chVoiceCall => 'Sprachanruf';

  @override
  String get chVideoCall => 'Videoanruf';

  @override
  String get chCallImpossibleBtRelay =>
      'Anruf nicht möglich: Bluetooth- oder Relaisverbindung';

  @override
  String get chGroupInfoTooltip => 'Gruppeninfo';

  @override
  String get chNoneFound => 'Keine';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'Älteres Ergebnis';

  @override
  String get chNewerResult => 'Neueres Ergebnis';

  @override
  String get chLoadingOlderMessages => 'Frühere Nachrichten werden geladen …';

  @override
  String get chToday => 'Heute';

  @override
  String get chYesterday => 'Gestern';

  @override
  String get chMonday => 'Montag';

  @override
  String get chTuesday => 'Dienstag';

  @override
  String get chWednesday => 'Mittwoch';

  @override
  String get chThursday => 'Donnerstag';

  @override
  String get chFriday => 'Freitag';

  @override
  String get chSaturday => 'Samstag';

  @override
  String get chSunday => 'Sonntag';

  @override
  String get chSayHello => 'Sag Hallo 👋';

  @override
  String get chBroadcastEmptyBody =>
      'Nachrichten ohne Empfänger erscheinen hier.';

  @override
  String get chP2pRelayedBody =>
      'Eure Nachrichten werden Peer-to-Peer weitergeleitet, ohne Internet.';

  @override
  String get chReply => 'Antworten';

  @override
  String get chReplyInThread => 'Im Thread antworten';

  @override
  String get chCopy => 'Kopieren';

  @override
  String get chAccessibilityMe => 'Ich';

  @override
  String get chPhotoLabel => 'Foto';

  @override
  String get chVideoLabel => 'Video';

  @override
  String get chVoiceMessageLabel => 'Sprachnachricht';

  @override
  String chFileLabel(Object name) {
    return 'Datei $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'Sticker $name';
  }

  @override
  String get chSendingStatus => 'wird gesendet';

  @override
  String get chPendingStatus => 'ausstehend';

  @override
  String get chFailedStatus => 'Senden fehlgeschlagen';

  @override
  String get chReadStatus => 'gelesen';

  @override
  String get chDeliveredStatus => 'zugestellt';

  @override
  String get chSentStatus => 'gesendet';

  @override
  String get chForwarded => 'Weitergeleitet';

  @override
  String get chRetrySendLabel => 'Senden erneut versuchen';

  @override
  String get chTransmissionDetailsLabel => 'Übertragungsdetails';

  @override
  String get chEditedBadge => 'bearbeitet';

  @override
  String get chFileWord => 'Datei';

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
  String get chVideoReceiving => 'Video wird empfangen';

  @override
  String get chPreparingVideo => 'Video wird vorbereitet…';

  @override
  String get nmContacts => 'Kontakte';

  @override
  String get nmFindByPseudo => 'Nach Name suchen';

  @override
  String get nmViaInternet => 'Über das Internet';

  @override
  String get nmOutOfRange => 'Außer Reichweite';

  @override
  String get chatsInvitePerson => 'Jemanden einladen';

  @override
  String get ivTitle => 'Lade deine Liebsten ein';

  @override
  String get ivSubtitle =>
      'Droplet ist besser, wenn die Wichtigen dabei sind – auch ohne Netz.';

  @override
  String get ivByNumber => 'Per Telefonnummer';

  @override
  String get ivNumberHint => 'Nummer mit Vorwahl (+49…)';

  @override
  String get ivContacts => 'Kontakte';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'Per Link';

  @override
  String get ivCopy => 'Kopieren';

  @override
  String get ivShare => 'Teilen';

  @override
  String get ivCopied => 'Link kopiert';

  @override
  String get ivByQr => 'Per QR-Code';

  @override
  String get ivQrHint => 'Die Person scannt ihn direkt bei dir.';

  @override
  String get ivScan => 'Code scannen';

  @override
  String get ivPrivacy =>
      'Link und Code enthalten nur deine öffentliche ID und deinen Schlüssel. Keine Nummer wird an Droplet gesendet.';

  @override
  String get evTitle => 'Video bearbeiten';

  @override
  String evSplit(int n) {
    return 'In $n Status aufteilen';
  }

  @override
  String evSplitHint(int s) {
    return 'Jeder Teil dauert höchstens $s s';
  }

  @override
  String evPublished(int n) {
    return '$n Status veröffentlicht';
  }

  @override
  String get svReply => 'Antworten';

  @override
  String get svStatusLabel => 'Status';

  @override
  String svSeenBy(int n) {
    return 'Gesehen von $n';
  }

  @override
  String get clMissedVoice => 'Verpasster Sprachanruf';

  @override
  String get clMissedVideo => 'Verpasster Videoanruf';

  @override
  String get clCallBack => 'Zurückrufen';

  @override
  String get stoTitle => 'Speicher';

  @override
  String get stoSubtitle => 'Fotos, Videos und Dateien';

  @override
  String stoUsed(String taille) {
    return '$taille belegt';
  }

  @override
  String get stoPhotos => 'Fotos';

  @override
  String get stoVideos => 'Videos';

  @override
  String get stoAudio => 'Sprache & Audio';

  @override
  String get stoDocuments => 'Dokumente';

  @override
  String get stoOther => 'Sonstiges (Status…)';

  @override
  String get stoByChat => 'Nach Chat';

  @override
  String get stoEmpty => 'Keine Dateien auf diesem Telefon';

  @override
  String stoDelete(int n) {
    return 'Löschen ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'Diese Dateien und ihre Nachrichten werden von diesem Telefon gelöscht.';

  @override
  String get tabSelectChat => 'Wähle einen Chat';

  @override
  String get clConnecting => 'Verbindung wird hergestellt…';

  @override
  String chUnreadMessages(int n) {
    return '$n ungelesene Nachricht(en)';
  }

  @override
  String get csMessagesSection => 'Nachrichten';

  @override
  String chGroupTyping(String noms) {
    return '$noms schreibt…';
  }

  @override
  String get tsReadBy => 'Gelesen von';

  @override
  String get tsDeliveredTo => 'Zugestellt an';

  @override
  String get tsWaitingFor => 'Ausstehend';

  @override
  String get chSelect => 'Auswählen';

  @override
  String get chForward => 'Weiterleiten';

  @override
  String get chForwardTo => 'Weiterleiten an…';

  @override
  String chSelectedCount(int n) {
    return '$n ausgewählt';
  }

  @override
  String get chForwarded1 => 'Nachricht weitergeleitet';

  @override
  String get apCaptionHint => 'Bildunterschrift hinzufügen…';

  @override
  String get apValidateCrop => 'Zuschneiden';

  @override
  String get chMediaReceiving => 'Wird empfangen';

  @override
  String get chStickersTooltip => 'Sticker';

  @override
  String get chAttachTooltip => 'Anhängen';

  @override
  String get chDeleteRecordingTooltip => 'Aufnahme löschen';

  @override
  String get chSlideToCancel => 'Zum Abbrechen wischen';

  @override
  String chReplyingTo(Object pseudo) {
    return 'Antwort an $pseudo';
  }

  @override
  String get chEffectBoom => 'Boom';

  @override
  String get chEffectLoud => 'Laut';

  @override
  String get chEffectGentle => 'Sanft';

  @override
  String get chEffectInvisibleInk => 'Unsichtbare Tinte';

  @override
  String get chEffectConfetti => 'Konfetti';

  @override
  String get chEffectFireworks => 'Feuerwerk';

  @override
  String get chEffectHearts => 'Herzen';

  @override
  String get chEffectSheetTitle => 'Nachrichteneffekt';

  @override
  String get chEffectSheetSubtitle =>
      'Wird einmal abgespielt, bei dir und bei deinem Gesprächspartner';

  @override
  String get chOnBubble => 'Auf der Sprechblase';

  @override
  String get chFullscreen => 'Vollbild';

  @override
  String get chTapToReveal => 'Zum Aufdecken tippen';

  @override
  String get chThreadTitle => 'Thread';

  @override
  String get chReplyHint => 'Antwort …';

  @override
  String get chCollapse => 'Einklappen';

  @override
  String get chSeeMore => 'Mehr anzeigen';

  @override
  String get chMessageOptionsSemantics => 'Nachrichtenoptionen';

  @override
  String get chLoveReactionSemantics => 'Ich liebe es';

  @override
  String get chBroadcastMesh => 'Mesh-Broadcast';

  @override
  String get chGroupFallback => 'Gruppe';

  @override
  String get ciSetupBiometrics =>
      'Richte einen Fingerabdruck oder Face ID in den Geräteeinstellungen ein.';

  @override
  String get ciEnableLockReason => 'Sperre für diese Konversation aktivieren';

  @override
  String get ciInfoTitle => 'Info';

  @override
  String get ciViewConversation => 'Konversation anzeigen';

  @override
  String get ciGatewayOnline => 'Gateway · online';

  @override
  String get ciOnline => 'Online';

  @override
  String get ciOffline => 'Offline';

  @override
  String get ciMessages => 'Nachrichten';

  @override
  String get ciMedia => 'Medien';

  @override
  String get ciStart => 'Beginn';

  @override
  String ciPhotosCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fotos ($count)',
      one: 'Foto ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciVoiceNotesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sprachnotizen ($count)',
      one: 'Sprachnotiz ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dateien ($count)',
      one: 'Datei ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet => 'Noch keine Medien geteilt.';

  @override
  String get ciSecurityCode => 'Sicherheitscode';

  @override
  String get ciVerified => 'Verifiziert';

  @override
  String get ciKeyChanged => 'Der Schlüssel hat sich geändert';

  @override
  String get ciNotVerified => 'Nicht verifiziert';

  @override
  String get ciConversationLock => 'Konversationssperre';

  @override
  String get ciLockEnabled =>
      'Aktiviert – Fingerabdruck zum Öffnen erforderlich';

  @override
  String get ciDisabled => 'Deaktiviert';

  @override
  String get ciEphemeralMessages => 'Verschwindende Nachrichten';

  @override
  String get ci30Seconds => '30 Sekunden';

  @override
  String get ci5Minutes => '5 Minuten';

  @override
  String get ci1Hour => '1 Stunde';

  @override
  String get ci24Hours => '24 Stunden';

  @override
  String get ciDurationBeforeDisappear => 'Zeit bis zum Verschwinden';

  @override
  String get ciBlockContactTitle => 'Diesen Kontakt blockieren?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo kann dir keine Nachrichten mehr senden. Du kannst die Blockierung jederzeit aufheben.';
  }

  @override
  String get ciBlock => 'Blockieren';

  @override
  String get ciUnblock => 'Blockierung aufheben';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo wurde blockiert';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return 'Die Blockierung von $pseudo wurde aufgehoben';
  }

  @override
  String get ciReportContactTitle => 'Diesen Kontakt melden?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'Eine anonyme Meldung wird an Droplet gesendet: eine technische Kennung und der unten gewählte Grund, nichts weiter. Keine Nachricht, kein Gespräch mit $pseudo wird jemals übertragen.';
  }

  @override
  String get ciReport => 'Melden';

  @override
  String get ciReportSent => 'Meldung gesendet. Danke.';

  @override
  String get ciReportFailed =>
      'Die Meldung konnte nicht gesendet werden — versuchen Sie es später erneut.';

  @override
  String get ciReportReasonSpam => 'Spam';

  @override
  String get ciReportReasonHarassment => 'Belästigung';

  @override
  String get ciReportReasonIllegal => 'Illegale Inhalte';

  @override
  String get ciReportReasonOther => 'Sonstiges';

  @override
  String mcReactWith(Object emoji) {
    return 'Mit $emoji reagieren';
  }

  @override
  String get nsMeshActive => 'Mesh aktiv';

  @override
  String get nsNoDeviceInRange => 'Kein Gerät in Reichweite';

  @override
  String get nsMessagesCirculate =>
      'Deine Nachrichten wandern von Gerät zu Gerät, ohne über das Internet zu laufen.';

  @override
  String get nsGetCloser =>
      'Nähere dich einem anderen Droplet-Gerät. Deine Nachrichten werden aufbewahrt und automatisch gesendet.';

  @override
  String get nsDevicesInRange => 'Geräte in Reichweite';

  @override
  String get nsReconnectingTitle => 'Wird neu verbunden';

  @override
  String get nsLinkMomentarilyLost =>
      'Verbindung vorübergehend unterbrochen, aber noch nicht aufgegeben.';

  @override
  String get nsRelaysAvailable => 'Verfügbare Relais';

  @override
  String get nsNoRelayAvailable =>
      'Im Moment kann kein Gerät deine Nachrichten weiterleiten.';

  @override
  String get nsViaBluetooth => 'Über Bluetooth';

  @override
  String get nsViaLocalWifi => 'Über lokales WLAN';

  @override
  String get nsWifiCarriesMore =>
      'WLAN überträgt Dateien und Sprache; Bluetooth überträgt nur Text.';

  @override
  String get scInvalidQrCode => 'Ungültiger QR-Code';

  @override
  String get scWrongCode =>
      'Das ist nicht der richtige Code – der Schlüssel stimmt nicht überein';

  @override
  String get scCodeVerified => 'Code verifiziert';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'Verifiziert – der Schlüssel von $pseudo stimmt mit diesem Code überein.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'Der Schlüssel von $pseudo hat sich seit der letzten Überprüfung geändert.';
  }

  @override
  String get scNotVerifiedYet => 'Noch nicht verifiziert.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'Vergleiche diesen Code mit dem auf dem Gerät von $pseudo angezeigten, oder scanne direkt dessen QR-Code zur automatischen Überprüfung.';
  }

  @override
  String get scContactKeyUnknown =>
      'Der Schlüssel des Kontakts ist noch nicht bekannt – verbinde dich erneut mit diesem Peer im Mesh.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'Code von $pseudo scannen';
  }

  @override
  String get tsNotDelivered => 'Nicht zugestellt';

  @override
  String get tsRead => 'Gelesen';

  @override
  String get tsDelivered => 'Zugestellt';

  @override
  String get tsSendingInProgress => 'Wird gesendet';

  @override
  String get tsWaitingForRelay => 'Warten auf ein Relais';

  @override
  String get tsSent => 'Gesendet';

  @override
  String tsSecondsSingular(Object value) {
    return '$value Sekunde';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value Sekunden';
  }

  @override
  String tsMinutes(Object n) {
    return '$n Min.';
  }

  @override
  String tsHours(Object n) {
    return '$n Std.';
  }

  @override
  String tsDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '$count Tag',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'Übertragung';

  @override
  String get tsStatus => 'Status';

  @override
  String get tsDelayUntilRead => 'Zeit bis zum Lesen';

  @override
  String get tsRoute => 'Route';

  @override
  String get tsRouteDetail =>
      'Die Geräte, die diese Nachricht weitergeleitet haben, in der Reihenfolge.';

  @override
  String get tsPath => 'Pfad';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Über $count Geräte geleitet',
      one: 'Über $count Gerät geleitet',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'Direkt empfangen';

  @override
  String get tsIntermediateDevicesDetail =>
      'Zwischengeschaltete Geräte haben diese Nachricht an dich weitergeleitet.';

  @override
  String get tsUnknown => 'Unbekannt';

  @override
  String get tsSentRouteNotReturned =>
      'Die Route einer gesendeten Nachricht wird nicht an den Absender zurückgemeldet.';

  @override
  String get tsNetwork => 'Netzwerk';

  @override
  String get tsMeshDroplet => 'Droplet-Mesh';

  @override
  String get tsNoServerNoOperator => 'Kein Server, kein Netzbetreiber.';

  @override
  String get qsScanSecurityCode => 'Sicherheitscode scannen';

  @override
  String get qsCodeDetected => 'Code erkannt';

  @override
  String get qsFrameQrCode =>
      'Halte den QR-Code, der auf dem Gerät deines Kontakts angezeigt wird, ins Bild';

  @override
  String get rmRecentVideo => 'Kürzliches Video';

  @override
  String get rmRecentPhoto => 'Kürzliches Foto';

  @override
  String get rmSeeAllPhotos => 'Alle Fotos anzeigen';

  @override
  String get rmSeeAll => 'Alle anzeigen';

  @override
  String get aicOriginal => 'Original';

  @override
  String get aicAzure => 'Azurblau';

  @override
  String get aicNeon => 'Neon';

  @override
  String get aicPaper => 'Papier';

  @override
  String get aicLagoon => 'Lagune';

  @override
  String get aicAmethyst => 'Amethyst';

  @override
  String get aicGold => 'Gold';

  @override
  String get aicTide => 'Gezeiten';

  @override
  String get aicDawn => 'Morgenröte';

  @override
  String get aicGlass => 'Glas';

  @override
  String get aicConstellation => 'Konstellation';

  @override
  String get aicPrism => 'Prisma';

  @override
  String get aicEmerald => 'Smaragd';

  @override
  String get aicChangeIconTitle => 'Symbol ändern?';

  @override
  String aicChangeIconMessage(Object name) {
    return 'Das Symbol „$name“ ersetzt das auf deinem Startbildschirm. Manche Launcher brauchen ein paar Sekunden, um es anzuzeigen, oder verlangen eine Rückkehr zum Startbildschirm.';
  }

  @override
  String get aicApply => 'Anwenden';

  @override
  String aicIconApplied(Object name) {
    return 'Symbol „$name“ angewendet';
  }

  @override
  String get aicChangeIconImpossible =>
      'Symboländerung auf diesem Gerät nicht möglich';

  @override
  String get aicTitle => 'Symbol';

  @override
  String get aicCurrentOnHomeScreen =>
      'Das, was auf deinem Startbildschirm erscheint';

  @override
  String get aicUnavailablePlatform => 'Auf dieser Plattform nicht verfügbar';

  @override
  String get aicAndroidExplanation =>
      'Android legt das App-Symbol bei der Installation fest. Droplet umgeht dies, indem es mehrere Einstiegspunkte deklariert, einen pro Symbol, und nur einen aktiv lässt. Dein Launcher benötigt eventuell ein paar Sekunden, um es zu bemerken.';

  @override
  String get aicAndroidOnly =>
      'Das Ändern des Symbols ist nur unter Android verfügbar.';

  @override
  String get beWeak => 'Schwach';

  @override
  String get beOkay => 'Ausreichend';

  @override
  String get beStrong => 'Stark';

  @override
  String get bePasswordTooShort =>
      'Das Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get bePasswordsDontMatch =>
      'Die beiden Passwörter stimmen nicht überein';

  @override
  String get beBackupSubject => 'Droplet-Backup';

  @override
  String get beBackupShareText =>
      'Verschlüsseltes Backup meiner Droplet-Identität – bitte sicher aufbewahren.';

  @override
  String get beBackupCreated => 'Backup erstellt';

  @override
  String get beBackupFailed => 'Backup fehlgeschlagen';

  @override
  String get beBackupMyIdentity => 'Meine Identität sichern';

  @override
  String get beWarningBody =>
      'Wer diese Datei und das Passwort besitzt, kann sich als du ausgeben. Bewahre sie sicher auf (sende sie niemals an jemand anderen als dich selbst) und wähle ein Passwort, das nur du kennst.';

  @override
  String get bePasswordProtects =>
      'Dieses Passwort schützt dein Backup. Es wird niemals gespeichert: Ohne es wird die Datei dauerhaft unbrauchbar.';

  @override
  String get bePassword => 'Passwort';

  @override
  String get beConfirmPassword => 'Passwort bestätigen';

  @override
  String get beIncludeMessageHistory => 'Nachrichtenverlauf einschließen';

  @override
  String get beOtherwiseOnlyIdentity =>
      'Andernfalls werden nur die Identität, Kontakte und Gruppen gesichert';

  @override
  String get beCreateAndShare => 'Backup erstellen und teilen';

  @override
  String get jsErrorJournalTitle => 'Fehlerprotokoll';

  @override
  String get jsNoErrorsRecorded =>
      'Keine Fehler protokolliert. Das ist der Normalzustand.';

  @override
  String get jsLinesStayOnDevice =>
      'Diese Zeilen verbleiben auf diesem Gerät: Droplet hat keinen Server, an den sie gesendet werden könnten. Falls du die App testest, sende sie bitte — ohne sie existiert der Fehler für niemanden.';

  @override
  String get jsErase => 'Löschen';

  @override
  String get jsShareSubject => 'Droplet – Fehlerprotokoll';

  @override
  String get jsShareText =>
      'Droplet-Fehlerprotokoll. Diese Datei enthält weder Nachrichten noch Kontakte noch Schlüssel.';

  @override
  String get jsShareUnavailable => 'Teilen nicht verfügbar – Protokoll kopiert';

  @override
  String get clOutgoingCall => 'Anruf läuft …';

  @override
  String get clIncomingCall => 'Eingehender Anruf …';

  @override
  String get clCallImpossible => 'Anruf nicht möglich';

  @override
  String get clCallEnded => 'Anruf beendet';

  @override
  String clCallWith(Object pseudo) {
    return 'Anruf mit $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'Ende-zu-Ende-verschlüsselt';

  @override
  String clCallStatusSemantics(Object status) {
    return 'Anrufstatus: $status';
  }

  @override
  String get clEnableMic => 'Mikrofon einschalten';

  @override
  String get clMuteMic => 'Mikrofon stummschalten';

  @override
  String get clDisableSpeaker => 'Lautsprecher ausschalten';

  @override
  String get clEnableSpeaker => 'Lautsprecher einschalten';

  @override
  String get clDisableCamera => 'Kamera ausschalten';

  @override
  String get clEnableCamera => 'Kamera einschalten';

  @override
  String get clHangUp => 'Auflegen';

  @override
  String get clIncomingVideoCall => 'Eingehender Videoanruf';

  @override
  String get clSwitchCamera => 'Kamera wechseln';

  @override
  String get gcGroupCall => 'Gruppenanruf';

  @override
  String get gcConnecting => 'Verbindung wird hergestellt …';

  @override
  String get gcOnline => 'Online';

  @override
  String get gcFailed => 'Fehlgeschlagen';

  @override
  String get gcDisconnected => 'Getrennt';

  @override
  String get gcReturnToCall => 'Zum Anruf zurück';

  @override
  String get gcMinimize => 'Minimieren';

  @override
  String get gcVoiceOnly => 'Nur Sprache';

  @override
  String gcReactWith(String emoji) {
    return 'Mit $emoji reagieren';
  }

  @override
  String get gcSpeakingNow => 'Spricht gerade';

  @override
  String get gcMicOff => 'Mikrofon aus';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer · nur Sprache',
      one: '$count Teilnehmer · nur Sprache',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'Nachrichten';

  @override
  String get ntfChannelMessagesDesc => 'Neue Nachrichten und Mesh-Status';

  @override
  String get ntfChannelCallsName => 'Anrufe';

  @override
  String get ntfChannelCallsDesc => 'Eingehende und verpasste Anrufe';

  @override
  String get ntfChannelMeshName => 'Mesh & Notfall';

  @override
  String get ntfChannelMeshDesc =>
      'Aktiver Mesh-Dienst, Status und Notfallnachrichten';

  @override
  String get ntfReply => 'Antworten';

  @override
  String get ntfYourReply => 'Deine Antwort';

  @override
  String get ntfMarkAsRead => 'Als gelesen markieren';

  @override
  String get ntfIncomingCall => 'Eingehender Anruf';

  @override
  String get ntfAnswer => 'Annehmen';

  @override
  String get ntfDecline => 'Ablehnen';

  @override
  String get ntfMissedCall => 'Verpasster Anruf';

  @override
  String get ntfSendFailedTitle => 'Senden fehlgeschlagen';

  @override
  String get ntfSendFailedBody =>
      'Eine Nachricht konnte nicht gesendet werden – ein neuer Versuch erfolgt, sobald ein Peer in Reichweite ist.';

  @override
  String get ntfNewStatusTitle => 'Neuer Status';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo hat einen Status veröffentlicht';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ $pseudo gefällt dein Status';
  }

  @override
  String get ntfTapToView => 'Zum Anzeigen tippen';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo hat auf deinen Status geantwortet';
  }

  @override
  String get ntfEmergencyTitle => 'Notfallnachricht';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo hat „Mir geht es gut“ gesendet';
  }

  @override
  String get mnAccept => 'Annehmen';

  @override
  String get mnMeshVoiceCall => 'Mesh-Sprachanruf';

  @override
  String get mnGroupCallIncoming => 'Eingehender Gruppenanruf';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo lädt dich ein';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gruppenanruf · $count weitere Teilnehmer',
      one: 'Gruppenanruf · $count weiterer Teilnehmer',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'Wer kann diesen Status sehen?';

  @override
  String get asAllContacts => 'Alle meine Kontakte';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kontakte',
      one: '$count Kontakt',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => 'Außer …';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgeschlossen',
      one: '$count ausgeschlossen',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'Kontakte ausschließen';

  @override
  String get asOnlyOption => 'Nur …';

  @override
  String get asShareWithSpecific => 'Mit bestimmten Kontakten teilen';

  @override
  String get asNoContactsAvailable => 'Keine Kontakte verfügbar';

  @override
  String get asConfirm => 'Bestätigen';

  @override
  String get apYourPhoto => 'Dein Foto';

  @override
  String get apNoPhotoAccessible =>
      'Auf diesem Gerät ist kein Foto zugänglich.';

  @override
  String get apBrowseFiles => 'Dateien durchsuchen';

  @override
  String get apRecentPhoto => 'Kürzliches Foto';

  @override
  String get bgSkip => 'Überspringen';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'Schritt $rang von $total.';
  }

  @override
  String get csGuideNetworkTitle => 'Niemand in der Nähe? Das ist normal';

  @override
  String get csGuideNetworkText =>
      'Droplet läuft über keinen Server: Es spricht mit Telefonen in Reichweite. Hier siehst du, wer erreichbar ist und über welche Funktechnik. Null Peers heißt nicht, dass es kaputt ist – nur, dass noch niemand da ist.';

  @override
  String get csGuideWriteTitle => 'Schreibe auch ohne jemanden in der Nähe';

  @override
  String get csGuideWriteText =>
      'Eine jetzt geschriebene Nachricht wartet auf deinem Telefon und wird gesendet, sobald ein Gerät in Reichweite kommt — auf der Straße, im Taxi. Sie ist nicht verloren, sie wartet.';

  @override
  String get csGuideBackupTitle => 'Sichere deine Identität';

  @override
  String get csGuideBackupText =>
      'Ohne Server kann dir niemand dein Konto zurückgeben. Exportiere deine Identität in den Einstellungen: ohne dieses Backup nimmt ein verlorenes Telefon alles mit.';

  @override
  String get csShowLockedChatsReason => 'Gesperrte Chats anzeigen';

  @override
  String get cvlNoBiometricsConfigured =>
      'Auf diesem Gerät ist kein Fingerabdruck eingerichtet';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'Unterhaltung mit $pseudo entsperren';
  }

  @override
  String get cvlAuthFailed => 'Authentifizierung fehlgeschlagen';

  @override
  String get cvlAuthError => 'Authentifizierungsfehler';

  @override
  String get cvlConversationLocked => 'Gesperrte Unterhaltung';

  @override
  String get cvlUnlock => 'Entsperren';

  @override
  String get dcAddText => 'Text hinzufügen';

  @override
  String get dcYourTextHint => 'Dein Text …';

  @override
  String get pbDropletProBadge => 'Droplet-Pro-Abzeichen';

  @override
  String get rpReact => 'Reagieren';

  @override
  String get rpSaveToPhone => 'Auf dem Telefon speichern';

  @override
  String get chViaTor => 'Über Tor';

  @override
  String get chTorInactive => 'Tor inaktiv';

  @override
  String get chViaInternet => 'Über das Internet';

  @override
  String get chReachedViaTorSemantic => 'Kontakt über Tor erreicht';

  @override
  String get nsTorConnectedTitle => 'Über Tor verbunden';

  @override
  String get nsTorInactiveTitle => 'Tor deaktiviert';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'Deine Nachrichten reisen über das Tor-Netzwerk und warten in einem verschlüsselten Postfach, bis $pseudo sich damit verbindet.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'Aktiviere Tor in den Einstellungen, um $pseudo schreiben zu können – ohne Tor bleiben deine Nachrichten auf diesem Gerät liegen.';
  }

  @override
  String get nsTorMailboxTitle => 'Verschlüsseltes Postfach';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'Weder du noch Droplet können den Inhalt lesen – nur $pseudo hat den Schlüssel.';
  }

  @override
  String get nsOpenTorSettings => 'Tor aktivieren';

  @override
  String get qrInvalidCode => 'Dieser QR-Code ist kein Droplet-Code.';

  @override
  String get qrPeerAdded => 'Kontakt hinzugefügt';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'Du kannst jetzt mit $pseudo chatten';
  }

  @override
  String get clViaInternet => 'Über das Internet';

  @override
  String get tsPathTorDetail =>
      'Diese Nachricht läuft nicht über Geräte in deiner Umgebung: Sie durchläuft ein verschlüsseltes Postfach im Tor-Netzwerk, auf das nur ihr beide Zugriff habt.';

  @override
  String get tsNetworkTorDetail =>
      'Um diesen Kontakt aus der Ferne zu erreichen, ist ein Relais-Server nötig – anders als beim lokalen Mesh kommt Droplet hier nicht ohne aus.';

  @override
  String get torSearchDirectory => 'Verzeichnis durchsuchen';

  @override
  String get dvTitle => 'Suchen';

  @override
  String get dvClose => 'Schließen';

  @override
  String get dvSearchHint => 'Nach einem Namen suchen …';

  @override
  String get dvEnableTorToSearch =>
      'Aktiviere Tor in den Einstellungen, um im Verzeichnis zu suchen.';

  @override
  String get dvSearching => 'Suche läuft …';

  @override
  String get dvNoResults => 'Keine Ergebnisse';

  @override
  String get dvNoUserFound => 'Für diese Suche wurde kein Nutzer gefunden.';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '$count Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'Senden';

  @override
  String get aiNewConversation => 'Neue Unterhaltung';

  @override
  String get aiMessageHint => 'Nachricht';

  @override
  String get aiCopied => 'Kopiert';

  @override
  String get aiAskQuestion => 'Stelle eine Frage';

  @override
  String get aiRunsLocally =>
      'Dieser Assistent läuft vollständig auf deinem Gerät – es wird nie etwas über das Internet gesendet.';

  @override
  String get aiMemorySaved => 'Das merke ich mir.';

  @override
  String get aiMemoryForgotten =>
      'Ich habe vergessen, worum du mich gebeten hast.';

  @override
  String get aiMemoryTitle => 'Assistent-Gedächtnis';

  @override
  String get aiMemoryEmpty =>
      'Noch nichts gespeichert. Sag „merk dir, dass…“, um etwas festzuhalten.';

  @override
  String get aiMemoryForget => 'Alles vergessen';

  @override
  String get aiExpertHint =>
      'Ich kenne Droplet in- und auswendig: das Mesh, Tor, Anrufe, Datenschutz.';

  @override
  String get chAskAssistant => 'Assistent fragen';

  @override
  String chAskAssistantInvite(Object name) {
    return 'Hilf mir, $name zu antworten.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'Assistent wird vorbereitet … $percentage %';
  }

  @override
  String get aiOneTimeDownload =>
      'Nur einmal – danach bleibt er auf deinem Gerät, ohne weiteren Download.';

  @override
  String get aiGenericError => 'Entschuldigung, es ist ein Fehler aufgetreten.';

  @override
  String get aiNotAvailableYet =>
      'Der Assistent ist in dieser Version von Droplet noch nicht verfügbar.';

  @override
  String aiDownloadFailed(Object error) {
    return 'Download fehlgeschlagen: $error';
  }

  @override
  String get ntfSomeoneCalling => 'Jemand versucht, dich zu erreichen';

  @override
  String get ntfNewMessageWake =>
      'Neue Nachricht — öffne Droplet, um sie zu lesen';

  @override
  String get chNearbyAndInternet => 'In der Nähe · Internet';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Relais · Internet',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'Warte auf Internet';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in der Nähe · Internet',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in der Nähe · kein Internet',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'Niemand in der Nähe · Internet';

  @override
  String get clPathMesh => 'Mesh · WLAN direkt';

  @override
  String get clPathInternetDirect => 'Internet · direkt';

  @override
  String get clPathInternetRelay => 'Internet · sicheres Relais';

  @override
  String get clReconnecting => 'Verbindung wird wiederhergestellt…';

  @override
  String get clLabelSpeaker => 'Lautsprecher';

  @override
  String get clLabelCamera => 'Kamera';

  @override
  String get clLabelMic => 'Mikro';

  @override
  String get clLabelFlip => 'Wechseln';

  @override
  String get clEncryptedShort => 'Ende-zu-Ende-verschlüsselt';

  @override
  String clQualitySemantics(int bars) {
    return 'Anrufqualität: $bars von 3';
  }

  @override
  String get beOnlineTitle => 'Automatische Online-Sicherung';

  @override
  String get beOnlineBody =>
      'Jeden Tag wird eine mit diesem Passwort verschlüsselte Kopie auf dem Droplet-Server gespeichert, der sie nicht lesen kann. Auf einem neuen Telefon genügen derselbe Name und dasselbe Passwort. Empfangene Fotos, Videos und Dateien sind nicht enthalten.';

  @override
  String get beOnlineSwitch => 'Täglich auf dem Server sichern';

  @override
  String beOnlineLast(String date) {
    return 'Letzte Sicherung: $date';
  }

  @override
  String get beOnlineNever => 'Noch keine Online-Sicherung';

  @override
  String get beOnlineNow => 'Jetzt sichern';

  @override
  String get beOnlineDone => 'Online-Sicherung erstellt';

  @override
  String get beOnlineFailed => 'Online-Sicherung derzeit nicht möglich';

  @override
  String get obRestoreFromServer => 'Vom Server wiederherstellen';

  @override
  String get obEnterPseudoFirst => 'Gib zuerst den Namen deiner Sicherung ein';

  @override
  String get obNoServerBackup =>
      'Keine Sicherung für diesen Namen und dieses Passwort';

  @override
  String get obTooManyAttempts =>
      'Zu viele Versuche – versuche es in einer Stunde erneut';

  @override
  String get chatsInviteLink => 'Mit Link einladen';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo lädt dich zu Droplet ein, dem verschlüsselten Messenger, der auch ohne Netz funktioniert: $lien';
  }

  @override
  String get invTitle => 'Einladung';

  @override
  String invBody(String pseudo) {
    return '$pseudo lädt dich zum Chatten auf Droplet ein.';
  }

  @override
  String get invAdd => 'Hinzufügen und schreiben';

  @override
  String get invInvalid =>
      'Dieser Einladungslink ist ungültig oder unvollständig.';

  @override
  String get invSelf => 'Das ist dein eigener Einladungslink.';
  @override
  String get seAnimationHeader => 'Sendeanimation';

  @override
  String get seAnimationFull => 'Vollständig';

  @override
  String get seAnimationReduced => 'Reduziert';

  @override
  String get seAnimationOff => 'Aus';

  @override
  String get seAnimationFullDesc => 'Plic trägt deine Nachricht fort, teleportiert sich und winkt dir zu.';

  @override
  String get seAnimationReducedDesc => 'Nur eine Überblendung, ohne Bewegung und Partikel.';

  @override
  String get seAnimationOffDesc => 'Keine Animation nach dem Senden.';

  @override
  String get seAnimationReplay => 'Zum Abspielen tippen';

  @override
  String get seAnimationNone => 'Keine Animation';

  @override
  String get seAnimationSampleIn => 'Sehen wir uns am Hafen?';

  @override
  String get seAnimationSampleOut => 'Bis gleich';

  @override
  String get trTitle => 'Übersetzung';

  @override
  String get trOnDevice => 'Übersetzung auf dem Gerät…';

  @override
  String get trUnknownLang => 'Unbekannte Sprache';

  @override
  String get trOriginal => 'Original';

  @override
  String get trCopy => 'Kopieren';

  @override
  String get trInChat => 'Im Chat';

  @override
  String get trRetry => 'Erneut versuchen';

  @override
  String get trSame => 'Diese Nachricht ist bereits in dieser Sprache.';

  @override
  String get trModel => 'Das Modell für diese Sprache ist noch nicht auf dem Gerät installiert.';

  @override
  String get trUnavailable => 'Dieses Gerät hat keine Offline-Übersetzung.';

  @override
  String get trFailed => 'Die Übersetzung ist fehlgeschlagen.';

  @override
  String get pfMessage => 'Nachricht';

  @override
  String get pfCall => 'Anruf';

  @override
  String get pfSecurity => 'Sicherheit';

  @override
  String get aiActCopy => 'Kopieren';

  @override
  String get aiActRead => 'Vorlesen';

  @override
  String get aiActStop => 'Vorlesen beenden';

  @override
  String get aiActLike => 'Gute Antwort';

  @override
  String get aiActDislike => 'Schlechte Antwort';

  @override
  String get aiActShare => 'Teilen';

  @override
  String get aiActRegenerate => 'Neu generieren';

  @override
  String get aiFeedbackThanks => 'Danke für dein Feedback';

  @override
  String get intelOnlineHeader => 'Übersetzung & Transkription';

  @override
  String get intelOnlineTitle => 'Online, wenn verbunden';

  @override
  String get intelOnlineSubtitle => 'Kostenlos – MyMemory, Apple oder Google';

  @override
  String get intelOnlineFooter => 'Aus: Nichts geht über das Internet. An und verbunden: Zu übersetzender Text geht an MyMemory; auf dem iPhone geht eine Sprachnachricht, die das Gerät nicht selbst transkribieren kann, an Apples Sprachdienst. Auf diesen Wegen ist der Inhalt nicht mehr Ende-zu-Ende-verschlüsselt. Auf Android wird nur das Sprachmodell heruntergeladen: Sprachnachrichten bleiben auf dem Telefon. Linkvorschauen kontaktieren außerdem die jeweilige Website.';

  @override
  String get trOnline => 'Online übersetzen';

  @override
  String get trOnlineNote => 'Der Text wird an MyMemory gesendet, einen kostenlosen Dienst. Auf diesem Weg ist er nicht mehr Ende-zu-Ende-verschlüsselt.';

  @override
  String get trViaOnline => 'Online übersetzt von MyMemory';

  @override
  String get vnModelDownloading => 'Das Sprachmodell für diese Sprache wird heruntergeladen. Versuche es gleich noch einmal.';

  @override
  String get vnModelNeeded => 'Das Sprachmodell für diese Sprache fehlt. Aktiviere „Online, wenn verbunden“ in den Einstellungen, um es einmalig herunterzuladen.';

  @override
  String get nwStatusHeader => 'Status';

  @override
  String get nwAddStatus => 'Status hinzufügen';

  @override
  String get nwStatusNewA11y => 'neu';

  @override
  String svReplySent(String name) {
    return 'Antwort an $name gesendet';
  }

  @override
  String get blkYouBlocked => 'Du hast diesen Kontakt blockiert.';

  @override
  String get blkUnblock => 'Nicht mehr blockieren';

  @override
  String get blkListTitle => 'Blockierte Kontakte';

  @override
  String get blkNone => 'Keine blockierten Kontakte';

  @override
  String get blkFooter => 'Ein blockierter Kontakt kann dir nicht mehr schreiben oder dich anrufen und erhält deine Status und dein Foto nicht mehr. Er wird nicht benachrichtigt. Dein Telefon leitet seine Nachrichten an andere weiter, ohne sie lesen zu können: Das Mesh-Netz hängt nicht davon ab, wen du blockierst.';

  @override
  String blkUnblockTitle(String name) {
    return '$name nicht mehr blockieren?';
  }

  @override
  String blkUnblockToCall(String name) {
    return '$name nicht mehr blockieren, um anzurufen?';
  }

  @override
  String get nvDone => 'Fertig';

  @override
  String get nvBack => 'Zurück';

  @override
  String get nvForward => 'Vorwärts';

  @override
  String get nvShare => 'Teilen';

  @override
  String get nvOpenInBrowser => 'Im Browser öffnen';

  @override
  String get nvReload => 'Neu laden';

  @override
  String get nvCopyLink => 'Link kopieren';

  @override
  String get nvLinkCopied => 'Link kopiert';

  @override
  String get nvOpen => 'Öffnen';

  @override
  String get nvMore => 'Mehr';

  @override
  String get nvNotSecure => 'Nicht sicher';

  @override
  String get nvErrorTitle => 'Seite nicht erreichbar';

  @override
  String get nvErrorBody => 'Droplet konnte diese Website nicht erreichen. Das Mesh-Netz überträgt kein Web – dafür braucht es eine Internetverbindung.';

  @override
  String get nvRetry => 'Erneut versuchen';

  @override
  String get ciLinks => 'Links';

  @override
  String get chatsFilterNearby => 'In der Nähe';


  @override
  String get chProxTitle => 'Droplet funktioniert auch ohne Internet';

  @override
  String get chProxActive => 'Droplet-Geräte sind in Reichweite';

  @override
  String get chProxBody => 'Telefone in der Nähe reichen Nachrichten weiter. Je mehr ihr seid, desto weiter kommen sie.';

  @override
  String get chProxSee => 'Umgebung ansehen';

  @override
  String get chStickerPreview => 'Sticker';

  @override
  String get edCrop => 'Zuschneiden';

  @override
  String get edRotate => 'Drehen';

  @override
  String get edFilters => 'Filter';

  @override
  String get edAdjust => 'Anpassen';

  @override
  String get edText => 'Text';

  @override
  String get edDraw => 'Zeichnen';

  @override
  String get edTrim => 'Kürzen';

  @override
  String get edBrightness => 'Helligkeit';

  @override
  String get edContrast => 'Kontrast';

  @override
  String get edSaturation => 'Sättigung';

  @override
  String get edWarmth => 'Wärme';

  @override
  String get edVignette => 'Vignette';

  @override
  String get edIntensity => 'Intensität';

  @override
  String get edUndo => 'Rückgängig';

  @override
  String get edDone => 'Fertig';

  @override
  String get edTextHint => 'Schreib etwas…';

  @override
  String get edDelete => 'Löschen';

  @override
  String get edOriginal => 'Original';

  @override
  String get edStyle => 'Stil';

  @override
  String get edBackground => 'Hintergrund';

  @override
  String get stNotificationsHeader => 'Mitteilungen';

  @override
  String get stNotifPreview => 'Vorschau anzeigen';

  @override
  String get stNotifPreviewSubtitle => 'Der Nachrichtentext erscheint in der Mitteilung. Aus zeigt der Sperrbildschirm nur an, dass eine Nachricht da ist.';

  @override
  String get stSearchHint => 'Einstellungen durchsuchen';

  @override
  String get stSearchEmpty => 'Keine passende Einstellung';

  @override
  String get chMentionAllSubtitle => 'Alle benachrichtigen';

  @override
  String get vuOnce => 'Einmal ansehen';

  @override
  String get vuOpened => 'Geöffnet';

  @override
  String get vuPhoto => 'Foto';

  @override
  String get vuVideo => 'Video';

  @override
  String get vuMissing => 'Dieses Medium ist noch nicht da';

  @override
  String get pollClosed => 'Umfrage beendet';

  @override
  String pollEndsAt(String quand) {
    return 'Endet um $quand';
  }

  @override
  String get vuVoice => 'Sprachnachricht';

  @override
  String get apPatternsHeader => 'Hintergrundmuster';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'Spiele';

  @override
  String get apPatternHome => 'Zuhause';

  @override
  String get apPatternGarden => 'Garten';

  @override
  String get imTitle => 'Markierte Nachrichten';

  @override
  String get imSubtitle => 'Was du beiseitegelegt hast';

  @override
  String get imAdd => 'Markieren';

  @override
  String get imRemove => 'Markierung entfernen';

  @override
  String get imAdded => 'Zu Markierten hinzugefügt';

  @override
  String get imRemoved => 'Aus Markierten entfernt';

  @override
  String get imEmptyBody => 'Halte eine Nachricht gedrückt, um sie zu markieren und sie später hier zu finden.';

  @override
  String get imClearAll => 'Alle entfernen';

  @override
  String get imClearAllBody => 'Die Nachrichten bleiben in ihren Chats; nur die Markierungen verschwinden.';

  @override
  String get imClear => 'Entfernen';

  @override
  String get imYou => 'Du';

  @override
  String get imUnknown => 'Nachricht';

  @override
  String get apPatternsFooter => 'Das Muster liegt hinter allen Chats.';

  @override
  String get grCreatedNoMessages => 'Gruppe erstellt · keine Nachrichten';

  @override
  String get chatsDelete => 'Chat löschen';

  @override
  String get chatsDeleteBody => 'Die Nachrichten verschwinden von diesem Gerät. Ohne Server kann sie niemand von anderen Geräten löschen.';

  @override
  String get chatsDeleteConfirm => 'Löschen';

  @override
  String get chatsDeleted => 'Chat gelöscht';

  @override
  String chatsDeleteTitle(String nom) {
    return 'Chat mit $nom löschen?';
  }

  @override
  String get chatsDocument => 'Dokument';

  @override
  String get epTitle => 'Selbstlöschende Nachrichten';

  @override
  String get epHeadline => 'Selbstlöschende Nachrichten in diesem Chat aktivieren';

  @override
  String get epBody => 'Neue Nachrichten tragen ihr Ablaufdatum mit sich: Sie verschwinden nach der gewählten Zeit von beiden Geräten.';

  @override
  String get epDelayHeader => 'Zeit bis zum Löschen';

  @override
  String get epHours24 => '24 Stunden';

  @override
  String get epDays7 => '7 Tage';

  @override
  String get epDays90 => '90 Tage';

  @override
  String get epOff => 'Aus';

  @override
  String get epFooter => 'Die Einstellung ändert nichts an bereits gesendeten Nachrichten: Jede behält ihre ursprüngliche Frist.';

  @override
  String get chOnlineNow => 'Online · Internet';

  @override
  String chInternetMinutesAgo(int count) {
    return 'Über Internet vor $count Min.';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'Über Internet vor $count Std.';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'Über Internet vor $count T.';
  }

  @override
  String get pdfMissing => 'Dieses Dokument ist nicht auf diesem Gerät.';

  @override
  String get pdfUnreadable => 'Dieses PDF ist nicht lesbar – es kam vielleicht unvollständig an.';

  @override
  String get giDescription => 'Beschreibung';

  @override
  String get giDescriptionAdd => 'Beschreibung hinzufügen';

  @override
  String get giDescriptionNone => 'Keine Beschreibung';

  @override
  String get giDescriptionHint => 'Worum geht es in dieser Gruppe?';

  @override
  String get giOnlyAdminsSend => 'Nur Admins dürfen schreiben';

  @override
  String get giOnlyAdminsSendBody => 'Andere Mitglieder lesen nur mit.';

  @override
  String get giSearchMembers => 'Mitglied suchen';

  @override
  String get chOnlyAdminsCanWrite => 'Nur Admins können in dieser Gruppe schreiben';

  @override
  String grCreatedBy(String nom) {
    return '$nom hat die Gruppe erstellt';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom hat dich hinzugefügt';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom ist nicht mehr in der Gruppe';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui hat $nom hinzugefügt';
  }

  @override
  String get giQrInvite => 'QR-Code';

  @override
  String get giQrRenew => 'Neuer Code';

  @override
  String get giQrRenewed => 'Neuer Code erstellt, der alte gilt nicht mehr';

  @override
  String get giQrExpired => 'Dieser Code ist abgelaufen';

  @override
  String get giQrExplainer => 'Dieser Code enthält keine Schlüssel. Er erlaubt nur, um Beitritt zu bitten – dein Gerät entscheidet.';

  @override
  String get giQrAlreadyMember => 'Du bist schon in dieser Gruppe';

  @override
  String get giQrNeedContact => 'Füge zuerst die einladende Person hinzu';

  @override
  String get giQrRequestFailed => 'Die Anfrage konnte nicht gesendet werden';

  @override
  String giQrRequestSent(String nom) {
    return 'Anfrage an $nom gesendet';
  }

  @override
  String giQrValidHours(int count) {
    return 'Noch $count Std. gültig';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'Noch $count Min. gültig';
  }

  @override
  String get cvNearby => 'In Reichweite';

  @override
  String get cvInternet => 'Internet';

  @override
  String get cvWaiting => 'Wartet';

  @override
  String get cvOutOfReach => 'Außer Reichweite';

  @override
  String get chWillSendWhenNearby => 'Wird gesendet, sobald er in Reichweite ist';

  @override
  String cvHops(int count) {
    return '$count Sprünge';
  }

  @override
  String get nwSeenSection => 'Gesehen';

  @override
  String get nwReceivedHeader => 'Empfangen';

  @override
  String get avTranslateTitle => 'Übersetzung';

  @override
  String get avTranslateShort => 'Verstehen, ohne die App zu verlassen';

  @override
  String get avTranslateLong => 'Die Nachricht wird auf Ihrem Telefon übersetzt: Ihr Inhalt geht an niemanden, auch nicht an einen Übersetzungsdienst. Das Original bleibt einen Fingertipp entfernt, denn eine Übersetzung ist nie ganz der Text.';

  @override
  String get apStickerQ => 'Hast du dafür einen Sticker?';

  @override
  String get apOnline => 'online';

  @override
  String get apMessage => 'Nachricht';

  @override
  String get apAutoTranslated => 'Automatisch übersetzt';

  @override
  String get apBgSend => 'Schau dir den Hintergrund an 😍';

  @override
  String get apBgA => 'Hast du was geändert?';

  @override
  String get apBgB => 'Er bewegt sich bei jeder Nachricht 😮';

  @override
  String get apFormatQ => 'Wo treffen wir uns?';

  @override
  String get apFormatDemo => 'Treffen **um 18 Uhr** vor dem __großen Markt__, Code `4821`. Überraschung: ||eine Torte||';

  @override
  String get apVoiceQ => 'Wo bist du?';

  @override
  String get apVoiceText => 'Ich stehe vor der Apotheke, ich warte bis 18 Uhr auf dich.';

  @override
  String get apTransQ => 'Hey, alles bereit?';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => 'Ja! Wir sehen uns morgen am Flughafen, Gate 12 um 9 Uhr.';

  @override
  String get hlpDataOnDevice => 'AUF IHREM TELEFON';

  @override
  String get hlpDataServers => 'WAS ÜBER EINEN SERVER LÄUFT';

  @override
  String get hlpDataServersFooter => 'Ohne Internet ist keiner dieser Server beteiligt: die Telefone sprechen direkt miteinander.';

  @override
  String get hlpDataNone => 'WONACH DROPLET NIE FRAGT';

  @override
  String get hlpRowKeys => 'Ihre Identität';

  @override
  String get hlpRowKeysBody => 'Ein hier erzeugtes Schlüsselpaar, nie versendet';

  @override
  String get hlpRowMessages => 'Ihre Nachrichten';

  @override
  String get hlpRowMessagesBody => 'Im privaten Speicher der App, beim Deinstallieren gelöscht';

  @override
  String get hlpRowProfile => 'Name und Foto';

  @override
  String get hlpRowProfileBody => 'Gehen nur an die Menschen, denen Sie schreiben';

  @override
  String get hlpRowSettings => 'Ihre Einstellungen';

  @override
  String get hlpRowSettingsBody => 'Hintergrund, Sprache, Mitteilungen — alles bleibt hier';

  @override
  String get hlpRowLog => 'Fehlerprotokoll';

  @override
  String get hlpRowLogBody => 'Eine lokale Datei, die nie von selbst weggeht';

  @override
  String get hlpRowDirectory => 'Verzeichnis';

  @override
  String get hlpRowDirectoryBody => 'Sieht einen Namen und eine öffentliche Kennung. Anfragen über Tor: nicht Ihre echte IP';

  @override
  String get hlpRowMailbox => 'Postfach';

  @override
  String get hlpRowMailboxBody => 'Hält eine verschlüsselte Nachricht bis zur Zustellung. Kann sie nicht lesen';

  @override
  String get hlpRowSignalling => 'Verbindungsaufbau';

  @override
  String get hlpRowSignallingBody => 'Sieht zwei Kennungen während des Verbindens. Keine Stimme läuft darüber';

  @override
  String get hlpRowRelay => 'Relais';

  @override
  String get hlpRowRelayBody => 'Leitet verschlüsselten Ton weiter, wenn die direkte Verbindung scheitert';

  @override
  String get hlpNonePhone => 'Telefonnummer';

  @override
  String get hlpNoneEmail => 'E-Mail-Adresse';

  @override
  String get hlpNoneContacts => 'Ihr Adressbuch';

  @override
  String get hlpNoneLocation => 'Ihr Standort';

  @override
  String get hlpNoneAds => 'Werbung und Tracker';

  @override
  String get hlpNoneAnalytics => 'Nutzungsmessung';

  @override
  String get hlpQOffline => 'Wie funktioniert Droplet ohne Internet?';

  @override
  String get hlpAOffline => 'Die Telefone sprechen direkt miteinander, über Bluetooth und WLAN. Eine Nachricht kann auch von Telefon zu Telefon springen, bis sie ankommt — ohne je über einen Server zu laufen.';

  @override
  String get hlpQCrypto => 'Sind meine Nachrichten wirklich verschlüsselt?';

  @override
  String get hlpACrypto => 'Ja, Ende zu Ende, mit dem Signal-Protokoll. Der Schlüssel existiert nur auf den beiden Telefonen. Weder ein Relais noch das Postfach noch wir können eine Nachricht öffnen.';

  @override
  String get hlpQNoAccount => 'Warum verlangt Droplet weder Nummer noch E-Mail?';

  @override
  String get hlpANoAccount => 'Weil es beides nicht braucht. Ihre Identität ist ein Schlüssel, der auf Ihrem Telefon entsteht. Nichts anzulegen, nichts zu bestätigen und anderswo nichts zu stehlen.';

  @override
  String get hlpQPending => 'Warum bleibt meine Nachricht ausstehend?';

  @override
  String get hlpAPending => 'Niemand ist in Reichweite und es gibt kein Internet. Die Nachricht wartet im Telefon und geht los, sobald sich ein Weg öffnet — Sie müssen nichts wiederholen.';

  @override
  String get hlpQAddSomeone => 'Wie füge ich jemanden hinzu?';

  @override
  String get hlpAAddSomeone => 'Halten Sie die Telefone nah zusammen: die Person erscheint von selbst. Aus der Ferne teilen Sie Ihren Einladungslink oder scannen deren QR-Code.';

  @override
  String get hlpQUninstall => 'Was passiert, wenn ich die App deinstalliere?';

  @override
  String get hlpAUninstall => 'Alles wird gelöscht: Nachrichten, Kontakte, Identität. Es gibt anderswo keine Kopie, also keine Wiederherstellung. Exportieren Sie vorher Ihre Einstellungen, wenn Sie das Telefon wechseln.';

  @override
  String get hlpQBattery => 'Verbraucht Droplet meinen Akku?';

  @override
  String get hlpABattery => 'Die Suche nach Geräten in der Nähe kostet Strom. In den Einstellungen können Sie sie reduzieren oder nur bei geöffneter App zulassen.';

  @override
  String get hlpQReport => 'Wie melde ich ein Problem?';

  @override
  String get hlpAReport => 'Über Kontakt und Hilfe. Sie sehen den genauen Text, der gesendet wird, bevor er weggeht — nichts verlässt Ihr Telefon ohne Sie.';

  @override
  String get svLikeStatus => 'Status gefällt mir';

  @override
  String get svUnlikeStatus => 'Gefällt mir entfernen';

  @override
  String get stAddPhotoSemantics => 'Ein Profilbild hinzufügen';

  @override
  String get stChangePhotoSemantics => 'Das Profilbild ändern';

  @override
  String get scOverheat => 'Telefon überhitzt — Android hat den Video-Encoder abgeschaltet. Lassen Sie es einige Minuten abkühlen.';

  @override
  String scTooHeavy(int mo) {
    return 'Datei zu schwer — höchstens $mo MB, um das lokale Netz zu überqueren.';
  }

  @override
  String get scUnsupported => 'Dieses Format wird für einen Status nicht unterstützt.';

  @override
  String get scUnreadableFile => 'Diese Datei lässt sich nicht lesen';

  @override
  String get scUnreadableTrack => 'Dieser Titel lässt sich nicht lesen';

  @override
  String get scNothingCaptured => 'Die Aufnahme hat nichts erfasst — bitte erneut versuchen.';

  @override
  String get scVideoTrimmed => 'Video auf 1:30 gekürzt — nur der Anfang wird veröffentlicht.';

  @override
  String get scUnreadableVideo => 'Video nicht lesbar';

  @override
  String get chAiMe => 'Ich';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'Hier ist das Ende eines Gesprächs in Droplet zwischen dem Nutzer („Ich“) und $pseudo:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'Der Nutzer möchte Hilfe bei der Antwort an $pseudo. Schlage eine kurze, natürliche Antwort vor, auf $langue verfasst, in der Ich-Form, als würde er sie selbst senden. Gib nur die vorgeschlagene Antwort, ohne Vorrede.';
  }

  @override
  String get hlpSectionHeader => 'Hilfe und Datenschutz';

  @override
  String get hlpPrivacy => 'Datenschutzerklärung';

  @override
  String get hlpData => 'Ihre Daten';

  @override
  String get hlpDataValue => 'Nichts geht raus';

  @override
  String get hlpContact => 'Kontakt und Hilfe';

  @override
  String get hlpPrivacyTitle => 'Datenschutz';

  @override
  String hlpUpdated(String date) {
    return 'Aktualisiert am $date';
  }

  @override
  String get hlpOnlyFrEn => 'Dieser Text existiert nur auf Französisch und Englisch. Ein ungenau übersetztes Rechtsdokument würde mehr verpflichten als helfen.';

  @override
  String get hlpReadInEnglish => 'Auf Englisch lesen';

  @override
  String get hlpReadInFrench => 'Auf Französisch lesen';

  @override
  String get hlpDataTitle => 'Ihre Daten';

  @override
  String get hlpDataLead => 'Was Droplet über Sie weiß, Zeile für Zeile. Nichts hier ist ein Versprechen: jede Zeile entspricht Code.';

  @override
  String get hlpStays => 'Verlässt das Gerät nie';

  @override
  String get hlpLeaves => 'Geht über einen Server';

  @override
  String get hlpNever => 'Existiert nicht';

  @override
  String get hlpCountTracking => 'Daten zum Tracking';

  @override
  String get hlpCountAccount => 'Konto anzulegen';

  @override
  String get hlpCountServers => 'Server, und wir nennen sie';

  @override
  String get hlpHelpTitle => 'Hilfe';

  @override
  String get hlpSearchHint => 'Suchen';

  @override
  String get hlpNoResult => 'Keine Antwort enthält dieses Wort. Schreiben Sie uns — vielleicht fehlt die Frage hier.';

  @override
  String get hlpStillStuckFooter => 'Steht die Antwort nicht hier, antwortet ein Mensch.';

  @override
  String get hlpContactTitle => 'Kontakt';

  @override
  String get hlpContactLead => 'Eine Frage, ein Problem, eine Idee. Wir lesen alles.';

  @override
  String get hlpBeforeWriting => 'Vor dem Schreiben';

  @override
  String get hlpHelpRowBody => 'Acht Antworten, auch ohne Internet lesbar';

  @override
  String get hlpWriteUs => 'Schreiben Sie uns';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'E-Mail';

  @override
  String get hlpWhatsAppHello => 'Hallo, ich nutze Droplet und habe eine Frage:';

  @override
  String get hlpEmailSubject => 'Droplet — Frage';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'WhatsApp ist nicht installiert. Die Nummer $numero wurde kopiert.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'Die Adresse $adresse wurde kopiert.';
  }

  @override
  String get hlpReportHeader => 'Ein Problem';

  @override
  String get hlpReport => 'Problem melden';

  @override
  String get hlpReportBody => 'Sie sehen, was rausgeht, bevor es rausgeht';

  @override
  String get hlpReportFooter => 'Droplet sendet nie von selbst einen Bericht: dafür gibt es keinen Server. Ein Problem erreicht uns nur, wenn Sie es senden.';

  @override
  String get hlpReportSubject => 'Droplet — Meldung';

  @override
  String get hlpReportSheetLead => 'Beschreiben Sie, was passiert ist. Der genaue Text, der gesendet wird, steht darunter.';

  @override
  String get hlpReportHint => 'Was ich gerade tat und was passierte…';

  @override
  String get hlpAttachLog => 'Fehlerprotokoll anhängen';

  @override
  String get hlpWhatWillBeSent => 'WAS GESENDET WIRD';

  @override
  String get hlpLogExcerpt => 'Protokoll (Ende):';

  @override
  String get hlpCopy => 'Kopieren';

  @override
  String get hlpCopied => 'Kopiert';

  @override
  String get hlpOnePerson => 'Droplet macht eine Person, kein Support-Team. Eine Antwort kann ein oder zwei Tage dauern — sie kommt.';

  @override
  String get avSectionHeader => 'Was Pro bringt';

  @override
  String get avUnlock => 'Droplet Pro freischalten';

  @override
  String get avVoiceTitle => 'Sprache als Text';

  @override
  String get avVoiceShort => 'Sprachnachricht lesen statt hören';

  @override
  String get avVoiceLong => 'Die Transkription läuft offline auf deinem Gerät. Die Sprachnachricht verlässt es nie, und du liest sie im Meeting, im Bus oder ganz ohne Netz.';

  @override
  String get avFormatTitle => 'Textgestaltung';

  @override
  String get avFormatShort => 'Fett, kursiv, Code, Spoiler';

  @override
  String get avFormatLong => 'Ein Wort fett, eine Zeile Code, eine verdeckte Stelle, die ein Tippen enthüllt: Deine Nachricht sagt genau, was du meintest.';

  @override
  String get avWallpaperTitle => 'Hintergründe und Muster';

  @override
  String get avWallpaperShort => 'Die ganze Galerie und alle vier Packs';

  @override
  String get avWallpaperLong => 'Jeder Hintergrund ist handgezeichnet, jedes Muster vor dem Einbau geprüft. Droplet, Spiele, Zuhause, Garten: Dein Chat sieht aus wie kein anderer.';

  @override
  String get avStickersTitle => 'Animierte Sticker';

  @override
  String get avStickersShort => 'Der Droplet-Tropfen, in Bewegung';

  @override
  String get avStickersLong => 'Sticker, für Droplet gezeichnet, Bild für Bild animiert und so leicht, dass sie ohne Internet durchs Mesh reisen.';

  @override
  String get avIconTitle => 'App-Symbole';

  @override
  String get avIconShort => 'Das Symbol auf dem Homescreen ändern';

  @override
  String get avIconLong => 'Ein unauffälliger Messenger beginnt beim Symbol. Wähle das, das zu dir passt – oder das, das niemand bemerkt.';

  @override
  String get avBadgeTitle => 'Pro-Abzeichen';

  @override
  String get avBadgeShort => 'Es steht neben deinem Namen';

  @override
  String get avBadgeLong => 'Es verleiht keine Macht über andere. Es sagt nur, dass du gezahlt hast, damit Droplet ohne Werbung, Zwangsabo und Datenverkauf bleibt.';

  @override
  String get sgTitle => 'Gruppenspeicher';

  @override
  String get sgEmpty => 'In dieser Gruppe wurde noch keine Datei geteilt.';

  @override
  String get sgByAuthor => 'Wer am meisten sendet';

  @override
  String get sgFiles => 'Dateien';

  @override
  String get sgSortRecent => 'Neueste zuerst';

  @override
  String get sgSortHeavy => 'Größte zuerst';

  @override
  String get sgNotOnDevice => 'Nicht hier';

  @override
  String get giPhotoChanged => 'Gruppenbild geändert';

  @override
  String get giPhotoFailed => 'Dieses Bild konnte nicht gespeichert werden';

  @override
  String sgTotal(int count) {
    return '$count geteilte Dateien';
  }

  @override
  String get vrTitle => 'Sprach-Raum';

  @override
  String get vrJoin => 'Beitreten';

  @override
  String get vrBack => 'Zurück';

  @override
  String get vrStart => 'Sprach-Raum öffnen';

  @override
  String get vrNeedsInternet => 'Ein Sprach-Raum braucht Internet: Das Mesh trägt eine wartende Nachricht, nicht zwanzig Stimmen zugleich.';

  @override
  String get vrUnreachable => 'Der Anrufserver ist gerade nicht erreichbar.';

  @override
  String vrFull(int count) {
    return 'Der Raum ist voll – höchstens $count Personen.';
  }

  @override
  String get vrWaiting => 'Warten auf die anderen…';

  @override
  String get vrWaitingBody => 'Der Raum ist offen. Die Gruppenmitglieder sehen ihn im Chat und kommen dazu, wenn sie Zeit haben.';

  @override
  String vrPeople(int count) {
    return '$count Personen dabei';
  }

  @override
  String get cvTitle => 'Unterhaltungen';

  @override
  String get cvNew => 'Neue Unterhaltung';

  @override
  String get cvPinned => 'Angeheftet';

  @override
  String get cvRecent => 'Zuletzt';

  @override
  String get cvPin => 'Anheften';

  @override
  String get cvUnpin => 'Lösen';

  @override
  String get cvRename => 'Umbenennen';

  @override
  String get cvRenameHint => 'Titel der Unterhaltung';

  @override
  String get cvUntitled => 'Ohne Titel';

  @override
  String get cvYesterday => 'Gestern';

  @override
  String get cvSearchHint => 'Unterhaltungen durchsuchen';

  @override
  String get cvEmpty => 'Noch keine Unterhaltungen. Stelle dem Assistenten deine erste Frage.';

  @override
  String get cvDeleteTitle => 'Diese Unterhaltung löschen?';

  @override
  String get cvDeleteBody => 'Sie kann nicht wiederhergestellt werden – sie existiert nur auf diesem Gerät.';

  @override
  String get jaWorking => 'Arbeitet…';

  @override
  String cvNoResult(String terme) {
    return 'Nichts gefunden für „$terme“.';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Keine Treffer',
      one: '1 Treffer',
      other: '$count Treffer',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Keine Schritte',
      one: '1 Schritt',
      other: '$count Schritte',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'Wohin deine Nachricht geht';

  @override
  String get moLocal => 'Auf dem Gerät';

  @override
  String get moLocalBody => 'Das Modell läuft auf diesem Telefon. Nichts verlässt es, auch offline nicht. Antworten sind kürzer und weniger verlässlich.';

  @override
  String get moOnline => 'Online';

  @override
  String get moOnlineBody => 'Deine Nachricht geht an Groq, das ein viel größeres Modell betreibt. Dafür braucht es Netz, und die Nachricht verlässt das Telefon.';

  @override
  String get moOnlineNoKey => 'Für ein entferntes Modell braucht es einen Schlüssel. Tippe, um einen hinzuzufügen – kostenlos, dauert eine Minute.';

  @override
  String get moRetryOnline => 'Online wiederholen';

  @override
  String get moRetryOnlineWhy => 'Das Modell auf dem Gerät stößt hier an seine Grenzen.';

  @override
  String get cpHint => 'Frag etwas…';

  @override
  String get cpAdd => 'Hinzufügen';

  @override
  String get cpPhoto => 'Foto';

  @override
  String get cpCamera => 'Kamera';

  @override
  String get cpFile => 'Datei';

  @override
  String get cpFileHint => 'PDF, Text, Code';

  @override
  String get cpDictate => 'Diktieren';

  @override
  String get cpSend => 'Senden';

  @override
  String get cpStop => 'Stoppen';

  @override
  String get cpThinking => 'Denkt nach…';

  @override
  String get amCopy => 'Kopieren';

  @override
  String get amCopyMarkdown => 'Als Markdown kopieren';

  @override
  String get amCopyMarkdownHint => 'Behält die Formatierung, für ein Dokument';

  @override
  String get amShare => 'Teilen';

  @override
  String get amEdit => 'Meine Frage bearbeiten';

  @override
  String get amEditHint => 'Alles danach wird entfernt';

  @override
  String get amEditTitle => 'Diese Frage bearbeiten?';

  @override
  String get amEditConfirm => 'Bearbeiten';

  @override
  String get amRegenerate => 'Neu generieren';

  @override
  String get amReadAloud => 'Vorlesen';

  @override
  String get amAsContext => 'Als Kontext verwenden';

  @override
  String get amAsContextHint => 'Setzt bei dieser Nachricht an';

  @override
  String get amChapter => 'Als Kapitel markieren';

  @override
  String get amChapterHint => 'Um sie in einer langen Unterhaltung wiederzufinden';

  @override
  String get amUnchapter => 'Markierung entfernen';

  @override
  String get amChapters => 'Kapitel';

  @override
  String get amChaptersEmpty => 'Noch keine Kapitel. Halte eine Nachricht gedrückt und wähle „Als Kapitel markieren“, um sie hier wiederzufinden.';

  @override
  String amEditBody(int count) {
    return '$count nachfolgende Nachrichten werden entfernt – sie beantworteten die alte Frage.';
  }

  @override
  String get trAssistant => 'Assistent';

  @override
  String get trArtifacts => 'Artefakte';

  @override
  String get trMemory => 'Erinnerungen';

  @override
  String get trHelp => 'Hilfe';

  @override
  String get arVersions => 'Versionen';

  @override
  String get arLatest => 'Neueste';

  @override
  String get arSource => 'Quelltext';

  @override
  String get arPreview => 'Vorschau';

  @override
  String get arGone => 'Dieses Artefakt gibt es nicht mehr.';

  @override
  String get arKindPage => 'Seite';

  @override
  String get arKindCode => 'Code';

  @override
  String get arKindDiagram => 'Diagramm';

  @override
  String get arKindData => 'Daten';

  @override
  String get arKindDoc => 'Dokument';

  @override
  String arVersion(int n) {
    return 'Version $n';
  }

  @override
  String get aiSources => 'Quellen';

  @override
  String get aiToolReading => 'Anhang wird gelesen…';

  @override
  String get aiToolWriting => 'Datei wird erstellt…';

  @override
  String get aiToolRemembering => 'Wird gemerkt…';

  @override
  String get arEmpty => 'Noch keine Artefakte. Der Assistent legt eines an, sobald er eine Seite, eine Tabelle oder Code erzeugt, der die Unterhaltung überladen würde.';

  @override
  String get raTitle => 'Online-Assistent';

  @override
  String get raIntro => 'Der Assistent auf dem Gerät läuft ohne Einrichtung. Der Online-Modus braucht einen Schlüssel: er bezahlt die Antworten und bleibt auf diesem Telefon.';

  @override
  String get raKey => 'Schlüssel';

  @override
  String get raKeySaved => 'Schlüssel gespeichert';

  @override
  String get raKeyFooter => 'Er liegt im Schlüsselbund des Systems und wird nie vollständig angezeigt.';

  @override
  String get raKeyRemove => 'Schlüssel entfernen';

  @override
  String get raWhere => 'Einen Schlüssel erstellst du auf console.groq.com unter „API Keys“. Er beginnt mit gsk_.';

  @override
  String get raPaste => 'Einfügen';

  @override
  String get raSaveAndTest => 'Speichern und testen';

  @override
  String get raTest => 'Schlüssel testen';

  @override
  String get raTesting => 'Wird getestet…';

  @override
  String get raNotTested => 'Noch nicht getestet';

  @override
  String get raNotTestedBody => 'Ein Aufruf mit acht Wörtern genügt. Besser hier als mitten in einer Frage.';

  @override
  String get raWorks => 'Der Schlüssel funktioniert';

  @override
  String get raWorksBody => 'Der Online-Modus steht nun in der Unterhaltung bereit, auf der Pille neben dem Eingabefeld.';

  @override
  String get raRefused => 'Schlüssel abgelehnt';

  @override
  String get raRefusedBody => 'Der Server erkennt ihn nicht. Oft fehlt beim Einfügen ein Zeichen, oder der Schlüssel wurde widerrufen.';

  @override
  String get raNoNetwork => 'Server nicht erreichbar';

  @override
  String get raNoNetworkBody => 'Der Schlüssel ist nicht schuld: die Anfrage kam nie an. Prüfe die Verbindung und versuche es erneut.';

  @override
  String get raModelGone => 'Modell nicht verfügbar';

  @override
  String get raModelGoneBody => 'Der Schlüssel wird akzeptiert, aber es kam nichts zurück. Das Modell wurde vermutlich zurückgezogen.';

  @override
  String get raQuota => 'Zu viele Anfragen';

  @override
  String get raQuotaBody => 'Der Schlüssel funktioniert, aber das Konto hat sein Limit erreicht. Später erneut versuchen oder das Guthaben prüfen.';

  @override
  String get raWhatGoesOut => 'Was das Gerät verlässt';

  @override
  String get raModel => 'Modell';

  @override
  String get raWhatGoesOutFooter => 'Im Online-Modus gehen deine Nachricht und die bisherigen Beiträge dieser Unterhaltung an Groq. Sonst nichts: keine Kontakte, keine anderen Unterhaltungen, kein Standort.';

  @override
  String get aiDownloadTitle => 'Modell für das Gerät laden?';

  @override
  String get aiDownloadConfirm => 'Laden';

  @override
  String get aiDownloading => 'Modell wird geladen';

  @override
  String aiDownloadBody(int mo) {
    return '$mo MB, einmalig. Danach antwortet der Assistent ohne Netz, und nichts verlässt dein Telefon. Während des Ladens kannst du ihn online weiterbenutzen.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo MB, einmalig. Danach antwortet der Assistent ohne Netz, und nichts verlässt das Telefon.';
  }

  @override
  String get aiGreetingPlain => 'Hallo';

  @override
  String get aiGreetingHint => 'Stell eine Frage, häng ein Foto an oder bitte um ein Dokument.';

  @override
  String get aiChipExplain => 'Erkläre mir…';

  @override
  String get aiChipWrite => 'Schreib eine Nachricht';

  @override
  String get aiChipSummarize => 'Fass das zusammen';

  @override
  String get aiChipTranslate => 'Übersetze nach…';

  @override
  String aiGreeting(String nom) {
    return 'Hallo, $nom';
  }

  @override
  String get cpNoPhoto => 'Keine Fotos: das Online-Modell kann kein Bild lesen. PDFs liest es dagegen, auch lange.';

  @override
  String get mvOpen => 'Sprachmodus';

  @override
  String get mvTapToTalk => 'Tippen, um zu sprechen';

  @override
  String get mvHoldToTalk => 'Halten, um zu sprechen';

  @override
  String get mvListening => 'Ich höre zu…';

  @override
  String get mvTranscribing => 'Transkription…';

  @override
  String get mvSpeaking => 'Antwort wird vorgelesen';

  @override
  String get mvProblem => 'Ein Problem';

  @override
  String get mvHandsFree => 'Freisprechen';

  @override
  String get mvHold => 'Halten';

  @override
  String get mvTalk => 'Sprechen';

  @override
  String get mvInterrupt => 'Unterbrechen';

  @override
  String get mvNoMic => 'Droplet hat keinen Zugriff auf das Mikrofon. Erlaube ihn in den Telefoneinstellungen.';

  @override
  String get mvFailed => 'Dieser Versuch hat nicht funktioniert. Zum erneuten Versuch tippen.';

  @override
  String get mvLive => 'Live';

  @override
  String get mvCaptions => 'Untertitel';

  @override
  String get mvExit => 'Sprachmodus verlassen';

  @override
  String get mvMute => 'Mikrofon stummschalten';

  @override
  String get mvUnmute => 'Stummschaltung aufheben';

  @override
  String get mvMuted => 'Mikrofon aus';

  @override
  String get mvTapToInterrupt => 'Zum Unterbrechen tippen';

  @override
  String scCompressing(int percent) {
    return 'Wird komprimiert… $percent %';
  }

  @override
  String get scStillHeavy => 'Dieses Video liegt weiterhin über 2 MB: Die Übertragung dauert länger.';

  @override
  String get baConnecting => 'Verbinden…';

  @override
  String get baMute => 'Stummschalten';

  @override
  String get baUnmute => 'Stummschaltung aufheben';

  @override
  String get baHangUp => 'Auflegen';

  @override
  String baOngoing(String name) {
    return 'Laufender Anruf mit $name. Zum Zurückkehren tippen.';
  }

  @override
  String get ntfOngoingCall => 'Laufender Anruf';

  @override
  String get ntfViaMesh => 'Über das Mesh';

  @override
  String get ntfViaInternet => 'Über das Internet';

  @override
  String get shSend => 'Senden';

  @override
  String get shRecents => 'Zuletzt';

  @override
  String get shPickRecipients => 'Wähle einen oder mehrere Empfänger';

  @override
  String shSendCount(int count) {
    return 'An $count senden';
  }

  @override
  String shSelected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get apcNothingYet => 'Noch nichts';

  @override
  String get apcOnline => 'Online';

  @override
  String get apcOffline => 'Offline';

  @override
  String get apcPhoto => 'Foto';

  @override
  String get apcVoice => 'Sprachnachricht';

  @override
  String get apcAttachment => 'Anhang';

  @override
  String get chKeyboardTooltip => 'Tastatur';

  @override
  String get asGallery => 'Galerie';

  @override
  String get asFile => 'Datei';

  @override
  String get asLocation => 'Standort';

  @override
  String get asSticker => 'Sticker';

  @override
  String get asPoll => 'Umfrage';

  @override
  String get asNoGalleryAccess => 'Droplet hat keinen Zugriff auf deine Fotos. Erlaube ihn in den Telefoneinstellungen oder wähle unten eine andere Quelle.';

  @override
  String asSendCount(int count) {
    return '$count senden';
  }

  @override
  String get asEmptyGallery => 'Auf diesem Telefon sind keine Fotos oder Videos.';

  @override
  String get expAucunPairTitre => 'Niemand in der Nähe?';

  @override
  String get expAucunPairTexte => 'Keine Störung. Droplet sucht ununterbrochen; sobald ein Gerät vorbeikommt, entsteht die Verbindung von selbst.';

  @override
  String get expRelaisTitre => 'Über jemanden geleitet';

  @override
  String get expRelaisTexte => 'Dieses Symbol bedeutet: Die Nachricht lief über ein oder mehrere Geräte. Das ist die Stärke des Mesh.';

  @override
  String get expApercuTitre => 'Kurzer Blick';

  @override
  String get expApercuTexte => 'Halte eine Unterhaltung gedrückt, um die letzten Nachrichten zu lesen, ohne sie zu öffnen oder als gelesen zu markieren.';

  @override
  String get expOfficielTitre => 'Das Droplet-Konto';

  @override
  String get expOfficielTexte => 'Neuigkeiten zur App kommen hier an. Jede Ankündigung ist signiert: Niemand kann eine fälschen.';

  @override
  String get expMicroTitre => 'Zum Sprechen halten';

  @override
  String get expMicroTexte => 'Gedrückt halten zum Aufnehmen. Nach links wischen bricht ab, nach oben wischen nimmt freihändig weiter auf.';

  @override
  String get expCameraTitre => 'Mikro oder Kamera';

  @override
  String get expCameraTexte => 'Ein kurzer Tipp auf diese Taste wechselt zwischen Sprachnachricht und runder Videonachricht.';

  @override
  String get expVueUniqueTitre => 'Nur einmal';

  @override
  String get expVueUniqueTexte => 'Schalte die „1“ ein: Das Nächste, was du sendest, lässt sich nur einmal öffnen und verschwindet dann.';

  @override
  String get expPiecesTitre => 'Mehrere auf einmal';

  @override
  String get expPiecesTexte => 'Die Büroklammer öffnet deine Galerie in der App. Wähle mehrere Fotos: Die Zahl zeigt die Sendereihenfolge.';

  @override
  String get expStickersTitre => 'Sticker und Tastatur';

  @override
  String get expStickersTexte => 'Dieses Symbol ersetzt die Tastatur durch Sticker und wird mit einem Tipp wieder zur Tastatur.';

  @override
  String get expEphemeresTitre => 'Verschwindende Nachrichten';

  @override
  String get expEphemeresTexte => 'Lege eine Frist fest: Neue Nachrichten dieser Unterhaltung löschen sich auf beiden Telefonen.';

  @override
  String get expVerrouTitre => 'Gesperrte Unterhaltung';

  @override
  String get expVerrouTexte => 'Gesperrt zeigt eine Unterhaltung ihre letzte Nachricht nicht mehr in der Liste und verlangt Entsperren.';

  @override
  String get expCodeTitre => 'Kontakt prüfen';

  @override
  String get expCodeTexte => 'Vergleicht diesen Code nebeneinander: Stimmt er überein, hat sich niemand dazwischengeschoben.';

  @override
  String get expStatutTitre => '24-Stunden-Status';

  @override
  String get expStatutTexte => 'Ein Status lebt einen Tag und verschwindet dann. Er wandert von Telefon zu Telefon, auch ohne Internet.';

  @override
  String get expGardeTitre => 'Nichts geht verloren';

  @override
  String get expGardeTexte => 'Eine Nachricht an jemanden, der fehlt, wird eine Woche aufbewahrt und geht von selbst los, sobald ein Weg frei wird.';

  @override
  String get expVoieTitre => 'Welcher Weg';

  @override
  String get expVoieTexte => 'Bluetooth, WLAN Direct oder Internet: Droplet nimmt, was da ist, und wechselt den Weg ohne Nachfrage.';

  @override
  String get cnAnnouncement => 'Neu bei Droplet';

  @override
  String get cnClearAll => 'Alle löschen';

  @override
  String get cnClearAllTitle => 'Alle Mitteilungen löschen?';

  @override
  String get cnClearAllBody => 'Die Mitteilungszentrale wird geleert. Deine Chats und Nachrichten bleiben unberührt.';

  @override
  String get cnDelete => 'Löschen';

  @override
  String get cnEmptyTitle => 'Nichts Neues';

  @override
  String get cnEmptyBody => 'Erwähnungen, Reaktionen auf deine Nachrichten, verpasste Anrufe und Neuigkeiten von Droplet erscheinen hier.';

  @override
  String get cnMentioned => 'hat dich erwähnt';

  @override
  String get cnShowLess => 'Weniger anzeigen';

  @override
  String get cnStatusLike => 'gefällt dein Status';

  @override
  String get cnStatusReply => 'hat auf deinen Status geantwortet';

  @override
  String get cnTitle => 'Mitteilungszentrale';

  @override
  String get ncDeliveryHeader => 'Zustellung';

  @override
  String get ncMentionsOnly => 'Nur Erwähnungen';

  @override
  String get ncMentionsOnlySub => 'Nur wenn jemand @dein Name oder @alle schreibt';

  @override
  String get ncMute1h => '1 Stunde';

  @override
  String get ncMute8h => '8 Stunden';

  @override
  String get ncMute1w => '1 Woche';

  @override
  String get ncMuteAlways => 'Immer';

  @override
  String get ncMuteFooter => 'Keine Mitteilungen, keine Töne. Nachrichten kommen trotzdem an und warten auf dich.';

  @override
  String get ncMuteFooterGroup => 'Keine Mitteilungen, keine Töne. Erwähnungen erreichen dich trotzdem.';

  @override
  String get ncMuteHeader => 'Stummschalten';

  @override
  String get ncMuteOff => 'Aus';

  @override
  String get ncPreviewAlways => 'Immer';

  @override
  String get ncPreviewFooter => 'Ohne Vorschau steht nur „Neue Nachricht“ in der Mitteilung: auf dem Sperrbildschirm ist nichts zu lesen.';

  @override
  String get ncPreviewHeader => 'Nachrichtenvorschau';

  @override
  String get ncPreviewNever => 'Nie';

  @override
  String get ncQuiet => 'Ohne Ton zustellen';

  @override
  String get ncQuietSub => 'In der Mitteilungsleiste, ohne Ton und Banner';

  @override
  String get ncSampleAuthor => 'Lea';

  @override
  String get ncSampleHidden => 'Neue Nachricht';

  @override
  String get ncSampleLabel => 'Beispielmitteilung';

  @override
  String get ncSampleText => 'Treffen wir uns um 19 Uhr?';

  @override
  String get ncStateMentions => 'Nur Erwähnungen';

  @override
  String get ncStateMuted => 'Stumm';

  @override
  String get ncStateOn => 'An';

  @override
  String get ncStateQuiet => 'Ohne Ton';

  @override
  String get ncSystemFooter => 'Ton und Bubbles dieses Chats legst du in Android fest.';

  @override
  String get ncSystemSettings => 'Ton und Bubbles';

  @override
  String get ncTitle => 'Mitteilungen';

  @override
  String get ntfNewMessage => 'Neue Nachricht';

  @override
  String get ntfNow => 'jetzt';

  @override
  String get rnBanners => 'Banner';

  @override
  String get rnBannersSub => 'Wenn eine Nachricht kommt, während Droplet offen ist';

  @override
  String get rnFocus1h => 'Für 1 Stunde';

  @override
  String get rnFocusEvening => 'Bis heute Abend';

  @override
  String get rnFocusTomorrow => 'Bis morgen früh';

  @override
  String get rnFocusFooter => 'Droplet bleibt still: Nachrichten kommen an und warten auf dich. Anrufe klingeln weiterhin.';

  @override
  String get rnFocusHeader => 'Fokus';

  @override
  String get rnFocusMentions => 'Erwähnungen zulassen';

  @override
  String get rnFocusMentionsSub => 'Wenn jemand in einer Gruppe @dein Name schreibt';

  @override
  String get rnFocusOff => 'Fokus ist aus';

  @override
  String get rnFocusOffSub => 'Mitteilungen kommen wie gewohnt';

  @override
  String get rnFocusOn => 'Fokus ist an';

  @override
  String get rnFocusStop => 'Fokus ausschalten';

  @override
  String get rnFocusStopShort => 'Beenden';

  @override
  String get rnInAppHeader => 'In Droplet';

  @override
  String get rnMutedEmpty => 'Keine stummgeschalteten Chats.';

  @override
  String get rnMutedHeader => 'Stummgeschaltet';

  @override
  String get rnPreview => 'Vorschau anzeigen';

  @override
  String get rnPreviewFooter => 'Nachrichtentext in Mitteilungen. Jeder Chat kann das anders regeln.';

  @override
  String get rnSystem => 'Android-Einstellungen';

  @override
  String get rnSystemFooter => 'Berechtigungen, Töne und Bubbles von Droplet in den Telefoneinstellungen.';

  @override
  String get stNotificationsSubtitle => 'Stumm, Vorschau, Fokus';

  @override
  String cnBellUnread(int count) {
    return 'Mitteilungen, $count neu';
  }

  @override
  String cnMore(int count) {
    return '+$count weitere';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count weitere';
  }

  @override
  String cnQuoted(String texte) {
    return '„$texte“';
  }

  @override
  String cnReacted(String emoji) {
    return 'hat mit $emoji auf deine Nachricht reagiert';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'Bis $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'Standard ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return '$nom stummschalten';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'Bis $heure · Anrufe klingeln weiterhin';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n Chats';
  }

  @override
  String get chatsNetSearching => 'Suche nach Geräten in der Nähe…';

  @override
  String get cfEmptyUnreadTitle => 'Alles gelesen';

  @override
  String get cfEmptyUnreadBody => 'Chats mit ungelesenen Nachrichten erscheinen hier.';

  @override
  String get cfEmptyGroupsTitle => 'Noch keine Gruppen';

  @override
  String get cfEmptyGroupsBody => 'Erstelle eine mit der Taste + oben rechts.';

  @override
  String get cfEmptyOtherTitle => 'Hier ist noch nichts';

  @override
  String get ciLockedWhereHint => 'Gesperrt. Zum Wiederfinden die Chatliste nach unten ziehen.';

  @override
  String get chDraftLabel => 'Entwurf:';

  @override
  String get rsMorning => 'Guten Morgen';

  @override
  String get rsEvening => 'Guten Abend';

  @override
  String get rsUnreadOne => '1 ungelesene Nachricht';

  @override
  String get rsChatsOne => 'in 1 Chat';

  @override
  String get rsMentionsOne => '1 Erwähnung';

  @override
  String get rsMissedOne => '1 verpasster Anruf';

  @override
  String get rsSeeUnread => 'Ungelesene anzeigen';

  @override
  String rsUnreadMany(int count) {
    return '$count ungelesene Nachrichten';
  }

  @override
  String rsChatsMany(int count) {
    return 'in $count Chats';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count Erwähnungen';
  }

  @override
  String rsMissedMany(int count) {
    return '$count verpasste Anrufe';
  }

  @override
  String get camUnavailable => 'Kamera nicht verfügbar. Prüfe die Berechtigung in den Einstellungen.';

  @override
  String get camTakePhoto => 'Foto aufnehmen';

  @override
  String get camFlip => 'Kamera wechseln';

  @override
  String get chE2eNotice => 'Nachrichten sind Ende-zu-Ende-verschlüsselt. Niemand sonst, nicht einmal Droplet, kann sie lesen.';

  @override
  String chCallUnreachable(String name) {
    return '$name ist außer Reichweite: Anrufen geht, sobald ihr in der Nähe oder online seid.';
  }

  @override
  String get chPin => 'Anheften';

  @override
  String get chUnpin => 'Loslösen';

  @override
  String get chPinnedMessage => 'Angeheftete Nachricht';

  @override
  String get chVoicePlay => 'Abspielen';

  @override
  String get chVoicePause => 'Pause';

  @override
  String chPinnedMessageN(String position) {
    return 'Angeheftete Nachricht $position';
  }

  @override
  String get msgInfo => 'Info';

  @override
  String get imSearch => 'Suchen';

  @override
  String get apcVideo => 'Video';

  @override
  String get adTitle => 'Verknüpfte Geräte';

  @override
  String get adSettingsSubtitle => 'Droplet Web auf deinem Computer';

  @override
  String get adHero => 'Nutze Droplet auf deinem Computer, auch wenn dein Telefon ausgeschaltet ist. Öffne einfach:';

  @override
  String get adLink => 'Gerät hinzufügen';

  @override
  String get adDevices => 'Geräte';

  @override
  String adCount(int n, int max) {
    return '$n von $max';
  }

  @override
  String get adNone => 'Keine verknüpften Geräte';

  @override
  String get adFooter => 'Deine Nachrichten sind auf jedem Gerät Ende-zu-Ende-verschlüsselt. Jedes verknüpfte Gerät hat eigene Schlüssel, und du kannst es jederzeit abmelden.';

  @override
  String adLinkedOn(String date) {
    return 'Verknüpft am $date';
  }

  @override
  String get adLogout => 'Abmelden';

  @override
  String adLogoutTitle(String nom) {
    return '$nom abmelden?';
  }

  @override
  String get adLogoutBody => 'Dieser Browser verliert den Zugriff auf deine Chats. Du kannst ihn jederzeit erneut verknüpfen.';

  @override
  String get adLogoutAll => 'Von allen Geräten abmelden';

  @override
  String get adLogoutAllBody => 'Alle verknüpften Browser verlieren den Zugriff auf deine Chats.';

  @override
  String get adScanTitle => 'Gerät hinzufügen';

  @override
  String get adScanHint => 'Öffne Droplet Web auf deinem Computer und richte die Kamera auf den QR-Code:';

  @override
  String get adSecurity => 'Der Code ändert sich jede Minute – ein Foto davon ist nutzlos.';

  @override
  String get adNotDroplet => 'Das ist kein Droplet Web-Code. Richte die Kamera auf den Code auf web.dropletmesh.app.';

  @override
  String get adConfirmTitle => 'Dieses Gerät verknüpfen?';

  @override
  String get adConfirmBody => 'Es kann deine Nachrichten lesen und senden, auch wenn dieses Telefon ausgeschaltet ist.';

  @override
  String get adConfirm => 'Verknüpfen';

  @override
  String get adLinking => 'Wird verknüpft …';

  @override
  String get adLinked => 'Gerät verknüpft';

  @override
  String get adServerDown => 'Die Droplet-Server sind gerade nicht erreichbar. Überprüfe deine Verbindung und versuche es erneut.';

  @override
  String get adLimit => 'Du hast bereits 4 verknüpfte Geräte. Melde eines ab, um ein weiteres zu verknüpfen.';

  @override
  String get adNoIdentity => 'Erstelle zuerst dein Droplet-Profil auf diesem Telefon.';

  @override
  String get adTorch => 'Taschenlampe';
}
