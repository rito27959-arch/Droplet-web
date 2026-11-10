// ============================================================================
// LES RÉGLAGES EN GLASMIO (Android 13+) — la passerelle Dart.
// ----------------------------------------------------------------------------
// La route `/settings` passe par ici :
//   • Glasmio disponible (Android 13+) → l'écran natif Compose s'ouvre avec
//     les vrais composants Glasmio (page à grand titre qui se replie, listes
//     groupées, interrupteurs, alertes, verre réel sous la barre du haut) ;
//   • sinon → l'écran Flutter `SettingsScreen`, inchangé.
//
// ⚠️ PARITÉ : CHAQUE LIGNE DE `SettingsScreen` EXISTE ICI, avec la même
// action. Les services appelés sont exactement ceux de `SettingsScreen`
// (aucune logique dupliquée en Kotlin). Ce qui demande une interface Flutter
// propre (changer sa photo, la feuille « À propos », le journal) s'ouvre
// côté Flutter, après fermeture de l'écran natif. Toute ligne ajoutée à
// `SettingsScreen` doit être ajoutée ici aussi.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/mesh_message.dart' show ContributionRank;
import '../../core/providers/locale_provider.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/providers/tor_providers.dart';
import '../../core/services/ai_knowledge_packs.dart';
import '../../core/services/appareils_lies.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/mesh_foreground_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/premium_service.dart';
import '../../core/services/reglages_notifs.dart';
import '../../core/services/service_intelligence.dart';
import '../../core/services/sound_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/tor_service.dart';
import '../../core/services/tor_transport.dart';
import '../../design_system/ouro_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../contribution/contribution_screen.dart';
import 'contacts_bloques_screen.dart';
import 'journal_sheet.dart';
import 'settings_screen.dart';

/// Les lignes qui mènent à une page Flutter : id → route.
const Map<String, String> _routes = {
  'appareils': '/settings/appareils',
  'apparence': '/settings/apparence',
  'notifications': '/settings/notifications',
  'icone': '/settings/icon',
  'maillage': '/mesh-network',
  'cartes': '/maps/offline',
  'stockage': '/settings/storage',
  'sauvegarde': '/backup/export',
  'urgence': '/safety',
  'contribution': '/contribution',
  'pro': '/premium',
  'tor_detail': '/tor',
  'aide': '/aide',
  'contact': '/aide/contact',
  'donnees': '/aide/donnees',
  'confidentialite': '/aide/confidentialite',
};

class PasserelleParametres extends ConsumerStatefulWidget {
  const PasserelleParametres({super.key});

  @override
  ConsumerState<PasserelleParametres> createState() => _PasserelleParametresState();
}

enum _Etat { attente, natif, flutter }

class _PasserelleParametresState extends ConsumerState<PasserelleParametres> {
  _Etat _etat = _Etat.attente;

  /// Ce qu'il faut faire côté Flutter une fois l'écran natif fermé.
  Future<void> Function()? _apres;

  ProviderSubscription<AsyncValue<TorServiceState>>? _ecouteTor;

