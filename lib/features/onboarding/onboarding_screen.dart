// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'ACCUEIL : ce qu'on voit une seule fois, entre l'ouverture de l'app et
// la première discussion.
//
// ── Ce que font les meilleures apps iOS, et ce qu'on en garde ─────────
//
// • PEU D'ÉCRANS, UNE IDÉE CHACUN. Quatre récits courts (un dessin, un
//   titre de deux ou trois mots, une phrase), puis trois étapes qui
//   installent : le nom, la photo, et « vous êtes prêt ». L'ancien
//   accueil enchaînait sept pages de listes de fonctionnalités : on les
//   survolait sans rien retenir.
// • ON PEUT TOUJOURS PASSER. « Passer » en haut à droite des récits, et
//   « J'ai déjà un compte » dès le premier écran : quelqu'un qui revient
//   ne doit pas lire une présentation pour retrouver ses discussions.
// • UN SEUL BOUTON PRINCIPAL, toujours au même endroit, qui dit ce qui
//   va se passer. Le reste en texte, discret.
// • CHAQUE DESSIN MONTRE CE QUE DIT LE TEXTE, avec la goutte de la marque
//   comme personnage (voir `illustrations_accueil.dart`).
// • RIEN DE FAUX. Les anciens textes promettaient « pas de serveur » ;
//   Droplet en utilise quand Internet est là (boîte aux lettres, appels,
//   sauvegarde en ligne). Les nouveaux disent ce qui est vrai : sans
//   Internet, de téléphone en téléphone ; avec, tout de suite.
//
// ── La continuité avec l'ouverture ───────────────────────────────────
//
// La marque de l'ouverture vient se poser au centre du premier récit
// (`HeroMarque`, `CibleOuverture`) ; le texte et les boutons n'entrent
// qu'une fois qu'elle est posée (`ApresOuverture`).
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/server_config.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/crypto_service.dart';
import '../../core/services/media_service.dart';
import '../../core/services/sauvegarde_en_ligne.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/droplet_design.dart';
import '../../design_system/ouro_alert.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_pressable.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/avatar_picker_sheet.dart';
import '../../shared/widgets/ios_magnifier_overlay.dart';
import 'illustrations_accueil.dart';
import 'ouverture_droplet.dart';

