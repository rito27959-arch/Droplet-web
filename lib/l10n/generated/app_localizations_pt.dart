// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Droplet';

  @override
  String get actionSend => 'Enviar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionSearch => 'Pesquisar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionNext => 'Avançar';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionEdit => 'Editar';

  @override
  String get tabChats => 'Conversas';

  @override
  String get tabNews => 'Novidades';

  @override
  String get tabCalls => 'Chamadas';

  @override
  String get tabPeers => 'Pares';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionAppearance => 'Aparência';

  @override
  String get appearanceAuto => 'Automático';

  @override
  String get appearanceLight => 'Claro';

  @override
  String get appearanceDark => 'Escuro';

  @override
  String get appearanceFooter =>
      'O Droplet foi pensado para o modo escuro: numa tela OLED, os pixels pretos ficam apagados, o que economiza bateria e evita ofuscamento no escuro. O modo claro continua disponível para leitura sob luz solar intensa.';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get languageAuto => 'Automático (idioma do telefone)';

  @override
  String get languageFooter =>
      '“Automático” segue o idioma definido no aparelho. Se esse idioma ainda não for compatível, o Droplet permanece em francês.';

  @override
  String get chatsTitle => 'Conversas';

  @override
  String get chatsSearchHint => 'Pesquisar';

  @override
  String get chatsFilterAll => 'Todas';

  @override
  String get chatsFilterUnread => 'Não lidas';

  @override
  String get chatsFilterGroups => 'Grupos';

  @override
  String get chatsFilterPinned => 'Fixadas';

  @override
  String get chatsEmptyTitle => 'Nenhuma conversa ainda';

  @override
  String get chatsEmptySubtitle =>
      'Aproxime-se de um aparelho que use o Droplet: ele aparecerá aqui automaticamente.';

  @override
  String get chatsSearchEmptyTitle => 'Nenhum resultado';

  @override
  String get chatsSearchEmptySubtitle => 'Tente outro nome.';

  @override
  String peersAtProximity(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pares por perto',
      one: '$count par por perto',
      zero: 'Procurando pares…',
    );
    return '$_temp0';
  }

  @override
  String get obMinChars => 'Pelo menos 3 caracteres';

  @override
  String get obChoosePseudo => 'Escolha um nome para começar';

  @override
  String get obRestoreFailed => 'Falha ao restaurar';

  @override
  String get obPhotoSaveFailed => 'Não foi possível salvar a foto';

  @override
  String get obShareUnavailable => 'Compartilhamento indisponível';

  @override
  String get obBackupPasswordTitle => 'Senha do backup';

  @override
  String get obBackupPasswordMessage =>
      'A que você escolheu ao exportar sua identidade.';

  @override
  String get obBackupPasswordPlaceholder => 'Senha';

  @override
  String get obRestore => 'Restaurar';

  @override
  String get obSkipStep => 'Pular esta etapa';

  @override
  String get obContinue => 'Continuar';

  @override
  String get obStart => 'Começar';

  @override
  String get obAlreadyHaveBackup => 'Já tenho um backup';

  @override
  String get obWelcomeTitle => 'Bem-vindo ao\nDroplet';

  @override
  String get obWelcomeSubtitle =>
      'Um mensageiro que funciona onde não há mais rede.';

  @override
  String get obFeatOfflineTitle => 'Sem internet, sem operadora';

  @override
  String get obFeatOfflineText =>
      'Os telefones conversam diretamente, salto a salto. Sem antena, sem conta.';

  @override
  String get obFeatEncryptedTitle => 'Criptografado de ponta a ponta';

  @override
  String get obFeatEncryptedText =>
      'Nem mesmo os telefones que retransmitem suas mensagens conseguem lê-las.';

  @override
  String get obFeatLocalTitle => 'Nada sai do seu aparelho';

  @override
  String get obFeatLocalText =>
      'Sem conta, sem servidor, sem coleta. Suas conversas ficam com você.';

  @override
  String get obRelayTitle => 'Salto a\nsalto';

  @override
  String get obRelaySubtitle =>
      'Sua mensagem salta de telefone em telefone até chegar ao destinatário, mesmo que você não esteja no alcance direto.';

  @override
  String get obFeatCrowdTitle => 'Quanto mais nós, mais longe alcança';

  @override
  String get obFeatCrowdText =>
      'Cada aparelho ao alcance amplia a rede para todos.';

  @override
  String get obFeatNothingLostTitle => 'Nada se perde';

  @override
  String get obFeatNothingLostText =>
      'Uma mensagem destinada a alguém ausente espera, e segue assim que um caminho se abre.';

  @override
  String get obSafetyTitle => 'Encontrar-se,\nsem rede';

  @override
  String get obSafetySubtitle =>
      'Quando mais nada funciona, saber onde os outros estão e que eles estão bem se torna a informação mais útil.';

  @override
  String get obFeatMapTitle => 'Um mapa que funciona offline';

  @override
  String get obFeatMapText =>
      'As áreas que você consulta ficam no telefone. Uma vez vistas, elas aparecem sem internet.';

  @override
  String get obFeatMeshPosTitle => 'As localizações vêm da malha';

  @override
  String get obFeatMeshPosText =>
      'Sem servidor: a localização sai do telefone do seu contato, criptografada, e salta de aparelho em aparelho até o seu.';

  @override
  String get obFeatCheckinTitle => '«Estou seguro», com um gesto';

  @override
  String get obFeatCheckinText =>
      'Um único toque transmite seu status para toda a vizinhança. Você escolhe incluir uma localização aproximada, ou não.';

  @override
  String get obStatusTitle => 'Compartilhar\nnovidades';

  @override
  String get obStatusSubtitle =>
      'Uma foto, uma palavra, um humor: seu status circula de telefone em telefone, como suas mensagens.';

  @override
  String get obFeatStatusMediaTitle => 'Foto, vídeo ou texto';

  @override
  String get obFeatStatusMediaText =>
      'Publique o que quiser mostrar. As pessoas ao alcance recebem, sem passar pela internet.';

  @override
  String get obFeatStatusSeenTitle => 'Você vê quem viu';

  @override
  String get obFeatStatusSeenText =>
      'Cada pessoa que abre seu status avisa de volta, pelo mesmo caminho.';

  @override
  String get obFeatStatusExpireTitle => 'Desaparece depois de um dia';

  @override
  String get obFeatStatusExpireText =>
      'Vinte e quatro horas, e o status é apagado de todos os telefones que o receberam.';

  @override
  String get obRemovePhoto => 'Remover a foto';

  @override
  String get obChoosePhoto => 'Escolher uma foto';

  @override
  String get obPhotoTitle => 'Um rosto,\nse quiser';

  @override
  String get obPhotoSubtitle =>
      'Ajuda os outros a te reconhecerem em uma lista. Nada te obriga a colocar uma.';

  @override
  String get obFeatPhotoLocalTitle => 'Ela fica neste telefone';

  @override
  String get obFeatPhotoLocalText =>
      'Nenhum servidor a recebe, nenhum backup online a guarda. Ela vive na pasta do aplicativo, e em nenhum outro lugar.';

  @override
  String get obFeatPhotoCompressTitle => 'Reduzida antes de ser guardada';

  @override
  String get obFeatPhotoCompressText =>
      'O Droplet guarda apenas uma miniatura de 320 pixels. Sua foto original nunca é copiada.';

  @override
  String get obNetworkTitle => 'O Droplet cresce\ncom você';

  @override
  String get obNetworkSubtitle =>
      'Cada pessoa que a instala amplia a rede — para ela, e para todos ao redor.';

  @override
  String get obSendToFriend => 'Enviar o Droplet para alguém';

  @override
  String get obFeatShareOfflineTitle =>
      'Até o compartilhamento dispensa a internet';

  @override
  String get obFeatShareOfflineText =>
      'O Droplet envia seu próprio arquivo de instalação. Ele viaja por Bluetooth, Wi-Fi Direct ou cartão de memória — sem conexão necessária, dos dois lados.';

  @override
  String get obFeatThreeTitle => 'Três pessoas bastam para começar';

  @override
  String get obFeatThreeText =>
      'A dois, vocês se escrevem ao alcance da vista. Com alguns num bairro, as mensagens se retransmitem e o alcance fica bem maior que cada telefone.';

  @override
  String get obIdentityTitle => 'Como devemos\nte chamar?';

  @override
  String get obIdentitySubtitle =>
      'Este nome aparecerá para as pessoas que você encontrar. Você pode escolher um que não te identifique.';

  @override
  String get obPseudoHint => 'Seu nome';

  @override
  String get obFeatKeysTitle => 'Suas chaves são criadas aqui, agora';

  @override
  String get obFeatKeysText =>
      'Elas nunca saem deste telefone. Lembre-se de fazer um backup nas configurações: sem ele, uma identidade perdida é perdida para sempre.';

  @override
  String get splashCaption => 'Offline. Sem operadora.';

  @override
  String get chatsMeshNetwork => 'Rede mesh';

  @override
  String get chatsNew => 'Novo';

  @override
  String get chatsNewGroup => 'Novo grupo';

  @override
  String get chatsAssistant => 'Assistente';

  @override
  String get chatsEmergencyMode => 'Modo de emergência';

  @override
  String get chatsUnpin => 'Desafixar';

  @override
  String get chatsPin => 'Fixar no topo';

  @override
  String get chatsUnmute => 'Ativar notificações';

  @override
  String get chatsMute => 'Silenciar';

  @override
  String get chatsArchive => 'Arquivar';

  @override
  String get swipePin => 'Fixar';

  @override
  String get swipeUnpin => 'Soltar';

  @override
  String get swipeMute => 'Silenciar';

  @override
  String get swipeUnmute => 'Ativar';

  @override
  String get swipeArchive => 'Arquivar';

  @override
  String get fmtBold => 'Negrito';

  @override
  String get fmtItalic => 'Itálico';

  @override
  String get fmtStrike => 'Riscado';

  @override
  String get fmtMono => 'Monoespaçado';

  @override
  String get fmtSpoiler => 'Spoiler';

  @override
  String get vnTranscribing => 'A transcrever…';

  @override
  String get vnTranscribeFailed => 'Transcrição indisponível neste aparelho';

  @override
  String get vnNoSpeech => 'Nenhuma fala reconhecida';

  @override
  String get msgTranslate => 'Traduzir';

  @override
  String get msgShowOriginal => 'Ver original';

  @override
  String get msgTranslatedFrom => 'Traduzido automaticamente';

  @override
  String get msgTranslateFailed => 'Tradução indisponível';

  @override
  String get msgTranslateModel =>
      'É preciso descarregar o modelo de idioma (uma vez, por Wi‑Fi)';

  @override
  String get pfWallpapers => 'Fundos animados';

  @override
  String get pfWallpapersDesc =>
      'Oito fundos multicoloridos que vivem atrás das tuas conversas e rodam a cada mensagem enviada.';

  @override
  String get pfFormatting => 'Formatação de texto';

  @override
  String get pfFormattingDesc =>
      'Negrito, itálico, riscado, código e spoilers dentro das tuas mensagens.';

  @override
  String get pfTranscription => 'Voz em texto';

  @override
  String get pfTranscriptionDesc =>
      'Lê uma mensagem de voz quando não podes ouvir. O reconhecimento é feito no teu telemóvel.';

  @override
  String get pfTranslation => 'Tradução';

  @override
  String get pfTranslationDesc =>
      'Traduz uma mensagem recebida sem que o conteúdo saia do aparelho.';

  @override
  String get pfAppIcons => 'Ícones da app';

  @override
  String get pfAppIconsDesc => 'Muda o ícone do Droplet no teu ecrã inicial.';

  @override
  String get pfBadge => 'Emblema e apoio';

  @override
  String get pfBadgeDesc =>
      'Um emblema ao lado do teu nome e o apoio a um projeto independente.';

  @override
  String get pfUnderstood => 'Percebi';

  @override
  String get pfFeaturesTitle => 'O que o pack abre';

  @override
  String get chatsUnarchive => 'Desarquivar';

  @override
  String get chatsArchivedTitle => 'Arquivadas';

  @override
  String get chatsNoArchived => 'Nenhuma conversa arquivada';

  @override
  String get chatsLockedTitle => 'Conversas bloqueadas';

  @override
  String get chatsNoLocked => 'Nenhuma conversa bloqueada';

  @override
  String get chatsCrashTitle => 'O Droplet fechou inesperadamente';

  @override
  String get chatsCrashBody =>
      'O Droplet não tem servidor: sem seu envio, essa falha não existe para mais ninguém. O relatório não contém mensagens, contatos ou chaves.';

  @override
  String get chatsSendReport => 'Enviar o relatório';

  @override
  String get chatsLater => 'Mais tarde';

  @override
  String get stTitle => 'Ajustes';

  @override
  String get stIconHeader => 'Ícone';

  @override
  String get stIconFooter => 'Treze ícones à escolha para a tela inicial.';

  @override
  String get stAppIcon => 'Ícone do aplicativo';

  @override
  String get stVariants13 => '13 variantes';

  @override
  String get stNetworkHeader => 'Rede';

  @override
  String get stNetworkFooter =>
      'O relé em segundo plano permite transmitir mensagens de outros mesmo com o Droplet fechado.';

  @override
  String get stRequireTor => 'Exigir Tor online';

  @override
  String get stRequireTorSubtitle => 'Sem Tor, nada chega aos servidores';

  @override
  String get stRequireTorFooter =>
      'O diretório e a caixa passam pelo Tor sempre que está ativo. Caso contrário, o Droplet liga-se diretamente: o conteúdo continua cifrado ponta a ponta, mas os servidores veem o teu endereço IP. Ativa para o impedir — ao custo das mensagens online quando o Tor não funciona.';

  @override
  String get stMeshNetwork => 'Rede mesh';

  @override
  String get stPeersTopology => 'Pares conectados e topologia';

  @override
  String get stOfflineMaps => 'Mapas offline';

  @override
  String get stZonesImport => 'Áreas salvas e importação de mapas';

  @override
  String get stSecurityHeader => 'Segurança';

  @override
  String get stSecurityFooter =>
      'O Droplet não guarda nenhuma cópia da sua identidade. Sem backup, ela se perde com o aparelho.';

  @override
  String get stBackupIdentity => 'Fazer backup da minha identidade';

  @override
  String get stExportEncrypted => 'Exportação criptografada por senha';

  @override
  String get stEmergencyMode => 'Modo de emergência';

  @override
  String get stSignalSafe => 'Sinalizar que você está seguro';

  @override
  String get stContributionHeader => 'Contribuição';

  @override
  String get stMyContribution => 'Minha contribuição';

  @override
  String get stDropletPro => 'Droplet Pro';

  @override
  String get stProActive => 'Ativo';

  @override
  String get stProPackUnlocked => 'Pacote desbloqueado';

  @override
  String get stProIconsThemes => 'Ícones e planos de fundo';

  @override
  String get stCrashLog => 'Registro de erros';

  @override
  String get stAbout => 'Sobre o Droplet';

  @override
  String get stBackgroundRelay => 'Retransmissão em segundo plano';

  @override
  String get stActiveClosed => 'Ativo mesmo com o app fechado';

  @override
  String get stActiveOpenOnly => 'Ativo apenas com o app aberto';

  @override
  String get stBatteryOptim => 'Otimização de bateria';

  @override
  String get stAndroidMayLimit => 'O Android pode limitar a retransmissão';

  @override
  String get stFix => 'Corrigir';

  @override
  String get stKeepActiveTitle => 'Manter o Droplet ativo?';

  @override
  String get stKeepActiveBody =>
      'Uma notificação permanente indicará que o Droplet está retransmitindo a malha, mesmo com o app fechado. Em troca, a bateria será mais exigida.';

  @override
  String get stEnable => 'Ativar';

  @override
  String get stCancel => 'Cancelar';

  @override
  String get stAboutTagline =>
      'Mensagens e chamadas offline, sem internet nem operadora.';

  @override
  String get stAboutDirect => 'Rede direta entre aparelhos — sem servidor';

  @override
  String get stAboutE2E =>
      'Criptografia de ponta a ponta em todas as mensagens';

  @override
  String get stAboutNoThirdParty => 'Nenhum dado enviado a terceiros';

  @override
  String get stAttributionEmoji =>
      'Emojis animados: Noto Animated Emoji © Google, sob licença CC BY 4.0.';

  @override
  String get stAttributionGemma =>
      'Assistente: Gemma 3 1B-IT © Google, quantizado (int4) por litert-community e republicado pelo Droplet, sob os termos de uso do Gemma (ai.google.dev/gemma/terms).';

  @override
  String get stChatBgHeader => 'Fundo da conversa';

  @override
  String get stChatPatterns => 'Desenhos Droplet';

  @override
  String get stChatPatternsSubtitle =>
      'Pequenos desenhos de traço sobre o fundo';

  @override
  String get stChatBgFooter =>
      'O degradê avança um passo a cada mensagem enviada. Escolha «Nenhum» para um fundo liso: nada é calculado, o que economiza bateria.';

  @override
  String get stBgFree => 'Grátis';

  @override
  String get stBgPremium => 'Premium · animados';

  @override
  String get stBgNone => 'Nenhum';

  @override
  String get stBgDefault => 'Predefinido';

  @override
  String get stBgThisChat => 'Fundo desta conversa';

  @override
  String get stTextSize => 'Tamanho do texto';

  @override
  String get stBubbleCorners => 'Cantos das mensagens';

  @override
  String get stAccentHeader => 'Cor de destaque';

  @override
  String get stAccentFooter =>
      'Colore as tuas bolhas, os botões e as ligações em toda a app.';

  @override
  String get stChatListHeader => 'Lista de conversas';

  @override
  String get stChatListTwoLines => 'Duas linhas';

  @override
  String get stChatListThreeLines => 'Três linhas';

  @override
  String get stResetAppearance => 'Repor a aparência';

  @override
  String get stPreviewIncoming => 'Vemo-nos hoje à noite?';

  @override
  String get stPreviewOutgoing => 'Sim, com gosto!';

  @override
  String get stAppearanceRow => 'Aparência';

  @override
  String get stAppearanceSubtitle => 'Tema, cor, tamanho do texto, fundos';

  @override
  String get stBgApply => 'Usar este fundo';

  @override
  String get stBgUnlock => 'Desbloquear com Premium';

  @override
  String get stBgApplied => 'Fundo aplicado';

  @override
  String get stBgPreviewHint =>
      'O fundo mexe-se e as cores rodam a cada mensagem enviada.';

  @override
  String get stBgPreviewIncoming => 'Já viste o novo fundo?';

  @override
  String get stBgPreviewOutgoing => 'Sim, é lindo ✨';

  @override
  String get stSoundHeader => 'Sons';

  @override
  String get stSoundToggle => 'Sons da app';

  @override
  String get stSoundSubtitle => 'Mensagens, ligações, alertas';

  @override
  String get stSoundFooter =>
      'Tons curtos, ao volume das notificações do sistema — em silêncio se o telemóvel estiver em silêncio ou modo de concentração.';

  @override
  String get stPacksHeader => 'Assistente — fichas offline';

  @override
  String get stPacksToggle => 'Fichas de primeiros socorros e emergência';

  @override
  String get stPacksSubtitle =>
      'O assistente apoia-se nelas para primeiros socorros e emergências.';

  @override
  String get stPacksFooter =>
      'Fichas de referência integradas (primeiros socorros, sismo, inundação, água potável…). Quando a pergunta se aplica, o assistente cita a ficha em vez de adivinhar. Não substituem formação nem uma chamada para os socorros.';

  @override
  String get stPrivateModeHeader => 'Modo privado';

  @override
  String get stTorFooter =>
      'O Tor protege seu endereço IP e conversas, encaminhando-os pela rede Tor. A malha local (BLE/Wi-Fi) continua funcionando normalmente.';

  @override
  String get stTorActiveAnon => 'Ativo — seus dados estão anonimizados';

  @override
  String get stTorConnecting => 'Conectando…';

  @override
  String get stTorDisabled => 'Modo privado desativado';

  @override
  String get callsTitle => 'Chamadas';

  @override
  String callsMissedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chamadas perdidas',
      one: '$count chamada perdida',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get callsNew => 'Nova chamada';

  @override
  String get callsAll => 'Todas';

  @override
  String get callsMissed => 'Perdidas';

  @override
  String get callsNoneMissed => 'Nenhuma chamada perdida';

  @override
  String get callsNone => 'Nenhuma chamada';

  @override
  String get callsMissedEmptyBody =>
      'As chamadas que você não atendeu vão aparecer aqui.';

  @override
  String get callsEmptyBody =>
      'As chamadas passam pela rede local, sem operadora nem plano. Seu histórico vai aparecer aqui.';

  @override
  String get callsRetained200 =>
      'As últimas 200 chamadas são mantidas apenas neste aparelho.';

  @override
  String get callsIncoming => 'Recebida';

  @override
  String get callsOutgoing => 'Efetuada';

  @override
  String get callsMissedLabel => 'Perdida';

  @override
  String get callsNoAnswer => 'Sem resposta';

  @override
  String get callsConnectionFailed => 'Falha na conexão';

  @override
  String get callsYesterday => 'ontem';

  @override
  String callsMinSec(Object m, Object s) {
    return '$m min $s s';
  }

  @override
  String callsSecOnly(Object s) {
    return '$s s';
  }

  @override
  String get peersTitle => 'Pares';

  @override
  String get peersSearching => 'Procurando…';

  @override
  String peersDevicesInRange(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aparelhos ao alcance',
      one: '$count aparelho ao alcance',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get peersNetworkMap => 'Mapa da rede';

  @override
  String get peersNoneInRange => 'Ninguém ao alcance';

  @override
  String get peersNoneInRangeBody =>
      'O Droplet procura constantemente por aparelhos próximos. Aproxime-se de alguém com o app para fazer a primeira conexão.';

  @override
  String get peersDirectRange => 'No alcance direto';

  @override
  String get peersDirectRangeFooter =>
      'Estes aparelhos são acessíveis sem passar por mais ninguém.';

  @override
  String get peersRelayed => 'Por retransmissão';

  @override
  String get peersRelayedFooter =>
      'Estes aparelhos estão fora do alcance direto: as mensagens chegam até eles por outros telefones.';

  @override
  String get peersRelay => 'Retransmissor';

  @override
  String get peersCall => 'Ligar';

  @override
  String get peersTooSlow => 'Muito lento para voz — aproxime-se';

  @override
  String get peersWifi => 'Wi-Fi';

  @override
  String get peersWifiDirect => 'Wi-Fi Direct';

  @override
  String get peersBluetooth => 'Bluetooth';

  @override
  String get peersUnknownLink => 'Ligação desconhecida';

  @override
  String get peersDirect => 'direto';

  @override
  String peersHops(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saltos',
      one: '$count salto',
      zero: 'direto',
    );
    return '$_temp0';
  }

  @override
  String get svExpired => 'Este status expirou';

  @override
  String get svReceiving => 'Recebendo…';

  @override
  String get svReceivingBody => 'O arquivo está chegando pela rede local';

  @override
  String get svProgressLabel => 'Progresso do status';

  @override
  String get svReplyHint => 'Responder…';

  @override
  String get svSendReply => 'Enviar resposta';

  @override
  String get svYourStatus => 'Seu status';

  @override
  String get svNoViewsYet =>
      'Ninguém viu este status ainda.\nEle continuará circulando enquanto você cruzar com outros aparelhos.';

  @override
  String get svJustNow => 'agora mesmo';

  @override
  String svMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count min',
      one: 'há $count min',
    );
    return '$_temp0';
  }

  @override
  String svHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count h',
      one: 'há $count h',
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
      other: '$count visualizações',
      one: '$count visualização',
    );
    return '$_temp0';
  }

  @override
  String svLikesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count curtidas',
      one: '$count curtida',
    );
    return '$_temp0';
  }

  @override
  String svRepliesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respostas',
      one: '$count resposta',
    );
    return '$_temp0';
  }

  @override
  String get cpFilterOriginal => 'Original';

  @override
  String get cpFilterDark => 'Escuro';

  @override
  String get cpFilterBright => 'Claro';

  @override
  String get cpFilterVintage => 'Vintage';

  @override
  String get cpWriteStatusHint => 'Escreva um status';

  @override
  String get cpPreparingVideo => 'Preparando o vídeo…';

  @override
  String get cpLoadingEllipsis => 'Carregando…';

  @override
  String cpEndsIn(Object s) {
    return 'Termina em $s s';
  }

  @override
  String get cpModeVideo => 'Vídeo';

  @override
  String get cpModePhoto => 'Foto';

  @override
  String get cpModeMessage => 'Mensagem';

  @override
  String get cpModeVoice => 'Voz';

  @override
  String get gcChooseName => 'Escolha um nome para o grupo';

  @override
  String get gcSelectOneMember => 'Selecione pelo menos um membro';

  @override
  String get gcCreationFailed => 'Falha ao criar o grupo';

  @override
  String get gcNewGroup => 'Novo grupo';

  @override
  String get gcGroupName => 'Nome do grupo';

  @override
  String get gcNameHint => 'ex. Equipe de campo';

  @override
  String get gcMembers => 'Membros';

  @override
  String gcSelectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '$count selecionado',
    );
    return '$_temp0';
  }

  @override
  String get gcNoOneInRange => 'Ninguém ao alcance';

  @override
  String get gcGetCloserBody =>
      'Aproxime-se de outro aparelho com Droplet: os pares aparecem aqui automaticamente.';

  @override
  String get gcCreateGroup => 'Criar grupo';

  @override
  String get gcConnected => 'Conectado';

  @override
  String get gcAlreadyMet => 'Já encontrado';

  @override
  String get giRenameGroup => 'Renomear grupo';

  @override
  String get giRenameFailed => 'Falha ao renomear';

  @override
  String get giNoPeerToAdd => 'Nenhum par disponível para adicionar';

  @override
  String get giAddMemberHeader => 'ADICIONAR UM MEMBRO';

  @override
  String get giAddMemberFailed => 'Falha ao adicionar membro';

  @override
  String get giRemoveMemberTitle => 'Remover este membro?';

  @override
  String get giRemoveMemberBody =>
      'Ele não poderá mais ler as mensagens enviadas após sua remoção.';

  @override
  String get giRemove => 'Remover';

  @override
  String get giRemoveMemberFailed => 'Falha ao remover membro';

  @override
  String get giLeaveGroupTitle => 'Sair do grupo?';

  @override
  String get giLeaveGroupBody =>
      'Você não receberá mais as mensagens enviadas após sua saída.';

  @override
  String get giLeave => 'Sair';

  @override
  String get giNoOneReachable =>
      'Nenhum membro alcançável por Wi-Fi local no momento';

  @override
  String get giMax4Participants =>
      'Máximo de 4 participantes por chamada em grupo — apenas os 3 primeiros alcançáveis serão chamados';

  @override
  String get giGroupNotFound => 'Grupo não encontrado';

  @override
  String get giGroupInfo => 'Info do grupo';

  @override
  String get giGroupCall => 'Chamada em grupo';

  @override
  String giMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get giEncryptedMessages => 'Mensagens do grupo criptografadas';

  @override
  String get giAdd => 'Adicionar';

  @override
  String get giMe => 'eu';

  @override
  String get giAdministrator => 'Administrador';

  @override
  String get giLeaveGroup => 'Sair do grupo';

  @override
  String get sfNoLocationShared => 'Localização não partilhada';

  @override
  String get sfLocationShared => 'Localização partilhada';

  @override
  String sfDistanceMeters(Object m) {
    return 'a $m m';
  }

  @override
  String sfDistanceKm(Object km) {
    return 'a $km km';
  }

  @override
  String get sfBearingN => 'a norte';

  @override
  String get sfBearingNE => 'a nordeste';

  @override
  String get sfBearingE => 'a este';

  @override
  String get sfBearingSE => 'a sudeste';

  @override
  String get sfBearingS => 'a sul';

  @override
  String get sfBearingSW => 'a sudoeste';

  @override
  String get sfBearingW => 'a oeste';

  @override
  String get sfBearingNW => 'a noroeste';

  @override
  String get sfBroadcastSafeTitle => 'Difundir \"Estou em segurança\"?';

  @override
  String get sfBroadcastSafeMessage =>
      'Este estado será visível para toda a mesh ao alcance, não apenas para os teus contactos. Podes incluir uma localização aproximada (arredondada, nunca exata).';

  @override
  String get sfWithLocation => 'Com localização aprox.';

  @override
  String get sfWithoutLocation => 'Sem localização';

  @override
  String get sfStatusBroadcast => 'Estado difundido para a mesh';

  @override
  String get sfBroadcastFailed => 'Falha na difusão';

  @override
  String get sfHelpRequestTitle => 'Difundir \"Preciso de ajuda\"?';

  @override
  String get sfHelpRequestMessage =>
      'Este estado sinalizará aos pares ao alcance que precisas de assistência. Podes incluir uma localização aproximada.';

  @override
  String get sfHelpRequestBroadcast => 'Pedido de ajuda difundido para a mesh';

  @override
  String sfDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há $count dia',
    );
    return '$_temp0';
  }

  @override
  String get sfTitle => 'Modo de emergência';

  @override
  String get sfViewOnMap => 'Ver no mapa';

  @override
  String get sfNeedHelp => 'Preciso de ajuda';

  @override
  String sfCheckinsReceived(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Check-ins recebidos ($count)',
      one: 'Check-in recebido ($count)',
    );
    return '$_temp0';
  }

  @override
  String get sfNoCheckinsYet => 'Ainda não foi recebido nenhum check-in';

  @override
  String get sfCheckinsAppearHere =>
      'Os estados \"em segurança\" difundidos pelos pares ao alcance aparecerão aqui.';

  @override
  String get sfSafeLabel => 'Em segurança';

  @override
  String sfSafeStatusWithLocation(Object location, Object time) {
    return 'Em segurança · $time · $location';
  }

  @override
  String sfSafeStatusNoLocation(Object time) {
    return 'Em segurança · $time';
  }

  @override
  String get sfBroadcastSemanticsLabel =>
      'Difundir o meu estado de segurança para a rede mesh';

  @override
  String get sfImSafe => 'Estou em segurança';

  @override
  String get emSosActive => 'SOS ATIVO';

  @override
  String get emSos => 'SOS';

  @override
  String get emSosActiveDescription =>
      'Sinal SOS ativo — difundido para todos os dispositivos próximos';

  @override
  String get emPullToSendSignal => 'Toca para enviar um sinal de emergência';

  @override
  String get emSignalRelayedDescription =>
      'O sinal é retransmitido de par em par\npor toda a rede mesh.';

  @override
  String get emBroadcasting => 'A difundir...';

  @override
  String get emSharePosition => 'Partilhar a minha localização';

  @override
  String get emSosActivated => 'Sinal SOS ativado';

  @override
  String get emSafeStatusMessage => '🟢 Estou em segurança';

  @override
  String get emSafetyStatusBroadcast => 'Estado de segurança difundido';

  @override
  String get pmEnterPayingNumber =>
      'Introduz o número que vai pagar (9 dígitos).';

  @override
  String get pmRequestSent => 'Pedido enviado…';

  @override
  String get pmPaymentLaunchFailed =>
      'Não foi possível iniciar o pagamento. Verifica o número e a tua ligação, ou paga manualmente abaixo.';

  @override
  String get pmValidateOnPhone =>
      'Confirma no teu telefone: introduz o teu código Mobile Money quando o pedido aparecer.';

  @override
  String get pmPaymentNotConfirmed =>
      'Pagamento não confirmado. Nada foi desbloqueado.';

  @override
  String pmInvalidLicenseReceived(Object contact) {
    return 'O pagamento foi efetuado, mas a licença recebida é inválida. Escreve-nos, ela será refeita: $contact';
  }

  @override
  String get pmProActivated => 'Droplet Pro ativado';

  @override
  String get pmPackUnlocked => 'Pack desbloqueado';

  @override
  String get pmInvalidCode =>
      'Este código não é válido neste dispositivo. Verifica que enviaste o código de dispositivo mostrado acima.';

  @override
  String get pmTitle => 'Droplet Pro';

  @override
  String get pmNeverAskTitle => 'O que a Droplet\nnunca vai pedir';

  @override
  String get pmNeverAskBody =>
      'Sem publicidade, sem subscrição obrigatória, sem revenda dos teus dados — nem sequer há um servidor para os recolher. O pack e o Pro financiam o resto.';

  @override
  String get pmCommunitySemantics =>
      'Junta-te à comunidade de mais de 1200 membros ativos';

  @override
  String get pmCommunityText => 'Junta-te a mais de 1200 membros na mesh';

  @override
  String get pmProPreviewSemantics =>
      'Pré-visualização das funcionalidades Pro desbloqueadas';

  @override
  String get pmAnimatedEmojis => 'Emojis\nanimados';

  @override
  String get pmWallpapers => 'Fundos\nde ecrã';

  @override
  String get pmAppIcons => 'Ícones\nda app';

  @override
  String get pmOnceForLife => 'uma vez, para sempre';

  @override
  String get pmProAdvantage1 => 'Os dez ícones e os oito fundos do pack';

  @override
  String get pmProAdvantage2 => 'O emblema Pro ao lado do teu nome';

  @override
  String get pmProAdvantage3 =>
      'As funcionalidades futuras, sem custo adicional';

  @override
  String get pmPackTitle => 'O pack';

  @override
  String get pmOnce => 'uma vez';

  @override
  String get pmPackAdvantage1 => 'Dez ícones de aplicação adicionais';

  @override
  String get pmPackAdvantage2 => 'Oito fundos de conversa';

  @override
  String get pmPayByHand => 'Ou pagar manualmente';

  @override
  String get pmHowTo => 'Como fazer';

  @override
  String get pmIfPromptDoesNotArrive =>
      'Se o pedido não chegar ao teu telefone, ou se preferires enviar o dinheiro tu mesmo.';

  @override
  String pmStep1Title(Object montant) {
    return 'Envia $montant F';
  }

  @override
  String get pmStep1Body =>
      'Escolhe o teu operador: o menu dele abre-se, e o número mantém-se aqui enquanto o navegas.';

  @override
  String get pmStep2Title => 'Envia o teu código de dispositivo';

  @override
  String get pmStep2Body =>
      'Juntamente com a captura do pagamento. Sem este código, a licença não pode ser criada — só é válida para o teu telefone.';

  @override
  String get pmStep3Title => 'Recebes uma licença';

  @override
  String get pmStep3Body =>
      'Uma linha longa que começa por DROP1. Cola-a abaixo: o desbloqueio é instantâneo e funciona offline, para sempre.';

  @override
  String get pmPayNow => 'Pagar agora';

  @override
  String get pmPayNowSubtitle =>
      'MTN Mobile Money ou Orange Money, a partir deste telefone ou de outro.';

  @override
  String get pmPhoneNumberSemantics =>
      'Número de telefone para o pagamento Mobile Money';

  @override
  String get pmWaitingForCode => 'A aguardar o teu código…';

  @override
  String pmPayAmount(Object montant) {
    return 'Pagar $montant F';
  }

  @override
  String get pmRestorePurchaseSemantics => 'Restaurar uma compra anterior';

  @override
  String get pmAlreadyPaidRestore => 'Já pagaste? Restaurar';

  @override
  String pmDialCode(Object code) {
    return 'Marca $code a partir do teu telefone';
  }

  @override
  String get pmChooseOperatorSemantics => 'Escolher um operador de pagamento';

  @override
  String get pmNumberAmountFilled =>
      'Número e montante já preenchidos — só falta o teu código secreto.';

  @override
  String get pmOrangeMenuInstructions =>
      'No menu da Orange: transferência de dinheiro, depois o número e o montante abaixo.';

  @override
  String get pmLabelNumber => 'Número';

  @override
  String get pmLabelAmount => 'Montante';

  @override
  String pmPayWithOperator(Object montant, Object operator) {
    return 'Pagar $montant francos com $operator';
  }

  @override
  String get pmMenuOpen => 'Menu aberto';

  @override
  String pmWhatsAppMessage(Object amount, Object code, Object offer) {
    return 'Olá, acabei de pagar pela Droplet.\n\nOferta: $offer\nMontante: $amount F\nCódigo de dispositivo: $code\n\n(anexo a captura do pagamento)';
  }

  @override
  String pmWhatsAppNotFound(Object contact) {
    return 'WhatsApp não encontrado — código copiado. Envia-o para $contact';
  }

  @override
  String get pmPrepareRequest => 'Preparar o meu pedido';

  @override
  String get pmReceivedLicense => 'Recebi a minha licença';

  @override
  String get pmPaste => 'Colar';

  @override
  String get pmUnlock => 'Desbloquear';

  @override
  String get pmProIsActive => 'Droplet Pro está ativo';

  @override
  String get pmPackIsUnlocked => 'O pack está desbloqueado';

  @override
  String get pmProActiveDescription =>
      'O emblema Pro acompanha o teu nome, e todos os ícones e fundos estão abertos para ti.';

  @override
  String get pmPackActiveDescription =>
      'Os dez ícones e os oito fundos do pack estão abertos para ti, nas definições.';

  @override
  String get pmLicenseDeviceBound =>
      'A tua licença é válida para este telefone. Se o mudares, guarda a mensagem que a contém: ela será refeita gratuitamente.';

  @override
  String torError(Object e) {
    return 'Erro: $e';
  }

  @override
  String get torEnable => 'Ativar o Tor';

  @override
  String get torProtected => 'Protegido';

  @override
  String get torDisabled => 'Desativado';

  @override
  String get torStateHeader => 'Estado';

  @override
  String get torCircuit => 'Circuito';

  @override
  String get torActive => 'Ativo';

  @override
  String get torInProgress => 'Em curso…';

  @override
  String get torInactive => 'Inativo';

  @override
  String get torFailed => 'Falhou';

  @override
  String get torReason => 'Motivo';

  @override
  String get torBannerConnecting => 'A ligar ao Tor…';

  @override
  String get torBannerActive => 'Tor ativo';

  @override
  String get torBannerError => 'Tor indisponível';

  @override
  String get torBannerOff => 'Tor desligado';

  @override
  String get torEncryption => 'Encriptação';

  @override
  String get torLatency => 'Latência';

  @override
  String get torContactsHeader => 'Contactos';

  @override
  String get torScanQrFooter =>
      'Digitaliza um código QR, ou procura um nome no diretório, para adicionar um contacto remoto.';

  @override
  String get torScanQrCode => 'Digitalizar um código QR';

  @override
  String get torMyQrCode => 'O meu código QR';

  @override
  String get torInformationHeader => 'Informações';

  @override
  String get torVersion => 'Versão';

  @override
  String get torHowItWorks => 'Como funciona?';

  @override
  String get torConnecting => 'A ligar…';

  @override
  String get torInactiveTitle => 'Tor inativo';

  @override
  String get torDataThroughTor => 'Os teus dados passam pela rede Tor';

  @override
  String get torEstablishingCircuit => 'A estabelecer o circuito (10-30s)';

  @override
  String get torActivateToProtect => 'Ativa para proteger a tua identidade';

  @override
  String get torHowItWorksTitle => 'Como o Tor protege os teus dados';

  @override
  String get torEncryptedCircuit => 'Circuito encriptado';

  @override
  String get torEncryptedCircuitDesc =>
      'As tuas mensagens passam por 3 relés Tor espalhados pelo mundo.';

  @override
  String get torHiddenIp => 'IP oculto';

  @override
  String get torHiddenIpDesc => 'Nenhum site consegue ver o teu endereço real.';

  @override
  String get torMeshPreserved => 'Mesh preservada';

  @override
  String get torMeshPreservedDesc =>
      'O Bluetooth e o Wi-Fi local continuam a funcionar.';

  @override
  String get torUnderstood => 'Entendi';

  @override
  String get qrTorNotActive =>
      'O Tor não está ativo. Ativa-o em Definições > Tor.';

  @override
  String get qrScanContactCode => 'Digitaliza o código QR de um contacto';

  @override
  String get qrCodeFromContactScreen =>
      'O código deve vir do ecrã Tor do teu contacto';

  @override
  String get qrScanAnother => 'Digitalizar outro';

  @override
  String get qrChat => 'Conversar';

  @override
  String get qgScanToConnect => 'Digitaliza para ligar';

  @override
  String get qgCopied => 'Copiado ✓';

  @override
  String get qgCopyCode => 'Copiar o código';

  @override
  String get qgHowItWorks => 'Como funciona';

  @override
  String get qgStep1 => 'Mostra este código QR ao teu contacto';

  @override
  String get qgStep2 => 'Ele digitaliza-o a partir do seu ecrã Tor';

  @override
  String get qgStep3 => 'Estão ligados através do Tor';

  @override
  String get shShareTo => 'Partilhar para…';

  @override
  String get shSearchConversation => 'Pesquisar uma conversa';

  @override
  String get shNoConversation => 'Nenhuma conversa';

  @override
  String get shOpenChatFirst =>
      'Abre primeiro uma conversa na Droplet para poderes partilhar conteúdo nela.';

  @override
  String get shGroup => 'Grupo';

  @override
  String get shDiscussion => 'Conversa';

  @override
  String shItemsToShare(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens para partilhar',
      one: '$count item para partilhar',
    );
    return '$_temp0';
  }

  @override
  String get omMapInstalled => 'Mapa instalado';

  @override
  String get omClearCacheTitle => 'Limpar a cache?';

  @override
  String get omRemoveZoneTitle => 'Remover esta zona?';

  @override
  String get omClearCacheMessage =>
      'As zonas que exploraste deixarão de estar disponíveis offline. Serão reconstituídas ao consultá-las novamente com rede.';

  @override
  String omRemoveZoneMessage(Object name) {
    return '«$name» será removida deste dispositivo.';
  }

  @override
  String get omClear => 'Limpar';

  @override
  String get omTitle => 'Mapas';

  @override
  String get omReading => 'A ler…';

  @override
  String get omNoMapsSaved => 'Nenhum mapa guardado';

  @override
  String omSizeOnDevice(Object size) {
    return '$size neste dispositivo';
  }

  @override
  String get omBrowseMapHint =>
      'Explora o mapa com rede: as zonas que vês permanecem disponíveis offline.';

  @override
  String get omOnThisDevice => 'Neste dispositivo';

  @override
  String get omZonesFillThemselves =>
      'As zonas consultadas preenchem-se sozinhas enquanto exploras o mapa com rede.';

  @override
  String get omMbtilesExplainer =>
      'Um ficheiro .mbtiles contém uma região inteira, preparada com antecedência. É o formato padrão dos mapas offline: qualquer ferramenta cartográfica sabe produzi-lo.';

  @override
  String get omImportMap => 'Importar um mapa';

  @override
  String get omReadingFile => 'A ler o ficheiro…';

  @override
  String get omMbtilesFromPhone => 'Ficheiro .mbtiles a partir deste telefone';

  @override
  String get omAttributionText =>
      'Os dados vêm do OpenStreetMap (licença ODbL), o fundo de mapa é fornecido pela CARTO. A Droplet nunca descarrega uma região inteira antecipadamente: nenhum serviço gratuito o permite. Só o que consultas é guardado.';

  @override
  String omTilesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blocos',
      one: '$count bloco',
    );
    return '$_temp0';
  }

  @override
  String omTilesCountK(Object k) {
    return '$k mil blocos';
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
  String get nwTitle => 'Novidades';

  @override
  String get nwStatusesNetwork24h => 'Estados da rede · 24 h';

  @override
  String nwStatusesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estados da rede',
      one: '$count estado da rede',
    );
    return '$_temp0';
  }

  @override
  String get nwPublishStatus => 'Publicar um estado';

  @override
  String get nwNoNewsYet => 'Nenhuma novidade por agora';

  @override
  String get nwStatusesAppearHere =>
      'Os estados publicados pelas pessoas ao alcance aparecerão aqui, sem passar pela internet.';

  @override
  String get nwRecent => 'Recentes';

  @override
  String get nwStatusExpires =>
      'Um estado desaparece sozinho 24 horas após a sua publicação.';

  @override
  String get nwPhoto => '📷 Foto';

  @override
  String get nwVideo => '🎥 Vídeo';

  @override
  String get nwVoiceMessage => '🎤 Mensagem de voz';

  @override
  String get nwMusic => '🎵 Música';

  @override
  String get nwStatusFallback => 'Estado';

  @override
  String get nwMyStatus => 'O meu estado';

  @override
  String get nwTapToPublish => 'Toca para publicar na rede';

  @override
  String get nwNotSeenYet => 'Ainda não visto';

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
      'Localização indisponível — verifica que a localização está ativada.';

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
  String get mpTitle => 'Localização';

  @override
  String get mpOffline => 'Offline';

  @override
  String get mpOnlineMap => 'Mapa online';

  @override
  String get mpMyPosition => 'A minha localização';

  @override
  String get mpLayers => 'Camadas';

  @override
  String get mpOfflineToast =>
      'Mapa offline: só as zonas já guardadas serão mostradas.';

  @override
  String get mpOnlineToast =>
      'Mapa online: as zonas consultadas serão guardadas para mais tarde.';

  @override
  String get mpMapLabel => 'Mapa';

  @override
  String get mpSatelliteLabel => 'Satélite';

  @override
  String get mpSatelliteMode => 'Modo satélite';

  @override
  String get mpMapMode => 'Modo mapa';

  @override
  String get mpWrite => 'Escrever';

  @override
  String get mpCenter => 'Centrar';

  @override
  String get mpNoOneOnMap => 'Ninguém no mapa';

  @override
  String get mpPositionsAppearHere =>
      'As localizações aparecem aqui quando um contacto as partilha a partir do modo Segurança.';

  @override
  String get mpYou => 'Tu';

  @override
  String get mnTitle => 'Rede mesh';

  @override
  String get mnPeers => 'Pares';

  @override
  String get mnAvgHops => 'Média saltos';

  @override
  String get mnSignal => 'Sinal';

  @override
  String get mnStrong => 'Forte';

  @override
  String get mnMedium => 'Médio';

  @override
  String get mnSearchingPeers => 'A procurar pares ao alcance…';

  @override
  String mnPeersConnectedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pares ligados',
      one: '$count par ligado',
    );
    return '$_temp0';
  }

  @override
  String get mnNoPeersYet => 'Nenhum par ligado por agora';

  @override
  String get mnGetCloserHint =>
      'Aproxima-te de outro dispositivo com a Droplet instalada — a descoberta acontece automaticamente, sem configuração.';

  @override
  String get mnConnectedPeersHeader => 'Pares ligados';

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
  String get mnActiveGateway => 'Gateway ativo';

  @override
  String get mnPath => 'Caminho';

  @override
  String get mnTransport => 'Transporte';

  @override
  String get mnBattery => 'Bateria';

  @override
  String get mnScore => 'Pontuação';

  @override
  String get mnReconnecting => 'A religar';

  @override
  String get cnBronze => 'Bronze';

  @override
  String get cnSilver => 'Prata';

  @override
  String get cnGold => 'Ouro';

  @override
  String get cnDiamond => 'Diamante';

  @override
  String cnPointsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pontos',
      one: '$count ponto',
    );
    return '$_temp0';
  }

  @override
  String cnPointsBeforeTier(Object points, Object tier) {
    return '$points antes do nível $tier';
  }

  @override
  String get cnRelayedMessages => 'Mensagens retransmitidas para outros';

  @override
  String cnPointsSuffix(Object n) {
    return '+$n pts';
  }

  @override
  String get cnGatewayMinutes => 'Minutos em modo retransmissor (gateway)';

  @override
  String get cnExplanation =>
      'Cada mensagem que o teu dispositivo retransmite para outros, e cada minuto em que fica disponível como retransmissor, ajuda a rede mesh a alcançar mais pessoas, mais longe. Este emblema não tem qualquer efeito na app — é apenas um reconhecimento da tua contribuição.';

  @override
  String get nmTitle => 'Nova mensagem';

  @override
  String get nmNewGroup => 'Novo grupo';

  @override
  String get nmScanCode => 'Digitalizar um código';

  @override
  String get nmVerifyContactIdentity => 'Verificar a identidade de um contacto';

  @override
  String get nmNoOneInRange => 'Ninguém ao alcance';

  @override
  String get nmNoResult => 'Sem resultados';

  @override
  String get nmPeopleWillAppearHere =>
      'As pessoas que o teu dispositivo deteta aparecerão aqui.';

  @override
  String get nmInRange => 'Ao alcance';

  @override
  String get nmDirectConnection => 'Ligação direta';

  @override
  String nmViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Via $count retransmissores',
      one: 'Via $count retransmissor',
    );
    return '$_temp0';
  }

  @override
  String get chFileTooLarge => 'Ficheiro demasiado grande (máx. 50 MB)';

  @override
  String get chCannotReadMedia => 'Não é possível ler este ficheiro multimédia';

  @override
  String get chLocationDenied =>
      'Localização recusada — ativa-a nas definições do telefone para partilhar a tua posição.';

  @override
  String get chGettingPosition => 'A obter a posição…';

  @override
  String get chPositionUnavailable =>
      'Localização indisponível — tenta novamente ao ar livre.';

  @override
  String get chMicPermissionDenied => 'Permissão de microfone recusada';

  @override
  String get chCannotStartRecording => 'Não é possível iniciar a gravação';

  @override
  String get chVoiceSendFailed => 'Não é possível enviar a mensagem de voz';

  @override
  String get chFileSendFailed => 'Não é possível enviar o ficheiro';

  @override
  String get chAudioNotFullyReceived =>
      'O áudio ainda não foi recebido na íntegra';

  @override
  String get chVoiceUnreadable =>
      'Esta mensagem de voz não pode ser reproduzida — pode ter chegado incompleta.';

  @override
  String get chFileNotFullyReceived =>
      'O ficheiro ainda não foi recebido na íntegra';

  @override
  String get chSaveFailed => 'Não é possível guardar';

  @override
  String chSavedIn(Object folder) {
    return 'Guardado em $folder';
  }

  @override
  String get chMessageCopied => 'Mensagem copiada';

  @override
  String get chCallImpossibleRelay =>
      'Chamada de voz impossível: este par só está acessível por retransmissão ou Bluetooth, demasiado lento para voz. Aproxima-te para mudar para Wi-Fi.';

  @override
  String chUrlCopied(Object url) {
    return 'URL copiado: $url';
  }

  @override
  String get chEditMessageTitle => 'Editar mensagem';

  @override
  String get chMessageHint => 'Mensagem';

  @override
  String get chNeverMet => 'Nunca encontrado';

  @override
  String get chSeenJustNow => 'Visto agora mesmo';

  @override
  String chSeenMinutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto há $count minutos',
      one: 'Visto há $count minuto',
    );
    return '$_temp0';
  }

  @override
  String chSeenHoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto há $count horas',
      one: 'Visto há $count hora',
    );
    return '$_temp0';
  }

  @override
  String get chSeenYesterday => 'Visto ontem';

  @override
  String chSeenDaysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visto há $count dias',
      one: 'Visto há $count dia',
    );
    return '$_temp0';
  }

  @override
  String get chOutOfRange => 'Fora de alcance';

  @override
  String get chCloseSearchTooltip => 'Fechar pesquisa';

  @override
  String get chNetworkDetailsSemantics => 'Rede Droplet, ver detalhes';

  @override
  String chMemberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membros',
      one: '$count membro',
    );
    return '$_temp0';
  }

  @override
  String get chTypingNow => 'a escrever…';

  @override
  String get chBroadcastChannel => 'Canal de difusão';

  @override
  String get chNearby => 'Perto';

  @override
  String chReachableViaRelays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Acessível via $count retransmissores',
      one: 'Acessível via $count retransmissor',
    );
    return '$_temp0';
  }

  @override
  String get chReconnectingEllipsis => 'A religar…';

  @override
  String get chSearchInConversation => 'Pesquisar na conversa';

  @override
  String get chVoiceCall => 'Chamada de voz';

  @override
  String get chVideoCall => 'Chamada de vídeo';

  @override
  String get chCallImpossibleBtRelay =>
      'Chamada impossível: ligação Bluetooth ou retransmitida';

  @override
  String get chGroupInfoTooltip => 'Informações do grupo';

  @override
  String get chNoneFound => 'Nenhum';

  @override
  String chSearchResultPosition(Object current, Object total) {
    return '$current/$total';
  }

  @override
  String get chOlderResult => 'Resultado mais antigo';

  @override
  String get chNewerResult => 'Resultado mais recente';

  @override
  String get chLoadingOlderMessages => 'A carregar mensagens anteriores…';

  @override
  String get chToday => 'Hoje';

  @override
  String get chYesterday => 'Ontem';

  @override
  String get chMonday => 'Segunda-feira';

  @override
  String get chTuesday => 'Terça-feira';

  @override
  String get chWednesday => 'Quarta-feira';

  @override
  String get chThursday => 'Quinta-feira';

  @override
  String get chFriday => 'Sexta-feira';

  @override
  String get chSaturday => 'Sábado';

  @override
  String get chSunday => 'Domingo';

  @override
  String get chSayHello => 'Diz olá 👋';

  @override
  String get chBroadcastEmptyBody =>
      'As mensagens sem destinatário aparecem aqui.';

  @override
  String get chP2pRelayedBody =>
      'As tuas trocas são retransmitidas de par em par, sem Internet.';

  @override
  String get chReply => 'Responder';

  @override
  String get chReplyInThread => 'Responder no tópico';

  @override
  String get chCopy => 'Copiar';

  @override
  String get chAccessibilityMe => 'Eu';

  @override
  String get chPhotoLabel => 'Foto';

  @override
  String get chVideoLabel => 'Vídeo';

  @override
  String get chVoiceMessageLabel => 'Mensagem de voz';

  @override
  String chFileLabel(Object name) {
    return 'Ficheiro $name';
  }

  @override
  String chStickerLabel(Object name) {
    return 'Sticker $name';
  }

  @override
  String get chSendingStatus => 'a enviar';

  @override
  String get chPendingStatus => 'pendente';

  @override
  String get chFailedStatus => 'falha no envio';

  @override
  String get chReadStatus => 'lida';

  @override
  String get chDeliveredStatus => 'entregue';

  @override
  String get chSentStatus => 'enviada';

  @override
  String get chForwarded => 'Reencaminhada';

  @override
  String get chRetrySendLabel => 'Tentar enviar novamente';

  @override
  String get chTransmissionDetailsLabel => 'Detalhes da transmissão';

  @override
  String get chEditedBadge => 'editada';

  @override
  String get chFileWord => 'Ficheiro';

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
  String get chVideoReceiving => 'A receber o vídeo';

  @override
  String get chPreparingVideo => 'A preparar o vídeo…';

  @override
  String get nmContacts => 'Contactos';

  @override
  String get nmFindByPseudo => 'Procurar por nome';

  @override
  String get nmViaInternet => 'Pela Internet';

  @override
  String get nmOutOfRange => 'Fora de alcance';

  @override
  String get chatsInvitePerson => 'Convidar alguém';

  @override
  String get ivTitle => 'Convide quem gosta';

  @override
  String get ivSubtitle =>
      'O Droplet é melhor quando quem importa está lá — mesmo sem rede.';

  @override
  String get ivByNumber => 'Por número de telefone';

  @override
  String get ivNumberHint => 'Número com indicativo (+351…)';

  @override
  String get ivContacts => 'Contactos';

  @override
  String get ivSms => 'SMS';

  @override
  String get ivWhatsapp => 'WhatsApp';

  @override
  String get ivByLink => 'Por link';

  @override
  String get ivCopy => 'Copiar';

  @override
  String get ivShare => 'Partilhar';

  @override
  String get ivCopied => 'Link copiado';

  @override
  String get ivByQr => 'Por código QR';

  @override
  String get ivQrHint => 'Peça à pessoa que o leia, cara a cara.';

  @override
  String get ivScan => 'Ler um código';

  @override
  String get ivPrivacy =>
      'O link e o código só contêm o seu identificador público e a sua chave. Nenhum número é enviado ao Droplet.';

  @override
  String get evTitle => 'Editar vídeo';

  @override
  String evSplit(int n) {
    return 'Dividir em $n estados';
  }

  @override
  String evSplitHint(int s) {
    return 'Cada parte dura no máximo $s s';
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
  String get clMissedVoice => 'Chamada de voz perdida';

  @override
  String get clMissedVideo => 'Videochamada perdida';

  @override
  String get clCallBack => 'Ligar de volta';

  @override
  String get stoTitle => 'Armazenamento';

  @override
  String get stoSubtitle => 'Fotos, vídeos e ficheiros';

  @override
  String stoUsed(String taille) {
    return '$taille usados';
  }

  @override
  String get stoPhotos => 'Fotos';

  @override
  String get stoVideos => 'Vídeos';

  @override
  String get stoAudio => 'Voz e áudio';

  @override
  String get stoDocuments => 'Documentos';

  @override
  String get stoOther => 'Outros (estados…)';

  @override
  String get stoByChat => 'Por conversa';

  @override
  String get stoEmpty => 'Nenhum ficheiro neste telemóvel';

  @override
  String stoDelete(int n) {
    return 'Eliminar ($n)';
  }

  @override
  String get stoDeleteConfirm =>
      'Estes ficheiros e as suas mensagens serão eliminados deste telemóvel.';

  @override
  String get tabSelectChat => 'Escolha uma conversa';

  @override
  String get clConnecting => 'A ligar…';

  @override
  String chUnreadMessages(int n) {
    return '$n mensagem(ns) não lida(s)';
  }

  @override
  String get csMessagesSection => 'Mensagens';

  @override
  String chGroupTyping(String noms) {
    return '$noms está a escrever…';
  }

  @override
  String get tsReadBy => 'Lido por';

  @override
  String get tsDeliveredTo => 'Entregue a';

  @override
  String get tsWaitingFor => 'Em espera';

  @override
  String get chSelect => 'Selecionar';

  @override
  String get chForward => 'Encaminhar';

  @override
  String get chForwardTo => 'Encaminhar para…';

  @override
  String chSelectedCount(int n) {
    return '$n selecionados';
  }

  @override
  String get chForwarded1 => 'Mensagem encaminhada';

  @override
  String get apCaptionHint => 'Adicionar uma legenda…';

  @override
  String get apValidateCrop => 'Recortar';

  @override
  String get chMediaReceiving => 'A receber';

  @override
  String get chStickersTooltip => 'Stickers';

  @override
  String get chAttachTooltip => 'Anexar';

  @override
  String get chDeleteRecordingTooltip => 'Eliminar gravação';

  @override
  String get chSlideToCancel => 'Deslize para cancelar';

  @override
  String chReplyingTo(Object pseudo) {
    return 'A responder a $pseudo';
  }

  @override
  String get chEffectBoom => 'Boom';

  @override
  String get chEffectLoud => 'Alto';

  @override
  String get chEffectGentle => 'Suave';

  @override
  String get chEffectInvisibleInk => 'Tinta invisível';

  @override
  String get chEffectConfetti => 'Confetes';

  @override
  String get chEffectFireworks => 'Fogo de artifício';

  @override
  String get chEffectHearts => 'Corações';

  @override
  String get chEffectSheetTitle => 'Efeito da mensagem';

  @override
  String get chEffectSheetSubtitle =>
      'Reproduz-se uma vez, no teu ecrã e no do teu interlocutor';

  @override
  String get chOnBubble => 'Na bolha';

  @override
  String get chFullscreen => 'Ecrã inteiro';

  @override
  String get chTapToReveal => 'Toca para revelar';

  @override
  String get chThreadTitle => 'Tópico';

  @override
  String get chReplyHint => 'Resposta…';

  @override
  String get chCollapse => 'Recolher';

  @override
  String get chSeeMore => 'Ver mais';

  @override
  String get chMessageOptionsSemantics => 'Opções da mensagem';

  @override
  String get chLoveReactionSemantics => 'Adoro';

  @override
  String get chBroadcastMesh => 'Difusão mesh';

  @override
  String get chGroupFallback => 'Grupo';

  @override
  String get ciSetupBiometrics =>
      'Configura uma impressão digital ou Face ID nas definições do teu dispositivo.';

  @override
  String get ciEnableLockReason => 'Ativar o bloqueio para esta conversa';

  @override
  String get ciInfoTitle => 'Informações';

  @override
  String get ciViewConversation => 'Ver conversa';

  @override
  String get ciGatewayOnline => 'Gateway · online';

  @override
  String get ciOnline => 'Online';

  @override
  String get ciOffline => 'Offline';

  @override
  String get ciMessages => 'Mensagens';

  @override
  String get ciMedia => 'Multimédia';

  @override
  String get ciStart => 'Início';

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
      other: 'Ficheiros ($count)',
      one: 'Ficheiro ($count)',
    );
    return '$_temp0';
  }

  @override
  String get ciNoMediaSharedYet =>
      'Ainda não foi partilhado nenhum ficheiro multimédia.';

  @override
  String get ciSecurityCode => 'Código de segurança';

  @override
  String get ciVerified => 'Verificado';

  @override
  String get ciKeyChanged => 'A chave mudou';

  @override
  String get ciNotVerified => 'Não verificado';

  @override
  String get ciConversationLock => 'Bloqueio de conversa';

  @override
  String get ciLockEnabled =>
      'Ativado — impressão digital necessária para abrir';

  @override
  String get ciDisabled => 'Desativado';

  @override
  String get ciEphemeralMessages => 'Mensagens efémeras';

  @override
  String get ci30Seconds => '30 segundos';

  @override
  String get ci5Minutes => '5 minutos';

  @override
  String get ci1Hour => '1 hora';

  @override
  String get ci24Hours => '24 horas';

  @override
  String get ciDurationBeforeDisappear => 'Tempo até desaparecer';

  @override
  String get ciBlockContactTitle => 'Bloquear este contacto?';

  @override
  String ciBlockContactBody(Object pseudo) {
    return '$pseudo deixará de poder enviar-te mensagens. Podes desbloqueá-lo a qualquer momento.';
  }

  @override
  String get ciBlock => 'Bloquear';

  @override
  String get ciUnblock => 'Desbloquear';

  @override
  String ciContactBlocked(Object pseudo) {
    return '$pseudo foi bloqueado';
  }

  @override
  String ciContactUnblocked(Object pseudo) {
    return '$pseudo foi desbloqueado';
  }

  @override
  String get ciReportContactTitle => 'Denunciar este contacto?';

  @override
  String ciReportContactBody(Object pseudo) {
    return 'Uma denúncia anónima será enviada ao Droplet: um identificador técnico e o motivo escolhido abaixo, nada mais. Nenhuma mensagem, nenhuma conversa com $pseudo é jamais transmitida.';
  }

  @override
  String get ciReport => 'Denunciar';

  @override
  String get ciReportSent => 'Denúncia enviada. Obrigado.';

  @override
  String get ciReportFailed =>
      'Não foi possível enviar a denúncia — tente novamente mais tarde.';

  @override
  String get ciReportReasonSpam => 'Spam';

  @override
  String get ciReportReasonHarassment => 'Assédio';

  @override
  String get ciReportReasonIllegal => 'Conteúdo ilegal';

  @override
  String get ciReportReasonOther => 'Outro';

  @override
  String mcReactWith(Object emoji) {
    return 'Reagir com $emoji';
  }

  @override
  String get nsMeshActive => 'Mesh ativa';

  @override
  String get nsNoDeviceInRange => 'Nenhum dispositivo ao alcance';

  @override
  String get nsMessagesCirculate =>
      'As tuas mensagens circulam de dispositivo em dispositivo, sem passar pela Internet.';

  @override
  String get nsGetCloser =>
      'Aproxima-te de outro dispositivo Droplet. As tuas mensagens são guardadas e serão enviadas sozinhas.';

  @override
  String get nsDevicesInRange => 'Dispositivos ao alcance';

  @override
  String get nsReconnectingTitle => 'A religar';

  @override
  String get nsLinkMomentarilyLost =>
      'Ligação momentaneamente perdida, ainda não abandonada.';

  @override
  String get nsRelaysAvailable => 'Retransmissores disponíveis';

  @override
  String get nsNoRelayAvailable =>
      'Neste momento, nenhum dispositivo consegue encaminhar as tuas mensagens mais longe.';

  @override
  String get nsViaBluetooth => 'Via Bluetooth';

  @override
  String get nsViaLocalWifi => 'Via Wi-Fi local';

  @override
  String get nsWifiCarriesMore =>
      'O Wi-Fi transporta ficheiros e voz; o Bluetooth só transporta texto.';

  @override
  String get scInvalidQrCode => 'Código QR inválido';

  @override
  String get scWrongCode =>
      'Este não é o código certo — a chave não corresponde';

  @override
  String get scCodeVerified => 'Código verificado';

  @override
  String scVerifiedBanner(Object pseudo) {
    return 'Verificado — a chave de $pseudo corresponde a este código.';
  }

  @override
  String scKeyChangedBanner(Object pseudo) {
    return 'A chave de $pseudo mudou desde a última verificação.';
  }

  @override
  String get scNotVerifiedYet => 'Ainda não verificado.';

  @override
  String scCompareCodeInstructions(Object pseudo) {
    return 'Compara este código com o que aparece no dispositivo de $pseudo, ou digitaliza diretamente o código QR dele para verificar automaticamente.';
  }

  @override
  String get scContactKeyUnknown =>
      'A chave do contacto ainda não é conhecida — volta a ligar-te a este par na mesh.';

  @override
  String scScanCodeOf(Object pseudo) {
    return 'Digitalizar o código de $pseudo';
  }

  @override
  String get tsNotDelivered => 'Não entregue';

  @override
  String get tsRead => 'Lida';

  @override
  String get tsDelivered => 'Entregue';

  @override
  String get tsSendingInProgress => 'A enviar';

  @override
  String get tsWaitingForRelay => 'À espera de um retransmissor';

  @override
  String get tsSent => 'Enviada';

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
      other: '$count dias',
      one: '$count dia',
    );
    return '$_temp0';
  }

  @override
  String get tsTitle => 'Transmissão';

  @override
  String get tsStatus => 'Estado';

  @override
  String get tsDelayUntilRead => 'Tempo até à leitura';

  @override
  String get tsRoute => 'Trajeto';

  @override
  String get tsRouteDetail =>
      'Os dispositivos que reencaminharam esta mensagem, por ordem.';

  @override
  String get tsPath => 'Caminho';

  @override
  String tsPassedThroughDevices(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Passou por $count dispositivos',
      one: 'Passou por $count dispositivo',
    );
    return '$_temp0';
  }

  @override
  String get tsReceivedDirect => 'Recebido diretamente';

  @override
  String get tsIntermediateDevicesDetail =>
      'Dispositivos intermediários reencaminharam esta mensagem até ti.';

  @override
  String get tsUnknown => 'Desconhecido';

  @override
  String get tsSentRouteNotReturned =>
      'O trajeto de uma mensagem enviada não é devolvido ao remetente.';

  @override
  String get tsNetwork => 'Rede';

  @override
  String get tsMeshDroplet => 'Mesh Droplet';

  @override
  String get tsNoServerNoOperator => 'Sem servidor, sem operadora.';

  @override
  String get qsScanSecurityCode => 'Digitalizar o código de segurança';

  @override
  String get qsCodeDetected => 'Código detetado';

  @override
  String get qsFrameQrCode =>
      'Enquadra o código QR mostrado no dispositivo do teu contacto';

  @override
  String get rmRecentVideo => 'Vídeo recente';

  @override
  String get rmRecentPhoto => 'Foto recente';

  @override
  String get rmSeeAllPhotos => 'Ver todas as fotos';

  @override
  String get rmSeeAll => 'Ver tudo';

  @override
  String get aicOriginal => 'Original';

  @override
  String get aicAzure => 'Azul';

  @override
  String get aicNeon => 'Néon';

  @override
  String get aicPaper => 'Papel';

  @override
  String get aicLagoon => 'Lagoa';

  @override
  String get aicAmethyst => 'Ametista';

  @override
  String get aicGold => 'Ouro';

  @override
  String get aicTide => 'Maré';

  @override
  String get aicDawn => 'Aurora';

  @override
  String get aicGlass => 'Vidro';

  @override
  String get aicConstellation => 'Constelação';

  @override
  String get aicPrism => 'Prisma';

  @override
  String get aicEmerald => 'Esmeralda';

  @override
  String get aicChangeIconTitle => 'Mudar o ícone?';

  @override
  String aicChangeIconMessage(Object name) {
    return 'O ícone «$name» substituirá o do teu ecrã principal. Alguns launchers demoram alguns segundos a mostrá-lo, ou pedem para voltar ao ecrã principal.';
  }

  @override
  String get aicApply => 'Aplicar';

  @override
  String aicIconApplied(Object name) {
    return 'Ícone «$name» aplicado';
  }

  @override
  String get aicChangeIconImpossible =>
      'Não é possível mudar o ícone neste dispositivo';

  @override
  String get aicTitle => 'Ícone';

  @override
  String get aicCurrentOnHomeScreen => 'O que aparece no teu ecrã principal';

  @override
  String get aicUnavailablePlatform => 'Indisponível nesta plataforma';

  @override
  String get aicAndroidExplanation =>
      'O Android fixa o ícone de uma aplicação na instalação. A Droplet contorna isso declarando vários pontos de entrada, um por ícone, deixando apenas um ativo. O teu launcher pode demorar alguns segundos a notar.';

  @override
  String get aicAndroidOnly =>
      'A mudança de ícone só está disponível no Android.';

  @override
  String get beWeak => 'Fraca';

  @override
  String get beOkay => 'Aceitável';

  @override
  String get beStrong => 'Forte';

  @override
  String get bePasswordTooShort =>
      'A palavra-passe deve ter pelo menos 8 caracteres';

  @override
  String get bePasswordsDontMatch => 'As duas palavras-passe não coincidem';

  @override
  String get beBackupSubject => 'Cópia de segurança da Droplet';

  @override
  String get beBackupShareText =>
      'Cópia de segurança encriptada da minha identidade Droplet — guarda-a num local seguro.';

  @override
  String get beBackupCreated => 'Cópia de segurança criada';

  @override
  String get beBackupFailed => 'Falha na cópia de segurança';

  @override
  String get beBackupMyIdentity =>
      'Fazer cópia de segurança da minha identidade';

  @override
  String get beWarningBody =>
      'Quem tiver este ficheiro e a palavra-passe pode fazer-se passar por ti. Guarda-o num local seguro (nunca o envies a mais ninguém além de ti mesmo) e escolhe uma palavra-passe que só tu conheças.';

  @override
  String get bePasswordProtects =>
      'Esta palavra-passe protege a tua cópia de segurança. Nunca é guardada: sem ela, o ficheiro torna-se definitivamente inutilizável.';

  @override
  String get bePassword => 'Palavra-passe';

  @override
  String get beConfirmPassword => 'Confirmar palavra-passe';

  @override
  String get beIncludeMessageHistory => 'Incluir o histórico de mensagens';

  @override
  String get beOtherwiseOnlyIdentity =>
      'Caso contrário, só a identidade, os contactos e os grupos são guardados';

  @override
  String get beCreateAndShare => 'Criar e partilhar a cópia de segurança';

  @override
  String get jsErrorJournalTitle => 'Registo de erros';

  @override
  String get jsNoErrorsRecorded => 'Nenhum erro registado. É o estado normal.';

  @override
  String get jsLinesStayOnDevice =>
      'Estas linhas permanecem neste dispositivo: a Droplet não tem nenhum servidor para onde as enviar. Se estás a testar a aplicação, envia-as — sem elas, o defeito não existe para ninguém.';

  @override
  String get jsErase => 'Apagar';

  @override
  String get jsShareSubject => 'Droplet — registo de erros';

  @override
  String get jsShareText =>
      'Registo de erros da Droplet. Este ficheiro não contém mensagens, contactos nem chaves.';

  @override
  String get jsShareUnavailable => 'Partilha indisponível — registo copiado';

  @override
  String get clOutgoingCall => 'A ligar…';

  @override
  String get clIncomingCall => 'Chamada a receber…';

  @override
  String get clCallImpossible => 'Chamada impossível';

  @override
  String get clCallEnded => 'Chamada terminada';

  @override
  String clCallWith(Object pseudo) {
    return 'Chamada com $pseudo';
  }

  @override
  String get clEndToEndEncrypted => 'Encriptado de ponta a ponta';

  @override
  String clCallStatusSemantics(Object status) {
    return 'Estado da chamada: $status';
  }

  @override
  String get clEnableMic => 'Ativar o microfone';

  @override
  String get clMuteMic => 'Desativar o microfone';

  @override
  String get clDisableSpeaker => 'Desativar o altifalante';

  @override
  String get clEnableSpeaker => 'Ativar o altifalante';

  @override
  String get clDisableCamera => 'Desativar a câmara';

  @override
  String get clEnableCamera => 'Ativar a câmara';

  @override
  String get clHangUp => 'Desligar';

  @override
  String get clIncomingVideoCall => 'Chamada de vídeo recebida';

  @override
  String get clSwitchCamera => 'Trocar câmera';

  @override
  String get gcGroupCall => 'Chamada de grupo';

  @override
  String get gcConnecting => 'A ligar…';

  @override
  String get gcOnline => 'Em linha';

  @override
  String get gcFailed => 'Falhou';

  @override
  String get gcDisconnected => 'Desligado';

  @override
  String get gcReturnToCall => 'Voltar à chamada';

  @override
  String get gcMinimize => 'Reduzir';

  @override
  String get gcVoiceOnly => 'Apenas voz';

  @override
  String gcReactWith(String emoji) {
    return 'Reagir com $emoji';
  }

  @override
  String get gcSpeakingNow => 'Está a falar';

  @override
  String get gcMicOff => 'Microfone desligado';

  @override
  String gcParticipantsVoiceOnly(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participantes · apenas voz',
      one: '$count participante · apenas voz',
    );
    return '$_temp0';
  }

  @override
  String get ntfChannelMessagesName => 'Mensagens';

  @override
  String get ntfChannelMessagesDesc => 'Novas mensagens e estados da malha';

  @override
  String get ntfChannelCallsName => 'Chamadas';

  @override
  String get ntfChannelCallsDesc => 'Chamadas recebidas e perdidas';

  @override
  String get ntfChannelMeshName => 'Malha e emergência';

  @override
  String get ntfChannelMeshDesc =>
      'Serviço de malha ativo, estados e mensagens de emergência';

  @override
  String get ntfReply => 'Responder';

  @override
  String get ntfYourReply => 'A tua resposta';

  @override
  String get ntfMarkAsRead => 'Marcar como lida';

  @override
  String get ntfIncomingCall => 'Chamada a receber';

  @override
  String get ntfAnswer => 'Atender';

  @override
  String get ntfDecline => 'Recusar';

  @override
  String get ntfMissedCall => 'Chamada perdida';

  @override
  String get ntfSendFailedTitle => 'Falha no envio';

  @override
  String get ntfSendFailedBody =>
      'Não foi possível enviar uma mensagem — nova tentativa assim que um par estiver ao alcance.';

  @override
  String get ntfNewStatusTitle => 'Novo estado';

  @override
  String ntfStatusPublishedBody(Object pseudo) {
    return '$pseudo publicou um estado';
  }

  @override
  String ntfStatusLikedTitle(Object pseudo) {
    return '❤️ $pseudo gostou do teu estado';
  }

  @override
  String get ntfTapToView => 'Tocar para ver';

  @override
  String ntfStatusReplyTitle(Object pseudo) {
    return '💬 $pseudo respondeu ao teu estado';
  }

  @override
  String get ntfEmergencyTitle => 'Mensagem de emergência';

  @override
  String ntfEmergencyBody(Object pseudo) {
    return '$pseudo difundiu «Estou em segurança»';
  }

  @override
  String get mnAccept => 'Aceitar';

  @override
  String get mnMeshVoiceCall => 'Chamada de voz por malha';

  @override
  String get mnGroupCallIncoming => 'Chamada de grupo a receber';

  @override
  String mnInvitesYou(Object pseudo) {
    return '$pseudo convida-te';
  }

  @override
  String mnGroupCallOtherParticipants(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Chamada de grupo · $count outros participantes',
      one: 'Chamada de grupo · $count outro participante',
    );
    return '$_temp0';
  }

  @override
  String get asWhoCanSee => 'Quem pode ver este estado?';

  @override
  String get asAllContacts => 'Todos os meus contactos';

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
  String get asExceptOption => 'Exceto...';

  @override
  String asExcludedCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count excluídos',
      one: '$count excluído',
    );
    return '$_temp0';
  }

  @override
  String get asExcludeContacts => 'Excluir contactos';

  @override
  String get asOnlyOption => 'Apenas...';

  @override
  String get asShareWithSpecific => 'Partilhar com contactos específicos';

  @override
  String get asNoContactsAvailable => 'Nenhum contacto disponível';

  @override
  String get asConfirm => 'Confirmar';

  @override
  String get apYourPhoto => 'A tua foto';

  @override
  String get apNoPhotoAccessible => 'Nenhuma foto acessível neste dispositivo.';

  @override
  String get apBrowseFiles => 'Procurar ficheiros';

  @override
  String get apRecentPhoto => 'Foto recente';

  @override
  String get bgSkip => 'Saltar';

  @override
  String bgStepOfTotal(Object rang, Object total) {
    return 'Passo $rang de $total.';
  }

  @override
  String get csGuideNetworkTitle => 'Ninguém por perto? É normal';

  @override
  String get csGuideNetworkText =>
      'A Droplet não passa por nenhum servidor: fala com os telemóveis ao alcance. Aqui vês quem está contactável, e por que rádio. Zero pares não significa que não funcione — apenas que ainda ninguém está por perto.';

  @override
  String get csGuideWriteTitle => 'Escreve mesmo sem ninguém por perto';

  @override
  String get csGuideWriteText =>
      'Uma mensagem escrita agora espera no teu telemóvel e parte assim que um aparelho passar ao alcance — na rua, num táxi. Não está perdida, está a aguardar.';

  @override
  String get csGuideBackupTitle =>
      'Faz uma cópia de segurança da tua identidade';

  @override
  String get csGuideBackupText =>
      'Sem servidor, ninguém pode devolver-te a tua conta. Exporta a tua identidade a partir das definições: sem esta cópia de segurança, um telemóvel perdido leva tudo consigo.';

  @override
  String get csShowLockedChatsReason => 'Mostrar as conversas bloqueadas';

  @override
  String get cvlNoBiometricsConfigured =>
      'Nenhuma impressão digital configurada neste dispositivo';

  @override
  String cvlUnlockConversationWith(Object pseudo) {
    return 'Desbloquear a conversa com $pseudo';
  }

  @override
  String get cvlAuthFailed => 'Falha na autenticação';

  @override
  String get cvlAuthError => 'Erro de autenticação';

  @override
  String get cvlConversationLocked => 'Conversa bloqueada';

  @override
  String get cvlUnlock => 'Desbloquear';

  @override
  String get dcAddText => 'Adicionar texto';

  @override
  String get dcYourTextHint => 'O teu texto...';

  @override
  String get pbDropletProBadge => 'Distintivo Droplet Pro';

  @override
  String get rpReact => 'Reagir';

  @override
  String get rpSaveToPhone => 'Guardar no telemóvel';

  @override
  String get chViaTor => 'Via Tor';

  @override
  String get chTorInactive => 'Tor inativo';

  @override
  String get chViaInternet => 'Pela Internet';

  @override
  String get chReachedViaTorSemantic => 'Contacto alcançado via Tor';

  @override
  String get nsTorConnectedTitle => 'Ligado via Tor';

  @override
  String get nsTorInactiveTitle => 'Tor desativado';

  @override
  String nsTorConnectedExplain(Object pseudo) {
    return 'As tuas mensagens viajam pela rede Tor e aguardam numa caixa de correio encriptada até $pseudo se ligar a ela.';
  }

  @override
  String nsTorInactiveExplain(Object pseudo) {
    return 'Ativa o Tor nas definições para poderes escrever a $pseudo — sem ele, as tuas mensagens ficarão à espera neste aparelho.';
  }

  @override
  String get nsTorMailboxTitle => 'Caixa de correio encriptada';

  @override
  String nsTorMailboxDetail(Object pseudo) {
    return 'Nem tu nem a Droplet conseguem ler o que ela contém — só $pseudo tem a chave.';
  }

  @override
  String get nsOpenTorSettings => 'Ativar o Tor';

  @override
  String get qrInvalidCode => 'Este código QR não é um código Droplet.';

  @override
  String get qrPeerAdded => 'Contacto adicionado';

  @override
  String qrReadyToChatWith(Object pseudo) {
    return 'Já podes conversar com $pseudo';
  }

  @override
  String get clViaInternet => 'Via Internet';

  @override
  String get tsPathTorDetail =>
      'Esta mensagem não passa pelos aparelhos à tua volta: transita por uma caixa de correio encriptada na rede Tor, acessível só a vocês os dois.';

  @override
  String get tsNetworkTorDetail =>
      'É necessário um servidor de retransmissão para chegar a este contacto à distância — ao contrário da malha local, a Droplet não consegue evitá-lo aqui.';

  @override
  String get torSearchDirectory => 'Procurar no diretório';

  @override
  String get dvTitle => 'Procurar';

  @override
  String get dvClose => 'Fechar';

  @override
  String get dvSearchHint => 'Procurar um nome...';

  @override
  String get dvEnableTorToSearch =>
      'Ativa o Tor nas definições para procurar no diretório.';

  @override
  String get dvSearching => 'A procurar...';

  @override
  String get dvNoResults => 'Sem resultados';

  @override
  String get dvNoUserFound =>
      'Não foi encontrado nenhum utilizador para esta pesquisa.';

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
  String get aiNewConversation => 'Nova conversa';

  @override
  String get aiMessageHint => 'Mensagem';

  @override
  String get aiCopied => 'Copiado';

  @override
  String get aiAskQuestion => 'Faz uma pergunta';

  @override
  String get aiRunsLocally =>
      'Este assistente funciona inteiramente no teu aparelho — nada é jamais enviado pela Internet.';

  @override
  String get aiMemorySaved => 'Vou lembrar-me disso.';

  @override
  String get aiMemoryForgotten => 'Esqueci o que me pediste para guardar.';

  @override
  String get aiMemoryTitle => 'Memória do assistente';

  @override
  String get aiMemoryEmpty =>
      'Nada guardado ainda. Diz «lembra-te de que…» para fixar uma informação.';

  @override
  String get aiMemoryForget => 'Esquecer tudo';

  @override
  String get aiExpertHint =>
      'Conheço o Droplet a fundo: a malha, o Tor, as chamadas, a privacidade.';

  @override
  String get chAskAssistant => 'Perguntar ao assistente';

  @override
  String chAskAssistantInvite(Object name) {
    return 'Ajuda-me a responder a $name.';
  }

  @override
  String aiPreparing(Object percentage) {
    return 'A preparar o assistente… $percentage %';
  }

  @override
  String get aiOneTimeDownload =>
      'Só uma vez — depois fica no teu aparelho, sem mais nenhum download.';

  @override
  String get aiGenericError => 'Desculpa, ocorreu um erro.';

  @override
  String get aiNotAvailableYet =>
      'O assistente ainda não está disponível nesta versão da Droplet.';

  @override
  String aiDownloadFailed(Object error) {
    return 'Transferência impossível: $error';
  }

  @override
  String get ntfSomeoneCalling => 'Alguém está a tentar contactar-te';

  @override
  String get ntfNewMessageWake => 'Nova mensagem — abre a Droplet para a ler';

  @override
  String get chNearbyAndInternet => 'Por perto · Internet';

  @override
  String chRelaysAndInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count retransmissores · Internet',
      one: '$count retransmissor · Internet',
    );
    return '$_temp0';
  }

  @override
  String get chWaitingInternet => 'Aguardando Internet';

  @override
  String chatsNetMeshInternet(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por perto · Internet',
    );
    return '$_temp0';
  }

  @override
  String chatsNetMeshOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por perto · sem Internet',
    );
    return '$_temp0';
  }

  @override
  String get chatsNetInternetOnly => 'Ninguém por perto · Internet';

  @override
  String get clPathMesh => 'Mesh · Wi-Fi direto';

  @override
  String get clPathInternetDirect => 'Internet · direto';

  @override
  String get clPathInternetRelay => 'Internet · retransmissão segura';

  @override
  String get clReconnecting => 'Reconectando…';

  @override
  String get clLabelSpeaker => 'Alto-falante';

  @override
  String get clLabelCamera => 'Câmera';

  @override
  String get clLabelMic => 'Microfone';

  @override
  String get clLabelFlip => 'Virar';

  @override
  String get clEncryptedShort => 'Criptografia de ponta a ponta';

  @override
  String clQualitySemantics(int bars) {
    return 'Qualidade da chamada: $bars de 3';
  }

  @override
  String get beOnlineTitle => 'Backup automático online';

  @override
  String get beOnlineBody =>
      'Todos os dias, uma cópia cifrada com esta senha é guardada no servidor Droplet, que não consegue lê-la. Num telefone novo, bastam o mesmo nome e a mesma senha. Fotos, vídeos e arquivos recebidos não estão incluídos.';

  @override
  String get beOnlineSwitch => 'Fazer backup no servidor todos os dias';

  @override
  String beOnlineLast(String date) {
    return 'Último backup: $date';
  }

  @override
  String get beOnlineNever => 'Ainda não há backup online';

  @override
  String get beOnlineNow => 'Fazer backup agora';

  @override
  String get beOnlineDone => 'Backup online concluído';

  @override
  String get beOnlineFailed => 'Backup online indisponível no momento';

  @override
  String get obRestoreFromServer => 'Restaurar do servidor';

  @override
  String get obEnterPseudoFirst => 'Digite primeiro o nome do seu backup';

  @override
  String get obNoServerBackup => 'Nenhum backup para este nome e senha';

  @override
  String get obTooManyAttempts =>
      'Tentativas demais — tente de novo em uma hora';

  @override
  String get chatsInviteLink => 'Convidar por link';

  @override
  String invShareText(String pseudo, String lien) {
    return '$pseudo convida você para o Droplet, o mensageiro criptografado que funciona até sem rede: $lien';
  }

  @override
  String get invTitle => 'Convite';

  @override
  String invBody(String pseudo) {
    return '$pseudo convida você para conversar no Droplet.';
  }

  @override
  String get invAdd => 'Adicionar e escrever';

  @override
  String get invInvalid =>
      'Este link de convite é inválido ou está incompleto.';

  @override
  String get invSelf => 'Este é o seu próprio link de convite.';
  @override
  String get seAnimationHeader => 'Animação de envio';

  @override
  String get seAnimationFull => 'Completa';

  @override
  String get seAnimationReduced => 'Reduzida';

  @override
  String get seAnimationOff => 'Desativada';

  @override
  String get seAnimationFullDesc => 'Plic leva sua mensagem, se teletransporta e acena para você.';

  @override
  String get seAnimationReducedDesc => 'Apenas um esmaecimento, sem movimento nem partículas.';

  @override
  String get seAnimationOffDesc => 'Nenhuma animação após o envio.';

  @override
  String get seAnimationReplay => 'Toque para repetir';

  @override
  String get seAnimationNone => 'Sem animação';

  @override
  String get seAnimationSampleIn => 'A gente se vê no porto?';

  @override
  String get seAnimationSampleOut => 'Até já';

  @override
  String get trTitle => 'Tradução';

  @override
  String get trOnDevice => 'Traduzindo no dispositivo…';

  @override
  String get trUnknownLang => 'Idioma desconhecido';

  @override
  String get trOriginal => 'Original';

  @override
  String get trCopy => 'Copiar';

  @override
  String get trInChat => 'Na conversa';

  @override
  String get trRetry => 'Tentar novamente';

  @override
  String get trSame => 'Esta mensagem já está nesse idioma.';

  @override
  String get trModel => 'O modelo deste idioma ainda não está instalado no dispositivo.';

  @override
  String get trUnavailable => 'Este dispositivo não tem tradutor offline.';

  @override
  String get trFailed => 'A tradução não foi concluída.';

  @override
  String get pfMessage => 'Mensagem';

  @override
  String get pfCall => 'Chamada';

  @override
  String get pfSecurity => 'Segurança';

  @override
  String get aiActCopy => 'Copiar';

  @override
  String get aiActRead => 'Ler em voz alta';

  @override
  String get aiActStop => 'Parar a leitura';

  @override
  String get aiActLike => 'Boa resposta';

  @override
  String get aiActDislike => 'Resposta ruim';

  @override
  String get aiActShare => 'Compartilhar';

  @override
  String get aiActRegenerate => 'Gerar novamente';

  @override
  String get aiFeedbackThanks => 'Obrigado pelo feedback';

  @override
  String get intelOnlineHeader => 'Tradução e transcrição';

  @override
  String get intelOnlineTitle => 'Online quando estiver conectado';

  @override
  String get intelOnlineSubtitle => 'Grátis — MyMemory, Apple ou Google';

  @override
  String get intelOnlineFooter => 'Desativado, nada passa pela internet. Ativado e conectado: o texto a traduzir vai para o MyMemory; no iPhone, um áudio que o aparelho não consegue transcrever vai para o serviço de voz da Apple. Nesses trajetos, o conteúdo deixa de ter criptografia de ponta a ponta. No Android, só o modelo de voz é baixado: os áudios ficam no telefone. As prévias de links também contactam o site em questão.';

  @override
  String get trOnline => 'Traduzir online';

  @override
  String get trOnlineNote => 'O texto será enviado ao MyMemory, um serviço gratuito. Nesse trajeto, deixa de ter criptografia de ponta a ponta.';

  @override
  String get trViaOnline => 'Traduzido online pelo MyMemory';

  @override
  String get vnModelDownloading => 'O modelo de voz deste idioma está sendo baixado. Tente de novo em instantes.';

  @override
  String get vnModelNeeded => 'Falta o modelo de voz deste idioma. Ative “Online quando estiver conectado” nos ajustes para baixá-lo uma vez.';

  @override
  String get nwStatusHeader => 'Status';

  @override
  String get nwAddStatus => 'Adicionar status';

  @override
  String get nwStatusNewA11y => 'novo';

  @override
  String svReplySent(String name) {
    return 'Resposta enviada para $name';
  }

  @override
  String get blkYouBlocked => 'Você bloqueou este contato.';

  @override
  String get blkUnblock => 'Desbloquear';

  @override
  String get blkListTitle => 'Contatos bloqueados';

  @override
  String get blkNone => 'Nenhum contato bloqueado';

  @override
  String get blkFooter => 'Um contato bloqueado não pode mais te escrever nem te ligar, e não recebe mais seus status nem sua foto. Ele não é avisado. Seu telefone continua retransmitindo as mensagens dele para outras pessoas, sem conseguir lê-las: a rede mesh não depende de quem você bloqueia.';

  @override
  String blkUnblockTitle(String name) {
    return 'Desbloquear $name?';
  }

  @override
  String blkUnblockToCall(String name) {
    return 'Desbloquear $name para ligar?';
  }

  @override
  String get nvDone => 'OK';

  @override
  String get nvBack => 'Voltar';

  @override
  String get nvForward => 'Avançar';

  @override
  String get nvShare => 'Compartilhar';

  @override
  String get nvOpenInBrowser => 'Abrir no navegador';

  @override
  String get nvReload => 'Recarregar';

  @override
  String get nvCopyLink => 'Copiar link';

  @override
  String get nvLinkCopied => 'Link copiado';

  @override
  String get nvOpen => 'Abrir';

  @override
  String get nvMore => 'Mais';

  @override
  String get nvNotSecure => 'Não seguro';

  @override
  String get nvErrorTitle => 'Página indisponível';

  @override
  String get nvErrorBody => 'O Droplet não conseguiu acessar este site. A rede em malha não transporta a web: é preciso uma conexão com a internet.';

  @override
  String get nvRetry => 'Tentar novamente';

  @override
  String get ciLinks => 'Links';

  @override
  String get chatsFilterNearby => 'Por perto';


  @override
  String get chProxTitle => 'O Droplet também funciona sem internet';

  @override
  String get chProxActive => 'Há dispositivos Droplet ao alcance';

  @override
  String get chProxBody => 'Os celulares próximos repassam as mensagens. Quanto mais gente por perto, mais longe elas vão.';

  @override
  String get chProxSee => 'Ver quem está por perto';

  @override
  String get chStickerPreview => 'Figurinha';

  @override
  String get edCrop => 'Cortar';

  @override
  String get edRotate => 'Girar';

  @override
  String get edFilters => 'Filtros';

  @override
  String get edAdjust => 'Ajustar';

  @override
  String get edText => 'Texto';

  @override
  String get edDraw => 'Desenho';

  @override
  String get edTrim => 'Cortar vídeo';

  @override
  String get edBrightness => 'Brilho';

  @override
  String get edContrast => 'Contraste';

  @override
  String get edSaturation => 'Saturação';

  @override
  String get edWarmth => 'Calor';

  @override
  String get edVignette => 'Vinheta';

  @override
  String get edIntensity => 'Intensidade';

  @override
  String get edUndo => 'Desfazer';

  @override
  String get edDone => 'OK';

  @override
  String get edTextHint => 'Escreva…';

  @override
  String get edDelete => 'Excluir';

  @override
  String get edOriginal => 'Original';

  @override
  String get edStyle => 'Estilo';

  @override
  String get edBackground => 'Fundo';

  @override
  String get stNotificationsHeader => 'Notificações';

  @override
  String get stNotifPreview => 'Mostrar prévia';

  @override
  String get stNotifPreviewSubtitle => 'O texto da mensagem aparece na notificação. Desativado, a tela bloqueada só avisa que chegou uma mensagem.';

  @override
  String get stSearchHint => 'Buscar ajustes';

  @override
  String get stSearchEmpty => 'Nenhum ajuste corresponde';

  @override
  String get chMentionAllSubtitle => 'Avisar todos';

  @override
  String get vuOnce => 'Ver uma vez';

  @override
  String get vuOpened => 'Aberta';

  @override
  String get vuPhoto => 'Foto';

  @override
  String get vuVideo => 'Vídeo';

  @override
  String get vuMissing => 'Esta mídia ainda não chegou';

  @override
  String get pollClosed => 'Enquete encerrada';

  @override
  String pollEndsAt(String quand) {
    return 'Termina às $quand';
  }

  @override
  String get vuVoice => 'Mensagem de voz';

  @override
  String get apPatternsHeader => 'Padrão do fundo';

  @override
  String get apPatternDroplet => 'Droplet';

  @override
  String get apPatternGames => 'Jogos';

  @override
  String get apPatternHome => 'Casa';

  @override
  String get apPatternGarden => 'Jardim';

  @override
  String get imTitle => 'Mensagens favoritas';

  @override
  String get imSubtitle => 'O que você guardou';

  @override
  String get imAdd => 'Favoritar';

  @override
  String get imRemove => 'Remover dos favoritos';

  @override
  String get imAdded => 'Adicionado aos favoritos';

  @override
  String get imRemoved => 'Removido dos favoritos';

  @override
  String get imEmptyBody => 'Toque e segure numa mensagem para favoritá-la e encontrá-la aqui depois.';

  @override
  String get imClearAll => 'Remover tudo';

  @override
  String get imClearAllBody => 'As mensagens continuam nas conversas; só as estrelas são removidas.';

  @override
  String get imClear => 'Remover';

  @override
  String get imYou => 'Você';

  @override
  String get imUnknown => 'Mensagem';

  @override
  String get apPatternsFooter => 'O padrão fica atrás de todas as conversas.';

  @override
  String get grCreatedNoMessages => 'Grupo criado · sem mensagens';

  @override
  String get chatsDelete => 'Apagar conversa';

  @override
  String get chatsDeleteBody => 'As mensagens somem deste telefone. Sem servidor, ninguém pode removê-las do aparelho dos outros.';

  @override
  String get chatsDeleteConfirm => 'Apagar';

  @override
  String get chatsDeleted => 'Conversa apagada';

  @override
  String chatsDeleteTitle(String nom) {
    return 'Apagar a conversa com $nom?';
  }

  @override
  String get chatsDocument => 'Documento';

  @override
  String get epTitle => 'Mensagens temporárias';

  @override
  String get epHeadline => 'Ative as mensagens temporárias nesta conversa';

  @override
  String get epBody => 'As novas mensagens levarão a própria validade: somem dos dois telefones quando o prazo acabar.';

  @override
  String get epDelayHeader => 'Tempo até desaparecer';

  @override
  String get epHours24 => '24 horas';

  @override
  String get epDays7 => '7 dias';

  @override
  String get epDays90 => '90 dias';

  @override
  String get epOff => 'Não';

  @override
  String get epFooter => 'A configuração não altera mensagens já enviadas: cada uma mantém o prazo com que saiu.';

  @override
  String get chOnlineNow => 'Online · Internet';

  @override
  String chInternetMinutesAgo(int count) {
    return 'Pela internet há $count min';
  }

  @override
  String chInternetHoursAgo(int count) {
    return 'Pela internet há $count h';
  }

  @override
  String chInternetDaysAgo(int count) {
    return 'Pela internet há $count d';
  }

  @override
  String get pdfMissing => 'Este documento não está neste telefone.';

  @override
  String get pdfUnreadable => 'Este PDF está ilegível — pode ter chegado incompleto.';

  @override
  String get giDescription => 'Descrição';

  @override
  String get giDescriptionAdd => 'Adicionar uma descrição';

  @override
  String get giDescriptionNone => 'Sem descrição';

  @override
  String get giDescriptionHint => 'Sobre o que é este grupo?';

  @override
  String get giOnlyAdminsSend => 'Só os administradores escrevem';

  @override
  String get giOnlyAdminsSendBody => 'Os outros membros leem sem poder responder.';

  @override
  String get giSearchMembers => 'Procurar um membro';

  @override
  String get chOnlyAdminsCanWrite => 'Só os administradores podem escrever neste grupo';

  @override
  String grCreatedBy(String nom) {
    return '$nom criou o grupo';
  }

  @override
  String grAddedYou(String nom) {
    return '$nom adicionou você';
  }

  @override
  String grMemberGone(String nom) {
    return '$nom não faz mais parte do grupo';
  }

  @override
  String grAdded(String qui, String nom) {
    return '$qui adicionou $nom';
  }

  @override
  String get giQrInvite => 'Código QR';

  @override
  String get giQrRenew => 'Novo código';

  @override
  String get giQrRenewed => 'Novo código criado; o antigo já não vale';

  @override
  String get giQrExpired => 'Este código expirou';

  @override
  String get giQrExplainer => 'Este código não contém chaves. Só permite pedir para entrar: o seu telefone decide.';

  @override
  String get giQrAlreadyMember => 'Você já está neste grupo';

  @override
  String get giQrNeedContact => 'Adicione primeiro quem o convida';

  @override
  String get giQrRequestFailed => 'O pedido não pôde ser enviado';

  @override
  String giQrRequestSent(String nom) {
    return 'Pedido enviado a $nom';
  }

  @override
  String giQrValidHours(int count) {
    return 'Válido por mais $count h';
  }

  @override
  String giQrValidMinutes(int count) {
    return 'Válido por mais $count min';
  }

  @override
  String get cvNearby => 'Por perto';

  @override
  String get cvInternet => 'Internet';

  @override
  String get cvWaiting => 'Aguardando';

  @override
  String get cvOutOfReach => 'Fora de alcance';

  @override
  String get chWillSendWhenNearby => 'Sairá assim que estiver ao alcance';

  @override
  String cvHops(int count) {
    return '$count saltos';
  }

  @override
  String get nwSeenSection => 'Vistos';

  @override
  String get nwReceivedHeader => 'Recebidos';

  @override
  String get avTranslateTitle => 'Tradução';

  @override
  String get avTranslateShort => 'Compreender sem sair da app';

  @override
  String get avTranslateLong => 'A mensagem é traduzida no seu telemóvel: o conteúdo não chega a ninguém, nem sequer a um tradutor. O original fica a um toque, porque uma tradução nunca é bem o texto.';

  @override
  String get apStickerQ => 'Tens um autocolante para isso?';

  @override
  String get apOnline => 'online';

  @override
  String get apMessage => 'Mensagem';

  @override
  String get apAutoTranslated => 'Traduzido automaticamente';

  @override
  String get apBgSend => 'Olha este fundo 😍';

  @override
  String get apBgA => 'Mudaste alguma coisa?';

  @override
  String get apBgB => 'Mexe-se a cada mensagem 😮';

  @override
  String get apFormatQ => 'Onde nos encontramos?';

  @override
  String get apFormatDemo => 'Encontramo-nos **às 18 h** em frente ao __grande mercado__, código `4821`. Surpresa: ||um bolo||';

  @override
  String get apVoiceQ => 'Onde estás?';

  @override
  String get apVoiceText => 'Estou em frente à farmácia, espero por ti até às 18 h.';

  @override
  String get apTransQ => 'Olá, está tudo pronto?';

  @override
  String get apTransSource => 'Yes! See you tomorrow at the airport, gate 12 at 9am.';

  @override
  String get apTransResult => 'Sim! Vemo-nos amanhã no aeroporto, porta 12 às 9 h.';

  @override
  String get hlpDataOnDevice => 'NO SEU TELEMÓVEL';

  @override
  String get hlpDataServers => 'O QUE PASSA POR UM SERVIDOR';

  @override
  String get hlpDataServersFooter => 'Sem internet, nenhum destes servidores intervém: os telemóveis falam diretamente.';

  @override
  String get hlpDataNone => 'O QUE O DROPLET NUNCA PEDE';

  @override
  String get hlpRowKeys => 'A sua identidade';

  @override
  String get hlpRowKeysBody => 'Um par de chaves criado aqui, nunca enviado';

  @override
  String get hlpRowMessages => 'As suas mensagens';

  @override
  String get hlpRowMessagesBody => 'No espaço privado da app, apagadas ao desinstalar';

  @override
  String get hlpRowProfile => 'Nome e foto';

  @override
  String get hlpRowProfileBody => 'Só chegam a quem escreve';

  @override
  String get hlpRowSettings => 'As suas definições';

  @override
  String get hlpRowSettingsBody => 'Fundo, idioma, notificações — fica tudo aqui';

  @override
  String get hlpRowLog => 'Registo de erros';

  @override
  String get hlpRowLogBody => 'Um ficheiro local que nunca sai sozinho';

  @override
  String get hlpRowDirectory => 'Diretório';

  @override
  String get hlpRowDirectoryBody => 'Vê um nome e um identificador público. Pedidos via Tor: não o seu IP real';

  @override
  String get hlpRowMailbox => 'Caixa de correio';

  @override
  String get hlpRowMailboxBody => 'Guarda uma mensagem cifrada até à entrega. Não a consegue ler';

  @override
  String get hlpRowSignalling => 'Ligação de chamadas';

  @override
  String get hlpRowSignallingBody => 'Vê dois identificadores enquanto liga. Nenhuma voz passa por lá';

  @override
  String get hlpRowRelay => 'Retransmissão';

  @override
  String get hlpRowRelayBody => 'Reencaminha o som cifrado quando a ligação direta falha';

  @override
  String get hlpNonePhone => 'Número de telefone';

  @override
  String get hlpNoneEmail => 'Endereço de e-mail';

  @override
  String get hlpNoneContacts => 'A sua lista de contactos';

  @override
  String get hlpNoneLocation => 'A sua localização';

  @override
  String get hlpNoneAds => 'Publicidade e rastreadores';

  @override
  String get hlpNoneAnalytics => 'Medição de audiência';

  @override
  String get hlpQOffline => 'Como funciona o Droplet sem internet?';

  @override
  String get hlpAOffline => 'Os telemóveis falam diretamente, por Bluetooth e Wi-Fi. Uma mensagem também pode saltar de telemóvel em telemóvel até chegar, sem nunca passar por um servidor.';

  @override
  String get hlpQCrypto => 'As minhas mensagens são mesmo cifradas?';

  @override
  String get hlpACrypto => 'Sim, de ponta a ponta, com o protocolo Signal. A chave só existe nos dois telemóveis. Nem um retransmissor, nem a caixa de correio, nem nós conseguimos abrir uma mensagem.';

  @override
  String get hlpQNoAccount => 'Porque é que o Droplet não pede número nem e-mail?';

  @override
  String get hlpANoAccount => 'Porque não precisa. A sua identidade é uma chave criada no seu telemóvel. Nada para criar, nada para verificar e nada para roubar noutro lado.';

  @override
  String get hlpQPending => 'Porque é que a minha mensagem fica pendente?';

  @override
  String get hlpAPending => 'Ainda não há ninguém ao alcance e não há internet. A mensagem espera no telemóvel e sai assim que um caminho abrir — não precisa de repetir nada.';

  @override
  String get hlpQAddSomeone => 'Como adiciono alguém?';

  @override
  String get hlpAAddSomeone => 'Aproxime os telemóveis: a pessoa aparece sozinha. À distância, partilhe o seu link de convite ou leia o código QR dela.';

  @override
  String get hlpQUninstall => 'O que acontece se desinstalar a app?';

  @override
  String get hlpAUninstall => 'Apaga-se tudo: mensagens, contactos, identidade. Não existe cópia noutro lado, logo não há restauro. Exporte as definições antes, se mudar de telemóvel.';

  @override
  String get hlpQBattery => 'O Droplet gasta a minha bateria?';

  @override
  String get hlpABattery => 'Procurar aparelhos à volta consome. Nas definições pode reduzir isso ou ativá-lo só com a app aberta.';

  @override
  String get hlpQReport => 'Como comunico um problema?';

  @override
  String get hlpAReport => 'Em Contacto e assistência. Verá o texto exato que vai ser enviado antes de sair — nada sai do seu telemóvel sem si.';

  @override
  String get svLikeStatus => 'Gostar do estado';

  @override
  String get svUnlikeStatus => 'Retirar o gosto';

  @override
  String get stAddPhotoSemantics => 'Adicionar uma foto de perfil';

  @override
  String get stChangePhotoSemantics => 'Mudar a foto de perfil';

  @override
  String get scOverheat => 'Telemóvel sobreaquecido — o Android desligou o codificador de vídeo. Deixe-o arrefecer alguns minutos.';

  @override
  String scTooHeavy(int mo) {
    return 'Ficheiro demasiado pesado — no máximo $mo MB para atravessar a rede local.';
  }

  @override
  String get scUnsupported => 'Este formato não é suportado para um estado.';

  @override
  String get scUnreadableFile => 'Não é possível ler este ficheiro';

  @override
  String get scUnreadableTrack => 'Não é possível ler esta faixa';

  @override
  String get scNothingCaptured => 'A gravação não captou nada — tente de novo.';

  @override
  String get scVideoTrimmed => 'Vídeo encurtado para 1 min 30 — só o início é publicado.';

  @override
  String get scUnreadableVideo => 'Vídeo ilegível';

  @override
  String get chAiMe => 'Eu';

  @override
  String chAiCtxIntro(String pseudo) {
    return 'Este é o fim de uma conversa no Droplet entre o utilizador («Eu») e $pseudo:';
  }

  @override
  String chAiCtxTask(String pseudo, String langue) {
    return 'O utilizador quer ajuda para responder a $pseudo. Propõe uma resposta curta e natural, escrita em $langue, na primeira pessoa, como se fosse ele a enviá-la. Dá apenas a resposta proposta, sem preâmbulo.';
  }

  @override
  String get hlpSectionHeader => 'Ajuda e privacidade';

  @override
  String get hlpPrivacy => 'Política de privacidade';

  @override
  String get hlpData => 'Os seus dados';

  @override
  String get hlpDataValue => 'Nada sai';

  @override
  String get hlpContact => 'Contacto e assistência';

  @override
  String get hlpPrivacyTitle => 'Privacidade';

  @override
  String hlpUpdated(String date) {
    return 'Atualizado a $date';
  }

  @override
  String get hlpOnlyFrEn => 'Este texto só existe em francês e inglês. Um documento jurídico traduzido de forma aproximada comprometeria mais do que ajudaria.';

  @override
  String get hlpReadInEnglish => 'Ler em inglês';

  @override
  String get hlpReadInFrench => 'Ler em francês';

  @override
  String get hlpDataTitle => 'Os seus dados';

  @override
  String get hlpDataLead => 'O que o Droplet sabe sobre si, linha a linha. Nada aqui é uma promessa: cada linha corresponde a código.';

  @override
  String get hlpStays => 'Nunca sai do aparelho';

  @override
  String get hlpLeaves => 'Passa por um servidor';

  @override
  String get hlpNever => 'Não existe';

  @override
  String get hlpCountTracking => 'dados para o seguir';

  @override
  String get hlpCountAccount => 'conta a criar';

  @override
  String get hlpCountServers => 'servidores, e dizemos quais';

  @override
  String get hlpHelpTitle => 'Ajuda';

  @override
  String get hlpSearchHint => 'Procurar';

  @override
  String get hlpNoResult => 'Nenhuma resposta contém essa palavra. Escreva-nos: talvez seja uma pergunta que falta aqui.';

  @override
  String get hlpStillStuckFooter => 'Se a resposta não estiver aqui, responde uma pessoa.';

  @override
  String get hlpContactTitle => 'Contacto';

  @override
  String get hlpContactLead => 'Uma pergunta, um problema, uma ideia. Lemos tudo.';

  @override
  String get hlpBeforeWriting => 'Antes de escrever';

  @override
  String get hlpHelpRowBody => 'Oito respostas, acessíveis sem internet';

  @override
  String get hlpWriteUs => 'Escreva-nos';

  @override
  String get hlpWhatsApp => 'WhatsApp';

  @override
  String get hlpEmail => 'E-mail';

  @override
  String get hlpWhatsAppHello => 'Olá, uso o Droplet e tenho uma pergunta:';

  @override
  String get hlpEmailSubject => 'Droplet — pergunta';

  @override
  String hlpWhatsAppMissing(String numero) {
    return 'O WhatsApp não está instalado. O número $numero foi copiado.';
  }

  @override
  String hlpEmailCopied(String adresse) {
    return 'O endereço $adresse foi copiado.';
  }

  @override
  String get hlpReportHeader => 'Um problema';

  @override
  String get hlpReport => 'Comunicar um problema';

  @override
  String get hlpReportBody => 'Verá o que sai antes de sair';

  @override
  String get hlpReportFooter => 'O Droplet nunca envia relatórios sozinho: não tem servidor para isso. Um problema só nos chega se o enviar.';

  @override
  String get hlpReportSubject => 'Droplet — comunicação';

  @override
  String get hlpReportSheetLead => 'Diga o que aconteceu. O texto exato que vai sair aparece abaixo.';

  @override
  String get hlpReportHint => 'O que eu estava a fazer e o que aconteceu…';

  @override
  String get hlpAttachLog => 'Anexar o registo de erros';

  @override
  String get hlpWhatWillBeSent => 'O QUE SERÁ ENVIADO';

  @override
  String get hlpLogExcerpt => 'Registo (fim):';

  @override
  String get hlpCopy => 'Copiar';

  @override
  String get hlpCopied => 'Copiado';

  @override
  String get hlpOnePerson => 'O Droplet é feito por uma pessoa, não por um serviço de apoio. A resposta pode demorar um dia ou dois — chega.';

  @override
  String get avSectionHeader => 'O que o Pro traz';

  @override
  String get avUnlock => 'Desbloquear o Droplet Pro';

  @override
  String get avVoiceTitle => 'Voz em texto';

  @override
  String get avVoiceShort => 'Leia um áudio sem ouvi-lo';

  @override
  String get avVoiceLong => 'A transcrição acontece no seu telefone, offline. O áudio não vai a lugar nenhum, e você o lê numa reunião, no ônibus ou sem rede.';

  @override
  String get avFormatTitle => 'Formatação';

  @override
  String get avFormatShort => 'Negrito, itálico, código, spoiler';

  @override
  String get avFormatLong => 'Uma palavra em negrito, uma linha de código, um trecho oculto revelado com um toque: sua mensagem diz exatamente o que você queria.';

  @override
  String get avWallpaperTitle => 'Fundos e padrões';

  @override
  String get avWallpaperShort => 'Toda a galeria e os quatro pacotes';

  @override
  String get avWallpaperLong => 'Cada fundo é desenhado à mão, cada padrão conferido antes de entrar no app. Droplet, Jogos, Casa, Jardim: sua conversa não se parece com nenhuma outra.';

  @override
  String get avStickersTitle => 'Figurinhas animadas';

  @override
  String get avStickersShort => 'A gota Droplet, em movimento';

  @override
  String get avStickersLong => 'Figurinhas desenhadas para o Droplet, animadas quadro a quadro e leves o bastante para viajar pela malha sem internet.';

  @override
  String get avIconTitle => 'Ícones do app';

  @override
  String get avIconShort => 'Mude o ícone na tela inicial';

  @override
  String get avIconLong => 'Um mensageiro discreto começa pelo ícone. Escolha o que se parece com você — ou o que menos chama atenção.';

  @override
  String get avBadgeTitle => 'Selo Pro';

  @override
  String get avBadgeShort => 'Acompanha o seu nome';

  @override
  String get avBadgeLong => 'Não dá poder algum sobre ninguém. Diz apenas que você pagou para o Droplet seguir sem anúncios, sem assinatura obrigatória e sem venda de dados.';

  @override
  String get sgTitle => 'Armazenamento do grupo';

  @override
  String get sgEmpty => 'Ainda não foi partilhado nenhum ficheiro neste grupo.';

  @override
  String get sgByAuthor => 'Quem mais envia';

  @override
  String get sgFiles => 'Ficheiros';

  @override
  String get sgSortRecent => 'Mais recentes';

  @override
  String get sgSortHeavy => 'Os maiores';

  @override
  String get sgNotOnDevice => 'Não está aqui';

  @override
  String get giPhotoChanged => 'Foto do grupo alterada';

  @override
  String get giPhotoFailed => 'Não foi possível guardar esta imagem';

  @override
  String sgTotal(int count) {
    return '$count ficheiros partilhados';
  }

  @override
  String get vrTitle => 'Sala de voz';

  @override
  String get vrJoin => 'Entrar';

  @override
  String get vrBack => 'Voltar';

  @override
  String get vrStart => 'Abrir uma sala de voz';

  @override
  String get vrNeedsInternet => 'Uma sala de voz precisa de internet: a malha leva uma mensagem que espera, não vinte vozes ao mesmo tempo.';

  @override
  String get vrUnreachable => 'O servidor de chamadas está inacessível de momento.';

  @override
  String vrFull(int count) {
    return 'A sala está cheia: no máximo $count pessoas.';
  }

  @override
  String get vrWaiting => 'À espera dos outros…';

  @override
  String get vrWaitingBody => 'A sala está aberta. Os membros do grupo veem-na na conversa e entram quando estiverem disponíveis.';

  @override
  String vrPeople(int count) {
    return '$count pessoas dentro';
  }

  @override
  String get cvTitle => 'Conversas';

  @override
  String get cvNew => 'Nova conversa';

  @override
  String get cvPinned => 'Fixadas';

  @override
  String get cvRecent => 'Recentes';

  @override
  String get cvPin => 'Fixar';

  @override
  String get cvUnpin => 'Desafixar';

  @override
  String get cvRename => 'Renomear';

  @override
  String get cvRenameHint => 'Título da conversa';

  @override
  String get cvUntitled => 'Sem título';

  @override
  String get cvYesterday => 'Ontem';

  @override
  String get cvSearchHint => 'Pesquisar nas conversas';

  @override
  String get cvEmpty => 'Ainda sem conversas. Faça a primeira pergunta ao assistente.';

  @override
  String get cvDeleteTitle => 'Eliminar esta conversa?';

  @override
  String get cvDeleteBody => 'Não poderá ser recuperada: só existe neste aparelho.';

  @override
  String get jaWorking => 'A trabalhar…';

  @override
  String cvNoResult(String terme) {
    return 'Nada encontrado para «$terme».';
  }

  @override
  String cvResults(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Sem resultados',
      one: '1 resultado',
      other: '$count resultados',
      locale: localeName,
    );
  }

  @override
  String jaSteps(int count) {
    return intl.Intl.plural(
      count,
      zero: 'Sem etapas',
      one: '1 etapa',
      other: '$count etapas',
      locale: localeName,
    );
  }

  @override
  String get moTitle => 'Para onde vai a sua mensagem';

  @override
  String get moLocal => 'No aparelho';

  @override
  String get moLocalBody => 'O modelo corre neste telemóvel. Nada sai dele, mesmo sem rede. As respostas são mais curtas e menos fiáveis.';

  @override
  String get moOnline => 'Online';

  @override
  String get moOnlineBody => 'A sua mensagem vai para a Groq, que corre um modelo muito maior. É preciso rede, e a mensagem sai do telemóvel.';

  @override
  String get moOnlineNoKey => 'Falar com um modelo remoto exige uma chave. Toque para adicionar uma — é gratuito e demora um minuto.';

  @override
  String get moRetryOnline => 'Refazer online';

  @override
  String get moRetryOnlineWhy => 'O modelo do aparelho atingiu os seus limites nesta pergunta.';

  @override
  String get cpHint => 'Pergunte alguma coisa…';

  @override
  String get cpAdd => 'Adicionar';

  @override
  String get cpPhoto => 'Foto';

  @override
  String get cpCamera => 'Câmara';

  @override
  String get cpFile => 'Ficheiro';

  @override
  String get cpFileHint => 'PDF, texto, código';

  @override
  String get cpDictate => 'Ditar';

  @override
  String get cpSend => 'Enviar';

  @override
  String get cpStop => 'Parar';

  @override
  String get cpThinking => 'A pensar…';

  @override
  String get amCopy => 'Copiar';

  @override
  String get amCopyMarkdown => 'Copiar como Markdown';

  @override
  String get amCopyMarkdownHint => 'Mantém a formatação, para um documento';

  @override
  String get amShare => 'Partilhar';

  @override
  String get amEdit => 'Editar a minha pergunta';

  @override
  String get amEditHint => 'Tudo o que vem a seguir será apagado';

  @override
  String get amEditTitle => 'Editar esta pergunta?';

  @override
  String get amEditConfirm => 'Editar';

  @override
  String get amRegenerate => 'Regenerar';

  @override
  String get amReadAloud => 'Ler em voz alta';

  @override
  String get amAsContext => 'Usar como contexto';

  @override
  String get amAsContextHint => 'Continua a partir desta mensagem';

  @override
  String get amChapter => 'Marcar como capítulo';

  @override
  String get amChapterHint => 'Para o reencontrar numa conversa longa';

  @override
  String get amUnchapter => 'Retirar a marca';

  @override
  String get amChapters => 'Capítulos';

  @override
  String get amChaptersEmpty => 'Ainda sem capítulos. Mantenha premida uma mensagem e escolha «Marcar como capítulo» para a encontrar aqui.';

  @override
  String amEditBody(int count) {
    return '$count mensagens seguintes serão apagadas: respondiam à pergunta antiga.';
  }

  @override
  String get trAssistant => 'Assistente';

  @override
  String get trArtifacts => 'Artefactos';

  @override
  String get trMemory => 'Memória';

  @override
  String get trHelp => 'Ajuda';

  @override
  String get arVersions => 'Versões';

  @override
  String get arLatest => 'A mais recente';

  @override
  String get arSource => 'Código';

  @override
  String get arPreview => 'Pré-visualização';

  @override
  String get arGone => 'Este artefacto já não existe.';

  @override
  String get arKindPage => 'Página';

  @override
  String get arKindCode => 'Código';

  @override
  String get arKindDiagram => 'Esquema';

  @override
  String get arKindData => 'Dados';

  @override
  String get arKindDoc => 'Documento';

  @override
  String arVersion(int n) {
    return 'Versão $n';
  }

  @override
  String get aiSources => 'Fontes';

  @override
  String get aiToolReading => 'A ler o anexo…';

  @override
  String get aiToolWriting => 'A criar o ficheiro…';

  @override
  String get aiToolRemembering => 'A memorizar…';

  @override
  String get arEmpty => 'Ainda sem artefactos. O assistente cria um assim que produz uma página, uma tabela ou código suficientemente longo para atrapalhar a conversa.';

  @override
  String get raTitle => 'Assistente online';

  @override
  String get raIntro => 'O assistente do aparelho funciona sem configuração. O modo online precisa de uma chave: é ela que paga as respostas, e fica neste telemóvel.';

  @override
  String get raKey => 'Chave';

  @override
  String get raKeySaved => 'Chave guardada';

  @override
  String get raKeyFooter => 'Fica no porta-chaves do sistema e nunca é mostrada por inteiro.';

  @override
  String get raKeyRemove => 'Remover a chave';

  @override
  String get raWhere => 'Cria-se em console.groq.com, em «API Keys». Começa por gsk_.';

  @override
  String get raPaste => 'Colar';

  @override
  String get raSaveAndTest => 'Guardar e testar';

  @override
  String get raTest => 'Testar a chave';

  @override
  String get raTesting => 'A testar…';

  @override
  String get raNotTested => 'Ainda não testada';

  @override
  String get raNotTestedBody => 'Basta uma chamada de oito palavras. Melhor aqui do que a meio de uma pergunta.';

  @override
  String get raWorks => 'A chave funciona';

  @override
  String get raWorksBody => 'O modo online já está disponível na conversa, na pastilha ao lado do campo de texto.';

  @override
  String get raRefused => 'Chave recusada';

  @override
  String get raRefusedBody => 'O servidor não a reconhece. Muitas vezes falta um caráter ao colar, ou a chave foi revogada.';

  @override
  String get raNoNetwork => 'Servidor inacessível';

  @override
  String get raNoNetworkBody => 'A chave não tem culpa: o pedido nunca chegou. Verifique a ligação e tente de novo.';

  @override
  String get raModelGone => 'Modelo indisponível';

  @override
  String get raModelGoneBody => 'A chave é aceite, mas não voltou nada. O modelo terá sido retirado.';

  @override
  String get raQuota => 'Demasiados pedidos';

  @override
  String get raQuotaBody => 'A chave funciona, mas a conta atingiu o limite. Tente mais tarde ou verifique o crédito.';

  @override
  String get raWhatGoesOut => 'O que sai';

  @override
  String get raModel => 'Modelo';

  @override
  String get raWhatGoesOutFooter => 'No modo online, a sua mensagem e as trocas anteriores desta conversa vão para a Groq. Mais nada: nem os contactos, nem as outras conversas, nem a localização.';

  @override
  String get aiDownloadTitle => 'Descarregar o modelo do aparelho?';

  @override
  String get aiDownloadConfirm => 'Descarregar';

  @override
  String get aiDownloading => 'A descarregar o modelo';

  @override
  String aiDownloadBody(int mo) {
    return '$mo MB para descarregar, uma só vez. Depois o assistente responde sem rede e nada sai do telemóvel. Pode continuar a usá-lo online durante a descarga.';
  }

  @override
  String moLocalToDownload(int mo) {
    return '$mo MB para descarregar, uma só vez. Depois responde sem rede e nada sai do telemóvel.';
  }

  @override
  String get aiGreetingPlain => 'Olá';

  @override
  String get aiGreetingHint => 'Faça uma pergunta, junte uma foto ou peça um documento.';

  @override
  String get aiChipExplain => 'Explica-me…';

  @override
  String get aiChipWrite => 'Escreve uma mensagem';

  @override
  String get aiChipSummarize => 'Resume isto';

  @override
  String get aiChipTranslate => 'Traduz para…';

  @override
  String aiGreeting(String nom) {
    return 'Olá, $nom';
  }

  @override
  String get cpNoPhoto => 'Sem fotos: o modelo online não sabe ler uma imagem. Lê, porém, PDF, mesmo longos.';

  @override
  String get mvOpen => 'Modo de voz';

  @override
  String get mvTapToTalk => 'Toque para falar';

  @override
  String get mvHoldToTalk => 'Mantenha para falar';

  @override
  String get mvListening => 'A ouvir…';

  @override
  String get mvTranscribing => 'A transcrever…';

  @override
  String get mvSpeaking => 'A responder em voz alta';

  @override
  String get mvProblem => 'Ocorreu um problema';

  @override
  String get mvHandsFree => 'Mãos livres';

  @override
  String get mvHold => 'Manter';

  @override
  String get mvTalk => 'Falar';

  @override
  String get mvInterrupt => 'Interromper';

  @override
  String get mvNoMic => 'O Droplet não tem acesso ao microfone. Permita-o nas definições do telefone.';

  @override
  String get mvFailed => 'Esta vez não funcionou. Toque para tentar de novo.';

  @override
  String get mvLive => 'Em direto';

  @override
  String get mvCaptions => 'Legendas';

  @override
  String get mvExit => 'Sair do modo de voz';

  @override
  String get mvMute => 'Desativar o microfone';

  @override
  String get mvUnmute => 'Reativar o microfone';

  @override
  String get mvMuted => 'Microfone desativado';

  @override
  String get mvTapToInterrupt => 'Toque para interromper';

  @override
  String scCompressing(int percent) {
    return 'A comprimir… $percent%';
  }

  @override
  String get scStillHeavy => 'Este vídeo continua acima de 2 MB: a transferência será mais lenta.';

  @override
  String get baConnecting => 'A ligar…';

  @override
  String get baMute => 'Desativar microfone';

  @override
  String get baUnmute => 'Reativar microfone';

  @override
  String get baHangUp => 'Terminar chamada';

  @override
  String baOngoing(String name) {
    return 'Chamada em curso com $name. Toque para voltar.';
  }

  @override
  String get ntfOngoingCall => 'Chamada em curso';

  @override
  String get ntfViaMesh => 'Pela malha';

  @override
  String get ntfViaInternet => 'Pela Internet';

  @override
  String get shSend => 'Enviar';

  @override
  String get shRecents => 'Recentes';

  @override
  String get shPickRecipients => 'Escolha um ou mais destinatários';

  @override
  String shSendCount(int count) {
    return 'Enviar a $count';
  }

  @override
  String shSelected(int count) {
    return '$count selecionado(s)';
  }

  @override
  String get apcNothingYet => 'Ainda nada';

  @override
  String get apcOnline => 'Online';

  @override
  String get apcOffline => 'Offline';

  @override
  String get apcPhoto => 'Foto';

  @override
  String get apcVoice => 'Mensagem de voz';

  @override
  String get apcAttachment => 'Anexo';

  @override
  String get chKeyboardTooltip => 'Teclado';

  @override
  String get asGallery => 'Galeria';

  @override
  String get asFile => 'Ficheiro';

  @override
  String get asLocation => 'Localização';

  @override
  String get asSticker => 'Autocolante';

  @override
  String get asPoll => 'Sondagem';

  @override
  String get asNoGalleryAccess => 'O Droplet não tem acesso às suas fotos. Permita-o nas definições do telefone ou escolha outra fonte abaixo.';

  @override
  String asSendCount(int count) {
    return 'Enviar $count';
  }

  @override
  String get asEmptyGallery => 'Nenhuma foto nem vídeo neste telefone.';

  @override
  String get expAucunPairTitre => 'Ninguém por perto?';

  @override
  String get expAucunPairTexte => 'Não é uma avaria. O Droplet procura sem parar; assim que um aparelho passar, a ligação faz-se sozinha.';

  @override
  String get expRelaisTitre => 'Passou por outro';

  @override
  String get expRelaisTexte => 'Este ícone indica que a mensagem atravessou um ou mais aparelhos antes de chegar. É a força da malha.';

  @override
  String get expApercuTitre => 'Espreitar';

  @override
  String get expApercuTexte => 'Mantenha o dedo numa conversa para ler as últimas mensagens sem a abrir nem marcar como lida.';

  @override
  String get expOfficielTitre => 'A conta Droplet';

  @override
  String get expOfficielTexte => 'As novidades da aplicação chegam aqui. Cada anúncio é assinado: ninguém pode falsificá-lo.';

  @override
  String get expMicroTitre => 'Falar sem largar';

  @override
  String get expMicroTexte => 'Mantenha premido para gravar. Deslize para a esquerda para cancelar, para cima para continuar sem segurar.';

  @override
  String get expCameraTitre => 'Micro ou câmara';

  @override
  String get expCameraTexte => 'Um toque breve neste botão alterna entre mensagem de voz e mensagem de vídeo redonda.';

  @override
  String get expVueUniqueTitre => 'Uma só vez';

  @override
  String get expVueUniqueTexte => 'Ative o «1» e o próximo envio só poderá ser aberto uma vez, desaparecendo depois.';

  @override
  String get expPiecesTitre => 'Várias de uma vez';

  @override
  String get expPiecesTexte => 'O clipe abre a sua galeria dentro da aplicação. Marque várias fotos: o número indica a ordem de envio.';

  @override
  String get expStickersTitre => 'Stickers e teclado';

  @override
  String get expStickersTexte => 'Este ícone troca o teclado pelos stickers e volta a ser teclado com um só toque.';

  @override
  String get expEphemeresTitre => 'Mensagens que se apagam';

  @override
  String get expEphemeresTexte => 'Defina um prazo e as novas mensagens desta conversa apagar-se-ão dos dois telemóveis.';

  @override
  String get expVerrouTitre => 'Conversa bloqueada';

  @override
  String get expVerrouTexte => 'Bloqueada, uma conversa deixa de mostrar a última mensagem na lista e pede desbloqueio.';

  @override
  String get expCodeTitre => 'Verificar um contacto';

  @override
  String get expCodeTexte => 'Compare este código lado a lado com o seu contacto: se for igual, ninguém se intrometeu entre vocês.';

  @override
  String get expStatutTitre => 'Estados de 24 horas';

  @override
  String get expStatutTexte => 'Um estado vive um dia e depois apaga-se. Viaja de telemóvel em telemóvel, mesmo sem internet.';

  @override
  String get expGardeTitre => 'Nada se perde';

  @override
  String get expGardeTexte => 'Uma mensagem enviada a alguém ausente é guardada uma semana e parte sozinha assim que houver caminho.';

  @override
  String get expVoieTitre => 'Por onde passa';

  @override
  String get expVoieTexte => 'Bluetooth, Wi-Fi direto ou internet: o Droplet usa o que houver e muda de via sem lhe perguntar nada.';

  @override
  String get cnAnnouncement => 'Novidade do Droplet';

  @override
  String get cnClearAll => 'Limpar tudo';

  @override
  String get cnClearAllTitle => 'Limpar todas as notificações?';

  @override
  String get cnClearAllBody => 'A central será esvaziada. Suas conversas e mensagens não são afetadas.';

  @override
  String get cnDelete => 'Limpar';

  @override
  String get cnEmptyTitle => 'Nada de novo';

  @override
  String get cnEmptyBody => 'Menções, reações às suas mensagens, chamadas perdidas e novidades do Droplet aparecerão aqui.';

  @override
  String get cnMentioned => 'mencionou você';

  @override
  String get cnShowLess => 'Mostrar menos';

  @override
  String get cnStatusLike => 'curtiu seu status';

  @override
  String get cnStatusReply => 'respondeu ao seu status';

  @override
  String get cnTitle => 'Central de notificações';

  @override
  String get ncDeliveryHeader => 'Entrega';

  @override
  String get ncMentionsOnly => 'Somente menções';

  @override
  String get ncMentionsOnlySub => 'Só quando alguém escreve @seu nome ou @todos';

  @override
  String get ncMute1h => '1 hora';

  @override
  String get ncMute8h => '8 horas';

  @override
  String get ncMute1w => '1 semana';

  @override
  String get ncMuteAlways => 'Sempre';

  @override
  String get ncMuteFooter => 'Sem notificações nem sons. As mensagens continuam chegando e esperam por você.';

  @override
  String get ncMuteFooterGroup => 'Sem notificações nem sons. As menções ainda chegam até você.';

  @override
  String get ncMuteHeader => 'Silenciar';

  @override
  String get ncMuteOff => 'Desativado';

  @override
  String get ncPreviewAlways => 'Sempre';

  @override
  String get ncPreviewFooter => 'Sem prévia, a notificação diz apenas “Nova mensagem”: nada aparece na tela de bloqueio.';

  @override
  String get ncPreviewHeader => 'Prévia da mensagem';

  @override
  String get ncPreviewNever => 'Nunca';

  @override
  String get ncQuiet => 'Entrega discreta';

  @override
  String get ncQuietSub => 'Na aba, sem som nem banner';

  @override
  String get ncSampleAuthor => 'Lia';

  @override
  String get ncSampleHidden => 'Nova mensagem';

  @override
  String get ncSampleLabel => 'Notificação de exemplo';

  @override
  String get ncSampleText => 'Nos encontramos às 19h?';

  @override
  String get ncStateMentions => 'Somente menções';

  @override
  String get ncStateMuted => 'Silenciado';

  @override
  String get ncStateOn => 'Ativadas';

  @override
  String get ncStateQuiet => 'Discretas';

  @override
  String get ncSystemFooter => 'O som e as bolhas desta conversa são ajustados no Android.';

  @override
  String get ncSystemSettings => 'Som e bolhas';

  @override
  String get ncTitle => 'Notificações';

  @override
  String get ntfNewMessage => 'Nova mensagem';

  @override
  String get ntfNow => 'agora';

  @override
  String get rnBanners => 'Banners';

  @override
  String get rnBannersSub => 'Quando chega uma mensagem com o Droplet aberto';

  @override
  String get rnFocus1h => 'Por 1 hora';

  @override
  String get rnFocusEvening => 'Até esta noite';

  @override
  String get rnFocusTomorrow => 'Até amanhã de manhã';

  @override
  String get rnFocusFooter => 'O Droplet fica em silêncio: as mensagens chegam e esperam por você. As chamadas continuam tocando.';

  @override
  String get rnFocusHeader => 'Foco';

  @override
  String get rnFocusMentions => 'Permitir menções';

  @override
  String get rnFocusMentionsSub => 'Quando alguém escreve @seu nome em um grupo';

  @override
  String get rnFocusOff => 'Foco desativado';

  @override
  String get rnFocusOffSub => 'As notificações chegam normalmente';

  @override
  String get rnFocusOn => 'Foco ativado';

  @override
  String get rnFocusStop => 'Desativar foco';

  @override
  String get rnFocusStopShort => 'Parar';

  @override
  String get rnInAppHeader => 'No Droplet';

  @override
  String get rnMutedEmpty => 'Nenhuma conversa silenciada.';

  @override
  String get rnMutedHeader => 'Silenciadas';

  @override
  String get rnPreview => 'Mostrar prévia';

  @override
  String get rnPreviewFooter => 'O texto das mensagens nas notificações. Cada conversa pode mudar isso.';

  @override
  String get rnSystem => 'Configurações do Android';

  @override
  String get rnSystemFooter => 'Permissões, sons e bolhas do Droplet nas configurações do telefone.';

  @override
  String get stNotificationsSubtitle => 'Silenciar, prévias, foco';

  @override
  String cnBellUnread(int count) {
    return 'Notificações, $count novas';
  }

  @override
  String cnMore(int count) {
    return '+$count a mais';
  }

  @override
  String ntfMoreMessages(int count) {
    return '+$count a mais';
  }

  @override
  String cnQuoted(String texte) {
    return '“$texte”';
  }

  @override
  String cnReacted(String emoji) {
    return 'reagiu $emoji à sua mensagem';
  }

  @override
  String ncMutedUntil(String heure) {
    return 'Até $heure';
  }

  @override
  String ncPreviewDefault(String valeur) {
    return 'Padrão ($valeur)';
  }

  @override
  String muTitle(String nom) {
    return 'Silenciar $nom';
  }

  @override
  String rnFocusUntil(String heure) {
    return 'Até $heure · as chamadas continuam tocando';
  }

  @override
  String ntfSummaryChats(String n) {
    return '$n conversas';
  }

  @override
  String get chatsNetSearching => 'Procurando aparelhos próximos…';

  @override
  String get cfEmptyUnreadTitle => 'Tudo lido';

  @override
  String get cfEmptyUnreadBody => 'Conversas com mensagens não lidas aparecerão aqui.';

  @override
  String get cfEmptyGroupsTitle => 'Nenhum grupo ainda';

  @override
  String get cfEmptyGroupsBody => 'Crie um com o botão + no canto superior direito.';

  @override
  String get cfEmptyOtherTitle => 'Nada aqui ainda';

  @override
  String get ciLockedWhereHint => 'Bloqueada. Para encontrá-la, puxe a lista de conversas para baixo.';

  @override
  String get chDraftLabel => 'Rascunho:';

  @override
  String get rsMorning => 'Bom dia';

  @override
  String get rsEvening => 'Boa noite';

  @override
  String get rsUnreadOne => '1 mensagem não lida';

  @override
  String get rsChatsOne => 'em 1 conversa';

  @override
  String get rsMentionsOne => '1 menção';

  @override
  String get rsMissedOne => '1 chamada perdida';

  @override
  String get rsSeeUnread => 'Ver não lidas';

  @override
  String rsUnreadMany(int count) {
    return '$count mensagens não lidas';
  }

  @override
  String rsChatsMany(int count) {
    return 'em $count conversas';
  }

  @override
  String rsMentionsMany(int count) {
    return '$count menções';
  }

  @override
  String rsMissedMany(int count) {
    return '$count chamadas perdidas';
  }

  @override
  String get camUnavailable => 'Câmera indisponível. Verifique a permissão nas Configurações.';

  @override
  String get camTakePhoto => 'Tirar uma foto';

  @override
  String get camFlip => 'Alternar câmera';

  @override
  String get chE2eNotice => 'As mensagens são protegidas com criptografia de ponta a ponta. Ninguém mais, nem mesmo o Droplet, pode lê-las.';

  @override
  String chCallUnreachable(String name) {
    return '$name está fora de alcance: você poderá ligar quando estiverem perto ou online.';
  }

  @override
  String get chPin => 'Fixar';

  @override
  String get chUnpin => 'Desafixar';

  @override
  String get chPinnedMessage => 'Mensagem fixada';

  @override
  String get chVoicePlay => 'Reproduzir';

  @override
  String get chVoicePause => 'Pausar';

  @override
  String chPinnedMessageN(String position) {
    return 'Mensagem fixada $position';
  }

  @override
  String get msgInfo => 'Dados';

  @override
  String get imSearch => 'Pesquisar';

  @override
  String get apcVideo => 'Vídeo';

  @override
  String get adTitle => 'Aparelhos conectados';

  @override
  String get adSettingsSubtitle => 'Droplet Web no seu computador';

  @override
  String get adHero => 'Use o Droplet no seu computador, mesmo com o celular desligado. É só abrir:';

  @override
  String get adLink => 'Conectar um aparelho';

  @override
  String get adDevices => 'Aparelhos';

  @override
  String adCount(int n, int max) {
    return '$n de $max';
  }

  @override
  String get adNone => 'Nenhum aparelho conectado';

  @override
  String get adFooter => 'Suas mensagens são protegidas com a criptografia de ponta a ponta em todos os seus aparelhos. Cada aparelho conectado tem suas próprias chaves, e você pode desconectá-lo a qualquer momento.';

  @override
  String adLinkedOn(String date) {
    return 'Conectado em $date';
  }

  @override
  String get adLogout => 'Desconectar';

  @override
  String adLogoutTitle(String nom) {
    return 'Desconectar $nom?';
  }

  @override
  String get adLogoutBody => 'Este navegador perderá o acesso às suas conversas. Você pode conectá-lo de novo a qualquer momento.';

  @override
  String get adLogoutAll => 'Desconectar de todos os aparelhos';

  @override
  String get adLogoutAllBody => 'Todos os navegadores conectados perderão o acesso às suas conversas.';

  @override
  String get adScanTitle => 'Conectar um aparelho';

  @override
  String get adScanHint => 'No seu computador, abra o Droplet Web e aponte para o QR code:';

  @override
  String get adSecurity => 'O código muda a cada minuto: uma foto dele não serve para nada.';

  @override
  String get adNotDroplet => 'Este não é um código do Droplet Web. Aponte para o código exibido em web.dropletmesh.app.';

  @override
  String get adConfirmTitle => 'Conectar este aparelho?';

  @override
  String get adConfirmBody => 'Ele poderá ler e enviar suas mensagens, mesmo com este celular desligado.';

  @override
  String get adConfirm => 'Conectar';

  @override
  String get adLinking => 'Conectando…';

  @override
  String get adLinked => 'Aparelho conectado';

  @override
  String get adServerDown => 'Não foi possível acessar os servidores do Droplet no momento. Verifique sua conexão e tente novamente.';

  @override
  String get adLimit => 'Você já tem 4 aparelhos conectados. Desconecte um para conectar outro.';

  @override
  String get adNoIdentity => 'Primeiro, crie seu perfil do Droplet neste celular.';

  @override
  String get adTorch => 'Lanterna';
}