  /// Les textes de la langue choisie pendant que l'écran natif est ouvert
  /// (Flutter, en arrière-plan, n'a pas encore reconstruit les siens).
  AppLocalizations? _textes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _demarrer());
  }

  @override
  void dispose() {
    _ecouteTor?.close();
    super.dispose();
  }

  Future<void> _demarrer() async {
    if (!await PontGlasmio.disponible()) {
      if (mounted) setState(() => _etat = _Etat.flutter);
      return;
    }
    if (!mounted) return;
    final ok = await PontGlasmio.ouvrir(
      ecran: 'parametres',
      description: await _description(),
      gestionnaire: _gerer,
      surFermeture: _surFermeture,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _etat = _Etat.flutter);
      return;
    }
    setState(() => _etat = _Etat.natif);
    // Tor change d'état tout seul (connexion en cours…) : l'écran suit.
    _ecouteTor = ref.listenManual(torStateProvider, (_, __) async {
      if (mounted) await PontGlasmio.mettreAJour(await _description());
    });
  }

  void _surFermeture() {
    _ecouteTor?.close();
    _ecouteTor = null;
    _textes = null;
    if (!mounted) return;
    final apres = _apres;
    _apres = null;
    if (apres != null) {
      unawaited(apres());
    } else {
      // Retour simple : on quitte les réglages comme avec la flèche.
      final routeur = GoRouter.of(context);
      if (routeur.canPop()) {
        routeur.pop();
      } else {
        routeur.go('/');
      }
    }
  }

  /// Ferme l'écran natif, puis remplace cette passerelle par [route].
  ReponseGlasmio _allerA(String route) {
    final routeur = GoRouter.of(context);
    _apres = () async {
      if (routeur.canPop()) {
        routeur.pop();
      } else if (mounted) {
        // Rien dessous (arrivée directe) : la passerelle reste, et montre
        // les réglages Flutter quand on reviendra.
        setState(() => _etat = _Etat.flutter);
      }
      await routeur.push(route);
    };
    return const ReponseGlasmio.fermer();
  }

  /// Ferme l'écran natif et montre les réglages Flutter (pour la photo du
  /// profil, qui demande l'interface de choix d'image de Droplet).
  ReponseGlasmio _reglagesFlutter() {
    _apres = () async {
      if (mounted) setState(() => _etat = _Etat.flutter);
    };
    return const ReponseGlasmio.fermer();
  }

  /// Ferme l'écran natif, ouvre une feuille Flutter par-dessus cette
  /// passerelle, puis quitte les réglages quand la feuille se ferme.
  ReponseGlasmio _feuille(Future<void> Function(BuildContext) ouvrir) {
    final routeur = GoRouter.of(context);
    _apres = () async {
      if (!mounted) return;
      await ouvrir(context);
      if (!mounted) return;
      if (routeur.canPop()) {
        routeur.pop();
      } else {
        setState(() => _etat = _Etat.flutter);
      }
    };
    return const ReponseGlasmio.fermer();
  }

  // ─────────────────────────────────────────────────────────────
  //  Les gestes
  // ─────────────────────────────────────────────────────────────

  Future<ReponseGlasmio> _gerer(String id, Object? valeur) async {
    final route = _routes[id];
    if (route != null) return _allerA(route);

    switch (id) {
      case 'profil':
        return _reglagesFlutter();
      case 'bloques':
        final routeur = GoRouter.of(context);
        final nav = Navigator.of(context);
        _apres = () async {
          if (routeur.canPop()) {
            routeur.pop();
          } else if (mounted) {
            setState(() => _etat = _Etat.flutter);
          }
          await nav.push(MaterialPageRoute<void>(builder: (_) => const ContactsBloquesScreen()));
        };
        return const ReponseGlasmio.fermer();
      case 'journal':
        return _feuille(afficherJournal);
      case 'a_propos':
        return _feuille(afficherAPropos);
      case 'sons':
        final on = valeur == true;
        await SoundService.setEnabled(on);
        if (on) SoundService.play(AppSound.messageIn);
      case 'packs':
        await AiKnowledgePacks.definirActif(valeur == true);
      case 'exiger_tor':
        await TorTransport.definirExigerTor(valeur == true);
      case 'intel_en_ligne':
        await ServiceIntelligence.autoriserEnLigne(valeur == true);
      case 'tor':
        final service = ref.read(torServiceProvider);
        if (valeur == true) {
          unawaited(service.start());
        } else {
          await service.stop();
        }
      case 'relais':
        if (valeur == true) {
          // Même confirmation que l'écran Flutter, en alerte Glasmio.
          if (!mounted) return ReponseGlasmio.rien;
          final l10n = _textes ?? AppLocalizations.of(context);
          return ReponseGlasmio.alerte({
            'titre': l10n.stKeepActiveTitle,
            'message': l10n.stKeepActiveBody,
            'confirmer': l10n.stEnable,
            'annuler': l10n.stCancel,
            'id': 'relais_confirme',
            // Si on annule, l'interrupteur revient à sa vraie position.
            'description': await _description(),
          });
        }
        await MeshForegroundService.stop();
      case 'relais_confirme':
        await MeshForegroundService.requestNotificationPermission();
        await MeshForegroundService.start();
      case 'batterie':
        await MeshForegroundService.requestIgnoreBatteryOptimization();
      default:
        if (id.startsWith('langue:')) {
          final code = id.substring(7);
          final locale = code == 'auto'
              ? null
              : kSupportedLocales.where((l) => l.languageCode == code).firstOrNull;
          await ref.read(localeProvider.notifier).set(locale);
          // ⚠️ Flutter ne dessine pas pendant que l'écran natif le couvre :
          // ses textes ne seront reconstruits qu'au retour. On charge donc
          // directement les traductions de la nouvelle langue pour redécrire
          // l'écran natif tout de suite.
          final l10n = await AppLocalizations.delegate.load(resolveLocale(locale));
          _textes = l10n;
          if (!mounted) return ReponseGlasmio.rien;
          return ReponseGlasmio.maj(await _description());
        }
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await _description());
  }

  // ─────────────────────────────────────────────────────────────
  //  La description de l'écran
  // ─────────────────────────────────────────────────────────────

  static int _c(Color c) => c.toARGB32();

  Map<String, Object?> _ligne(
    String id,
    String type, {
    required String icone,
    required Color teinte,
    required String titre,
    String? sous,
    String? valeur,
    bool coche = false,
    bool actif = true,
    bool cliquable = false,
  }) =>
      {
        'id': id,
        'type': type,
        'icone': icone,
        'teinte': _c(teinte),
        'titre': titre,
        'sous': ?sous,
        'valeur': ?valeur,
        'coche': coche,
        'actif': actif,
        'cliquable': cliquable,
      };

  Map<String, Object?> _section(List<Map<String, Object?>> lignes, {String? entete, String? pied}) => {
        'entete': ?entete,
        'pied': ?pied,
        'lignes': lignes,
      };

  Future<Map<String, Object?>> _description({AppLocalizations? l10n}) async {
    final textes = l10n ?? _textes ?? AppLocalizations.of(context);
    final me = StorageService.currentUser;
    final pseudo = me?.pseudo ?? '—';
    final myId = ref.read(meshRepositoryProvider).myId;
    final rank = StorageService.getContributionPoints().rank;
    final choisie = ref.read(localeProvider);
    final tor = ref.read(torStateProvider).valueOrNull;
    final torOn = tor == TorServiceState.connected;
    final torEnCours = tor == TorServiceState.connecting;
    final relais = await MeshForegroundService.isRunning;
    final exempt = await MeshForegroundService.isIgnoringBatteryOptimizations;
    final concentration = ReglagesNotifs.concentrationJusqua != null;
    final appareils = AppareilsLies.liste().length;
    final sons = SoundService.enabled;
    final packs = AiKnowledgePacks.actif;
    final exigerTor = TorTransport.exigerTor;
    final intel = ServiceIntelligence.enLigneAutorise;
    final court = myId.isEmpty ? '—' : '${myId.substring(0, myId.length.clamp(0, 16))}…';
    if (!mounted) return const {};

    return {
      'titre': textes.stTitle,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      // Suit le réglage clair/sombre de Droplet : noir pur de Glasmio en
      // sombre, fond groupé clair d'iOS en clair. Aucune lueur.
      'sombre': OuroColors.isDark,
      'accent': _c(OuroColors.accent),
      'profil': {
        'id': 'profil',
        'nom': pseudo,
        'sous': court,
        'photo': AvatarService.chemin(me?.avatarUrl),
        'initiale': pseudo.characters.isEmpty ? '?' : pseudo.characters.first.toUpperCase(),
        'couleur': NotificationService.couleurAvatar(pseudo),
        'pro': PremiumService.niveau.estPro,
        'aide': me?.avatarUrl == null ? textes.stAddPhotoSemantics : textes.stChangePhotoSemantics,
      },
      'sections': [
        _section([
          _ligne('appareils', 'nav',
              icone: 'laptop', teinte: OuroColors.systemGreen,
              titre: textes.adTitle, sous: textes.adSettingsSubtitle,
              valeur: appareils == 0 ? null : '$appareils'),
        ]),
        _section([
          _ligne('apparence', 'nav',
              icone: 'palette', teinte: OuroColors.systemIndigo,
              titre: textes.stAppearanceRow, sous: textes.stAppearanceSubtitle),
        ]),
        _section(
          entete: textes.sectionLanguage,
          pied: textes.languageFooter,
          [
            _ligne('langue:auto', 'choix',
                icone: 'translate', teinte: OuroColors.systemGray,
                titre: textes.languageAuto, coche: choisie == null),
            for (final locale in kSupportedLocales)
              _ligne('langue:${locale.languageCode}', 'choix',
                  icone: 'lettre:${kLanguageEndonyms[locale.languageCode]!.characters.first}',
                  teinte: OuroColors.secondaryLabel,
                  titre: languageLabel(locale), coche: choisie == locale),
          ],
        ),
        _section([
          _ligne('notifications', 'nav',
              icone: concentration ? 'nightlight' : 'notifications',
              teinte: concentration ? OuroColors.systemIndigo : OuroColors.systemRed,
              titre: textes.ncTitle,
              sous: concentration ? textes.rnFocusOn : textes.stNotificationsSubtitle),
        ]),
        _section(
          entete: textes.stSoundHeader,
          pied: textes.stSoundFooter,
          [
            _ligne('sons', 'interrupteur',
                icone: sons ? 'notifications_active' : 'notifications_off',
                teinte: OuroColors.accent,
                titre: textes.stSoundToggle, sous: textes.stSoundSubtitle, coche: sons),
          ],
        ),
        _section(
          entete: textes.stPacksHeader,
          pied: textes.stPacksFooter,
          [
            _ligne('packs', 'interrupteur',
                icone: 'menu_book', teinte: OuroColors.accent,
                titre: textes.stPacksToggle, sous: textes.stPacksSubtitle, coche: packs),
          ],
        ),
        _section(
          entete: textes.stIconHeader,
          pied: textes.stIconFooter,
          [
            _ligne('icone', 'nav',
                icone: 'apps', teinte: OuroColors.systemPink,
                titre: textes.stAppIcon, sous: textes.stVariants13),
          ],
        ),
        _section(
          entete: textes.stNetworkHeader,
          pied: textes.stNetworkFooter,
          [
            _ligne('maillage', 'nav',
                icone: 'wifi_tethering', teinte: OuroColors.systemTeal,
                titre: textes.stMeshNetwork, sous: textes.stPeersTopology),
            _ligne('relais', 'interrupteur',
                icone: 'autorenew', teinte: OuroColors.systemIndigo,
                titre: textes.stBackgroundRelay,
                sous: relais ? textes.stActiveClosed : textes.stActiveOpenOnly,
                coche: relais),
            // Comme l'écran Flutter : seulement si utile.
            if (relais && !exempt)
              _ligne('batterie', 'action',
                  icone: 'battery_alert', teinte: OuroColors.systemOrange,
                  titre: textes.stBatteryOptim, sous: textes.stAndroidMayLimit,
                  valeur: textes.stFix),
            _ligne('exiger_tor', 'interrupteur',
                icone: exigerTor ? 'vpn_lock' : 'public',
                teinte: exigerTor ? OuroColors.systemPurple : OuroColors.systemGray,
                titre: textes.stRequireTor, sous: textes.stRequireTorSubtitle, coche: exigerTor),
            _ligne('cartes', 'nav',
                icone: 'map', teinte: OuroColors.systemGreen,
                titre: textes.stOfflineMaps, sous: textes.stZonesImport),
            _ligne('stockage', 'nav',
                icone: 'pie_chart', teinte: OuroColors.systemIndigo,
                titre: textes.stoTitle, sous: textes.stoSubtitle),
          ],
        ),
        _section(
          entete: textes.stSecurityHeader,
          pied: textes.stSecurityFooter,
          [
            _ligne('bloques', 'nav',
                icone: 'block', teinte: OuroColors.errorRed,
                titre: textes.blkListTitle,
                valeur: '${StorageService.getBlockedContacts().length}'),
            _ligne('sauvegarde', 'nav',
                icone: 'lock', teinte: OuroColors.systemGray,
                titre: textes.stBackupIdentity, sous: textes.stExportEncrypted),
            _ligne('urgence', 'nav',
                icone: 'health_and_safety', teinte: OuroColors.systemRed,
                titre: textes.stEmergencyMode, sous: textes.stSignalSafe),
          ],
        ),
        _section(
          entete: textes.intelOnlineHeader,
          pied: textes.intelOnlineFooter,
          [
            _ligne('intel_en_ligne', 'interrupteur',
                icone: intel ? 'cloud_done' : 'cloud_off',
                teinte: intel ? OuroColors.accent : OuroColors.systemGray,
                titre: textes.intelOnlineTitle, sous: textes.intelOnlineSubtitle, coche: intel),
          ],
        ),
        _section(
          entete: textes.stContributionHeader,
          [
            _ligne('contribution', 'nav',
                icone: rank == ContributionRank.diamant ? 'diamond' : 'workspace_premium',
                teinte: rankColor(rank),
                titre: textes.stMyContribution, valeur: rankLabel(textes, rank)),
            _ligne('pro', 'nav',
                icone: 'auto_awesome', teinte: OuroColors.accent,
                titre: textes.stDropletPro,
                valeur: switch (PremiumService.niveau) {
                  NiveauPremium.pro => textes.stProActive,
                  NiveauPremium.pack => textes.stProPackUnlocked,
                  NiveauPremium.aucun => textes.stProIconsThemes,
                }),
          ],
        ),
        _section(
          entete: textes.stPrivateModeHeader,
          pied: textes.stTorFooter,
          [
            // La ligne s'ouvre sur la page Tor, l'interrupteur démarre ou
            // arrête Tor — comme dans l'écran Flutter.
            _ligne('tor', 'interrupteur',
                icone: 'shield',
                teinte: torOn
                    ? const Color(0xFF34C759)
                    : torEnCours
                        ? const Color(0xFFFFC107)
                        : OuroColors.systemGray,
                titre: 'Tor',
                sous: torOn
                    ? textes.stTorActiveAnon
                    : torEnCours
                        ? textes.stTorConnecting
                        : textes.stTorDisabled,
                coche: torOn || torEnCours,
                cliquable: true),
          ],
        ),
        _section(
          entete: textes.hlpSectionHeader,
          [
            _ligne('aide', 'nav',
                icone: 'help', teinte: OuroColors.systemIndigo,
                titre: textes.hlpHelpTitle, sous: textes.hlpHelpRowBody),
            _ligne('contact', 'nav',
                icone: 'support_agent', teinte: OuroColors.accent, titre: textes.hlpContact),
            _ligne('donnees', 'nav',
                icone: 'shield', teinte: OuroColors.systemGreen,
                titre: textes.hlpData, valeur: textes.hlpDataValue),
            _ligne('confidentialite', 'nav',
                icone: 'privacy_tip', teinte: OuroColors.systemGray, titre: textes.hlpPrivacy),
          ],
        ),
        _section([
          _ligne('journal', 'nav',
              icone: 'bug_report', teinte: OuroColors.systemGray, titre: textes.stCrashLog),
          _ligne('a_propos', 'nav',
              icone: 'info', teinte: OuroColors.systemGray, titre: textes.stAbout),
        ]),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return switch (_etat) {
      _Etat.flutter => const SettingsScreen(),
      // Pendant que l'écran natif est ouvert (ou s'ouvre), un simple fond :
      // c'est lui qu'on aperçoit une fraction de seconde à la fermeture.
      _ => ColoredBox(color: OuroColors.systemGroupedBackground, child: const SizedBox.expand()),
    };
  }
}