/// Les étapes de l'accueil.
enum EtapeAccueil { recits, nom, photo, pret }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.depart = EtapeAccueil.recits, this.recitDepart = 0, this.pseudoDepart});

  /// Pour les tests de rendu : commencer à une étape donnée.
  @visibleForTesting
  final EtapeAccueil depart;
  @visibleForTesting
  final int recitDepart;
  @visibleForTesting
  final String? pseudoDepart;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _recitsCtrl = PageController(initialPage: widget.recitDepart);
  late final TextEditingController _pseudoCtrl = TextEditingController(text: widget.pseudoDepart);
  final FocusNode _focusNom = FocusNode();

  static const int _nbRecits = 4;

  late EtapeAccueil _etape = widget.depart;
  late int _recit = widget.recitDepart;

  /// Le sens de la dernière transition : vers l'avant (on avance dans
  /// l'accueil) ou vers l'arrière (retour).
  bool _enAvant = true;

  bool _busy = false;

  /// Le nom du fichier de la photo choisie, s'il y en a une.
  String? _avatarNom;

  /// Ses octets, pour l'afficher sans relire le fichier tout juste écrit.
  Uint8List? _avatarApercu;

  /// Vrai une fois l'identité créée : on ne revient plus en arrière (le
  /// nom et la photo sont enregistrés, les clés générées — un champ encore
  /// modifiable ferait croire qu'on peut changer ce qui ne changera plus).
  bool _identiteCreee = false;

  @override
  void initState() {
    super.initState();
    _pseudoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _recitsCtrl.dispose();
    _pseudoCtrl.dispose();
    _focusNom.dispose();
    super.dispose();
  }

  String get _pseudo => _pseudoCtrl.text.trim();
  bool get _pseudoValid => _pseudo.length >= 3;

  // ─────────────────────────────────────────────────────────────
  //  NAVIGATION
  // ─────────────────────────────────────────────────────────────

  void _allerA(EtapeAccueil etape) {
    final avant = etape.index > _etape.index;
    if (etape == EtapeAccueil.recits) {
      // Retour aux récits : un contrôleur neuf, posé sur le récit qu'on
      // avait quitté (l'ancien a été détaché avec sa page).
      final ancien = _recitsCtrl;
      _recitsCtrl = PageController(initialPage: _recit);
      WidgetsBinding.instance.addPostFrameCallback((_) => ancien.dispose());
    }
    setState(() {
      _enAvant = avant;
      _etape = etape;
    });
    // Le clavier s'ouvre de lui-même sur l'étape du nom, comme dans les
    // assistants d'Apple : c'est la seule chose à faire sur cet écran.
    if (etape == EtapeAccueil.nom) {
      Future<void>.delayed(const Duration(milliseconds: 380), () {
        if (mounted && _etape == EtapeAccueil.nom) _focusNom.requestFocus();
      });
    } else {
      _focusNom.unfocus();
    }
  }

  void _principal() {
    OuroHaptics.light();
    switch (_etape) {
      case EtapeAccueil.recits:
        if (_recit < _nbRecits - 1) {
          _recitsCtrl.nextPage(duration: const Duration(milliseconds: 520), curve: Curves.easeInOutCubic);
        } else {
          _allerA(EtapeAccueil.nom);
        }
      case EtapeAccueil.nom:
        // ⚠️ VALIDÉ ICI AUSSI, pas seulement par le bouton grisé : la
        // touche « Terminé » du clavier appelle cette même méthode.
        if (!_pseudoValid) {
          _toast(AppLocalizations.of(context).obMinChars, DropletToastType.warning);
          return;
        }
        _allerA(EtapeAccueil.photo);
      case EtapeAccueil.photo:
        // Sans photo, le bouton principal en propose une ; avec, il crée
        // le compte.
        if (_avatarNom == null) {
          _choisirPhoto();
        } else {
          _createIdentity();
        }
      case EtapeAccueil.pret:
        context.go('/chats');
    }
  }

  void _retour() {
    if (_identiteCreee || _busy) return;
    OuroHaptics.light();
    switch (_etape) {
      case EtapeAccueil.photo:
        _allerA(EtapeAccueil.nom);
      case EtapeAccueil.nom:
        _allerA(EtapeAccueil.recits);
      case EtapeAccueil.recits:
      case EtapeAccueil.pret:
        break;
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  IDENTITÉ
  // ─────────────────────────────────────────────────────────────

  Future<void> _createIdentity() async {
    final pseudo = _pseudo;
    if (pseudo.isEmpty) {
      _toast(AppLocalizations.of(context).obChoosePseudo, DropletToastType.warning);
      return;
    }
    if (pseudo.length < 3) {
      _toast(AppLocalizations.of(context).obMinChars, DropletToastType.warning);
      return;
    }

    setState(() => _busy = true);

    final id = StorageService.generateCryptoIdentity(pseudo);
    final publicKey = await CryptoService.ensureIdentityKeyPair();
    await StorageService.saveUser(DropletUserModel(
      id: id,
      pseudo: pseudo,
      publicKey: publicKey,
      // ⚠️ Le NOM du fichier, jamais son chemin absolu (voir
      // `AvatarService`) : un chemin enregistré pointe dans le vide après
      // une restauration.
      avatarUrl: _avatarNom,
    ));
    await StorageService.setOnboardingComplete();

    try {
      final repo = ref.read(meshRepositoryProvider);
      await repo.init(id, pseudo);
      ref.read(callProvider.notifier).init(repo.transport, repo: repo, signalingUrl: kSignalingUrl);
      ref.read(groupCallProvider.notifier).init(repo.transport, repo.myId, repo: repo);
    } catch (e) {
      debugPrint('[Onboarding] mesh init error: $e');
    }

    if (!mounted) return;
    OuroHaptics.success();
    setState(() {
      _busy = false;
      _identiteCreee = true;
    });
    _allerA(EtapeAccueil.pret);
  }

  Future<String?> _promptBackupPassword() {
    final l10n = AppLocalizations.of(context);
    return ouroPrompt(
      context,
      title: l10n.obBackupPasswordTitle,
      message: l10n.obBackupPasswordMessage,
      placeholder: l10n.obBackupPasswordPlaceholder,
      confirmLabel: l10n.obRestore,
      obscure: true,
    );
  }

  /// « J'ai déjà un compte » : les deux façons de le retrouver.
  Future<void> _restaurer() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final choix = await ouroChoice<int>(
      context,
      title: l10n.acRestoreTitle,
      message: l10n.acRestoreMessage,
      options: [
        OuroChoiceOption(label: l10n.acRestoreFile, value: 0),
        OuroChoiceOption(label: l10n.acRestoreOnline, value: 1),
      ],
    );
    if (!mounted || choix == null) return;
    if (choix == 0) {
      await _restoreFromBackup();
    } else {
      await _restoreFromServer();
    }
  }

  Future<void> _restoreFromBackup() async {
    final result = await FilePicker.platform.pickFiles();
    final path = result?.files.single.path;
    if (path == null) return;

    if (!mounted) return;
    final password = await _promptBackupPassword();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      final contents = await BackupService.readBackup(file: File(path), password: password);
      await BackupService.restoreBackup(contents);

      try {
        final repo = ref.read(meshRepositoryProvider);
        await repo.init(contents.identity.id, contents.identity.pseudo);
        ref.read(callProvider.notifier).init(repo.transport, repo: repo, signalingUrl: kSignalingUrl);
        ref.read(groupCallProvider.notifier).init(repo.transport, repo.myId, repo: repo);
      } catch (e) {
        debugPrint('[Onboarding] mesh init error (restore): $e');
      }

      if (!mounted) return;
      context.go('/chats');
    } on BackupPasswordException catch (e) {
      if (!mounted) return;
      _toast(e.message, DropletToastType.error);
    } catch (e) {
      if (!mounted) return;
      _toast(AppLocalizations.of(context).obRestoreFailed, DropletToastType.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restoreFromServer() async {
    final l10n = AppLocalizations.of(context);
    // Le pseudo du compte : celui déjà tapé à l'étape du nom, sinon on le
    // demande — « J'ai déjà un compte » est proposé dès le premier écran.
    var pseudo = _pseudo;
    if (pseudo.isEmpty) {
      final saisi = await ouroPrompt(
        context,
        title: l10n.acRestorePseudoTitle,
        message: l10n.acRestorePseudoMessage,
        placeholder: l10n.obPseudoHint,
        confirmLabel: l10n.obContinue,
      );
      pseudo = (saisi ?? '').trim();
      if (pseudo.isEmpty || !mounted) return;
    }
    final password = await _promptBackupPassword();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      final contents = await SauvegardeEnLigne.telecharger(pseudo: pseudo, motDePasse: password);
      if (contents == null) {
        if (mounted) _toast(l10n.obNoServerBackup, DropletToastType.error);
        return;
      }
      await BackupService.restoreBackup(contents);
      // La sauvegarde quotidienne continue sur ce téléphone.
      unawaited(SauvegardeEnLigne.activer(password).then<void>((_) {}, onError: (Object e) {
        debugPrint('[Onboarding] sauvegarde en ligne non réactivée: $e');
      }));

      try {
        final repo = ref.read(meshRepositoryProvider);
        await repo.init(contents.identity.id, contents.identity.pseudo);
        ref.read(callProvider.notifier).init(repo.transport, repo: repo, signalingUrl: kSignalingUrl);
        ref.read(groupCallProvider.notifier).init(repo.transport, repo.myId, repo: repo);
      } catch (e) {
        debugPrint('[Onboarding] mesh init error (restore serveur): $e');
      }

      if (!mounted) return;
      context.go('/chats');
    } on SauvegardeTropDEssais {
      if (!mounted) return;
      _toast(l10n.obTooManyAttempts, DropletToastType.error);
    } on BackupPasswordException catch (e) {
      if (!mounted) return;
      _toast(e.message, DropletToastType.error);
    } catch (e) {
      if (!mounted) return;
      _toast(l10n.obRestoreFailed, DropletToastType.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  PHOTO DE PROFIL
  // ─────────────────────────────────────────────────────────────

  /// ⚠️ RIEN N'EST JAMAIS CHARGÉ EN TAILLE RÉELLE (voir `AvatarService`) :
  /// une photo décodée pèse une cinquantaine de Mo, Droplet vise des
  /// téléphones de 2 Go.
  Future<void> _choisirPhoto() async {
    final octets = await choisirUnePhoto(context);
    if (octets == null || !mounted) return;

    final nom = await AvatarService.enregistrer(octets);
    if (!mounted) return;
    if (nom == null) {
      _toast(AppLocalizations.of(context).obPhotoSaveFailed, DropletToastType.error);
      return;
    }
    OuroHaptics.success();
    setState(() {
      _avatarNom = nom;
      _avatarApercu = octets;
    });
  }

  Future<void> _retirerPhoto() async {
    OuroHaptics.light();
    await AvatarService.supprimer();
    if (!mounted) return;
    setState(() {
      _avatarNom = null;
      _avatarApercu = null;
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  INVITATION
  // ─────────────────────────────────────────────────────────────

  /// Envoie Droplet — le fichier d'installation lui-même quand c'est
  /// possible, un texte sinon. Le fichier part par Bluetooth, Wi-Fi Direct
  /// ou carte mémoire : personne n'a besoin d'Internet, à aucun moment.
  Future<void> _partagerLApp() async {
    OuroHaptics.light();
    final apk = await MediaService.installerPath;
    try {
      if (apk != null && File(apk).existsSync()) {
        await Share.shareXFiles(
          [XFile(apk, mimeType: 'application/vnd.android.package-archive', name: 'Droplet.apk')],
          subject: 'Droplet',
          text: kTexteInvitation,
        );
      } else {
        await Share.share(kTexteInvitation, subject: 'Droplet');
      }
    } catch (e) {
      debugPrint('[Onboarding] partage impossible: $e');
      if (!mounted) return;
      _toast(AppLocalizations.of(context).obShareUnavailable, DropletToastType.error);
    }
  }

  void _toast(String message, DropletToastType type) {
    ref.read(toastProvider.notifier).show(message, type: type);
  }

  // ─────────────────────────────────────────────────────────────
  //  AFFICHAGE
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final etape = switch (_etape) {
      EtapeAccueil.recits => _recits(l10n),
      EtapeAccueil.nom => _EtapeNom(
          controller: _pseudoCtrl,
          focus: _focusNom,
          onSubmit: _principal,
        ),
      EtapeAccueil.photo => _EtapePhoto(
          pseudo: _pseudo,
          apercu: _avatarApercu,
          onChoisir: _busy ? null : _choisirPhoto,
        ),
      EtapeAccueil.pret => _EtapePret(pseudo: _pseudo, apercu: _avatarApercu),
    };

    return PopScope(
      // Le retour du téléphone remonte d'une étape plutôt que de quitter
      // l'app au milieu de l'accueil.
      canPop: _etape == EtapeAccueil.recits || _identiteCreee,
      onPopInvokedWithResult: (aPoppe, _) {
        if (!aPoppe) _retour();
      },
      child: Scaffold(
        backgroundColor: OuroColors.systemBackground,
        body: IosMagnifierOverlay(
          child: SafeArea(
            child: Column(
              children: [
                _barreDuHaut(l10n),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 480),
                    reverseDuration: const Duration(milliseconds: 480),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    layoutBuilder: (actuel, anciens) => Stack(
                      fit: StackFit.expand,
                      children: [...anciens, ?actuel],
                    ),
                    transitionBuilder: (enfant, animation) => _TransitionEtape(
                      animation: animation,
                      entrant: enfant.key == ValueKey(_etape),
                      enAvant: _enAvant,
                      child: enfant,
                    ),
                    child: KeyedSubtree(key: ValueKey(_etape), child: etape),
                  ),
                ),
                _barreDuBas(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// La barre du haut : « Passer » sur les récits, « Retour » ensuite —
  /// au même endroit et dans le même style que les assistants d'iOS.
  Widget _barreDuHaut(AppLocalizations l10n) {
    final retour = (_etape == EtapeAccueil.nom || _etape == EtapeAccueil.photo) && !_identiteCreee;
    final passer = _etape == EtapeAccueil.recits && _recit < _nbRecits - 1;
    return SizedBox(
      height: 44,
      child: ApresOuverture(
        builder: (context) => Row(
          children: [
            AnimatedOpacity(
              opacity: retour ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(
                ignoring: !retour,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: _busy ? null : _retour,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.chevron_back, size: 24, color: OuroColors.accent),
                      Text(l10n.acBack, style: OuroTypography.body.copyWith(color: OuroColors.accent)),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: passer ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(
                ignoring: !passer,
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  onPressed: () {
                    OuroHaptics.light();
                    _allerA(EtapeAccueil.nom);
                  },
                  child: Text(l10n.acSkip, style: OuroTypography.body.copyWith(color: OuroColors.accent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Les récits ─────────────────────────────────────────────────

  Widget _recits(AppLocalizations l10n) {
    final pages = [
      (titre: 'Droplet', texte: l10n.acStory1Text),
      (titre: l10n.acStory2Title, texte: l10n.acStory2Text),
      (titre: l10n.acStory3Title, texte: l10n.acStory3Text),
      (titre: l10n.acStory4Title, texte: l10n.acStory4Text),
    ];
    return PageView.builder(
      controller: _recitsCtrl,
      itemCount: _nbRecits,
      onPageChanged: (i) {
        OuroHaptics.selection();
        setState(() => _recit = i);
      },
      itemBuilder: (context, i) {
        final actif = i == _recit;
        final dessin = switch (i) {
          0 => HeroMarque(actif: actif),
          1 => IllustrationRelais(actif: actif),
          2 => IllustrationChiffrement(actif: actif),
          _ => IllustrationSecurite(actif: actif),
        };
        // ⚠️ LE PREMIER RÉCIT ATTEND LA FIN DE L'OUVERTURE pour faire
        // entrer son texte : la marque y est encore en vol.
        final texte = _TexteRecit(titre: pages[i].titre, texte: pages[i].texte, nomDeMarque: i == 0);
        return AnimatedBuilder(
          animation: _recitsCtrl,
          builder: (context, enfant) {
            // Une légère parallaxe : le dessin glisse moins vite que le
            // texte, et s'efface un peu en sortant — la profondeur des
            // présentations d'Apple, sans effet de manège.
            var decalage = 0.0;
            if (_recitsCtrl.hasClients && _recitsCtrl.position.haveDimensions) {
              decalage = (_recitsCtrl.page ?? _recit.toDouble()) - i;
            }
            final largeur = MediaQuery.sizeOf(context).width;
            return Column(
              children: [
                Expanded(
                  flex: 11,
                  child: Opacity(
                    opacity: (1 - decalage.abs() * 0.8).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(decalage * largeur * 0.35, 0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320, maxHeight: 280),
                          child: AspectRatio(aspectRatio: 320 / 260, child: dessin),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 8, child: enfant!),
              ],
            );
          },
          child: i == 0 ? ApresOuverture(builder: (_) => texte) : texte,
        );
      },
    );
  }

  // ── La barre du bas ────────────────────────────────────────────

  Widget _barreDuBas(AppLocalizations l10n) {
    final (String libelle, bool actif) = switch (_etape) {
      EtapeAccueil.recits => (_recit < _nbRecits - 1 ? l10n.obContinue : l10n.obStart, true),
      EtapeAccueil.nom => (l10n.obContinue, _pseudoValid),
      EtapeAccueil.photo => (_avatarNom == null ? l10n.obChoosePhoto : l10n.obContinue, true),
      EtapeAccueil.pret => (l10n.obStart, true),
    };
    final String? secondaire = switch (_etape) {
      EtapeAccueil.recits => l10n.acHaveAccount,
      EtapeAccueil.nom => l10n.acHaveAccount,
      EtapeAccueil.photo => _avatarNom == null ? l10n.acLater : l10n.obRemovePhoto,
      EtapeAccueil.pret => l10n.obSendToFriend,
    };
    final VoidCallback? actionSecondaire = switch (_etape) {
      EtapeAccueil.recits || EtapeAccueil.nom => _restaurer,
      EtapeAccueil.photo => _avatarNom == null ? _createIdentity : _retirerPhoto,
      EtapeAccueil.pret => _partagerLApp,
    };

    final barre = Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Les points des récits : présents, mais à leur place —
          // AU-DESSUS du bouton, discrets, comme le contrôle de page d'iOS.
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _etape == EtapeAccueil.recits
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: _Points(nombre: _nbRecits, controleur: _recitsCtrl, actuel: _recit),
                  )
                : const SizedBox(width: double.infinity),
          ),
          _BoutonPrincipal(
            libelle: libelle,
            actif: actif && !_busy,
            occupe: _busy,
            onTap: _principal,
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 44,
            child: secondaire == null
                ? null
                : CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: _busy ? null : actionSecondaire,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        secondaire,
                        key: ValueKey(secondaire),
                        style: OuroTypography.body.copyWith(
                          color: _etape == EtapeAccueil.photo && _avatarNom != null ? OuroColors.secondaryLabel : OuroColors.accent,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
    // Pendant l'ouverture, rien ne doit attirer l'œil ailleurs que sur la
    // marque : la barre arrive avec le texte du premier récit.
    return ValueListenableBuilder<bool>(
      valueListenable: OuvertureDroplet.active,
      builder: (context, ouverture, enfant) => AnimatedOpacity(
        opacity: ouverture ? 0 : 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: enfant,
      ),
      child: barre,
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LES ÉTAPES
// ─────────────────────────────────────────────────────────────

/// Le texte d'un récit : un titre court, une phrase, centrés.
class _TexteRecit extends StatelessWidget {
  const _TexteRecit({required this.titre, required this.texte, this.nomDeMarque = false});

  final String titre;
  final String texte;

  /// Le premier récit : le titre est le nom de l'app, en Inter Tight
  /// serré, comme le mot-symbole de l'ouverture.
  final bool nomDeMarque;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _Apparition(
            delai: 0,
            child: Text(
              titre,
              textAlign: TextAlign.center,
              style: nomDeMarque
                  ? TextStyle(
                      fontFamily: 'Inter Tight',
                      fontWeight: FontWeight.w700,
                      fontSize: 40,
                      height: 1.1,
                      letterSpacing: -0.8,
                      color: OuroColors.label,
                    )
                  : OuroTypography.largeTitle.copyWith(color: OuroColors.label, height: 1.12),
            ),
          ),
          const SizedBox(height: 14),
          _Apparition(
            delai: 90,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                texte,
                textAlign: TextAlign.center,
                style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel, height: 1.38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Étape 1 — le nom.
class _EtapeNom extends StatelessWidget {
  const _EtapeNom({required this.controller, required this.focus, required this.onSubmit});

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pseudo = controller.text.trim();
    final court = pseudo.isNotEmpty && pseudo.length < 3;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 12),
      child: Column(
        children: [
          // L'avatar se remplit de l'initiale à mesure qu'on tape : on voit
          // tout de suite comment on apparaîtra chez les autres.
          _Apparition(delai: 0, child: _Avatar(pseudo: pseudo, taille: 92)),
          const SizedBox(height: 26),
          _Apparition(
            delai: 60,
            child: Text(
              l10n.obIdentityTitle,
              textAlign: TextAlign.center,
              style: OuroTypography.largeTitle.copyWith(color: OuroColors.label, height: 1.12),
            ),
          ),
          const SizedBox(height: 12),
          _Apparition(
            delai: 120,
            child: Text(
              l10n.obIdentitySubtitle,
              textAlign: TextAlign.center,
              style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel, height: 1.38),
            ),
          ),
          const SizedBox(height: 28),
          _Apparition(
            delai: 180,
            child: Container(
              decoration: BoxDecoration(
                color: OuroColors.secondarySystemBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller,
                focusNode: focus,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                inputFormatters: [LengthLimitingTextInputFormatter(24)],
                cursorColor: OuroColors.accent,
                magnifierConfiguration: TextMagnifier.adaptiveMagnifierConfiguration,
                style: OuroTypography.title3.copyWith(color: OuroColors.label),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: l10n.obPseudoHint,
                  hintStyle: OuroTypography.title3.copyWith(color: OuroColors.tertiaryLabel),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              // L'indication n'apparaît que quand elle sert : on a commencé
              // à écrire, mais c'est encore trop court.
              child: court
                  ? Text(l10n.obMinChars, key: const ValueKey('court'), style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel))
                  : Row(
                      key: const ValueKey('cles'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.lock_fill, size: 13, color: OuroColors.tertiaryLabel),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.acNameFootnote,
                            textAlign: TextAlign.center,
                            style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Étape 2 — la photo.
class _EtapePhoto extends StatelessWidget {
  const _EtapePhoto({required this.pseudo, required this.apercu, required this.onChoisir});

  final String pseudo;
  final Uint8List? apercu;
  final VoidCallback? onChoisir;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 12),
      child: Column(
        children: [
          _Apparition(
            delai: 0,
            child: OuroPressable(
              onTap: onChoisir,
              semantique: l10n.obChoosePhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _Avatar(pseudo: pseudo, taille: 148, photo: apercu),
                  // Le petit appareil photo : sans lui, le rond ressemble à
                  // un avatar déjà défini plutôt qu'à un bouton.
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OuroColors.accentRempli,
                        border: Border.all(color: OuroColors.systemBackground, width: 4),
                      ),
                      child: Icon(CupertinoIcons.camera_fill, size: 17, color: OuroColors.texteSurAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          _Apparition(
            delai: 60,
            child: Text(
              l10n.acPhotoTitle,
              textAlign: TextAlign.center,
              style: OuroTypography.largeTitle.copyWith(color: OuroColors.label, height: 1.12),
            ),
          ),
          const SizedBox(height: 12),
          _Apparition(
            delai: 120,
            child: Text(
              l10n.acPhotoText,
              textAlign: TextAlign.center,
              style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel, height: 1.38),
            ),
          ),
        ],
      ),
    );
  }
}

/// Étape 3 — vous êtes prêt.
class _EtapePret extends StatelessWidget {
  const _EtapePret({required this.pseudo, required this.apercu});

  final String pseudo;
  final Uint8List? apercu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 12),
      child: Column(
        children: [
          SizedBox(
            width: 300,
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Deux ronds dans l'eau, une seule fois : le compte naît.
                const Positioned.fill(child: OndesArrivee(rayon: 64)),
                _Avatar(pseudo: pseudo, taille: 128, photo: apercu),
                // La coche, qui arrive avec un petit rebond — le seul de tout
                // l'accueil : c'est le seul moment de célébration.
                Positioned(
                  left: 150 + 28,
                  top: 115 + 28,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 520),
                    curve: const Interval(0.25, 1, curve: Curves.easeOutBack),
                    builder: (context, v, enfant) => Transform.scale(scale: v, child: enfant),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OuroColors.systemGreen,
                        border: Border.all(color: OuroColors.systemBackground, width: 4),
                      ),
                      child: const Icon(CupertinoIcons.checkmark_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Apparition(
            delai: 200,
            child: Text(
              l10n.acReadyTitle(pseudo),
              textAlign: TextAlign.center,
              style: OuroTypography.largeTitle.copyWith(color: OuroColors.label, height: 1.12),
            ),
          ),
          const SizedBox(height: 12),
          _Apparition(
            delai: 280,
            child: Text(
              l10n.acReadyText,
              textAlign: TextAlign.center,
              style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel, height: 1.38),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BRIQUES
// ─────────────────────────────────────────────────────────────

/// Le passage d'une étape à l'autre, comme une page qu'on pousse sur
/// iOS : la nouvelle arrive de la droite, l'ancienne recule d'un tiers en
/// s'effaçant. À l'envers pour un retour.
class _TransitionEtape extends StatelessWidget {
  const _TransitionEtape({required this.animation, required this.entrant, required this.enAvant, required this.child});

  final Animation<double> animation;
  final bool entrant;
  final bool enAvant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return FadeTransition(opacity: animation, child: child);
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, enfant) {
        final v = animation.value; // 1 = à sa place
        final largeur = MediaQuery.sizeOf(context).width;
        final double dx;
        final double opacite;
        if (entrant) {
          dx = (enAvant ? 1 : -0.3) * (1 - v) * largeur;
          opacite = enAvant ? 1 : v;
        } else {
          dx = (enAvant ? -0.3 : 1) * (1 - v) * largeur;
          opacite = enAvant ? v : 1;
        }
        return Opacity(
          opacity: opacite.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(dx, 0), child: enfant),
        );
      },
      child: child,
    );
  }
}

/// Une apparition douce : un fondu et 12 points de montée, après un délai.
/// Rejouée à chaque fois que l'élément est construit pour la première fois.
class _Apparition extends StatelessWidget {
  const _Apparition({required this.delai, required this.child});

  final int delai;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    final total = 520 + delai;
    final debut = delai / total;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (context, v, enfant) {
        final p = Curves.easeOutCubic.transform(((v - debut) / (1 - debut)).clamp(0.0, 1.0));
        return Opacity(
          opacity: p,
          child: Transform.translate(offset: Offset(0, 12 * (1 - p)), child: enfant),
        );
      },
      child: child,
    );
  }
}

/// L'avatar : la photo, ou l'initiale sur le bleu de Droplet.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.pseudo, required this.taille, this.photo});

  final String pseudo;
  final double taille;
  final Uint8List? photo;

  @override
  Widget build(BuildContext context) {
    final initiale = pseudo.isEmpty ? '' : pseudo.characters.first.toUpperCase();
    final bleu = DDAccents.parCle('bleu');
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: photo != null
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: initiale.isEmpty
                    ? [OuroColors.tertiarySystemFill, OuroColors.secondarySystemFill]
                    : [bleu.sombre, bleu.clair],
              ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photo != null
          ? Image.memory(
              photo!,
              width: taille,
              height: taille,
              fit: BoxFit.cover,
              cacheWidth: AvatarService.cote,
              cacheHeight: AvatarService.cote,
              gaplessPlayback: true,
            )
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (enfant, a) => ScaleTransition(
                scale: Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
                child: FadeTransition(opacity: a, child: enfant),
              ),
              child: initiale.isEmpty
                  ? Icon(CupertinoIcons.person_fill, key: const ValueKey('vide'), size: taille * 0.5, color: OuroColors.tertiaryLabel)
                  : Text(
                      initiale,
                      key: ValueKey(initiale),
                      style: TextStyle(
                        fontFamily: 'Inter Tight',
                        fontWeight: FontWeight.w700,
                        fontSize: taille * 0.42,
                        height: 1,
                        color: Colors.white,
                      ),
                    ),
            ),
    );
  }
}

/// Le bouton principal : plein, large, toujours au même endroit.
class _BoutonPrincipal extends StatelessWidget {
  const _BoutonPrincipal({required this.libelle, required this.actif, required this.occupe, required this.onTap});

  final String libelle;
  final bool actif;
  final bool occupe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OuroPressable(
      onTap: actif ? onTap : null,
      scale: 0.98,
      opacity: 0.85,
      semantique: libelle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 52,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: actif || occupe ? OuroColors.accentRempli : OuroColors.quaternarySystemFill,
          borderRadius: BorderRadius.circular(14),
        ),
        child: occupe
            ? SizedBox(width: 22, height: 22, child: OuroSpinner(color: OuroColors.texteSurAccent, radius: 11))
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  libelle,
                  key: ValueKey(libelle),
                  style: OuroTypography.headline.copyWith(color: actif ? OuroColors.texteSurAccent : OuroColors.tertiaryLabel),
                ),
              ),
      ),
    );
  }
}

/// Les points des récits, comme le contrôle de page d'iOS : tous de la
/// même taille, celui de la page courante plus sombre — et qui glisse
/// avec le doigt, au lieu de sauter d'un point à l'autre.
class _Points extends StatelessWidget {
  const _Points({required this.nombre, required this.controleur, required this.actuel});

  final int nombre;
  final PageController controleur;
  final int actuel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controleur,
      builder: (context, _) {
        var page = actuel.toDouble();
        if (controleur.hasClients && controleur.position.haveDimensions) page = controleur.page ?? page;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < nombre; i++)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(OuroColors.label, OuroColors.quaternaryLabel, (page - i).abs().clamp(0.0, 1.0)),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// ⚠️ AUCUN LIEN DE TÉLÉCHARGEMENT N'EST ÉCRIT ICI, ET C'EST VOLONTAIRE :
/// Droplet n'est distribué à aucune adresse publique pour l'instant, et un
/// lien mort ferait perdre la personne qu'on invite. Le jour de la
/// publication, il suffit de renseigner [kLienTelechargement].
const String kLienTelechargement = '';

/// Le message qui accompagne le partage.
String get kTexteInvitation {
  const base = 'Je t\'envoie Droplet — une messagerie qui marche même sans '
      'internet : les téléphones se parlent directement. Installe le fichier '
      'joint, et on pourra s\'écrire même sans réseau.';
  return kLienTelechargement.isEmpty ? base : '$base\n\n$kLienTelechargement';
}
