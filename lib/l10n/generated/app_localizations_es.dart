// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'Enviar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionDone => 'Listo';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabNews => 'Novedades';

  @override
  String get tabCalls => 'Llamadas';

  @override
  String get tabPeers => 'Contactos';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get appearanceAuto => 'Automático';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Oscuro';

  @override
  String get appearanceFooter =>
      'Droplet está diseñado para el modo oscuro: en una pantalla OLED, los píxeles negros están apagados, lo que ahorra batería y evita deslumbrar en la oscuridad. El modo claro sigue disponible para leer con luz solar intensa.';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get languageAuto => 'Automático (idioma del teléfono)';

  @override
  String get languageFooter =>
      '«Automático» sigue el idioma configurado en el dispositivo. Si ese idioma aún no está disponible, Droplet permanece en francés.';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get chatsSearchHint => 'Buscar';

  @override
  String get chatsFilterAll => 'Todos';

  @override
  String get chatsFilterUnread => 'No leídos';

  @override
  String get chatsFilterGroups => 'Grupos';

  @override
  String get chatsFilterPinned => 'Fijados';

  @override
  String get chatsEmptyTitle => 'Sin chats todavía';

  @override
  String get chatsEmptySubtitle =>
      'Acércate a un dispositivo que use Droplet: aparecerá aquí automáticamente.';

  @override
  String get chatsSearchEmptyTitle => 'Sin resultados';

  @override
  String get chatsSearchEmptySubtitle => 'Prueba con otro nombre.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contactos cerca',
      one: '$count contacto cerca',
      zero: 'Buscando contactos…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'Al menos 3 caracteres';

  @override
  String get obChoosePseudo => 'Elige un nombre para empezar';

  @override
  String get obRestoreFailed => 'Error al restaurar';

  @override
  String get obPhotoSaveFailed => 'No se pudo guardar la foto';

  @override
  String get obShareUnavailable => 'Uso compartido no disponible';

  @override
  String get obBackupPasswordTitle => 'Contraseña de la copia de seguridad';

  @override
  String get obBackupPasswordMessage =>
      'La que elegiste al exportar tu identidad.';

  @override
  String get obBackupPasswordPlaceholder => 'Contraseña';

  @override
  String get obRestore => 'Restaurar';

  @override
  String get obSkipStep => 'Omitir este paso';

  @override
  String get obContinue => 'Continuar';

  @override
  String get obStart => 'Empezar';

  @override
  String get obAlreadyHaveBackup => 'Ya tengo una copia de seguridad';

  @override
  String get obWelcomeTitle => 'Bienvenido a\nDroplet';

  @override
  String get obWelcomeSubtitle =>
      'Una mensajería que funciona donde ya no hay red.';

  @override
  String get obFeatOfflineTitle => 'Sin internet, sin operador';

  @override
  String get obFeatOfflineText =>
      'Los teléfonos se comunican directamente, salto a salto. Sin antena, sin factura.';

  @override
  String get obFeatEncryptedTitle => 'Cifrado de extremo a extremo';

  @override
  String get obFeatEncryptedText =>
      'Ni siquiera los teléfonos que retransmiten tus mensajes pueden leerlos.';

  @override
  String get obFeatLocalTitle => 'Nada sale de tu dispositivo';

  @override
  String get obFeatLocalText =>
      'Sin cuenta, sin servidor, sin recopilación. Tus conversaciones se quedan contigo.';

  @override
  String get obRelayTitle => 'Salto a\nsalto';

  @override
  String get obRelaySubtitle =>
      'Tu mensaje salta de teléfono en teléfono hasta llegar a su destinatario, aunque no estés en alcance directo.';

  @override
  String get obFeatCrowdTitle => 'Cuantos más seamos, más lejos llega';

  @override
  String get obFeatCrowdText =>
      'Cada dispositivo a tu alcance amplía la red para todos.';

  @override
  String get obFeatNothingLostTitle => 'Nada se pierde';

  @override
  String get obFeatNothingLostText =>
      'Un mensaje destinado a alguien ausente espera, y sigue su camino en cuanto se abre uno.';

  @override
  String get obSafetyTitle => 'Encontrarse,\nsin red';

  @override
  String get obSafetySubtitle =>
      'Cuando nada más funciona, saber dónde están los demás y que están bien se vuelve la información más útil.';

  @override
  String get obFeatMapTitle => 'Un mapa que funciona sin conexión';

  @override
  String get obFeatMapText =>
      'Las zonas que consultas se guardan en el teléfono. Una vez vistas, se muestran sin internet.';

  @override
  String get obFeatMeshPosTitle => 'Las ubicaciones vienen de la malla';

  @override
  String get obFeatMeshPosText =>
      'Sin servidor: la ubicación sale del teléfono de tu contacto, cifrada, y salta de dispositivo en dispositivo hasta el tuyo.';

  @override
  String get obFeatCheckinTitle => '«Estoy a salvo», con un gesto';

  @override
  String get obFeatCheckinText =>
      'Con un solo toque, tu estado se difunde a todo el vecindario. Tú eliges si añadir una ubicación aproximada, o no.';

  @override
  String get obStatusTitle => 'Compartir\nnovedades';

  @override
  String get obStatusSubtitle =>
      'Una foto, una palabra, un estado de ánimo: tu estado circula de teléfono en teléfono, como tus mensajes.';

  @override
  String get obFeatStatusMediaTitle => 'Foto, video o texto';

  @override
  String get obFeatStatusMediaText =>
      'Publica lo que quieras mostrar. Las personas a tu alcance lo reciben, sin pasar por internet.';

  @override
  String get obFeatStatusSeenTitle => 'Ves quién lo ha visto';

  @override
  String get obFeatStatusSeenText =>
      'Cada persona que abre tu estado te lo hace saber, por el mismo camino.';

  @override
  String get obFeatStatusExpireTitle => 'Desaparece después de un día';

  @override
  String get obFeatStatusExpireText =>
      'Veinticuatro horas, y luego el estado se borra de todos los teléfonos que lo recibieron.';

  @override
  String get obRemovePhoto => 'Quitar la foto';

  @override
  String get obChoosePhoto => 'Elegir una foto';

  @override
  String get obPhotoTitle => 'Un rostro,\nsi quieres';

  @override
  String get obPhotoSubtitle =>
      'Ayuda a que los demás te reconozcan en una lista. Nada te obliga a poner una.';

  @override
  String get obFeatPhotoLocalTitle => 'Se queda en este teléfono';

  @override
  String get obFeatPhotoLocalText =>
      'Ningún servidor la recibe, ninguna copia de seguridad en línea la conserva. Vive en la carpeta de la app, y en ningún otro lugar.';

  @override
  String get obFeatPhotoCompressTitle => 'Reducida antes de guardarse';

  @override
  String get obFeatPhotoCompressText =>
      'Droplet solo guarda una miniatura de 320 píxeles. Tu foto original nunca se copia.';

  @override
  String get obNetworkTitle => 'Droplet crece\ncontigo';

  @override
  String get obNetworkSubtitle =>
      'Cada persona que la instala amplía la red, para ella y para todos a su alrededor.';

  @override
  String get obSendToFriend => 'Enviar Droplet a alguien cercano';

  @override
  String get obFeatShareOfflineTitle =>
      'Incluso compartir prescinde de internet';

  @override
  String get obFeatShareOfflineText =>
      'Droplet te envía su propio archivo de instalación. Viaja por Bluetooth, Wi-Fi Direct o una tarjeta de memoria: sin conexión necesaria, en ningún extremo.';

  @override
  String get obFeatThreeTitle => 'Con tres personas basta para empezar';

  @override
  String get obFeatThreeText =>
      'Entre dos, os escribís al alcance de la vista. Con unos pocos en un barrio, los mensajes se retransmiten y el alcance se vuelve mucho mayor que cada teléfono.';

  @override
  String get obIdentityTitle => '¿Cómo debemos\nllamarte?';

  @override
  String get obIdentitySubtitle =>
      'Este nombre aparecerá ante las personas que te encuentres. Puedes elegir uno que no te identifique.';

  @override
  String get obPseudoHint => 'Tu nombre';

  @override
  String get obFeatKeysTitle => 'Tus claves se crean aquí, ahora mismo';

  @override
  String get obFeatKeysText =>
      'Nunca salen de este teléfono. Recuerda hacer una copia de seguridad desde los ajustes: sin ella, una identidad perdida lo está para siempre.';

  @override
  String get splashCaption => 'Sin conexión. Sin operador.';

  @override
  String get chatsMeshNetwork => 'Red mesh';

  @override
  String get chatsNew => 'Nuevo';

  @override
  String get chatsNewGroup => 'Nuevo grupo';

  @override
  String get chatsAssistant => 'Asistente';

  @override
  String get chatsEmergencyMode => 'Modo de emergencia';

  @override
  String get chatsUnpin => 'Dejar de fijar';

  @override
  String get chatsPin => 'Fijar arriba';

  @override
  String get chatsUnmute => 'Activar notificaciones';

  @override
  String get chatsMute => 'Silenciar';

  @override
  String get chatsArchive => 'Archivar';

  @override
  String get swipePin => 'Fijar';

  @override
  String get swipeUnpin => 'Soltar';

  @override
  String get swipeMute => 'Silenciar';

  @override
  String get swipeUnmute => 'Activar';

  @override
  String get swipeArchive => 'Archivar';

  @override
  String get fmtBold => 'Negrita';

  @override
  String get fmtItalic => 'Cursiva';

  @override
  String get fmtStrike => 'Tachado';

  @override
  String get fmtMono => 'Monoespaciado';

  @override
  String get fmtSpoiler => 'Spoiler';

  @override
  String get vnTranscribing => 'Transcribiendo…';

  @override
  String get vnTranscribeFailed =>
      'Transcripción no disponible en este dispositivo';

  @override
  String get vnNoSpeech => 'No se reconoció ninguna voz';

  @override
  String get msgTranslate => 'Traducir';

  @override
  String get msgShowOriginal => 'Ver original';

  @override
  String get msgTranslatedFrom => 'Traducido automáticamente';

  @override
  String get msgTranslateFailed => 'Traducción no disponible';

  @override
  String get msgTranslateModel =>
      'Hay que descargar el modelo de idioma (una vez, con Wi‑Fi)';

  @override
  String get pfWallpapers => 'Fondos animados';

  @override
  String get pfWallpapersDesc =>
      'Ocho fondos multicolores que viven detrás de tus chats y giran con cada mensaje enviado.';

  @override
  String get pfFormatting => 'Formato de texto';

  @override
  String get pfFormattingDesc =>
      'Negrita, cursiva, tachado, código y spoilers dentro de tus mensajes.';

  @override
  String get pfTranscription => 'Voz a texto';

  @override
  String get pfTranscriptionDesc =>
      'Lee un mensaje de voz cuando no puedes escucharlo. El reconocimiento ocurre en tu teléfono.';

  @override
  String get pfTranslation => 'Traducción';

  @override
  String get pfTranslationDesc =>
      'Traduce un mensaje recibido sin que su contenido salga del dispositivo.';

  @override
  String get pfAppIcons => 'Iconos de la app';

  @override
  String get pfAppIconsDesc =>
      'Cambia el icono de Droplet en tu pantalla de inicio.';

  @override
  String get pfBadge => 'Insignia y apoyo';

  @override
  String get pfBadgeDesc =>
      'Una insignia junto a tu nombre y el apoyo a un proyecto independiente.';

  @override
  String get pfUnderstood => 'Entendido';

  @override
  String get pfFeaturesTitle => 'Lo que abre el pack';

  @override
  String get chatsUnarchive => 'Desarchivar';

  @override
  String get chatsArchivedTitle => 'Archivados';

  @override
  String get chatsNoArchived => 'Sin conversaciones archivadas';

  @override
  String get chatsLockedTitle => 'Chats bloqueados';

  @override
  String get chatsNoLocked => 'Sin conversaciones bloqueadas';

  @override
  String get chatsCrashTitle => 'Droplet se cerró inesperadamente';

  @override
  String get chatsCrashBody =>
      'Droplet no tiene servidor: sin tu envío, este fallo no existe para nadie más. El informe no contiene mensajes, contactos ni claves.';

  @override
  String get chatsSendReport => 'Enviar el informe';

  @override
  String get chatsLater => 'Más tarde';

  @override
  String get stTitle => 'Ajustes';

  @override
  String get stIconHeader => 'Icono';

  @override
  String get stIconFooter =>
      'Trece iconos para elegir para la pantalla de inicio.';

  @override
  String get stAppIcon => 'Icono de la app';

  @override
  String get stVariants13 => '13 variantes';

  @override
  String get stNetworkHeader => 'Red';

  @override
  String get stNetworkFooter =>
      'El relevo en segundo plano permite transmitir los mensajes de otros incluso con Droplet cerrado.';

  @override
  String get stRequireTor => 'Exigir Tor en línea';

  @override
  String get stRequireTorSubtitle => 'Sin Tor, nada sale hacia los servidores';

  @override
  String get stRequireTorFooter =>
      'El directorio y el buzón pasan por Tor cuando está activo. Si no, Droplet se conecta directamente: el contenido sigue cifrado de extremo a extremo, pero los servidores ven tu dirección IP. Actívalo para impedirlo, a costa de la mensajería en línea cuando Tor no funciona.';

  @override
  String get stMeshNetwork => 'Red mesh';

  @override
  String get stPeersTopology => 'Pares conectados y topología';

  @override
  String get stOfflineMaps => 'Mapas sin conexión';

  @override
  String get stZonesImport => 'Zonas guardadas e importación de mapas';

  @override
  String get stSecurityHeader => 'Seguridad';

  @override
  String get stSecurityFooter =>
      'Droplet no guarda ninguna copia de tu identidad. Sin copia de seguridad, se pierde con el dispositivo.';

  @override
  String get stBackupIdentity => 'Respaldar mi identidad';

  @override
  String get stExportEncrypted => 'Exportación cifrada con contraseña';

  @override
  String get stEmergencyMode => 'Modo de emergencia';

  @override
  String get stSignalSafe => 'Indicar que estás a salvo';

  @override
  String get stContributionHeader => 'Contribución';

  @override
  String get stMyContribution => 'Mi contribución';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'Activo';

  @override
  String get stProPackUnlocked => 'Paquete desbloqueado';

  @override
  String get stProIconsThemes => 'Iconos y fondos';

  @override
  String get stCrashLog => 'Registro de errores';

  @override
  String get stAbout => 'Acerca de Droplet';

  @override
  String get stBackgroundRelay => 'Retransmisión en segundo plano';

  @override
  String get stActiveClosed => 'Activo incluso con la app cerrada';

  @override
  String get stActiveOpenOnly => 'Activo solo con la app abierta';

  @override
  String get stBatteryOptim => 'Optimización de batería';

  @override
  String get stAndroidMayLimit => 'Android puede limitar la retransmisión';

  @override
  String get stFix => 'Corregir';

  @override
  String get stKeepActiveTitle => '¿Mantener Droplet activo?';

  @override
  String get stKeepActiveBody =>
      'Una notificación permanente indicará que Droplet retransmite la malla, incluso con la app cerrada. A cambio, se consumirá más batería.';

  @override
  String get stEnable => 'Activar';

  @override
  String get stCancel => 'Cancelar';

  @override
  String get stAboutTagline =>
      'Mensajería y llamadas sin conexión, sin internet ni operador.';

  @override
  String get stAboutDirect => 'Red directa entre dispositivos: sin servidor';

  @override
  String get stAboutE2E => 'Cifrado de extremo a extremo en todos los mensajes';

  @override
  String get stAboutNoThirdParty => 'Ningún dato se envía a terceros';

  @override
  String get stAttributionEmoji =>
      'Emojis animados: Noto Animated Emoji © Google, bajo licencia CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'Asistente: Gemma 3 1B-IT © Google, cuantizado (int4) por litert-community y republicado por Droplet, bajo los términos de uso de Gemma (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'Fondo de chat';

  @override
  String get stChatPatterns => 'Dibujos Droplet';

  @override
  String get stChatPatternsSubtitle =>
      'Pequeños dibujos de línea sobre el fondo';

  @override
  String get stChatBgFooter =>
      'El degradado avanza un paso con cada mensaje enviado. Elige «Ninguno» para un fondo liso: así no se calcula nada, lo que ahorra batería.';

  @override
  String get stBgFree => 'Gratis';

  @override
  String get stBgPremium => 'Premium · animados';

  @override
  String get stBgNone => 'Ninguno';

  @override
  String get stBgDefault => 'Predeterminado';

  @override
  String get stBgThisChat => 'Fondo de este chat';

  @override
  String get stTextSize => 'Tamaño del texto';

  @override
  String get stBubbleCorners => 'Esquinas de los mensajes';

  @override
  String get stAccentHeader => 'Color de acento';

  @override
  String get stAccentFooter =>
      'Colorea tus burbujas, los botones y los enlaces en toda la app.';

  @override
  String get stChatListHeader => 'Lista de chats';

  @override
  String get stChatListTwoLines => 'Dos líneas';

  @override
  String get stChatListThreeLines => 'Tres líneas';

  @override
  String get stResetAppearance => 'Restablecer la apariencia';

  @override
  String get stPreviewIncoming => '¿Nos vemos esta noche?';

  @override
  String get stPreviewOutgoing => '¡Sí, encantado!';

  @override
  String get stAppearanceRow => 'Apariencia';

  @override
  String get stAppearanceSubtitle => 'Tema, color, tamaño del texto, fondos';

  @override
  String get stBgApply => 'Usar este fondo';

  @override
  String get stBgUnlock => 'Desbloquear con Premium';

  @override
  String get stBgApplied => 'Fondo aplicado';

  @override
  String get stBgPreviewHint =>
      'El fondo se mueve y sus colores giran con cada mensaje enviado.';

  @override
  String get stBgPreviewIncoming => '¿Has visto el nuevo fondo?';

  @override
  String get stBgPreviewOutgoing => 'Sí, es precioso ✨';

  @override
  String get stSoundHeader => 'Sonidos';

  @override
  String get stSoundToggle => 'Sonidos de la app';

  @override
  String get stSoundSubtitle => 'Mensajes, conexiones, alertas';

  @override
  String get stSoundFooter =>
      'Tonos breves, al volumen de las notificaciones del sistema — en silencio si el teléfono está en silencio o modo concentración.';

  @override
  String get stPacksHeader => 'Asistente — fichas sin conexión';

  @override
  String get stPacksToggle => 'Fichas de primeros auxilios y emergencia';

  @override
  String get stPacksSubtitle =>
      'El asistente se apoya en ellas para primeros auxilios y emergencias.';

  @override
  String get stPacksFooter =>
      'Fichas de referencia integradas (primeros auxilios, terremoto, inundación, agua potable…). Cuando la pregunta lo requiere, el asistente cita la ficha en vez de improvisar. No sustituyen una formación ni una llamada a emergencias.';

  @override
  String get stPrivateModeHeader => 'Modo privado';

  @override
  String get stTorFooter =>
      'Tor protege tu dirección IP y tus conversaciones haciéndolas pasar por la red Tor. La malla local (BLE/Wi-Fi) sigue funcionando con normalidad.';

  @override
  String get stTorActiveAnon => 'Activo: tus datos están anonimizados';

  @override
  String get stTorConnecting => 'Conectando…';

  @override
  String get stTorDisabled => 'Modo privado desactivado';

  @override
  String get callsTitle => 'Llamadas';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count llamadas perdidas',
      one: '$count llamada perdida',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'Nueva llamada';

  @override
  String get callsAll => 'Todas';

  @override
  String get callsMissed => 'Perdidas';

  @override
  String get callsNoneMissed => 'Sin llamadas perdidas';

  @override
  String get callsNone => 'Sin llamadas';

  @override
  String get callsMissedEmptyBody =>
      'Las llamadas que no contestaste aparecerán aquí.';

  @override
  String get callsEmptyBody =>
      'Las llamadas pasan por la red local, sin operador ni tarifa. Tu historial aparecerá aquí.';

  @override
  String get callsRetained200 =>
      'Las últimas 200 llamadas se guardan solo en este dispositivo.';

  @override
  String get callsIncoming => 'Entrante';

  @override
  String get callsOutgoing => 'Saliente';

  @override
  String get callsMissedLabel => 'Perdida';

  @override
  String get callsNoAnswer => 'Sin respuesta';

  @override
  String get callsConnectionFailed => 'Fallo de conexión';

  @override
  String get callsYesterday => 'ayer';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m min $s s';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s s';
  }

  @override
  String get peersTitle => 'Contactos';

  @override
  String get peersSearching => 'Buscando…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dispositivos al alcance',
      one: '$count dispositivo al alcance',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'Mapa de la red';

  @override
  String get peersNoneInRange => 'Nadie al alcance';

  @override
  String get peersNoneInRangeBody =>
      'Droplet busca constantemente dispositivos cercanos. Acércate a alguien con la app para establecer la primera conexión.';

  @override
  String get peersDirectRange => 'Al alcance directo';

  @override
  String get peersDirectRangeFooter =>
      'Estos dispositivos son accesibles sin pasar por nadie más.';

  @override
  String get peersRelayed => 'Por retransmisión';

  @override
  String get peersRelayedFooter =>
      'Estos dispositivos están fuera de alcance directo: los mensajes les llegan a través de otros teléfonos.';

  @override
  String get peersRelay => 'Retransmisor';

  @override
  String get peersCall => 'Llamar';

  @override
  String get peersTooSlow => 'Demasiado lento para voz: acércate';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'Bluetooth';

  @override
  String get peersUnknownLink => 'Enlace desconocido';

  @override
  String get peersDirect => 'directo';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saltos',
      one: '$count salto',
      zero: 'directo',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'Este estado ha caducado';

  @override
  String get svReceiving => 'Recibiendo…';

  @override
  String get svReceivingBody => 'El archivo llega por la red local';

  @override
  String get svProgressLabel => 'Progreso del estado';

  @override
  String get svReplyHint => 'Responder…';

  @override
  String get svSendReply => 'Enviar respuesta';

  @override
  String get svYourStatus => 'Tu estado';

  @override
  String get svNoViewsYet =>
      'Nadie ha visto este estado todavía.\nSeguirá circulando mientras te cruces con otros dispositivos.';

  @override
  String get svJustNow => 'justo ahora';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count min',
      one: 'hace $count min',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count h',
      one: 'hace $count h',
    );
    return '$_temp0';
  }

  @override
  String get svDefaultMusicTitle => 'Música';

  @override
  String svViewsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vistas',
      one: '$count vista',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '$count me gusta',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '$count respuesta',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'Original';

  @override
  String get cpFilterDark => 'Oscuro';

  @override
  String get cpFilterBright => 'Luminoso';

  @override
  String get cpFilterVintage => 'Vintage';

  @override
  String get cpWriteStatusHint => 'Escribe un estado';

  @override
  String get cpPreparingVideo => 'Preparando el video…';

  @override
  String get cpLoadingEllipsis => 'Cargando…';

  @override
  String cpEndsIn(Object s) {
    return 'Termina en $s s';
  }

  @override
  String get cpModeVideo => 'Video';

  @override
  String get cpModePhoto => 'Foto';

  @override
  String get cpModeMessage => 'Mensaje';

  @override
  String get cpModeVoice => 'Voz';

  @override
  String get gcChooseName => 'Elige un nombre para el grupo';

  @override
  String get gcSelectOneMember => 'Selecciona al menos un miembro';

  @override
  String get gcCreationFailed => 'Error al crear el grupo';

  @override
  String get gcNewGroup => 'Nuevo grupo';

  @override
  String get gcGroupName => 'Nombre del grupo';

  @override
  String get gcNameHint => 'ej. Equipo de campo';

  @override
  String get gcMembers => 'Miembros';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '$count seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'Nadie al alcance';

  @override
  String get gcGetCloserBody =>
      'Acércate a otro dispositivo con Droplet: los contactos aparecen aquí automáticamente.';

  @override
  String get gcCreateGroup => 'Crear grupo';

  @override
  String get gcConnected => 'Conectado';

  @override
  String get gcAlreadyMet => 'Ya conocido';

  @override
  String get giRenameGroup => 'Renombrar grupo';

  @override
  String get giRenameFailed => 'Error al renombrar';

  @override
  String get giNoPeerToAdd => 'No hay contactos disponibles para añadir';

  @override
  String get giAddMemberHeader => 'AÑADIR UN MIEMBRO';

  @override
  String get giAddMemberFailed => 'Error al añadir al miembro';

  @override
  String get giRemoveMemberTitle => '¿Quitar a este miembro?';

  @override
  String get giRemoveMemberBody =>
      'No podrá leer los mensajes enviados después de su retiro.';

  @override
  String get giRemove => 'Quitar';

  @override
  String get giRemoveMemberFailed => 'Error al quitar al miembro';

  @override
  String get giLeaveGroupTitle => '¿Salir del grupo?';

  @override
  String get giLeaveGroupBody =>
      'No recibirás los mensajes enviados después de tu salida.';

  @override
  String get giLeave => 'Salir';

  @override
  String get giNoOneReachable =>
      'Ningún miembro alcanzable por Wi-Fi local por ahora';

  @override
  String get giMax4Participants =>
      'Máximo 4 participantes por llamada grupal: solo se llamará a los 3 primeros alcanzables';

  @override
  String get giGroupNotFound => 'Grupo no encontrado';

  @override
  String get giGroupInfo => 'Info del grupo';

  @override
  String get giGroupCall => 'Llamada grupal';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '$count miembro',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'Mensajes de grupo cifrados';

  @override
  String get giAdd => 'Añadir';

  @override
  String get giMe => 'yo';

  @override
  String get giAdministrator => 'Administrador';

  @override
  String get giLeaveGroup => 'Salir del grupo';

  @override
  String get sfNoLocationShared => 'Ubicación no compartida';

  @override
  String get sfLocationShared => 'Ubicación compartida';

  @override
  String sfDistanceMeters(Object m) {
    return 'a $m m';
  }

  @override
  String sfDistanceKm(Object km) {
    return 'a $km km';
  }

  @override
  String get sfBearingN => 'al norte';

  @override
  String get sfBearingNE => 'al noreste';

  @override
  String get sfBearingE => 'al este';

  @override
  String get sfBearingSE => 'al sureste';

  @override
  String get sfBearingS => 'al sur';

  @override
  String get sfBearingSW => 'al suroeste';

  @override
  String get sfBearingW => 'al oeste';

  @override
  String get sfBearingNW => 'al noroeste';

  @override
  String get sfBroadcastSafeTitle => '¿Difundir \"Estoy a salvo\"?';

  @override
  String get sfBroadcastSafeMessage =>
      'Este estado será visible para toda la malla al alcance, no solo tus contactos. Puedes incluir una ubicación aproximada (redondeada, nunca exacta).';

  @override
  String get sfWithLocation => 'Con ubicación aprox.';

  @override
  String get sfWithoutLocation => 'Sin ubicación';

  @override
  String get sfStatusBroadcast => 'Estado difundido a la malla';

  @override
  String get sfBroadcastFailed => 'Error al difundir';

  @override
  String get sfHelpRequestTitle => '¿Difundir \"Necesito ayuda\"?';

  @override
  String get sfHelpRequestMessage =>
      'Este estado indicará a los pares al alcance que necesitas asistencia. Puedes incluir una ubicación aproximada.';

  @override
  String get sfHelpRequestBroadcast =>
      'Solicitud de ayuda difundida a la malla';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace $count día',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'Modo de emergencia';

  @override
  String get sfViewOnMap => 'Ver en el mapa';

  @override
  String get sfNeedHelp => 'Necesito ayuda';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Check-ins recibidos ($count)',
      one: 'Check-in recibido ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'Aún no se ha recibido ningún check-in';

  @override
  String get sfCheckinsAppearHere =>
      'Los estados \"a salvo\" difundidos por los pares al alcance aparecerán aquí.';

  @override
  String get sfSafeLabel => 'A salvo';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'A salvo · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'A salvo · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'Difundir mi estado de seguridad a la red mesh';

  @override
  String get sfImSafe => 'Estoy a salvo';

  @override
  String get emSosActive => 'SOS ACTIVO';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'Señal SOS activa: difundida a todos los dispositivos cercanos';

  @override
  String get emPullToSendSignal => 'Toca para enviar una señal de emergencia';

  @override
  String get emSignalRelayedDescription =>
      'La señal se retransmite de par en par\npor toda la red mesh.';

  @override
  String get emBroadcasting => 'Difundiendo...';

  @override
  String get emSharePosition => 'Compartir mi ubicación';

  @override
  String get emSosActivated => 'Señal SOS activada';

  @override
  String get emSafeStatusMessage => '🟢 Estoy a salvo';

  @override
  String get emSafetyStatusBroadcast => 'Estado de seguridad difundido';

  @override
  String get pmEnterPayingNumber =>
      'Introduce el número que va a pagar (9 dígitos).';

  @override
  String get pmRequestSent => 'Solicitud enviada…';

  @override
  String get pmPaymentLaunchFailed =>
      'No se pudo iniciar el pago. Comprueba el número y tu conexión, o paga manualmente más abajo.';

  @override
  String get pmValidateOnPhone =>
      'Confirma en tu teléfono: introduce tu código Mobile Money cuando aparezca el aviso.';

  @override
  String get pmPaymentNotConfirmed =>
      'Pago no confirmado. No se ha desbloqueado nada.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'El pago se realizó pero la licencia recibida no es válida. Escríbenos, se rehará: $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro activado';

  @override
  String get pmPackUnlocked => 'Pack desbloqueado';

  @override
  String get pmInvalidCode =>
      'Este código no es válido en este dispositivo. Comprueba que has enviado el código de dispositivo mostrado arriba.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'Lo que Droplet\nnunca pedirá';

  @override
  String get pmNeverAskBody =>
      'Sin publicidad, sin suscripción obligatoria, sin reventa de tus datos: ni siquiera hay un servidor para recopilarlos. El pack y Pro financian el resto.';

  @override
  String get pmCommunitySemantics =>
      'Únete a la comunidad de más de 1200 miembros activos';

  @override
  String get pmCommunityText => 'Únete a más de 1200 miembros en la malla';

  @override
  String get pmProPreviewSemantics =>
      'Vista previa de las funciones Pro desbloqueadas';

  @override
  String get pmAnimatedEmojis => 'Emojis\nanimados';

  @override
  String get pmWallpapers => 'Fondos\nde pantalla';

  @override
  String get pmAppIcons => 'Iconos\nde la app';

  @override
  String get pmOnceForLife => 'una vez, de por vida';

  @override
  String get pmProAdvantage1 => 'Los diez iconos y los ocho fondos del pack';

  @override
  String get pmProAdvantage2 => 'La insignia Pro junto a tu nombre';

  @override
  String get pmProAdvantage3 => 'Las funciones futuras, sin coste adicional';

  @override
  String get pmPackTitle => 'El pack';

  @override
  String get pmOnce => 'una vez';

  @override
  String get pmPackAdvantage1 => 'Diez iconos de aplicación adicionales';

  @override
  String get pmPackAdvantage2 => 'Ocho fondos de conversación';

  @override
  String get pmPayByHand => 'O pagar manualmente';

  @override
  String get pmHowTo => 'Cómo hacerlo';

  @override
  String get pmIfPromptDoesNotArrive =>
      'Si el aviso no llega a tu teléfono, o si prefieres enviar el dinero tú mismo.';

  @override
  String pmStep1Title(Object montant) {
    return 'Envía $montant F';
  }

  @override
  String get pmStep1Body =>
      'Elige tu operador: se abre su menú, y el número permanece visible aquí mientras lo recorres.';

  @override
  String get pmStep2Title => 'Envía tu código de dispositivo';

  @override
  String get pmStep2Body =>
      'Junto con la captura del pago. Sin este código, la licencia no se puede generar: solo es válida para tu teléfono.';

  @override
  String get pmStep3Title => 'Recibes una licencia';

  @override
  String get pmStep3Body =>
      'Una línea larga que empieza por DROP1. Pégala abajo: el desbloqueo es instantáneo y funciona sin conexión, para siempre.';

  @override
  String get pmPayNow => 'Pagar ahora';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money u Orange Money, desde este teléfono o desde otro.';

  @override
  String get pmPhoneNumberSemantics =>
      'Número de teléfono para el pago Mobile Money';

  @override
  String get pmWaitingForCode => 'Esperando tu código…';

  @override
  String pmPayAmount(Object montant) {
    return 'Pagar $montant F';
  }

  @override
  String get pmRestorePurchaseSemantics => 'Restaurar una compra anterior';

  @override
  String get pmAlreadyPaidRestore => '¿Ya has pagado? Restaurar';

  @override
  String pmDialCode(Object code) {
    return 'Marca $code desde tu teléfono';
  }

  @override
  String get pmChooseOperatorSemantics => 'Elegir un operador de pago';

  @override
  String get pmNumberAmountFilled =>
      'Número e importe ya rellenados: solo falta tu código secreto.';

  @override
  String get pmOrangeMenuInstructions =>
      'En el menú de Orange: transferencia de dinero, luego el número y el importe de abajo.';

  @override
  String get pmLabelNumber => 'Número';

  @override
  String get pmLabelAmount => 'Importe';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return 'Pagar $montant francos con $operator';
  }

  @override
  String get pmMenuOpen => 'Menú abierto';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'Hola, acabo de pagar por Droplet.\n\nOferta: $offer\nImporte: $amount F\nCódigo de dispositivo: $code\n\n(adjunto la captura del pago)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'No se encontró WhatsApp: código copiado. Envíalo a $contact';
  }

  @override
  String get pmPrepareRequest => 'Preparar mi solicitud';

  @override
  String get pmReceivedLicense => 'He recibido mi licencia';

  @override
  String get pmPaste => 'Pegar';

  @override
  String get pmUnlock => 'Desbloquear';

  @override
  String get pmProIsActive => 'Droplet Pro está activo';

  @override
  String get pmPackIsUnlocked => 'El pack está desbloqueado';

  @override
  String get pmProActiveDescription =>
      'La insignia Pro acompaña tu nombre, y todos los iconos y fondos están disponibles para ti.';

  @override
  String get pmPackActiveDescription =>
      'Los diez iconos y los ocho fondos del pack están disponibles para ti, en los ajustes.';

  @override
  String get pmLicenseDeviceBound =>
      'Tu licencia es válida para este teléfono. Si lo cambias, conserva el mensaje que la contiene: se rehará gratis.';

  @override
  String torError(Object e) {
    return 'Error: $e';
  }

  @override
  String get torEnable => 'Activar Tor';

  @override
  String get torProtected => 'Protegido';

  @override
  String get torDisabled => 'Desactivado';

  @override
  String get torStateHeader => 'Estado';

  @override
  String get torCircuit => 'Circuito';

  @override
  String get torActive => 'Activo';

  @override
  String get torInProgress => 'En curso…';

  @override
  String get torInactive => 'Inactivo';

  @override
  String get torFailed => 'Fallo';

  @override
  String get torReason => 'Motivo';

  @override
  String get torBannerConnecting => 'Conectando a Tor…';

  @override
  String get torBannerActive => 'Tor activo';

  @override
  String get torBannerError => 'Tor no disponible';

  @override
  String get torBannerOff => 'Tor apagado';

  @override
  String get torEncryption => 'Cifrado';

  @override
  String get torLatency => 'Latencia';

  @override
  String get torContactsHeader => 'Contactos';

  @override
  String get torScanQrFooter =>
      'Escanea un código QR, o busca un nombre en el directorio, para añadir un contacto remoto.';

  @override
  String get torScanQrCode => 'Escanear un código QR';

  @override
  String get torMyQrCode => 'Mi código QR';

  @override
  String get torInformationHeader => 'Información';

  @override
  String get torVersion => 'Versión';

  @override
  String get torHowItWorks => '¿Cómo funciona?';

  @override
  String get torConnecting => 'Conectando…';

  @override
  String get torInactiveTitle => 'Tor inactivo';

  @override
  String get torDataThroughTor => 'Tus datos pasan por la red Tor';

  @override
  String get torEstablishingCircuit => 'Estableciendo el circuito (10-30s)';

  @override
  String get torActivateToProtect => 'Actívalo para proteger tu identidad';

  @override
  String get torHowItWorksTitle => 'Cómo Tor protege tus datos';

  @override
  String get torEncryptedCircuit => 'Circuito cifrado';

  @override
  String get torEncryptedCircuitDesc =>
      'Tus mensajes pasan por 3 nodos Tor repartidos por el mundo.';

  @override
  String get torHiddenIp => 'IP oculta';

  @override
  String get torHiddenIpDesc => 'Ningún sitio puede ver tu dirección real.';

  @override
  String get torMeshPreserved => 'Malla preservada';

  @override
  String get torMeshPreservedDesc =>
      'El Bluetooth y el Wi-Fi local siguen funcionando.';

  @override
  String get torUnderstood => 'Entendido';

  @override
  String get qrTorNotActive => 'Tor no está activo. Actívalo en Ajustes > Tor.';

  @override
  String get qrScanContactCode => 'Escanea el código QR de un contacto';

  @override
  String get qrCodeFromContactScreen =>
      'El código debe provenir de la pantalla Tor de tu contacto';

  @override
  String get qrScanAnother => 'Escanear otro';

  @override
  String get qrChat => 'Chatear';

  @override
  String get qgScanToConnect => 'Escanea para conectar';

  @override
  String get qgCopied => 'Copiado ✓';

  @override
  String get qgCopyCode => 'Copiar el código';

  @override
  String get qgHowItWorks => 'Cómo funciona';

  @override
  String get qgStep1 => 'Muestra este código QR a tu contacto';

  @override
  String get qgStep2 => 'Lo escanea desde su pantalla Tor';

  @override
  String get qgStep3 => 'Estáis conectados a través de Tor';

  @override
  String get shShareTo => 'Compartir con…';

  @override
  String get shSearchConversation => 'Buscar una conversación';

  @override
  String get shNoConversation => 'Ninguna conversación';

  @override
  String get shOpenChatFirst =>
      'Abre primero una conversación en Droplet para poder compartir contenido en ella.';

  @override
  String get shGroup => 'Grupo';

  @override
  String get shDiscussion => 'Conversación';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos para compartir',
      one: '$count elemento para compartir',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'Mapa instalado';

  @override
  String get omClearCacheTitle => '¿Vaciar la caché?';

  @override
  String get omRemoveZoneTitle => '¿Eliminar esta zona?';

  @override
  String get omClearCacheMessage =>
      'Las zonas que has explorado ya no estarán disponibles sin conexión. Se reconstruirán al consultarlas de nuevo con red.';

  @override
  String omRemoveZoneMessage(Object name) {
    return '«$name» se eliminará de este dispositivo.';
  }

  @override
  String get omClear => 'Vaciar';

  @override
  String get omTitle => 'Mapas';

  @override
  String get omReading => 'Leyendo…';

  @override
  String get omNoMapsSaved => 'Ningún mapa guardado';

  @override
  String omSizeOnDevice(Object size) {
    return '$size en este dispositivo';
  }

  @override
  String get omBrowseMapHint =>
      'Explora el mapa con red: las zonas que consultas permanecen disponibles sin conexión.';

  @override
  String get omOnThisDevice => 'En este dispositivo';

  @override
  String get omZonesFillThemselves =>
      'Las zonas consultadas se rellenan solas mientras exploras el mapa con red.';

  @override
  String get omMbtilesExplainer =>
      'Un archivo .mbtiles contiene una región entera, preparada de antemano. Es el formato estándar de los mapas sin conexión: cualquier herramienta cartográfica sabe generarlo.';

  @override
  String get omImportMap => 'Importar un mapa';

  @override
  String get omReadingFile => 'Leyendo el archivo…';

  @override
  String get omMbtilesFromPhone => 'Archivo .mbtiles desde este teléfono';

  @override
  String get omAttributionText =>
      'Los datos provienen de OpenStreetMap (licencia ODbL), el fondo de mapa lo sirve CARTO. Droplet nunca descarga una región entera de antemano: ningún servicio gratuito lo permite. Solo se conserva lo que consultas.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teselas',
      one: '$count tesela',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '$k k teselas';
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
  String get nwTitle => 'Novedades';

  @override
  String get nwStatusesNetwork24h => 'Estados de la red · 24 h';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estados de la red',
      one: '$count estado de la red',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'Publicar un estado';

  @override
  String get nwNoNewsYet => 'Sin novedades por ahora';

  @override
  String get nwStatusesAppearHere =>
      'Los estados publicados por las personas al alcance aparecerán aquí, sin pasar por internet.';

  @override
  String get nwRecent => 'Recientes';

  @override
  String get nwStatusExpires =>
      'Un estado desaparece por sí solo 24 horas después de su publicación.';

  @override
  String get nwPhoto => '📷 Foto';

  @override
  String get nwVideo => '🎥 Vídeo';

  @override
  String get nwVoiceMessage => '🎤 Mensaje de voz';

  @override
  String get nwMusic => '🎵 Música';

  @override
  String get nwStatusFallback => 'Estado';

  @override
  String get nwMyStatus => 'Mi estado';

  @override
  String get nwTapToPublish => 'Toca para publicar en la red';

  @override
  String get nwNotSeenYet => 'Aún no visto';

  @override
  String nwSeenByCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto por $count',
      one: 'Visto por $count',
    );
    return '$_temp0';
  }

  @override
  String get mpLocationUnavailable =>
      'Ubicación no disponible — comprueba que la localización esté activada.';

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
    return '$distance de ti';
  }

  @override
  String get mpTitle => 'Ubicación';

  @override
  String get mpOffline => 'Sin conexión';

  @override
  String get mpOnlineMap => 'Mapa en línea';

  @override
  String get mpMyPosition => 'Mi ubicación';

  @override
  String get mpLayers => 'Capas';

  @override
  String get mpOfflineToast =>
      'Mapa sin conexión: solo se mostrarán las zonas ya guardadas.';

  @override
  String get mpOnlineToast =>
      'Mapa en línea: las zonas consultadas se guardarán para más tarde.';

  @override
  String get mpMapLabel => 'Mapa';

  @override
  String get mpSatelliteLabel => 'Satélite';

  @override
  String get mpSatelliteMode => 'Modo satélite';

  @override
  String get mpMapMode => 'Modo mapa';

  @override
  String get mpWrite => 'Escribir';

  @override
  String get mpCenter => 'Centrar';

  @override
  String get mpNoOneOnMap => 'Nadie en el mapa';

  @override
  String get mpPositionsAppearHere =>
      'Las ubicaciones aparecen aquí cuando un contacto las comparte desde el modo Seguridad.';

  @override
  String get mpYou => 'Tú';

  @override
  String get mnTitle => 'Red mesh';

  @override
  String get mnPeers => 'Pares';

  @override
  String get mnAvgHops => 'Saltos prom.';

  @override
  String get mnSignal => 'Señal';

  @override
  String get mnStrong => 'Fuerte';

  @override
  String get mnMedium => 'Media';

  @override
  String get mnSearchingPeers => 'Buscando pares al alcance…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pares conectados',
      one: '$count par conectado',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'Ningún par conectado por ahora';

  @override
  String get mnGetCloserHint =>
      'Acércate a otro dispositivo con Droplet instalado: el descubrimiento se hace automáticamente, sin configuración.';

  @override
  String get mnConnectedPeersHeader => 'Pares conectados';

  @override
  String mnHopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saltos',
      one: '$count salto',
    );
    return '$_temp0';
  }

  @override
  String get mnBluetooth => 'Bluetooth';

  @override
  String get mnWifiLocal => 'Wi-Fi local';

  @override
  String get mnP2pNative => 'P2P nativo';

  @override
  String get mnActiveGateway => 'Puerta de enlace activa';

  @override
  String get mnPath => 'Ruta';

  @override
  String get mnTransport => 'Transporte';

  @override
  String get mnBattery => 'Batería';

  @override
  String get mnScore => 'Puntuación';

  @override
  String get mnReconnecting => 'Reconectando';

  @override
  String get cnBronze => 'Bronce';

  @override
  String get cnSilver => 'Plata';

  @override
  String get cnGold => 'Oro';

  @override
  String get cnDiamond => 'Diamante';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count puntos',
      one: '$count punto',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '$points antes del nivel $tier';
  }

  @override
  String get cnRelayedMessages => 'Mensajes retransmitidos para otros';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n pts';
  }

  @override
  String get cnGatewayMinutes => 'Minutos en modo repetidor (gateway)';

  @override
  String get cnExplanation =>
      'Cada mensaje que tu dispositivo retransmite para otros, y cada minuto que permanece disponible como repetidor, ayuda a la red mesh a llegar a más gente, más lejos. Esta insignia no tiene ningún efecto en la app: es solo un reconocimiento de tu contribución.';

  @override
  String get nmTitle => 'Nuevo mensaje';

  @override
  String get nmNewGroup => 'Nuevo grupo';

  @override
  String get nmScanCode => 'Escanear un código';

  @override
  String get nmVerifyContactIdentity => 'Verificar la identidad de un contacto';

  @override
  String get nmNoOneInRange => 'Nadie al alcance';

  @override
  String get nmNoResult => 'Sin resultados';

  @override
  String get nmPeopleWillAppearHere =>
      'Las personas que tu dispositivo detecte aparecerán aquí.';

  @override
  String get nmInRange => 'Al alcance';

  @override
  String get nmDirectConnection => 'Conexión directa';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vía $count repetidores',
      one: 'Vía $count repetidor',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'Archivo demasiado grande (máx. 50 MB)';

  @override
  String get chCannotReadMedia => 'No se puede leer este archivo multimedia';

  @override
  String get chLocationDenied =>
      'Ubicación denegada: actívala en los ajustes del teléfono para compartir tu posición.';

  @override
  String get chGettingPosition => 'Obteniendo la posición…';

  @override
  String get chPositionUnavailable =>
      'Ubicación no disponible: inténtalo de nuevo al aire libre.';

  @override
  String get chMicPermissionDenied => 'Permiso de micrófono denegado';

  @override
  String get chCannotStartRecording => 'No se puede iniciar la grabación';

  @override
  String get chVoiceSendFailed => 'No se puede enviar el mensaje de voz';

  @override
  String get chFileSendFailed => 'No se puede enviar el archivo';

  @override
  String get chAudioNotFullyReceived =>
      'El audio aún no se ha recibido por completo';

  @override
  String get chVoiceUnreadable =>
      'Este mensaje de voz no se puede reproducir; puede que haya llegado incompleto.';

  @override
  String get chFileNotFullyReceived =>
      'El archivo aún no se ha recibido por completo';

  @override
  String get chSaveFailed => 'No se puede guardar';

  @override
  String chSavedIn(Object folder) {
    return 'Guardado en $folder';
  }

  @override
  String get chMessageCopied => 'Mensaje copiado';

  @override
  String get chCallImpossibleRelay =>
      'Llamada de voz no posible: este par solo es accesible por retransmisión o Bluetooth, demasiado lento para la voz. Acércate para pasar a Wi-Fi.';

  @override
  String chUrlCopied(Object url) {
    return 'URL copiada: $url';
  }

  @override
  String get chEditMessageTitle => 'Editar mensaje';

  @override
  String get chMessageHint => 'Mensaje';

  @override
  String get chNeverMet => 'Nunca visto';

  @override
  String get chSeenJustNow => 'Visto ahora mismo';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto hace $count minutos',
      one: 'Visto hace $count minuto',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto hace $count horas',
      one: 'Visto hace $count hora',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'Visto ayer';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto hace $count días',
      one: 'Visto hace $count día',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'Fuera de alcance';

  @override
  String get chCloseSearchTooltip => 'Cerrar búsqueda';

  @override
  String get chNetworkDetailsSemantics => 'Red Droplet, ver detalles';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miembros',
      one: '$count miembro',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'escribiendo…';

  @override
  String get chBroadcastChannel => 'Canal de difusión';

  @override
  String get chNearby => 'Cerca';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Accesible vía $count repetidores',
      one: 'Accesible vía $count repetidor',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'Reconectando…';

  @override
  String get chSearchInConversation => 'Buscar en la conversación';

  @override
  String get chVoiceCall => 'Llamada de voz';

  @override
  String get chVideoCall => 'Videollamada';

  @override
  String get chCallImpossibleBtRelay =>
      'Llamada no posible: conexión Bluetooth o retransmitida';

  @override
  String get chGroupInfoTooltip => 'Información del grupo';

  @override
  String get chNoneFound => 'Ninguno';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'Resultado anterior';

  @override
  String get chNewerResult => 'Resultado más reciente';

  @override
  String get chLoadingOlderMessages => 'Cargando mensajes anteriores…';

  @override
  String get chToday => 'Hoy';

  @override
  String get chYesterday => 'Ayer';

  @override
  String get chMonday => 'Lunes';

  @override
  String get chTuesday => 'Martes';

  @override
  String get chWednesday => 'Miércoles';

  @override
  String get chThursday => 'Jueves';

  @override
  String get chFriday => 'Viernes';

  @override
  String get chSaturday => 'Sábado';

  @override
  String get chSunday => 'Domingo';

  @override
  String get chSayHello => 'Saluda 👋';

  @override
  String get chBroadcastEmptyBody =>
      'Los mensajes sin destinatario aparecen aquí.';

  @override
  String get chP2pRelayedBody =>
      'Tus intercambios se retransmiten de par en par, sin Internet.';

  @override
  String get chReply => 'Responder';

  @override
  String get chReplyInThread => 'Responder en el hilo';

  @override
  String get chCopy => 'Copiar';

  @override
  String get chAccessibilityMe => 'Yo';

  @override
  String get chPhotoLabel => 'Foto';

  @override
  String get chVideoLabel => 'Vídeo';

  @override
  String get chVoiceMessageLabel => 'Mensaje de voz';

  @override
  String chFileLabel(Object name) {
    return 'Archivo $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'Sticker $name';
  }

  @override
  String get chSendingStatus => 'enviando';

  @override
  String get chPendingStatus => 'pendiente';

  @override
  String get chFailedStatus => 'error al enviar';

  @override
  String get chReadStatus => 'leído';

  @override
  String get chDeliveredStatus => 'entregado';

  @override
  String get chSentStatus => 'enviado';

  @override
  String get chForwarded => 'Reenviado';

  @override
  String get chRetrySendLabel => 'Reintentar envío';

  @override
  String get chTransmissionDetailsLabel => 'Detalles de la transmisión';

  @override
  String get chEditedBadge => 'editado';

  @override
  String get chFileWord => 'Archivo';

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
  String get chVideoReceiving => 'Recibiendo el vídeo';

  @override
  String get chPreparingVideo => 'Preparando el vídeo…';

  @override
  String get nmContacts => 'Contactos';

  @override
  String get nmFindByPseudo => 'Buscar por alias';

  @override
  String get nmViaInternet => 'Por Internet';

  @override
  String get nmOutOfRange => 'Fuera de alcance';

  @override
  String get chatsInvitePerson => 'Invitar a alguien';

  @override
  String get ivTitle => 'Invita a los tuyos';

  @override
  String get ivSubtitle =>
      'Droplet es mejor cuando están los que importan, incluso sin red.';

  @override
  String get ivByNumber => 'Por número de teléfono';

  @override
  String get ivNumberHint => 'Número con prefijo (+34…)';

  @override
  String get ivContacts => 'Contactos';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'Por enlace';

  @override
  String get ivCopy => 'Copiar';

  @override
  String get ivShare => 'Compartir';

  @override
  String get ivCopied => 'Enlace copiado';

  @override
  String get ivByQr => 'Por código QR';

  @override
  String get ivQrHint => 'Que la otra persona lo escanee, en persona.';

  @override
  String get ivScan => 'Escanear un código';

  @override
  String get ivPrivacy =>
      'El enlace y el código solo contienen tu identificador público y tu clave. Ningún número se envía a Droplet.';

  @override
  String get evTitle => 'Editar vídeo';

  @override
  String evSplit(int n) {
    return 'Dividir en $n estados';
  }

  @override
  String evSplitHint(int s) {
    return 'Cada parte dura como máximo $s s';
  }

  @override
  String evPublished(int n) {
    return '$n estados publicados';
  }

  @override
  String get svReply => 'Responder';

  @override
  String get svStatusLabel => 'Estado';

  @override
  String svSeenBy(int n) {
    return 'Visto por $n';
  }

  @override
  String get clMissedVoice => 'Llamada de voz perdida';

  @override
  String get clMissedVideo => 'Videollamada perdida';

  @override
  String get clCallBack => 'Devolver llamada';

  @override
  String get stoTitle => 'Almacenamiento';

  @override
  String get stoSubtitle => 'Fotos, vídeos y archivos';

  @override
  String stoUsed(String taille) {
    return '$taille usados';
  }

  @override
  String get stoPhotos => 'Fotos';

  @override
  String get stoVideos => 'Vídeos';

  @override
  String get stoAudio => 'Voz y audio';

  @override
  String get stoDocuments => 'Documentos';

  @override
  String get stoOther => 'Otros (estados…)';

  @override
  String get stoByChat => 'Por chat';

  @override
  String get stoEmpty => 'Ningún archivo en este teléfono';

  @override
  String stoDelete(int n) {
    return 'Eliminar ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'Estos archivos y sus mensajes se eliminarán de este teléfono.';

  @override
  String get tabSelectChat => 'Elige un chat';

  @override
  String get clConnecting => 'Conectando…';

  @override
  String chUnreadMessages(int n) {
    return '$n mensaje(s) sin leer';
  }

  @override
  String get csMessagesSection => 'Mensajes';

  @override
  String chGroupTyping(String noms) {
    return '$noms está escribiendo…';
  }

  @override
  String get tsReadBy => 'Leído por';

  @override
  String get tsDeliveredTo => 'Entregado a';

  @override
  String get tsWaitingFor => 'En espera';

  @override
  String get chSelect => 'Seleccionar';

  @override
  String get chForward => 'Reenviar';

  @override
  String get chForwardTo => 'Reenviar a…';

  @override
  String chSelectedCount(int n) {
    return '$n seleccionados';
  }

  @override
  String get chForwarded1 => 'Mensaje reenviado';

  @override
  String get apCaptionHint => 'Añadir un pie de foto…';

  @override
  String get apValidateCrop => 'Recortar';

  @override
  String get chMediaReceiving => 'Recibiendo';

  @override
  String get chStickersTooltip => 'Stickers';

  @override
  String get chAttachTooltip => 'Adjuntar';

  @override
  String get chDeleteRecordingTooltip => 'Eliminar grabación';

  @override
  String get chSlideToCancel => 'Desliza para cancelar';

  @override
  String chReplyingTo(Object pseudo) {
    return 'Respondiendo a $pseudo';
  }

  @override
  String get chEffectBoom => 'Boom';

  @override
  String get chEffectLoud => 'Fuerte';

  @override
  String get chEffectGentle => 'Suave';

  @override
  String get chEffectInvisibleInk => 'Tinta invisible';

  @override
  String get chEffectConfetti => 'Confeti';

  @override
  String get chEffectFireworks => 'Fuegos artificiales';

  @override
  String get chEffectHearts => 'Corazones';

  @override
  String get chEffectSheetTitle => 'Efecto del mensaje';

  @override
  String get chEffectSheetSubtitle =>
      'Se reproduce una vez, en tu pantalla y en la de tu interlocutor';

  @override
  String get chOnBubble => 'En la burbuja';

  @override
  String get chFullscreen => 'Pantalla completa';

  @override
  String get chTapToReveal => 'Toca para revelar';

  @override
  String get chThreadTitle => 'Hilo de conversación';

  @override
  String get chReplyHint => 'Respuesta…';

  @override
  String get chCollapse => 'Contraer';

  @override
  String get chSeeMore => 'Ver más';

  @override
  String get chMessageOptionsSemantics => 'Opciones del mensaje';

  @override
  String get chLoveReactionSemantics => 'Me encanta';

  @override
  String get chBroadcastMesh => 'Difusión mesh';

  @override
  String get chGroupFallback => 'Grupo';

  @override
  String get ciSetupBiometrics =>
      'Configura una huella dactilar o Face ID en los ajustes de tu dispositivo.';

  @override
  String get ciEnableLockReason => 'Activar el bloqueo para esta conversación';

  @override
  String get ciInfoTitle => 'Información';

  @override
  String get ciViewConversation => 'Ver conversación';

  @override
  String get ciGatewayOnline => 'Puerta de enlace · en línea';

  @override
  String get ciOnline => 'En línea';

  @override
  String get ciOffline => 'Sin conexión';

  @override
  String get ciMessages => 'Mensajes';

  @override
  String get ciMedia => 'Multimedia';

  @override
  String get ciStart => 'Inicio';

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
      other: 'Notas de voz ($count)',
      one: 'Nota de voz ($count)',
    );
    return '$_temp0';
  }

  @override
  String ciFilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Archivos ($count)',
      one: 'Archivo ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet =>
      'Aún no se ha compartido ningún archivo multimedia.';

  @override
  String get ciSecurityCode => 'Código de seguridad';

  @override
  String get ciVerified => 'Verificado';

  @override
  String get ciKeyChanged => 'La clave ha cambiado';

  @override
  String get ciNotVerified => 'No verificado';

  @override
  String get ciConversationLock => 'Bloqueo de conversación';

  @override
  String get ciLockEnabled =>
      'Activado: se requiere huella dactilar para abrir';

  @override
  String get ciDisabled => 'Desactivado';

  @override
  String get ciEphemeralMessages => 'Mensajes efímeros';

  @override
  String get ci30Seconds => '30 segundos';

  @override
  String get ci5Minutes => '5 minutos';

  @override
  String get ci1Hour => '1 hora';

  @override
  String get ci24Hours => '24 horas';

  @override
  String get ciDurationBeforeDisappear => 'Tiempo antes de desaparecer';

  @override
  String get ciBlockContactTitle => '¿Bloquear este contacto?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo ya no podrá enviarte mensajes. Puedes desbloquearlo en cualquier momento.';
  }

  @override
  String get ciBlock => 'Bloquear';

  @override
  String get ciUnblock => 'Desbloquear';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo ha sido bloqueado';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo ha sido desbloqueado';
  }

  @override
  String get ciReportContactTitle => '¿Denunciar este contacto?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'Se enviará una denuncia anónima a Droplet: un identificador técnico y el motivo elegido a continuación, nada más. Ningún mensaje ni conversación con $pseudo se transmite jamás.';
  }

  @override
  String get ciReport => 'Denunciar';

  @override
  String get ciReportSent => 'Denuncia enviada. Gracias.';

  @override
  String get ciReportFailed =>
      'No se pudo enviar la denuncia — inténtalo de nuevo más tarde.';

  @override
  String get ciReportReasonSpam => 'Spam';

  @override
  String get ciReportReasonHarassment => 'Acoso';

  @override
  String get ciReportReasonIllegal => 'Contenido ilegal';

  @override
  String get ciReportReasonOther => 'Otro';

  @override
  String mcReactWith(Object emoji) {
    return 'Reaccionar con $emoji';
  }

  @override
  String get nsMeshActive => 'Mesh activa';

  @override
  String get nsNoDeviceInRange => 'Ningún dispositivo al alcance';

  @override
  String get nsMessagesCirculate =>
      'Tus mensajes viajan de dispositivo en dispositivo, sin pasar por Internet.';

  @override
  String get nsGetCloser =>
      'Acércate a otro dispositivo Droplet. Tus mensajes se conservan y se enviarán solos.';

  @override
  String get nsDevicesInRange => 'Dispositivos al alcance';

  @override
  String get nsReconnectingTitle => 'Reconectando';

  @override
  String get nsLinkMomentarilyLost =>
      'Conexión perdida momentáneamente, aún no abandonada.';

  @override
  String get nsRelaysAvailable => 'Repetidores disponibles';

  @override
  String get nsNoRelayAvailable =>
      'Por ahora, ningún dispositivo puede reenviar tus mensajes más lejos.';

  @override
  String get nsViaBluetooth => 'Por Bluetooth';

  @override
  String get nsViaLocalWifi => 'Por Wi-Fi local';

  @override
  String get nsWifiCarriesMore =>
      'El Wi-Fi transporta archivos y voz; el Bluetooth solo transporta texto.';

  @override
  String get scInvalidQrCode => 'Código QR no válido';

  @override
  String get scWrongCode =>
      'Este no es el código correcto: la clave no coincide';

  @override
  String get scCodeVerified => 'Código verificado';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'Verificado: la clave de $pseudo coincide con este código.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'La clave de $pseudo ha cambiado desde la última verificación.';
  }

  @override
  String get scNotVerifiedYet => 'Aún no verificado.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'Compara este código con el que aparece en el dispositivo de $pseudo, o escanea directamente su código QR para verificar automáticamente.';
  }

  @override
  String get scContactKeyUnknown =>
      'La clave del contacto aún no se conoce: vuelve a conectarte con este par en la malla.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'Escanear el código de $pseudo';
  }

  @override
  String get tsNotDelivered => 'No entregado';

  @override
  String get tsRead => 'Leído';

  @override
  String get tsDelivered => 'Entregado';

  @override
  String get tsSendingInProgress => 'Enviando';

  @override
  String get tsWaitingForRelay => 'Esperando un repetidor';

  @override
  String get tsSent => 'Enviado';

  @override
  String tsSecondsSingular(Object value) {
    return '$value segundo';
  }

  @override
  String tsSecondsPlural(Object value) {
    return '$value segundos';
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
      other: '$count días',
      one: '$count día',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'Transmisión';

  @override
  String get tsStatus => 'Estado';

  @override
  String get tsDelayUntilRead => 'Tiempo hasta la lectura';

  @override
  String get tsRoute => 'Ruta';

  @override
  String get tsRouteDetail =>
      'Los dispositivos que reenviaron este mensaje, en orden.';

  @override
  String get tsPath => 'Ruta';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pasó por $count dispositivos',
      one: 'Pasó por $count dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'Recibido directamente';

  @override
  String get tsIntermediateDevicesDetail =>
      'Dispositivos intermedios reenviaron este mensaje hasta ti.';

  @override
  String get tsUnknown => 'Desconocido';

  @override
  String get tsSentRouteNotReturned =>
      'La ruta de un mensaje enviado no se devuelve a su remitente.';

  @override
  String get tsNetwork => 'Red';

  @override
  String get tsMeshDroplet => 'Mesh Droplet';

  @override
  String get tsNoServerNoOperator => 'Sin servidor, sin operador.';

  @override
  String get qsScanSecurityCode => 'Escanear el código de seguridad';

  @override
  String get qsCodeDetected => 'Código detectado';

  @override
  String get qsFrameQrCode =>
      'Encuadra el código QR que aparece en el dispositivo de tu contacto';

  @override
  String get rmRecentVideo => 'Vídeo reciente';

  @override
  String get rmRecentPhoto => 'Foto reciente';

  @override
  String get rmSeeAllPhotos => 'Ver todas las fotos';

  @override
  String get rmSeeAll => 'Ver todo';

  @override
  String get aicOriginal => 'Original';

  @override
  String get aicAzure => 'Azul';

  @override
  String get aicNeon => 'Neón';

  @override
  String get aicPaper => 'Papel';

  @override
  String get aicLagoon => 'Laguna';

  @override
  String get aicAmethyst => 'Amatista';

  @override
  String get aicGold => 'Oro';

  @override
  String get aicTide => 'Marea';

  @override
  String get aicDawn => 'Aurora';

  @override
  String get aicGlass => 'Cristal';

  @override
  String get aicConstellation => 'Constelación';

  @override
  String get aicPrism => 'Prisma';

  @override
  String get aicEmerald => 'Esmeralda';

  @override
  String get aicChangeIconTitle => '¿Cambiar el icono?';

  @override
  String aicChangeIconMessage(Object name) {
    return 'El icono «$name» sustituirá al de tu pantalla de inicio. Algunos lanzadores tardan unos segundos en mostrarlo, o piden volver al inicio.';
  }

  @override
  String get aicApply => 'Aplicar';

  @override
  String aicIconApplied(Object name) {
    return 'Icono «$name» aplicado';
  }

  @override
  String get aicChangeIconImpossible =>
      'No se puede cambiar el icono en este dispositivo';

  @override
  String get aicTitle => 'Icono';

  @override
  String get aicCurrentOnHomeScreen =>
      'El que aparece en tu pantalla de inicio';

  @override
  String get aicUnavailablePlatform => 'No disponible en esta plataforma';

  @override
  String get aicAndroidExplanation =>
      'Android fija el icono de una aplicación al instalarla. Droplet evita esto declarando varios puntos de entrada, uno por icono, y dejando solo uno activo. Tu lanzador puede tardar unos segundos en notarlo.';

  @override
  String get aicAndroidOnly =>
      'El cambio de icono solo está disponible en Android.';

  @override
  String get beWeak => 'Débil';

  @override
  String get beOkay => 'Aceptable';

  @override
  String get beStrong => 'Segura';

  @override
  String get bePasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get bePasswordsDontMatch => 'Las dos contraseñas no coinciden';

  @override
  String get beBackupSubject => 'Copia de seguridad de Droplet';

  @override
  String get beBackupShareText =>
      'Copia de seguridad cifrada de mi identidad Droplet: guárdala en un lugar seguro.';

  @override
  String get beBackupCreated => 'Copia de seguridad creada';

  @override
  String get beBackupFailed => 'Error en la copia de seguridad';

  @override
  String get beBackupMyIdentity => 'Hacer copia de seguridad de mi identidad';

  @override
  String get beWarningBody =>
      'Cualquiera que tenga este archivo y la contraseña puede hacerse pasar por ti. Guárdalo en un lugar seguro (nunca lo envíes a nadie más que a ti mismo) y elige una contraseña que solo tú conozcas.';

  @override
  String get bePasswordProtects =>
      'Esta contraseña protege tu copia de seguridad. Nunca se guarda: sin ella, el archivo queda definitivamente inutilizable.';

  @override
  String get bePassword => 'Contraseña';

  @override
  String get beConfirmPassword => 'Confirmar contraseña';

  @override
  String get beIncludeMessageHistory => 'Incluir el historial de mensajes';

  @override
  String get beOtherwiseOnlyIdentity =>
      'En caso contrario, solo se guardan la identidad, los contactos y los grupos';

  @override
  String get beCreateAndShare => 'Crear y compartir la copia de seguridad';

  @override
  String get jsErrorJournalTitle => 'Registro de errores';

  @override
  String get jsNoErrorsRecorded =>
      'No hay errores registrados. Es el estado normal.';

  @override
  String get jsLinesStayOnDevice =>
      'Estas líneas permanecen en este dispositivo: Droplet no tiene ningún servidor al que enviarlas. Si estás probando la aplicación, envíalas; sin ellas, el fallo no existe para nadie.';

  @override
  String get jsErase => 'Borrar';

  @override
  String get jsShareSubject => 'Droplet: registro de errores';

  @override
  String get jsShareText =>
      'Registro de errores de Droplet. Este archivo no contiene mensajes, contactos ni claves.';

  @override
  String get jsShareUnavailable =>
      'Uso compartido no disponible: registro copiado';

  @override
  String get clOutgoingCall => 'Llamando…';

  @override
  String get clIncomingCall => 'Llamada entrante…';

  @override
  String get clCallImpossible => 'Llamada no posible';

  @override
  String get clCallEnded => 'Llamada finalizada';

  @override
  String clCallWith(Object pseudo) {
    return 'Llamada con $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'Cifrado de extremo a extremo';

  @override
  String clCallStatusSemantics(Object status) {
    return 'Estado de la llamada: $status';
  }

  @override
  String get clEnableMic => 'Activar el micrófono';

  @override
  String get clMuteMic => 'Silenciar el micrófono';

  @override
  String get clDisableSpeaker => 'Desactivar el altavoz';

  @override
  String get clEnableSpeaker => 'Activar el altavoz';

  @override
  String get clDisableCamera => 'Desactivar la cámara';

  @override
  String get clEnableCamera => 'Activar la cámara';

  @override
  String get clHangUp => 'Colgar';

  @override
  String get clIncomingVideoCall => 'Videollamada entrante';

  @override
  String get clSwitchCamera => 'Cambiar cámara';

  @override
  String get gcGroupCall => 'Llamada de grupo';

  @override
  String get gcConnecting => 'Conectando…';

  @override
  String get gcOnline => 'En línea';

  @override
  String get gcFailed => 'Fallido';

  @override
  String get gcDisconnected => 'Desconectado';

  @override
  String get gcReturnToCall => 'Volver a la llamada';

  @override
  String get gcMinimize => 'Minimizar';

  @override
  String get gcVoiceOnly => 'Solo voz';

  @override
  String gcReactWith(String emoji) {
    return 'Reaccionar con $emoji';
  }

  @override
  String get gcSpeakingNow => 'Está hablando';

  @override
  String get gcMicOff => 'Micrófono apagado';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes · solo voz',
      one: '$count participante · solo voz',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'Mensajes';

  @override
  String get ntfChannelMessagesDesc => 'Mensajes nuevos y estados de la malla';

  @override
  String get ntfChannelCallsName => 'Llamadas';

  @override
  String get ntfChannelCallsDesc => 'Llamadas entrantes y perdidas';

  @override
  String get ntfChannelMeshName => 'Malla y emergencia';

  @override
  String get ntfChannelMeshDesc =>
      'Servicio de malla activo, estados y mensajes de emergencia';

  @override
  String get ntfReply => 'Responder';

  @override
  String get ntfYourReply => 'Tu respuesta';

  @override
  String get ntfMarkAsRead => 'Marcar como leído';

  @override
  String get ntfIncomingCall => 'Llamada entrante';

  @override
  String get ntfAnswer => 'Contestar';

  @override
  String get ntfDecline => 'Rechazar';

  @override
  String get ntfMissedCall => 'Llamada perdida';

  @override
  String get ntfSendFailedTitle => 'Error al enviar';

  @override
  String get ntfSendFailedBody =>
      'No se pudo enviar un mensaje: se reintentará en cuanto haya un par al alcance.';

  @override
  String get ntfNewStatusTitle => 'Nuevo estado';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo publicó un estado';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ A $pseudo le gustó tu estado';
  }

  @override
  String get ntfTapToView => 'Toca para ver';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo respondió a tu estado';
  }

  @override
  String get ntfEmergencyTitle => 'Mensaje de emergencia';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo difundió «Estoy a salvo»';
  }

  @override
  String get mnAccept => 'Aceptar';

  @override
  String get mnMeshVoiceCall => 'Llamada de voz por malla';

  @override
  String get mnGroupCallIncoming => 'Llamada de grupo entrante';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo te invita';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Llamada de grupo · $count participantes más',
      one: 'Llamada de grupo · $count participante más',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => '¿Quién puede ver este estado?';

  @override
  String get asAllContacts => 'Todos mis contactos';

  @override
  String asContactsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contactos',
      one: '$count contacto',
    );
    return '$_temp0';
  }

  @override
  String get asExceptOption => 'Excepto...';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count excluidos',
      one: '$count excluido',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'Excluir contactos';

  @override
  String get asOnlyOption => 'Solo...';

  @override
  String get asShareWithSpecific => 'Compartir con contactos específicos';

  @override
  String get asNoContactsAvailable => 'No hay contactos disponibles';

  @override
  String get asConfirm => 'Confirmar';

  @override
  String get apYourPhoto => 'Tu foto';

  @override
  String get apNoPhotoAccessible =>
      'No hay ninguna foto accesible en este dispositivo.';

  @override
  String get apBrowseFiles => 'Explorar archivos';

  @override
  String get apRecentPhoto => 'Foto reciente';

  @override
  String get bgSkip => 'Omitir';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'Paso $rang de $total.';
  }

  @override
  String get csGuideNetworkTitle => '¿Nadie cerca? Es normal';

  @override
  String get csGuideNetworkText =>
      'Droplet no pasa por ningún servidor: habla con los teléfonos que están al alcance. Aquí ves quién es alcanzable, y por qué radio. Cero pares no significa que no funcione, solo que todavía no hay nadie.';

  @override
  String get csGuideWriteTitle => 'Escribe incluso sin nadie cerca';

  @override
  String get csGuideWriteText =>
      'Un mensaje escrito ahora espera en tu teléfono y sale en cuanto un dispositivo pasa al alcance —en la calle, en un taxi. No está perdido, está esperando.';

  @override
  String get csGuideBackupTitle => 'Haz una copia de seguridad de tu identidad';

  @override
  String get csGuideBackupText =>
      'Sin servidor, nadie puede devolverte tu cuenta. Exporta tu identidad desde los ajustes: sin esta copia de seguridad, un teléfono perdido se lo lleva todo.';

  @override
  String get csShowLockedChatsReason => 'Mostrar los chats bloqueados';

  @override
  String get cvlNoBiometricsConfigured =>
      'No hay ninguna huella digital configurada en este dispositivo';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'Desbloquear la conversación con $pseudo';
  }

  @override
  String get cvlAuthFailed => 'Error de autenticación';

  @override
  String get cvlAuthError => 'Error de autenticación';

  @override
  String get cvlConversationLocked => 'Conversación bloqueada';

  @override
  String get cvlUnlock => 'Desbloquear';

  @override
  String get dcAddText => 'Añadir texto';

  @override
  String get dcYourTextHint => 'Tu texto...';

  @override
  String get pbDropletProBadge => 'Insignia Droplet Pro';

  @override
  String get rpReact => 'Reaccionar';

  @override
  String get rpSaveToPhone => 'Guardar en el teléfono';

  @override
  String get chViaTor => 'Vía Tor';

  @override
  String get chTorInactive => 'Tor inactivo';

  @override
  String get chViaInternet => 'Por Internet';

  @override
  String get chReachedViaTorSemantic => 'Contacto al que se llega por Tor';

  @override
  String get nsTorConnectedTitle => 'Conectado vía Tor';

  @override
  String get nsTorInactiveTitle => 'Tor desactivado';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'Tus mensajes viajan por la red Tor y esperan en un buzón cifrado hasta que $pseudo se conecte a él.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'Activa Tor en los ajustes para poder escribirle a $pseudo; sin él, tus mensajes se quedarán esperando en este dispositivo.';
  }

  @override
  String get nsTorMailboxTitle => 'Buzón cifrado';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'Ni tú ni Droplet podéis leer lo que contiene: solo $pseudo tiene la clave.';
  }

  @override
  String get nsOpenTorSettings => 'Activar Tor';

  @override
  String get qrInvalidCode => 'Este código QR no es un código de Droplet.';

  @override
  String get qrPeerAdded => 'Contacto añadido';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'Ya puedes chatear con $pseudo';
  }

  @override
  String get clViaInternet => 'Vía Internet';

  @override
  String get tsPathTorDetail =>
      'Este mensaje no pasa por los dispositivos que te rodean: transita por un buzón cifrado en la red Tor, accesible solo para vosotros dos.';

  @override
  String get tsNetworkTorDetail =>
      'Se necesita un servidor de relevo para llegar a este contacto a distancia; a diferencia de la malla local, Droplet no puede prescindir de él aquí.';

  @override
  String get torSearchDirectory => 'Buscar en el directorio';

  @override
  String get dvTitle => 'Buscar';

  @override
  String get dvClose => 'Cerrar';

  @override
  String get dvSearchHint => 'Buscar un nombre...';

  @override
  String get dvEnableTorToSearch =>
      'Activa Tor en los ajustes para buscar en el directorio.';

  @override
  String get dvSearching => 'Buscando…';

  @override
  String get dvNoResults => 'Sin resultados';

  @override
  String get dvNoUserFound =>
      'No se encontró ningún usuario para esta búsqueda.';

  @override
  String dvResultsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '$count resultado',
    );
    return '$_temp0';
  }

  @override
  String get dvSend => 'Enviar';

  @override
  String get aiNewConversation => 'Nueva conversación';

  @override
  String get aiMessageHint => 'Mensaje';

  @override
  String get aiCopied => 'Copiado';

  @override
  String get aiAskQuestion => 'Haz una pregunta';

  @override
  String get aiRunsLocally =>
      'Este asistente se ejecuta enteramente en tu dispositivo: nada se envía nunca por Internet.';

  @override
  String get aiMemorySaved => 'Lo recordaré.';

  @override
  String get aiMemoryForgotten => 'He olvidado lo que me pediste recordar.';

  @override
  String get aiMemoryTitle => 'Memoria del asistente';

  @override
  String get aiMemoryEmpty =>
      'Nada guardado todavía. Di «recuerda que…» para fijar una información.';

  @override
  String get aiMemoryForget => 'Olvidar todo';

  @override
  String get aiExpertHint =>
      'Conozco Droplet a fondo: la malla, Tor, las llamadas, la privacidad.';

  @override
  String get chAskAssistant => 'Preguntar al asistente';

  @override
  String chAskAssistantInvite(Object name) {
    return 'Ayúdame a responder a $name.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'Preparando el asistente… $percentage %';
  }

  @override
  String get aiOneTimeDownload =>
      'Solo una vez: después se queda en tu dispositivo, sin ninguna otra descarga.';

  @override
  String get aiGenericError => 'Lo sentimos, se ha producido un error.';

  @override
  String get aiNotAvailableYet =>
      'El asistente aún no está disponible en esta versión de Droplet.';

  @override
  String aiDownloadFailed(Object error) {
    return 'Descarga imposible: $error';
  }

  @override
  String get ntfSomeoneCalling => 'Alguien intenta contactarte';

  @override
  String get ntfNewMessageWake => 'Mensaje nuevo: abre Droplet para leerlo';

  @override
  String get chNearbyAndInternet => 'Cerca · Internet';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repetidores · Internet',
      one: '$count repetidor · Internet',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'Esperando Internet';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cerca · Internet',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cerca · sin Internet',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'Nadie cerca · Internet';

  @override
  String get clPathMesh => 'Mesh · Wi-Fi directo';

  @override
  String get clPathInternetDirect => 'Internet · directo';

  @override
  String get clPathInternetRelay => 'Internet · relé seguro';

  @override
  String get clReconnecting => 'Reconectando…';

  @override
  String get clLabelSpeaker => 'Altavoz';

  @override
  String get clLabelCamera => 'Cámara';

  @override
  String get clLabelMic => 'Micrófono';

  @override
  String get clLabelFlip => 'Girar';

  @override
  String get clEncryptedShort => 'Cifrado de extremo a extremo';

  @override
  String clQualitySemantics(int bars) {
    return 'Calidad de la llamada: $bars de 3';
  }

  @override
  String get beOnlineTitle => 'Copia de seguridad automática en línea';

  @override
  String get beOnlineBody =>
      'Cada día se guarda en el servidor de Droplet una copia cifrada con esta contraseña, que el servidor no puede leer. En un teléfono nuevo basta con el mismo seudónimo y la misma contraseña. No incluye las fotos, vídeos ni archivos recibidos.';

  @override
  String get beOnlineSwitch => 'Hacer copia en el servidor cada día';

  @override
  String beOnlineLast(String date) {
    return 'Última copia: $date';
  }

  @override
  String get beOnlineNever => 'Aún no hay copia en línea';

  @override
  String get beOnlineNow => 'Hacer copia ahora';

  @override
  String get beOnlineDone => 'Copia en línea realizada';

  @override
  String get beOnlineFailed => 'Copia en línea no disponible por ahora';

  @override
  String get obRestoreFromServer => 'Restaurar desde el servidor';

  @override
  String get obEnterPseudoFirst => 'Escribe primero el seudónimo de tu copia';

  @override
  String get obNoServerBackup =>
      'No hay copia para este seudónimo y contraseña';

  @override
  String get obTooManyAttempts =>
      'Demasiados intentos: vuelve a intentarlo en una hora';

  @override
  String get chatsInviteLink => 'Invitar con un enlace';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo te invita a Droplet, la mensajería cifrada que funciona incluso sin red: $lien';
  }

  @override
  String get invTitle => 'Invitación';

  @override
  String invBody(String pseudo) {
    return '$pseudo te invita a chatear en Droplet.';
  }

  @override
  String get invAdd => 'Añadir y escribir';

  @override
  String get invInvalid =>
      'Este enlace de invitación no es válido o está incompleto.';

  @override
  String get invSelf => 'Es tu propio enlace de invitación.';
  @override
  String get seAnimationHeader => 'Animación de envío';

  @override
  String get seAnimationFull => 'Completa';

  @override
  String get seAnimationReduced => 'Reducida';

  @override
  String get seAnimationOff => 'Desactivada';

  @override
  String get seAnimationFullDesc => 'Plic lleva tu mensaje, se teletransporta y te saluda.';

  @override
  String get seAnimationReducedDesc => 'Un simple fundido, sin movimiento ni partículas.';

  @override
  String get seAnimationOffDesc => 'Sin animación después de enviar.';

  @override
  String get seAnimationReplay => 'Toca para repetir';

  @override
  String get seAnimationNone => 'Sin animación';

  @override
  String get seAnimationSampleIn => '¿Nos vemos en el puerto?';

  @override
  String get seAnimationSampleOut => 'Hasta ahora';

  @override
  String get trTitle => 'Traducción';

  @override
  String get trOnDevice => 'Traduciendo en el dispositivo…';

  @override
  String get trUnknownLang => 'Idioma desconocido';

  @override
  String get trOriginal => 'Original';

  @override
  String get trCopy => 'Copiar';

  @override
  String get trInChat => 'En el chat';

  @override
  String get trRetry => 'Reintentar';

  @override
  String get trSame => 'Este mensaje ya está en ese idioma.';

  @override
  String get trModel => 'El modelo de este idioma aún no está instalado en el dispositivo.';

  @override
  String get trUnavailable => 'Este dispositivo no tiene motor de traducción sin conexión.';

  @override
  String get trFailed => 'La traducción no se completó.';

  @override
  String get pfMessage => 'Mensaje';

  @override
  String get pfCall => 'Llamada';

  @override
  String get pfSecurity => 'Seguridad';

  @override
  String get aiActCopy => 'Copiar';

  @override
  String get aiActRead => 'Leer en voz alta';

  @override
  String get aiActStop => 'Detener la lectura';

  @override
  String get aiActLike => 'Buena respuesta';

  @override
  String get aiActDislike => 'Mala respuesta';

  @override
  String get aiActShare => 'Compartir';

  @override
  String get aiActRegenerate => 'Regenerar';

  @override
  String get aiFeedbackThanks => 'Gracias por tu opinión';

  @override
  String get intelOnlineHeader => 'Traducción y transcripción';

  @override
  String get intelOnlineTitle => 'En línea cuando estoy conectado';

  @override
  String get intelOnlineSubtitle => 'Gratis — MyMemory, Apple o Google';

  @override
  String get intelOnlineFooter => 'Desactivado, nada pasa por Internet. Activado y con conexión: el texto a traducir va a MyMemory; en iPhone, un audio que el dispositivo no sabe transcribir va al servicio de voz de Apple. En esos trayectos, el contenido ya no está cifrado de extremo a extremo. En Android, solo se descarga el modelo de voz: los audios se quedan en el teléfono. Las vistas previas de enlaces también contactan con el sitio en cuestión.';

  @override
  String get trOnline => 'Traducir en línea';

  @override
  String get trOnlineNote => 'El texto se enviará a MyMemory, un servicio gratuito. En ese trayecto ya no está cifrado de extremo a extremo.';

  @override
  String get trViaOnline => 'Traducido en línea por MyMemory';

  @override
  String get vnModelDownloading => 'El modelo de voz de este idioma se está descargando. Vuelve a intentarlo en un momento.';

  @override
  String get vnModelNeeded => 'Falta el modelo de voz de este idioma. Activa «En línea cuando estoy conectado» en Ajustes para descargarlo una vez.';

  @override
  String get nwStatusHeader => 'Estados';

  @override
  String get nwAddStatus => 'Añadir estado';

  @override
  String get nwStatusNewA11y => 'nuevo';

  @override
  String svReplySent(String name) {
    return 'Respuesta enviada a $name';
  }

  @override
  String get blkYouBlocked => 'Bloqueaste a este contacto.';

  @override
  String get blkUnblock => 'Desbloquear';

  @override
  String get blkListTitle => 'Contactos bloqueados';

  @override
  String get blkNone => 'No hay contactos bloqueados';

  @override
  String get blkFooter => 'Un contacto bloqueado ya no puede escribirte ni llamarte, y deja de recibir tus estados y tu foto. No se le avisa. Tu teléfono sigue retransmitiendo sus mensajes para otras personas, sin poder leerlos: la red en malla no depende de a quién bloquees.';

  @override
  String blkUnblockTitle(String name) {
    return '¿Desbloquear a $name?';
  }

  @override
  String blkUnblockToCall(String name) {
    return '¿Desbloquear a $name para llamarle?';
  }

  @override
  String get nvDone => 'OK';

  @override
  String get nvBack => 'Atrás';

  @override
  String get nvForward => 'Adelante';

  @override
  String get nvShare => 'Compartir';

  @override
  String get nvOpenInBrowser => 'Abrir en el navegador';

  @override
  String get nvReload => 'Recargar';

  @override
  String get nvCopyLink => 'Copiar enlace';

  @override
  String get nvLinkCopied => 'Enlace copiado';

  @override
  String get nvOpen => 'Abrir';

  @override
  String get nvMore => 'Más';

  @override
  String get nvNotSecure => 'No seguro';

  @override
  String get nvErrorTitle => 'Página no disponible';

  @override
  String get nvErrorBody => 'Droplet no pudo acceder a este sitio. La red mallada no transporta la web: necesitas conexión a Internet.';

  @override
  String get nvRetry => 'Reintentar';

  @override
  String get ciLinks => 'Enlaces';

  @override
  String get chatsFilterNearby => 'Cerca';


  @override
  String get chProxTitle => 'Droplet también funciona sin Internet';

  @override
  String get chProxActive => 'Hay dispositivos Droplet al alcance';

  @override
  String get chProxBody => 'Los teléfonos cercanos se pasan los mensajes. Cuantos más seáis alrededor, más lejos llegan.';

  @override
  String get chProxSee => 'Ver quién está cerca';

  @override
  String get chStickerPreview => 'Sticker';

  @override
  String get edCrop => 'Recortar';

  @override
  String get edRotate => 'Girar';

  @override
  String get edFilters => 'Filtros';

  @override
  String get edAdjust => 'Ajustar';

  @override
  String get edText => 'Texto';

  @override
  String get edDraw => 'Dibujo';

  @override
  String get edTrim => 'Recortar vídeo';

  @override
  String get edBrightness => 'Brillo';

  @override
  String get edContrast => 'Contraste';

  @override
  String get edSaturation => 'Saturación';

  @override
  String get edWarmth => 'Calidez';

  @override
  String get edVignette => 'Viñeta';

  @override
  String get edIntensity => 'Intensidad';

  @override
  String get edUndo => 'Deshacer';

  @override
  String get edDone => 'Listo';

  @override
  String get edTextHint => 'Escribe…';

  @override
  String get edDelete => 'Eliminar';

  @override
  String get edOriginal => 'Original';

  @override
  String get edStyle => 'Estilo';

  @override
  String get edBackground => 'Fondo';

  @override
  String get stNotificationsHeader => 'Notificaciones';

  @override
  String get stNotifPreview => 'Vista previa';

  @override
  String get stNotifPreviewSubtitle => 'El texto del mensaje aparece en la notificación. Desactivado, la pantalla bloqueada solo anuncia un mensaje nuevo.';

  @override
  String get stSearchHint => 'Buscar ajustes';

  @override
  String get stSearchEmpty => 'Ningún ajuste coincide';

  @override
  String get chMentionAllSubtitle => 'Avisar a todos';

  @override
  String get vuOnce => 'Ver una vez';

  @override
  String get vuOpened => 'Abierta';

  @override
  String get vuPhoto => 'Foto';

  @override
  String get vuVideo => 'Vídeo';

  @override
  String get vuMissing => 'Este contenido aún no ha llegado';

  @override
  String get pollClosed => 'Encuesta cerrada';

  @override
  String pollEndsAt(String quand) {
    return 'Termina a las $quand';
  }

  @override
  String get vuVoice => 'Mensaje de voz';

  @override
  String get apPatternsHeader => 'Motivo del fondo';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'Juegos';

  @override
  String get apPatternHome => 'Casa';

  @override
  String get apPatternGarden => 'Jardín';

  @override
  String get imTitle => 'Mensajes destacados';

  @override
  String get imSubtitle => 'Lo que has guardado';

  @override
  String get imAdd => 'Destacar';

  @override
  String get imRemove => 'Quitar de destacados';

  @override
  String get imAdded => 'Añadido a destacados';

  @override
  String get imRemoved => 'Quitado de destacados';

  @override
  String get imEmptyBody => 'Mantén pulsado un mensaje para destacarlo y encontrarlo aquí más tarde.';

  @override
  String get imClearAll => 'Quitar todo';

  @override
  String get imClearAllBody => 'Los mensajes siguen en sus chats; solo se quitan las estrellas.';

  @override
  String get imClear => 'Quitar';

  @override
  String get imYou => 'Tú';

  @override
  String get imUnknown => 'Mensaje';

  @override
  String get apPatternsFooter => 'El motivo se aplica a todos tus chats.';

  @override
  String get grCreatedNoMessages => 'Grupo creado · sin mensajes';

  @override
  String get chatsDelete => 'Eliminar chat';

  @override
  String get chatsDeleteBody => 'Los mensajes desaparecen de este teléfono. Sin servidor, nadie puede quitarlos del de los demás.';

  @override
  String get chatsDeleteConfirm => 'Eliminar';

  @override
  String get chatsDeleted => 'Chat eliminado';

  @override
  String chatsDeleteTitle(String nom) {
    return '¿Eliminar el chat con $nom?';
  }

  @override
  String get chatsDocument => 'Documento';

  @override
  String get epTitle => 'Mensajes temporales';

  @override
  String get epHeadline => 'Activa los mensajes temporales en este chat';

  @override
  String get epBody => 'Los mensajes nuevos llevarán su fecha de caducidad: desaparecerán de ambos teléfonos al cumplirse el tiempo elegido.';

  @override
  String get epDelayHeader => 'Tiempo antes de desaparecer';

  @override
  String get epHours24 => '24 horas';

  @override
  String get epDays7 => '7 días';

  @override
  String get epDays90 => '90 días';

  @override
  String get epOff => 'No';

  @override
  String get epFooter => 'El ajuste no afecta a los mensajes ya enviados: cada uno conserva el tiempo con el que salió.';

  @override
  String get chOnlineNow => 'En línea · Internet';

  @override
  String chInternetMinutesAgo(int count) {
    return 'Por internet hace $count min';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'Por internet hace $count h';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'Por internet hace $count d';
  }

  @override
  String get pdfMissing => 'Este documento no está en este teléfono.';

  @override
  String get pdfUnreadable => 'Este PDF no se puede leer: quizá llegó incompleto.';

  @override
  String get giDescription => 'Descripción';

  @override
  String get giDescriptionAdd => 'Añadir una descripción';

  @override
  String get giDescriptionNone => 'Sin descripción';

  @override
  String get giDescriptionHint => '¿De qué trata este grupo?';

  @override
  String get giOnlyAdminsSend => 'Solo los administradores escriben';

  @override
  String get giOnlyAdminsSendBody => 'Los demás miembros leen sin poder responder.';

  @override
  String get giSearchMembers => 'Buscar un miembro';

  @override
  String get chOnlyAdminsCanWrite => 'Solo los administradores pueden escribir en este grupo';

  @override
  String grCreatedBy(String nom) {
    return '$nom creó el grupo';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom te añadió';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom ya no está en el grupo';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui añadió a $nom';
  }

  @override
  String get giQrInvite => 'Código QR';

  @override
  String get giQrRenew => 'Nuevo código';

  @override
  String get giQrRenewed => 'Nuevo código creado; el anterior ya no sirve';

  @override
  String get giQrExpired => 'Este código ha caducado';

  @override
  String get giQrExplainer => 'Este código no contiene ninguna clave. Solo permite pedir entrar: tu teléfono decide.';

  @override
  String get giQrAlreadyMember => 'Ya estás en este grupo';

  @override
  String get giQrNeedContact => 'Añade primero a quien te invita';

  @override
  String get giQrRequestFailed => 'No se pudo enviar la solicitud';

  @override
  String giQrRequestSent(String nom) {
    return 'Solicitud enviada a $nom';
  }

  @override
  String giQrValidHours(int count) {
    return 'Válido $count h más';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'Válido $count min más';
  }

  @override
  String get cvNearby => 'Cerca';

  @override
  String get cvInternet => 'Internet';

  @override
  String get cvWaiting => 'Esperando';

  @override
  String get cvOutOfReach => 'Fuera de alcance';

  @override
  String get chWillSendWhenNearby => 'Se enviará en cuanto esté a tu alcance';

  @override
  String cvHops(int count) {
    return '$count saltos';
  }

  @override
  String get nwSeenSection => 'Vistos';

  @override
  String get nwReceivedHeader => 'Recibidos';

  @override
  String get avTranslateTitle => 'Traducción';

  @override
  String get avTranslateShort => 'Entender sin salir de la app';

  @override
  String get avTranslateLong => 'El mensaje se traduce en tu teléfono: su contenido no llega a nadie, ni siquiera a un traductor. El original queda a un toque, porque una traducción nunca es del todo el texto.';

  @override
  String get apStickerQ => '¿Tienes un sticker para eso?';

  @override
  String get apOnline => 'en línea';

  @override
  String get apMessage => 'Mensaje';

  @override
  String get apAutoTranslated => 'Traducido automáticamente';

  @override
  String get apBgSend => 'Mira este fondo 😍';

  @override
  String get apBgA => '¿Cambiaste algo?';

  @override
  String get apBgB => 'Se mueve con cada mensaje 😮';

  @override
  String get apFormatQ => '¿Dónde quedamos?';

  @override
  String get apFormatDemo => 'Nos vemos **a las 18 h** frente al __gran mercado__, código `4821`. Sorpresa: ||un pastel||';

  @override
  String get apVoiceQ => '¿Dónde estás?';

  @override
  String get apVoiceText => 'Estoy frente a la farmacia, te espero hasta las 18 h.';

  @override
  String get apTransQ => 'Oye, ¿todo listo?';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => '¡Sí! Nos vemos mañana en el aeropuerto, puerta 12 a las 9.';

  @override
  String get hlpDataOnDevice => 'EN TU TELÉFONO';

  @override
  String get hlpDataServers => 'LO QUE PASA POR UN SERVIDOR';

  @override
  String get hlpDataServersFooter => 'Sin internet, ninguno de estos servidores interviene: los teléfonos hablan directamente.';

  @override
  String get hlpDataNone => 'LO QUE DROPLET NUNCA PIDE';

  @override
  String get hlpRowKeys => 'Tu identidad';

  @override
  String get hlpRowKeysBody => 'Un par de claves creado aquí, nunca enviado';

  @override
  String get hlpRowMessages => 'Tus mensajes';

  @override
  String get hlpRowMessagesBody => 'En el espacio privado de la app, borrados al desinstalar';

  @override
  String get hlpRowProfile => 'Nombre y foto';

  @override
  String get hlpRowProfileBody => 'Solo llegan a quienes escribes';

  @override
  String get hlpRowSettings => 'Tus ajustes';

  @override
  String get hlpRowSettingsBody => 'Fondo, idioma, notificaciones — todo se queda aquí';

  @override
  String get hlpRowLog => 'Registro de errores';

  @override
  String get hlpRowLogBody => 'Un archivo local que nunca sale solo';

  @override
  String get hlpRowDirectory => 'Directorio';

  @override
  String get hlpRowDirectoryBody => 'Ve un nombre y un identificador público. Peticiones por Tor: no tu IP real';

  @override
  String get hlpRowMailbox => 'Buzón';

  @override
  String get hlpRowMailboxBody => 'Guarda un mensaje cifrado hasta su entrega. No puede leerlo';

  @override
  String get hlpRowSignalling => 'Conexión de llamadas';

  @override
  String get hlpRowSignallingBody => 'Ve dos identificadores mientras conecta. Ninguna voz pasa por ahí';

  @override
  String get hlpRowRelay => 'Retransmisión';

  @override
  String get hlpRowRelayBody => 'Reenvía el audio cifrado cuando falla el enlace directo';

  @override
  String get hlpNonePhone => 'Número de teléfono';

  @override
  String get hlpNoneEmail => 'Correo electrónico';

  @override
  String get hlpNoneContacts => 'Tu agenda';

  @override
  String get hlpNoneLocation => 'Tu ubicación';

  @override
  String get hlpNoneAds => 'Publicidad y rastreadores';

  @override
  String get hlpNoneAnalytics => 'Analítica';

  @override
  String get hlpQOffline => '¿Cómo funciona Droplet sin internet?';

  @override
  String get hlpAOffline => 'Los teléfonos hablan directamente, por Bluetooth y Wi-Fi. Un mensaje también puede saltar de teléfono en teléfono hasta llegar, sin pasar nunca por un servidor.';

  @override
  String get hlpQCrypto => '¿Mis mensajes están realmente cifrados?';

  @override
  String get hlpACrypto => 'Sí, de extremo a extremo, con el protocolo Signal. La clave solo existe en los dos teléfonos. Ni un relé, ni el buzón, ni nosotros podemos abrir un mensaje.';

  @override
  String get hlpQNoAccount => '¿Por qué Droplet no pide número ni correo?';

  @override
  String get hlpANoAccount => 'Porque no los necesita. Tu identidad es una clave creada en tu teléfono. Nada que crear, nada que verificar y nada que robar en otro sitio.';

  @override
  String get hlpQPending => '¿Por qué mi mensaje sigue pendiente?';

  @override
  String get hlpAPending => 'Nadie está aún al alcance y no hay internet. El mensaje espera en el teléfono y sale en cuanto se abre un camino — no hay que repetir nada.';

  @override
  String get hlpQAddSomeone => '¿Cómo añado a alguien?';

  @override
  String get hlpAAddSomeone => 'Acerca los teléfonos: la persona aparece sola. A distancia, comparte tu enlace de invitación o escanea su código QR.';

  @override
  String get hlpQUninstall => '¿Qué pasa si desinstalo la app?';

  @override
  String get hlpAUninstall => 'Todo se borra: mensajes, contactos, identidad. No hay copia en ningún sitio, así que no hay restauración. Exporta tus ajustes antes si cambias de teléfono.';

  @override
  String get hlpQBattery => '¿Droplet gasta mi batería?';

  @override
  String get hlpABattery => 'Buscar dispositivos cerca consume. En los ajustes puedes reducirlo o activarlo solo con la app abierta.';

  @override
  String get hlpQReport => '¿Cómo informo de un problema?';

  @override
  String get hlpAReport => 'Desde Contacto y asistencia. Verás el texto exacto que se enviará antes de que salga — nada sale de tu teléfono sin ti.';

  @override
  String get svLikeStatus => 'Me gusta el estado';

  @override
  String get svUnlikeStatus => 'Quitar el me gusta';

  @override
  String get stAddPhotoSemantics => 'Añadir una foto de perfil';

  @override
  String get stChangePhotoSemantics => 'Cambiar la foto de perfil';

  @override
  String get scOverheat => 'El teléfono se ha sobrecalentado — Android apagó el codificador de vídeo. Déjalo enfriar unos minutos.';

  @override
  String scTooHeavy(int mo) {
    return 'Archivo demasiado pesado — $mo MB como máximo para cruzar la red local.';
  }

  @override
  String get scUnsupported => 'Este formato no se admite para un estado.';

  @override
  String get scUnreadableFile => 'No se puede leer este archivo';

  @override
  String get scUnreadableTrack => 'No se puede leer esta pista';

  @override
  String get scNothingCaptured => 'La grabación no capturó nada — inténtalo de nuevo.';

  @override
  String get scVideoTrimmed => 'Vídeo acortado a 1 min 30 — solo se publica el principio.';

  @override
  String get scUnreadableVideo => 'Vídeo ilegible';

  @override
  String get chAiMe => 'Yo';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'Este es el final de una conversación en Droplet entre el usuario («Yo») y $pseudo:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'El usuario quiere ayuda para responder a $pseudo. Propón una respuesta corta y natural, escrita en $langue, en primera persona, como si la enviara él mismo. Da solo la respuesta propuesta, sin preámbulo.';
  }

  @override
  String get hlpSectionHeader => 'Ayuda y privacidad';

  @override
  String get hlpPrivacy => 'Política de privacidad';

  @override
  String get hlpData => 'Tus datos';

  @override
  String get hlpDataValue => 'Nada sale';

  @override
  String get hlpContact => 'Contacto y asistencia';

  @override
  String get hlpPrivacyTitle => 'Privacidad';

  @override
  String hlpUpdated(String date) {
    return 'Actualizado el $date';
  }

  @override
  String get hlpOnlyFrEn => 'Este texto solo existe en francés e inglés. Un documento jurídico mal traducido comprometería más de lo que ayudaría.';

  @override
  String get hlpReadInEnglish => 'Leer en inglés';

  @override
  String get hlpReadInFrench => 'Leer en francés';

  @override
  String get hlpDataTitle => 'Tus datos';

  @override
  String get hlpDataLead => 'Lo que Droplet sabe de ti, línea por línea. Nada aquí es una promesa: cada línea corresponde a código.';

  @override
  String get hlpStays => 'Nunca sale del dispositivo';

  @override
  String get hlpLeaves => 'Pasa por un servidor';

  @override
  String get hlpNever => 'No existe';

  @override
  String get hlpCountTracking => 'datos para rastrearte';

  @override
  String get hlpCountAccount => 'cuenta que crear';

  @override
  String get hlpCountServers => 'servidores, y decimos cuáles';

  @override
  String get hlpHelpTitle => 'Ayuda';

  @override
  String get hlpSearchHint => 'Buscar';

  @override
  String get hlpNoResult => 'Ninguna respuesta contiene esa palabra. Escríbenos: puede ser una pregunta que falta aquí.';

  @override
  String get hlpStillStuckFooter => 'Si la respuesta no está, responde una persona.';

  @override
  String get hlpContactTitle => 'Contacto';

  @override
  String get hlpContactLead => 'Una pregunta, un problema, una idea. Lo leemos todo.';

  @override
  String get hlpBeforeWriting => 'Antes de escribir';

  @override
  String get hlpHelpRowBody => 'Ocho respuestas, disponibles sin internet';

  @override
  String get hlpWriteUs => 'Escríbenos';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'Correo';

  @override
  String get hlpWhatsAppHello => 'Hola, uso Droplet y tengo una pregunta:';

  @override
  String get hlpEmailSubject => 'Droplet — pregunta';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'WhatsApp no está instalado. Se copió el número $numero.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'Se copió la dirección $adresse.';
  }

  @override
  String get hlpReportHeader => 'Un problema';

  @override
  String get hlpReport => 'Informar de un problema';

  @override
  String get hlpReportBody => 'Verás lo que sale antes de que salga';

  @override
  String get hlpReportFooter => 'Droplet no envía ningún informe por su cuenta: no tiene servidor para eso. Un problema solo nos llega si tú lo envías.';

  @override
  String get hlpReportSubject => 'Droplet — informe';

  @override
  String get hlpReportSheetLead => 'Cuenta qué pasó. El texto exacto que se enviará aparece debajo.';

  @override
  String get hlpReportHint => 'Qué estaba haciendo y qué ocurrió…';

  @override
  String get hlpAttachLog => 'Adjuntar el registro de errores';

  @override
  String get hlpWhatWillBeSent => 'LO QUE SE ENVIARÁ';

  @override
  String get hlpLogExcerpt => 'Registro (final):';

  @override
  String get hlpCopy => 'Copiar';

  @override
  String get hlpCopied => 'Copiado';

  @override
  String get hlpOnePerson => 'Droplet lo hace una persona, no un servicio de atención. La respuesta puede tardar un día o dos — llega.';

  @override
  String get avSectionHeader => 'Lo que aporta Pro';

  @override
  String get avUnlock => 'Desbloquear Droplet Pro';

  @override
  String get avVoiceTitle => 'Voz a texto';

  @override
  String get avVoiceShort => 'Lee un audio sin escucharlo';

  @override
  String get avVoiceLong => 'La transcripción ocurre en tu teléfono, sin conexión. El audio no sale de ahí, y puedes leerlo en una reunión, en el bus o sin red.';

  @override
  String get avFormatTitle => 'Formato de texto';

  @override
  String get avFormatShort => 'Negrita, cursiva, código, spoiler';

  @override
  String get avFormatLong => 'Una palabra en negrita, una línea de código, un pasaje oculto que se descubre con un toque: tu mensaje dice justo lo que querías.';

  @override
  String get avWallpaperTitle => 'Fondos y motivos';

  @override
  String get avWallpaperShort => 'Toda la galería y los cuatro packs';

  @override
  String get avWallpaperLong => 'Cada fondo está dibujado a mano, cada motivo verificado antes de entrar en la app. Droplet, Juegos, Casa, Jardín: tu pantalla no se parece a ninguna otra.';

  @override
  String get avStickersTitle => 'Stickers animados';

  @override
  String get avStickersShort => 'La gota Droplet, en movimiento';

  @override
  String get avStickersLong => 'Stickers dibujados para Droplet, animados fotograma a fotograma y tan ligeros que viajan por la malla sin internet.';

  @override
  String get avIconTitle => 'Iconos de la app';

  @override
  String get avIconShort => 'Cambia el icono en tu pantalla de inicio';

  @override
  String get avIconLong => 'Una app de mensajería discreta empieza por su icono. Elige el que te represente, o el que menos llame la atención.';

  @override
  String get avBadgeTitle => 'Insignia Pro';

  @override
  String get avBadgeShort => 'Acompaña a tu nombre';

  @override
  String get avBadgeLong => 'No otorga ningún poder sobre nadie. Solo dice que pagaste para que Droplet siga sin anuncios, sin suscripción obligatoria y sin venta de datos.';

  @override
  String get sgTitle => 'Almacenamiento del grupo';

  @override
  String get sgEmpty => 'Aún no se ha compartido ningún archivo en este grupo.';

  @override
  String get sgByAuthor => 'Quién envía más';

  @override
  String get sgFiles => 'Archivos';

  @override
  String get sgSortRecent => 'Más recientes';

  @override
  String get sgSortHeavy => 'Los más pesados';

  @override
  String get sgNotOnDevice => 'No está aquí';

  @override
  String get giPhotoChanged => 'Foto del grupo cambiada';

  @override
  String get giPhotoFailed => 'No se pudo guardar esta imagen';

  @override
  String sgTotal(int count) {
    return '$count archivos compartidos';
  }

  @override
  String get vrTitle => 'Sala de voz';

  @override
  String get vrJoin => 'Entrar';

  @override
  String get vrBack => 'Volver';

  @override
  String get vrStart => 'Abrir una sala de voz';

  @override
  String get vrNeedsInternet => 'Una sala de voz necesita internet: la malla lleva un mensaje que espera, no veinte voces a la vez.';

  @override
  String get vrUnreachable => 'No se puede conectar con el servidor de llamadas por ahora.';

  @override
  String vrFull(int count) {
    return 'La sala está llena: $count personas como máximo.';
  }

  @override
  String get vrWaiting => 'Esperando a los demás…';

  @override
  String get vrWaitingBody => 'La sala está abierta. Los miembros del grupo la ven en el chat y entran cuando pueden.';

  @override
  String vrPeople(int count) {
    return '$count personas dentro';
  }

  @override
  String get cvTitle => 'Conversaciones';

  @override
  String get cvNew => 'Nueva conversación';

  @override
  String get cvPinned => 'Fijadas';

  @override
  String get cvRecent => 'Recientes';

  @override
  String get cvPin => 'Fijar';

  @override
  String get cvUnpin => 'No fijar';

  @override
  String get cvRename => 'Cambiar el nombre';

  @override
  String get cvRenameHint => 'Título de la conversación';

  @override
  String get cvUntitled => 'Sin título';

  @override
  String get cvYesterday => 'Ayer';

  @override
  String get cvSearchHint => 'Buscar en las conversaciones';

  @override
  String get cvEmpty => 'Todavía no hay conversaciones. Hazle una primera pregunta al asistente.';

  @override
  String get cvDeleteTitle => '¿Eliminar esta conversación?';

  @override
  String get cvDeleteBody => 'No se podrá recuperar: solo existe en este dispositivo.';

  @override
  String get jaWorking => 'Trabajando…';

  @override
  String cvNoResult(String terme) {
    return 'No se encontró nada para «$terme».';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Sin resultados',
      one: '1 resultado',
      other: '$count resultados',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Sin pasos',
      one: '1 paso',
      other: '$count pasos',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'Adónde va tu mensaje';

  @override
  String get moLocal => 'En el dispositivo';

  @override
  String get moLocalBody => 'El modelo funciona en este teléfono. Nada sale de él, incluso sin conexión. Las respuestas son más cortas y menos fiables.';

  @override
  String get moOnline => 'En línea';

  @override
  String get moOnlineBody => 'Tu mensaje va a Groq, que ejecuta un modelo mucho más grande. Necesita conexión, y el mensaje sale del teléfono.';

  @override
  String get moOnlineNoKey => 'Hablar con un modelo remoto necesita una clave. Toca para añadir una: es gratis y lleva un minuto.';

  @override
  String get moRetryOnline => 'Rehacer en línea';

  @override
  String get moRetryOnlineWhy => 'El modelo del dispositivo llegó a su límite con esta pregunta.';

  @override
  String get cpHint => 'Pregunta lo que quieras…';

  @override
  String get cpAdd => 'Añadir';

  @override
  String get cpPhoto => 'Foto';

  @override
  String get cpCamera => 'Cámara';

  @override
  String get cpFile => 'Archivo';

  @override
  String get cpFileHint => 'PDF, texto, código';

  @override
  String get cpDictate => 'Dictar';

  @override
  String get cpSend => 'Enviar';

  @override
  String get cpStop => 'Detener';

  @override
  String get cpThinking => 'Pensando…';

  @override
  String get amCopy => 'Copiar';

  @override
  String get amCopyMarkdown => 'Copiar como Markdown';

  @override
  String get amCopyMarkdownHint => 'Conserva el formato, para un documento';

  @override
  String get amShare => 'Compartir';

  @override
  String get amEdit => 'Editar mi pregunta';

  @override
  String get amEditHint => 'Se borrará todo lo que viene después';

  @override
  String get amEditTitle => '¿Editar esta pregunta?';

  @override
  String get amEditConfirm => 'Editar';

  @override
  String get amRegenerate => 'Regenerar';

  @override
  String get amReadAloud => 'Leer en voz alta';

  @override
  String get amAsContext => 'Usar como contexto';

  @override
  String get amAsContextHint => 'Continúa a partir de este mensaje';

  @override
  String get amChapter => 'Marcar como capítulo';

  @override
  String get amChapterHint => 'Para volver a encontrarlo en una conversación larga';

  @override
  String get amUnchapter => 'Quitar la marca';

  @override
  String get amChapters => 'Capítulos';

  @override
  String get amChaptersEmpty => 'Todavía no hay capítulos. Mantén pulsado un mensaje y elige «Marcar como capítulo» para encontrarlo aquí.';

  @override
  String amEditBody(int count) {
    return 'Se borrarán $count mensajes posteriores: respondían a la pregunta anterior.';
  }

  @override
  String get trAssistant => 'Asistente';

  @override
  String get trArtifacts => 'Artefactos';

  @override
  String get trMemory => 'Memoria';

  @override
  String get trHelp => 'Ayuda';

  @override
  String get arVersions => 'Versiones';

  @override
  String get arLatest => 'La más reciente';

  @override
  String get arSource => 'Código';

  @override
  String get arPreview => 'Vista previa';

  @override
  String get arGone => 'Este artefacto ya no existe.';

  @override
  String get arKindPage => 'Página';

  @override
  String get arKindCode => 'Código';

  @override
  String get arKindDiagram => 'Esquema';

  @override
  String get arKindData => 'Datos';

  @override
  String get arKindDoc => 'Documento';

  @override
  String arVersion(int n) {
    return 'Versión $n';
  }

  @override
  String get aiSources => 'Fuentes';

  @override
  String get aiToolReading => 'Leyendo el archivo adjunto…';

  @override
  String get aiToolWriting => 'Creando el archivo…';

  @override
  String get aiToolRemembering => 'Guardando en la memoria…';

  @override
  String get arEmpty => 'Todavía no hay artefactos. El asistente crea uno en cuanto produce una página, una tabla o código lo bastante largo como para estorbar en la conversación.';

  @override
  String get raTitle => 'Asistente en línea';

  @override
  String get raIntro => 'El asistente del dispositivo funciona sin configurar nada. El modo en línea necesita una clave: es la que paga las respuestas, y se queda en este teléfono.';

  @override
  String get raKey => 'Clave';

  @override
  String get raKeySaved => 'Clave guardada';

  @override
  String get raKeyFooter => 'Se guarda en el llavero del sistema y nunca se muestra entera.';

  @override
  String get raKeyRemove => 'Quitar la clave';

  @override
  String get raWhere => 'Se crea en console.groq.com, en «API Keys». Empieza por gsk_.';

  @override
  String get raPaste => 'Pegar';

  @override
  String get raSaveAndTest => 'Guardar y probar';

  @override
  String get raTest => 'Probar la clave';

  @override
  String get raTesting => 'Probando…';

  @override
  String get raNotTested => 'Sin probar todavía';

  @override
  String get raNotTestedBody => 'Basta una llamada de ocho palabras para saberlo. Mejor aquí que en mitad de una pregunta.';

  @override
  String get raWorks => 'La clave funciona';

  @override
  String get raWorksBody => 'El modo en línea ya está disponible en la conversación, en la pastilla junto al campo de texto.';

  @override
  String get raRefused => 'Clave rechazada';

  @override
  String get raRefusedBody => 'El servidor no la reconoce. A menudo falta un carácter al pegar, o la clave fue revocada.';

  @override
  String get raNoNetwork => 'Servidor inaccesible';

  @override
  String get raNoNetworkBody => 'La clave no tiene la culpa: la petición nunca llegó. Comprueba la conexión y vuelve a intentarlo.';

  @override
  String get raModelGone => 'Modelo no disponible';

  @override
  String get raModelGoneBody => 'La clave se acepta, pero no volvió nada. Probablemente el modelo fue retirado.';

  @override
  String get raQuota => 'Demasiadas peticiones';

  @override
  String get raQuotaBody => 'La clave funciona, pero la cuenta llegó a su límite. Inténtalo más tarde o revisa su saldo.';

  @override
  String get raWhatGoesOut => 'Qué sale';

  @override
  String get raModel => 'Modelo';

  @override
  String get raWhatGoesOutFooter => 'En modo en línea, tu mensaje y los turnos anteriores de esta conversación van a Groq. Nada más: ni tus contactos, ni tus otras conversaciones, ni tu ubicación.';

  @override
  String get aiDownloadTitle => '¿Descargar el modelo del dispositivo?';

  @override
  String get aiDownloadConfirm => 'Descargar';

  @override
  String get aiDownloading => 'Descargando el modelo del dispositivo';

  @override
  String aiDownloadBody(int mo) {
    return '$mo MB de descarga, una sola vez. Después el asistente responde sin red y nada sale del teléfono. Puedes seguir usándolo en línea mientras se descarga.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo MB de descarga, una sola vez. Después responde sin red y nada sale del teléfono.';
  }

  @override
  String get aiGreetingPlain => 'Hola';

  @override
  String get aiGreetingHint => 'Haz una pregunta, adjunta una foto o pide un documento.';

  @override
  String get aiChipExplain => 'Explícame…';

  @override
  String get aiChipWrite => 'Escribe un mensaje';

  @override
  String get aiChipSummarize => 'Resume esto';

  @override
  String get aiChipTranslate => 'Traduce a…';

  @override
  String aiGreeting(String nom) {
    return 'Hola, $nom';
  }

  @override
  String get cpNoPhoto => 'Sin fotos: el modelo en línea no sabe leer una imagen. En cambio sí lee PDF, incluso largos.';

  @override
  String get mvOpen => 'Modo de voz';

  @override
  String get mvTapToTalk => 'Toca para hablar';

  @override
  String get mvHoldToTalk => 'Mantén para hablar';

  @override
  String get mvListening => 'Escuchando…';

  @override
  String get mvTranscribing => 'Transcribiendo…';

  @override
  String get mvSpeaking => 'Respondiendo en voz alta';

  @override
  String get mvProblem => 'Ha ocurrido un problema';

  @override
  String get mvHandsFree => 'Manos libres';

  @override
  String get mvHold => 'Mantener';

  @override
  String get mvTalk => 'Hablar';

  @override
  String get mvInterrupt => 'Interrumpir';

  @override
  String get mvNoMic => 'Droplet no tiene acceso al micrófono. Concédelo en los ajustes del teléfono.';

  @override
  String get mvFailed => 'Este turno no se ha completado. Toca para volver a intentarlo.';

  @override
  String get mvLive => 'En directo';

  @override
  String get mvCaptions => 'Subtítulos';

  @override
  String get mvExit => 'Salir del modo de voz';

  @override
  String get mvMute => 'Silenciar el micrófono';

  @override
  String get mvUnmute => 'Activar el micrófono';

  @override
  String get mvMuted => 'Micrófono silenciado';

  @override
  String get mvTapToInterrupt => 'Toca para interrumpir';

  @override
  String scCompressing(int percent) {
    return 'Comprimiendo… $percent %';
  }

  @override
  String get scStillHeavy => 'Este vídeo sigue superando los 2 MB: su transferencia será más lenta.';

  @override
  String get baConnecting => 'Conectando…';

  @override
  String get baMute => 'Silenciar';

  @override
  String get baUnmute => 'Activar micrófono';

  @override
  String get baHangUp => 'Colgar';

  @override
  String baOngoing(String name) {
    return 'Llamada en curso con $name. Toca para volver.';
  }

  @override
  String get ntfOngoingCall => 'Llamada en curso';

  @override
  String get ntfViaMesh => 'Por la malla';

  @override
  String get ntfViaInternet => 'Por Internet';

  @override
  String get shSend => 'Enviar';

  @override
  String get shRecents => 'Recientes';

  @override
  String get shPickRecipients => 'Elige uno o varios destinatarios';

  @override
  String shSendCount(int count) {
    return 'Enviar a $count';
  }

  @override
  String shSelected(int count) {
    return '$count seleccionado(s)';
  }

  @override
  String get apcNothingYet => 'Nada todavía';

  @override
  String get apcOnline => 'En línea';

  @override
  String get apcOffline => 'Desconectado';

  @override
  String get apcPhoto => 'Foto';

  @override
  String get apcVoice => 'Mensaje de voz';

  @override
  String get apcAttachment => 'Adjunto';

  @override
  String get chKeyboardTooltip => 'Teclado';

  @override
  String get asGallery => 'Galería';

  @override
  String get asFile => 'Archivo';

  @override
  String get asLocation => 'Ubicación';

  @override
  String get asSticker => 'Sticker';

  @override
  String get asPoll => 'Encuesta';

  @override
  String get asNoGalleryAccess => 'Droplet no tiene acceso a tus fotos. Concédelo en los ajustes del teléfono o elige otra fuente abajo.';

  @override
  String asSendCount(int count) {
    return 'Enviar $count';
  }

  @override
  String get asEmptyGallery => 'No hay fotos ni vídeos en este teléfono.';

  @override
  String get expAucunPairTitre => '¿Nadie cerca?';

  @override
  String get expAucunPairTexte => 'No es un fallo. Droplet busca sin parar; en cuanto pase un dispositivo, el enlace se crea solo.';

  @override
  String get expRelaisTitre => 'Pasó por otro';

  @override
  String get expRelaisTexte => 'Este icono indica que el mensaje atravesó uno o varios dispositivos antes de llegar. Es la fuerza de la malla.';

  @override
  String get expApercuTitre => 'Vistazo';

  @override
  String get expApercuTexte => 'Mantén pulsada una conversación para leer sus últimos mensajes sin abrirla ni marcarla como leída.';

  @override
  String get expOfficielTitre => 'La cuenta Droplet';

  @override
  String get expOfficielTexte => 'Las novedades de la aplicación llegan aquí. Cada anuncio está firmado: nadie puede falsificarlo.';

  @override
  String get expMicroTitre => 'Hablar sin soltar';

  @override
  String get expMicroTexte => 'Mantén pulsado para grabar. Desliza a la izquierda para cancelar, hacia arriba para seguir sin sujetar.';

  @override
  String get expCameraTitre => 'Micro o cámara';

  @override
  String get expCameraTexte => 'Una pulsación breve en este botón alterna entre mensaje de voz y mensaje de vídeo redondo.';

  @override
  String get expVueUniqueTitre => 'Una sola vez';

  @override
  String get expVueUniqueTexte => 'Activa el «1» y lo próximo que envíes solo podrá abrirse una vez y luego desaparecerá.';

  @override
  String get expPiecesTitre => 'Varias a la vez';

  @override
  String get expPiecesTexte => 'El clip abre tu galería dentro de la app. Marca varias fotos: el número indica el orden de envío.';

  @override
  String get expStickersTitre => 'Stickers y teclado';

  @override
  String get expStickersTexte => 'Este icono cambia el teclado por los stickers, y vuelve a ser teclado con un solo toque.';

  @override
  String get expEphemeresTitre => 'Mensajes que se borran';

  @override
  String get expEphemeresTexte => 'Elige un plazo y los nuevos mensajes de esta conversación se borrarán de ambos teléfonos.';

  @override
  String get expVerrouTitre => 'Conversación bloqueada';

  @override
  String get expVerrouTexte => 'Bloqueada, una conversación deja de mostrar su último mensaje en la lista y pide desbloqueo.';

  @override
  String get expCodeTitre => 'Verificar un contacto';

  @override
  String get expCodeTexte => 'Compara este código junto a tu contacto: si coincide, nadie se ha colado entre vosotros.';

  @override
  String get expStatutTitre => 'Estados de 24 horas';

  @override
  String get expStatutTexte => 'Un estado vive un día y luego se borra. Viaja de teléfono en teléfono, incluso sin internet.';

  @override
  String get expGardeTitre => 'Nada se pierde';

  @override
  String get expGardeTexte => 'Un mensaje enviado a alguien ausente se guarda una semana y sale solo en cuanto se abre un camino.';

  @override
  String get expVoieTitre => 'Por dónde pasa';

  @override
  String get expVoieTexte => 'Bluetooth, Wi-Fi directo o internet: Droplet usa lo que haya y cambia de vía sin preguntarte nada.';

  @override
  String get cnAnnouncement => 'Novedad de Droplet';

  @override
  String get cnClearAll => 'Borrar todo';

  @override
  String get cnClearAllTitle => '¿Borrar todas las notificaciones?';

  @override
  String get cnClearAllBody => 'El centro se vaciará. Tus chats y mensajes no se tocan.';

  @override
  String get cnDelete => 'Borrar';

  @override
  String get cnEmptyTitle => 'Nada nuevo';

  @override
  String get cnEmptyBody => 'Aquí aparecerán las menciones, las reacciones a tus mensajes, las llamadas perdidas y las novedades de Droplet.';

  @override
  String get cnMentioned => 'te mencionó';

  @override
  String get cnShowLess => 'Mostrar menos';

  @override
  String get cnStatusLike => 'le gustó tu estado';

  @override
  String get cnStatusReply => 'respondió a tu estado';

  @override
  String get cnTitle => 'Centro de notificaciones';

  @override
  String get ncDeliveryHeader => 'Entrega';

  @override
  String get ncMentionsOnly => 'Solo menciones';

  @override
  String get ncMentionsOnlySub => 'Solo cuando alguien escribe @tu nombre o @todos';

  @override
  String get ncMute1h => '1 hora';

  @override
  String get ncMute8h => '8 horas';

  @override
  String get ncMute1w => '1 semana';

  @override
  String get ncMuteAlways => 'Siempre';

  @override
  String get ncMuteFooter => 'Sin notificaciones ni sonidos. Los mensajes siguen llegando y te esperan.';

  @override
  String get ncMuteFooterGroup => 'Sin notificaciones ni sonidos. Las menciones te siguen llegando.';

  @override
  String get ncMuteHeader => 'Silenciar';

  @override
  String get ncMuteOff => 'Desactivado';

  @override
  String get ncPreviewAlways => 'Siempre';

  @override
  String get ncPreviewFooter => 'Sin vista previa, la notificación solo dice «Nuevo mensaje»: nada se lee en la pantalla bloqueada.';

  @override
  String get ncPreviewHeader => 'Vista previa del mensaje';

  @override
  String get ncPreviewNever => 'Nunca';

  @override
  String get ncQuiet => 'Entrega discreta';

  @override
  String get ncQuietSub => 'En el panel, sin sonido ni banner';

  @override
  String get ncSampleAuthor => 'Lea';

  @override
  String get ncSampleHidden => 'Nuevo mensaje';

  @override
  String get ncSampleLabel => 'Notificación de ejemplo';

  @override
  String get ncSampleText => '¿Nos vemos a las 19 h?';

  @override
  String get ncStateMentions => 'Solo menciones';

  @override
  String get ncStateMuted => 'Silenciado';

  @override
  String get ncStateOn => 'Activadas';

  @override
  String get ncStateQuiet => 'Discretas';

  @override
  String get ncSystemFooter => 'El sonido y las burbujas de este chat se ajustan en Android.';

  @override
  String get ncSystemSettings => 'Sonido y burbujas';

  @override
  String get ncTitle => 'Notificaciones';

  @override
  String get ntfNewMessage => 'Nuevo mensaje';

  @override
  String get ntfNow => 'ahora';

  @override
  String get rnBanners => 'Banners';

  @override
  String get rnBannersSub => 'Cuando llega un mensaje con Droplet abierto';

  @override
  String get rnFocus1h => 'Durante 1 hora';

  @override
  String get rnFocusEvening => 'Hasta esta tarde';

  @override
  String get rnFocusTomorrow => 'Hasta mañana por la mañana';

  @override
  String get rnFocusFooter => 'Droplet se calla: los mensajes llegan y te esperan. Las llamadas siguen sonando.';

  @override
  String get rnFocusHeader => 'Concentración';

  @override
  String get rnFocusMentions => 'Permitir menciones';

  @override
  String get rnFocusMentionsSub => 'Cuando alguien escribe @tu nombre en un grupo';

  @override
  String get rnFocusOff => 'Concentración desactivada';

  @override
  String get rnFocusOffSub => 'Las notificaciones llegan con normalidad';

  @override
  String get rnFocusOn => 'Concentración activada';

  @override
  String get rnFocusStop => 'Desactivar concentración';

  @override
  String get rnFocusStopShort => 'Detener';

  @override
  String get rnInAppHeader => 'En Droplet';

  @override
  String get rnMutedEmpty => 'No hay chats silenciados.';

  @override
  String get rnMutedHeader => 'Silenciados';

  @override
  String get rnPreview => 'Mostrar vista previa';

  @override
  String get rnPreviewFooter => 'El texto de los mensajes en las notificaciones. Cada chat puede cambiarlo.';

  @override
  String get rnSystem => 'Ajustes de Android';

  @override
  String get rnSystemFooter => 'Permisos, sonidos y burbujas de Droplet en los ajustes del teléfono.';

  @override
  String get stNotificationsSubtitle => 'Silencio, vistas previas, concentración';

  @override
  String cnBellUnread(int count) {
    return 'Notificaciones, $count nuevas';
  }

  @override
  String cnMore(int count) {
    return '+$count más';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count más';
  }

  @override
  String cnQuoted(String texte) {
    return '«$texte»';
  }

  @override
  String cnReacted(String emoji) {
    return 'reaccionó $emoji a tu mensaje';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'Hasta las $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'Predeterminado ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return 'Silenciar a $nom';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'Hasta las $heure · las llamadas siguen sonando';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n chats';
  }

  @override
  String get chatsNetSearching => 'Buscando dispositivos cercanos…';

  @override
  String get cfEmptyUnreadTitle => 'Todo leído';

  @override
  String get cfEmptyUnreadBody => 'Aquí aparecerán los chats con mensajes sin leer.';

  @override
  String get cfEmptyGroupsTitle => 'Aún no hay grupos';

  @override
  String get cfEmptyGroupsBody => 'Crea uno con el botón + arriba a la derecha.';

  @override
  String get cfEmptyOtherTitle => 'Aún no hay nada aquí';

  @override
  String get ciLockedWhereHint => 'Bloqueado. Para encontrarlo, desliza hacia abajo la lista de chats.';

  @override
  String get chDraftLabel => 'Borrador:';

  @override
  String get rsMorning => 'Buenos días';

  @override
  String get rsEvening => 'Buenas noches';

  @override
  String get rsUnreadOne => '1 mensaje sin leer';

  @override
  String get rsChatsOne => 'en 1 chat';

  @override
  String get rsMentionsOne => '1 mención';

  @override
  String get rsMissedOne => '1 llamada perdida';

  @override
  String get rsSeeUnread => 'Ver los no leídos';

  @override
  String rsUnreadMany(int count) {
    return '$count mensajes sin leer';
  }

  @override
  String rsChatsMany(int count) {
    return 'en $count chats';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count menciones';
  }

  @override
  String rsMissedMany(int count) {
    return '$count llamadas perdidas';
  }

  @override
  String get camUnavailable => 'Cámara no disponible. Revisa el permiso en Ajustes.';

  @override
  String get camTakePhoto => 'Tomar una foto';

  @override
  String get camFlip => 'Cambiar de cámara';

  @override
  String get chE2eNotice => 'Los mensajes están cifrados de extremo a extremo. Nadie más, ni siquiera Droplet, puede leerlos.';

  @override
  String chCallUnreachable(String name) {
    return '$name está fuera de alcance: podrás llamar cuando estéis cerca o en línea.';
  }

  @override
  String get chPin => 'Fijar';

  @override
  String get chUnpin => 'Desfijar';

  @override
  String get chPinnedMessage => 'Mensaje fijado';

  @override
  String get chVoicePlay => 'Reproducir';

  @override
  String get chVoicePause => 'Pausa';

  @override
  String chPinnedMessageN(String position) {
    return 'Mensaje fijado $position';
  }

  @override
  String get msgInfo => 'Info.';

  @override
  String get imSearch => 'Buscar';

  @override
  String get apcVideo => 'Vídeo';
}
