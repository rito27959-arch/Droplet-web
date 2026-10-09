// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'écran RÉGLAGES — refait à l'identique du modèle de Réglages sur iOS,
// puisque c'est exactement le même besoin : une liste d'options rangées
// par thème.
//
// CE QUI A CHANGÉ À LA REFONTE : l'ancienne version empilait de grandes
// cartes espacées, chacune avec sa propre icône dans un cercle coloré et
// sa propre animation d'entrée décalée. C'était lisible, mais ça
// n'utilisait qu'une fraction de l'écran et ne ressemblait à aucune
// convention connue.
//
// La nouvelle version utilise les LISTES GROUPÉES (voir `ouro_list.dart`) :
// des îlots compacts, séparés par de petits titres gris, avec les icônes
// en pastilles carrées colorées. C'est plus dense, immédiatement familier,
// et surtout ça permet d'ajouter des explications sous chaque groupe sans
// alourdir les lignes elles-mêmes.
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/service_intelligence.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/premium_service.dart';
import '../../core/services/mesh_foreground_service.dart';
import '../../core/services/sound_service.dart';
import '../../core/services/ai_knowledge_packs.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/liquid_bridge.dart';
import '../../shared/widgets/avatar_picker_sheet.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../../shared/widgets/premium_badge.dart';
import '../../shared/widgets/moon_sun_avatar.dart';
import 'journal_sheet.dart';
import '../contribution/contribution_screen.dart';
import '../../core/providers/tor_providers.dart';
import '../../core/services/tor_service.dart';
import '../../core/services/tor_transport.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_retour_ios.dart';
import 'contacts_bloques_screen.dart';
import '../../core/services/reglages_notifs.dart';
import '../../core/services/appareils_lies.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = StorageService.currentUser;
    final myId = ref.watch(meshRepositoryProvider).myId;
    final rank = StorageService.getContributionPoints().rank;
    final l10n = AppLocalizations.of(context);

    return OuroLargeTitleScaffold(
      title: l10n.stTitle,
      // Fond « groupé » : c'est le fond que prend iOS dès qu'un écran
      // contient des îlots de liste, plutôt que du contenu plein écran.
      backgroundColor: OuroColors.systemGroupedBackground,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Profil ────────────────────────────────────────────
                // Une grande ligne d'identité en tête, exactement comme
                // la fiche de compte en haut de Réglages iOS.
                _ProfileCard(pseudo: me?.pseudo ?? '—', identifier: myId),

                const SizedBox(height: DesignTokens.space5),

                // ── APPAREILS LIÉS ─────────────────────────────────
                //
                // Droplet Web : lier un navigateur en scannant son code.
                // Juste sous le profil, comme « Appareils connectés » chez
                // WhatsApp — c'est une affaire de compte, pas d'apparence.
                ValueListenableBuilder<int>(
                  valueListenable: AppareilsLies.revision,
                  builder: (context, _, _) => OuroListSection(
                    children: [
                      OuroListRow(
                        icon: Icons.laptop_mac_rounded,
                        iconColor: OuroColors.systemGreen,
                        title: l10n.adTitle,
                        subtitle: l10n.adSettingsSubtitle,
                        value: AppareilsLies.liste().isEmpty ? null : '${AppareilsLies.liste().length}',
                        onTap: () => context.push('/settings/appareils'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: DesignTokens.space5),

                // ── APPARENCE ──────────────────────────────────────
                //
                // Tout ce qui change l'allure de l'app tient sur une page
                // à part, avec son aperçu en direct : thème, couleur
                // d'accent, taille du texte, arrondi des bulles, fonds,
                // liste des discussions, icône. C'est l'organisation de
                // Telegram, et elle évite une page de réglages qui
                // s'allonge sans fin.
                OuroListSection(
                  children: [
                    OuroListRow(
                      icon: Icons.palette_rounded,
                      iconColor: OuroColors.systemIndigo,
                      title: l10n.stAppearanceRow,
                      subtitle: l10n.stAppearanceSubtitle,
                      onTap: () => context.push('/settings/apparence'),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),

                const _LanguageSection(),

                const SizedBox(height: DesignTokens.space5),

                // ── NOTIFICATIONS ──────────────────────────────────
                //
                // Concentration, aperçus, bannières, et ce qui est en
                // sourdine — sur une page à part, comme dans Réglages
                // d'iOS : six réglages liés ne s'empilent pas ici.
                OuroListSection(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: ReglagesNotifs.revision,
                      builder: (context, _, _) {
                        final concentration = ReglagesNotifs.concentrationJusqua != null;
                        return OuroListRow(
                          icon: concentration
                              ? Icons.nightlight_round
                              : Icons.notifications_rounded,
                          iconColor: concentration
                              ? OuroColors.systemIndigo
                              : OuroColors.systemRed,
                          title: l10n.ncTitle,
                          subtitle: concentration
                              ? l10n.rnFocusOn
                              : l10n.stNotificationsSubtitle,
                          onTap: () => context.push('/settings/notifications'),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),

                const _SoundSection(),

                const SizedBox(height: DesignTokens.space5),

                const _AssistantPacksSection(),

                const SizedBox(height: DesignTokens.space5),

                OuroListSection(
                  header: l10n.stIconHeader,
                  footer: l10n.stIconFooter,
                  children: [
                    OuroListRow(
                      icon: Icons.apps_rounded,
                      iconColor: OuroColors.systemPink,
                      title: l10n.stAppIcon,
                      subtitle: l10n.stVariants13,
                      onTap: () => context.push('/settings/icon'),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),

                OuroListSection(
                  header: l10n.stNetworkHeader,
                  footer: l10n.stNetworkFooter,
                  children: [
                    OuroListRow(
                      icon: Icons.wifi_tethering_rounded,
                      iconColor: OuroColors.systemTeal,
                      title: l10n.stMeshNetwork,
                      subtitle: l10n.stPeersTopology,
                      onTap: () => context.push('/mesh-network'),
                    ),
                    const _BackgroundServiceRow(),
                    const _ExigerTorRow(),
                    OuroListRow(
                      icon: Icons.map_rounded,
                      iconColor: OuroColors.systemGreen,
                      title: l10n.stOfflineMaps,
                      subtitle: l10n.stZonesImport,
                      onTap: () => context.push('/maps/offline'),
                    ),
                    OuroListRow(
                      icon: Icons.pie_chart_rounded,
                      iconColor: OuroColors.systemIndigo,
                      title: l10n.stoTitle,
                      subtitle: l10n.stoSubtitle,
                      onTap: () => context.push('/settings/storage'),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),

                OuroListSection(
                  header: l10n.stSecurityHeader,
                  footer: l10n.stSecurityFooter,
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: StorageService.revisionBlocage,
                      builder: (context, _, _) => OuroListRow(
                        icon: Icons.block_rounded,
                        iconColor: OuroColors.errorRed,
                        title: l10n.blkListTitle,
                        value: '${StorageService.getBlockedContacts().length}',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const ContactsBloquesScreen()),
                        ),
                      ),
                    ),
                    OuroListRow(
                      icon: Icons.lock_rounded,
                      iconColor: OuroColors.systemGray,
                      title: l10n.stBackupIdentity,
                      subtitle: l10n.stExportEncrypted,
                      onTap: () => context.push('/backup/export'),
                    ),
                    OuroListRow(
                      icon: Icons.health_and_safety_rounded,
                      iconColor: OuroColors.systemRed,
                      title: l10n.stEmergencyMode,
                      subtitle: l10n.stSignalSafe,
                      onTap: () => context.push('/safety'),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),

                // Traduction et transcription en ligne : désactivées par
                // défaut, et le prix (le contenu quitte l'appareil) est
                // écrit sous l'interrupteur.
                const _SectionIntelligenceEnLigne(),

                const SizedBox(height: DesignTokens.space5),

                OuroListSection(
                  header: l10n.stContributionHeader,
                  children: [
                    OuroListRow(
                      icon: rankIcon(rank),
                      iconColor: rankColor(rank),
                      title: l10n.stMyContribution,
                      value: rankLabel(l10n, rank),
                      onTap: () => context.push('/contribution'),
                    ),
                    // ⚠️ ICI ET PAS EN TÊTE D'ÉCRAN. Une entrée payante
                    // posée tout en haut des réglages est la première
                    // chose que voit quelqu'un qui cherchait à changer
                    // son fond d'écran — et une application qui réclame
                    // de l'argent avant d'avoir servi se désinstalle.
                    // Elle vit donc à côté de la contribution, qui parle
                    // déjà de soutenir le projet.
                    OuroListRow(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.stDropletPro,
                      value: switch (PremiumService.niveau) {
                        NiveauPremium.pro => l10n.stProActive,
                        NiveauPremium.pack => l10n.stProPackUnlocked,
                        NiveauPremium.aucun => l10n.stProIconsThemes,
                      },
                      onTap: () => context.push('/premium'),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),

                const _TorSection(),

                const SizedBox(height: DesignTokens.space5),

                // ── AIDE ET CONFIDENTIALITÉ ────────────────────────
                //
                // La place est celle de WhatsApp, Telegram et Signal :
                // vers le bas, juste avant « À propos ». Personne ne
                // cherche l'aide en haut d'un écran de réglages — on y
                // arrive après avoir fait défiler, c'est-à-dire après
                // avoir cherché ailleurs.
                //
                // ⚠️ ET TOUT MARCHE HORS LIGNE. Chez les trois autres,
                // ces quatre lignes ouvrent un NAVIGATEUR. Droplet est
                // fait pour servir quand il n'y a pas de réseau : une
                // aide qui exige Internet serait muette exactement au
                // moment où quelqu'un se demande pourquoi son message
                // ne part pas. Les réponses et les textes sont donc
                // embarqués.
                OuroListSection(
                  header: l10n.hlpSectionHeader,
                  children: [
                    OuroListRow(
                      icon: Icons.help_outline_rounded,
                      iconColor: OuroColors.systemIndigo,
                      title: l10n.hlpHelpTitle,
                      subtitle: l10n.hlpHelpRowBody,
                      onTap: () => context.push('/aide'),
                    ),
                    OuroListRow(
                      icon: Icons.support_agent_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.hlpContact,
                      onTap: () => context.push('/aide/contact'),
                    ),
                    OuroListRow(
                      icon: Icons.shield_rounded,
                      iconColor: OuroColors.systemGreen,
                      title: l10n.hlpData,
                      // La valeur dit la réponse avant qu'on ouvre : sur
                      // une messagerie, c'est LA question.
                      value: l10n.hlpDataValue,
                      onTap: () => context.push('/aide/donnees'),
                    ),
                    OuroListRow(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: OuroColors.systemGray,
                      title: l10n.hlpPrivacy,
                      onTap: () => context.push('/aide/confidentialite'),
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),

                OuroListSection(
                  children: [
                    // Le journal des erreurs.
                    //
                    // Droplet n'a AUCUN serveur, donc aucun rapport de
                    // plantage ne remonte nulle part. Quand l'app se
                    // ferme toute seule chez quelqu'un, la seule trace
                    // existante est ce fichier local — encore faut-il
                    // pouvoir le lire sans brancher l'appareil à un
                    // ordinateur. C'est le rôle de cette rangée.
                    OuroListRow(
                      icon: Icons.bug_report_rounded,
                      iconColor: OuroColors.systemGray,
                      title: l10n.stCrashLog,
                      onTap: () => _showJournal(context),
                    ),
                    OuroListRow(
                      icon: Icons.info_rounded,
                      iconColor: OuroColors.systemGray,
                      title: l10n.stAbout,
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showJournal(BuildContext context) async {
    await afficherJournal(context);
  }

  Future<void> _showAbout(BuildContext context) {
    OuroHaptics.selection();
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AboutSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PROFIL
// ─────────────────────────────────────────────────────────────

/// Fiche d'identité en haut de l'écran — grand avatar, pseudo, début de
/// l'identifiant public.
///
/// ⚠️ C'EST ICI QU'ON CHANGE SA PHOTO, ET IL FALLAIT QUE ÇA EXISTE.
///
/// La photo se choisit à l'installation. Si c'était le SEUL endroit,
/// se tromper de photo obligerait à réinstaller l'application — donc à
/// perdre son identité et toutes ses conversations, puisque Droplet n'a
/// aucun serveur pour les restituer. Une décision définitive prise en
/// dix secondes le premier jour serait une faute de conception, pas un
/// détail d'ergonomie.
class _ProfileCard extends ConsumerStatefulWidget {
  const _ProfileCard({required this.pseudo, required this.identifier});

  final String pseudo;
  final String identifier;

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  /// Le nom du fichier de la photo — jamais son chemin. Voir
  /// `AvatarService`.
  String? _nom = StorageService.currentUser?.avatarUrl;

  Future<void> _changerLaPhoto() async {
    final octets = await choisirUnePhoto(context);
    if (octets == null || !mounted) return;
    final nom = await AvatarService.enregistrer(octets);
    if (nom == null || !mounted) return;
    await _enregistrer(nom);
  }

  Future<void> _retirerLaPhoto() async {
    OuroHaptics.light();
    await AvatarService.supprimer();
    if (!mounted) return;
    await _enregistrer(null);
  }

  Future<void> _enregistrer(String? nom) async {
    final me = StorageService.currentUser;
    if (me == null) return;
    await StorageService.saveUser(
      DropletUserModel(
        id: me.id,
        pseudo: me.pseudo,
        publicKey: me.publicKey,
        avatarUrl: nom,
      ),
    );
    // ⚠️ PRÉVENIR MES CONTACTS. Le « hello » porte l'empreinte de ma photo :
    // en le renvoyant, chaque contact voit qu'elle a changé (ou disparu) et
    // redemande la nouvelle. Sans ça, ils garderaient l'ancienne jusqu'au
    // prochain « hello » ordinaire.
    AvatarService.oublierMonEmpreinte();
    unawaited(ref.read(meshRepositoryProvider).sendHello().then<void>((_) {}, onError: (Object e) {
      debugPrint('[Réglages] annonce du profil non envoyée: $e');
    }));
    // ⚠️ LE « HELLO » NE FRANCHIT PAS INTERNET. Un contact joint seulement
    // par la boîte aux lettres .onion ne voit donc jamais l'empreinte
    // changer : on lui pousse la photo directement.
    unawaited(ref
        .read(meshRepositoryProvider)
        .diffuserMaPhotoAuxContacts()
        .then<void>((_) {}, onError: (Object e) {
      debugPrint('[Réglages] photo non poussée par Internet: $e');
    }));
    if (!mounted) return;
    if (nom != null) OuroHaptics.success();
    setState(() => _nom = nom);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pseudo = widget.pseudo;
    final identifier = widget.identifier;
    final chemin = AvatarService.chemin(_nom);
    final estPro = PremiumService.niveau.estPro;
    // L'identifiant complet fait 64 caractères : illisible et inutile en
    // entier. On en montre juste assez pour reconnaître le sien.
    final short = identifier.isEmpty
        ? '—'
        : '${identifier.substring(0, identifier.length.clamp(0, 16))}…';

    return Container(
      padding: const EdgeInsets.all(DesignTokens.space4),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: chemin == null
                ? l10n.stAddPhotoSemantics
                : l10n.stChangePhotoSemantics,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: _changerLaPhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  chemin == null
                      ? MoonSunAvatar(pseudo: pseudo, radius: 30)
                      : PeerAvatar(
                          pseudo: pseudo,
                          radius: 30,
                          imagePath: chemin,
                        ),
                  // La pastille d'appareil photo : sans elle, rien
                  // n'indique que l'avatar est touchable, et personne
                  // n'appuie sur un avatar.
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OuroColors.accentRempli,
                        border: Border.all(
                          color: OuroColors.secondarySystemGroupedBackground,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: 11,
                        color: OuroColors.texteSurAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        pseudo,
                        style: OuroTypography.title3.copyWith(
                          color: OuroColors.label,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // ⚠️ `Flexible` sur le nom, et le badge APRÈS : un
                    // pseudo long doit se faire tronquer, jamais pousser
                    // le badge hors de l'écran. L'inverse donnait un
                    // badge invisible précisément chez les gens qui
                    // avaient payé pour l'avoir.
                    if (estPro) ...[const SizedBox(width: 7), const BadgePro()],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  short,
                  style: OuroTypography.footnote.copyWith(
                    color: OuroColors.secondaryLabel,
                  ),
                ),
                // Le retrait n'apparaît que s'il y a quelque chose à
                // retirer : proposer « retirer la photo » à quelqu'un
                // qui n'en a pas est du bruit.
                if (chemin != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: GestureDetector(
                      onTap: _retirerLaPhoto,
                      child: Text(
                        l10n.obRemovePhoto,
                        style: OuroTypography.footnote.copyWith(
                          color: OuroColors.accent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  APPARENCE
// ─────────────────────────────────────────────────────────────

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final choisie = ref.watch(localeProvider);

    return OuroListSection(
      header: l10n.sectionLanguage,
      footer: l10n.languageFooter,
      children: [
        // ── AUTOMATIQUE, EN PREMIER ─────────────────────────────────
        //
        // Une ligne à part plutôt qu'un onzième élément de
        // `kSupportedLocales` : elle ne représente pas une LANGUE mais
        // un COMPORTEMENT (suivre le système), et mérite une icône et
        // une place différentes — exactement comme « Automatique »
        // dans la section Apparence juste au-dessus.
        OuroListRow(
          icon: Icons.translate_rounded,
          iconColor: OuroColors.systemGray,
          title: l10n.languageAuto,
          showChevron: false,
          trailing: choisie == null
              ? Icon(Icons.check_rounded, size: 20, color: OuroColors.accent)
              : const SizedBox(width: 20),
          onTap: () {
            if (choisie == null) return;
            OuroHaptics.selection();
            ref.read(localeProvider.notifier).set(null);
          },
        ),
        for (final locale in kSupportedLocales)
          OuroListRow(
            // Le drapeau serait ambigu (l'espagnol se parle sur trois
            // continents, l'arabe dans vingt pays) — la lettre initiale
            // du nom, dans SON alphabet, identifie la langue sans
            // prétendre à une nationalité.
            icon: null,
            leading: SizedBox(
              width: 29,
              height: 29,
              child: Center(
                child: Text(
                  kLanguageEndonyms[locale.languageCode]!.characters.first,
                  style: OuroTypography.headline.copyWith(
                    color: OuroColors.secondaryLabel,
                  ),
                ),
              ),
            ),
            title: languageLabel(locale),
            showChevron: false,
            trailing: choisie == locale
                ? Icon(Icons.check_rounded, size: 20, color: OuroColors.accent)
                : const SizedBox(width: 20),
            onTap: () {
              if (choisie == locale) return;
              OuroHaptics.selection();
              ref.read(localeProvider.notifier).set(locale);
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SONS
// ─────────────────────────────────────────────────────────────

/// L'unique interrupteur des tonalités de l'app — voir `SoundService`.
class _SoundSection extends StatefulWidget {
  const _SoundSection();

  @override
  State<_SoundSection> createState() => _SoundSectionState();
}

class _SoundSectionState extends State<_SoundSection> {
  late bool _on = SoundService.enabled;

  Future<void> _toggle(bool value) async {
    OuroHaptics.light();
    setState(() => _on = value);
    await SoundService.setEnabled(value);
    // Un aperçu quand on (ré)active : on entend tout de suite ce que ça
    // fait, comme quand on choisit une sonnerie.
    if (value) SoundService.play(AppSound.messageIn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroListSection(
      header: l10n.stSoundHeader,
      footer: l10n.stSoundFooter,
      children: [
        OuroListRow(
          icon: _on
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_rounded,
          iconColor: OuroColors.accent,
          title: l10n.stSoundToggle,
          subtitle: l10n.stSoundSubtitle,
          showChevron: false,
          trailing: LiquidGlassSwitch(value: _on, onChanged: _toggle),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  EXIGER TOR POUR LES SERVICES EN LIGNE
// ─────────────────────────────────────────────────────────────

/// Interdit la liaison directe vers l'annuaire et la boîte aux lettres
/// quand Tor n'est pas disponible.
///
/// ⚠️ CE RÉGLAGE EXISTE PARCE QUE LE DÉFAUT EST UN COMPROMIS. Auparavant,
/// l'annuaire et la mailbox n'étaient créés QUE derrière Tor : une panne de
/// Tor coupait toute la messagerie en ligne (introuvable par pseudo, aucun
/// message relayé). Le repli en liaison directe répare ça, mais il expose
/// l'adresse IP aux serveurs — le contenu, lui, reste chiffré de bout en
/// bout dans les deux cas. Un compromis pareil ne doit pas être imposé en
/// silence : il se règle ici.
class _ExigerTorRow extends StatefulWidget {
  const _ExigerTorRow();

  @override
  State<_ExigerTorRow> createState() => _ExigerTorRowState();
}

class _ExigerTorRowState extends State<_ExigerTorRow> {
  late bool _on = TorTransport.exigerTor;

  Future<void> _toggle(bool value) async {
    OuroHaptics.light();
    setState(() => _on = value);
    await TorTransport.definirExigerTor(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroListRow(
      icon: _on ? Icons.vpn_lock_rounded : Icons.public_rounded,
      iconColor: _on ? OuroColors.systemPurple : OuroColors.systemGray,
      title: l10n.stRequireTor,
      subtitle: l10n.stRequireTorSubtitle,
      showChevron: false,
      trailing: LiquidGlassSwitch(value: _on, onChanged: _toggle),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  PACKS DE CONNAISSANCE DE L'ASSISTANT
// ─────────────────────────────────────────────────────────────

/// Active/désactive les fiches de référence hors ligne que l'assistant
/// glisse dans sa réponse quand la question touche aux premiers secours
/// ou à une situation d'urgence (voir `AiKnowledgePacks`).
class _AssistantPacksSection extends StatefulWidget {
  const _AssistantPacksSection();

  @override
  State<_AssistantPacksSection> createState() => _AssistantPacksSectionState();
}

class _AssistantPacksSectionState extends State<_AssistantPacksSection> {
  late bool _on = AiKnowledgePacks.actif;

  Future<void> _toggle(bool value) async {
    OuroHaptics.light();
    setState(() => _on = value);
    await AiKnowledgePacks.definirActif(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroListSection(
      header: l10n.stPacksHeader,
      footer: l10n.stPacksFooter,
      children: [
        OuroListRow(
          icon: _on ? Icons.menu_book_rounded : Icons.menu_book_outlined,
          iconColor: OuroColors.accent,
          title: l10n.stPacksToggle,
          subtitle: l10n.stPacksSubtitle,
          showChevron: false,
          trailing: LiquidGlassSwitch(value: _on, onChanged: _toggle),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  SERVICE D'ARRIÈRE-PLAN
// ─────────────────────────────────────────────────────────────

/// Ligne à interrupteur qui active le relais mesh en arrière-plan, et
/// propose l'exemption d'optimisation batterie quand c'est nécessaire.
class _BackgroundServiceRow extends ConsumerStatefulWidget {
  const _BackgroundServiceRow();

  @override
  ConsumerState<_BackgroundServiceRow> createState() =>
      _BackgroundServiceRowState();
}

class _BackgroundServiceRowState extends ConsumerState<_BackgroundServiceRow> {
  bool? _running;
  bool _batteryExempt = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final running = await MeshForegroundService.isRunning;
    final exempt = await MeshForegroundService.isIgnoringBatteryOptimizations;
    if (!mounted) return;
    setState(() {
      _running = running;
      _batteryExempt = exempt;
    });
  }

  Future<void> _toggle(bool value) async {
    OuroHaptics.light();
    if (value) {
      final confirmed = await _confirmEnable();
      if (confirmed != true) {
        // L'utilisateur a renoncé : on rafraîchit pour que
        // l'interrupteur revienne à sa position réelle.
        await _refresh();
        return;
      }
      await MeshForegroundService.requestNotificationPermission();
      await MeshForegroundService.start();
    } else {
      await MeshForegroundService.stop();
    }
    await _refresh();
  }

  Future<bool?> _confirmEnable() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EnableBackgroundSheet(
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final running = _running ?? false;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        OuroListRow(
          icon: Icons.autorenew_rounded,
          iconColor: OuroColors.systemIndigo,
          title: l10n.stBackgroundRelay,
          subtitle: _running == null
              ? '…'
              : running
              ? l10n.stActiveClosed
              : l10n.stActiveOpenOnly,
          showChevron: false,
          trailing: LiquidGlassSwitch(
            value: running,
            onChanged: _running == null ? null : _toggle,
          ),
        ),
        // L'avertissement batterie n'apparaît QUE s'il est pertinent —
        // c'est-à-dire service actif mais Android encore autorisé à le
        // brider. Un avertissement affiché en permanence finit par ne
        // plus être lu du tout.
        if (running && !_batteryExempt)
          OuroListRow(
            icon: Icons.battery_alert_rounded,
            iconColor: OuroColors.systemOrange,
            title: l10n.stBatteryOptim,
            subtitle: l10n.stAndroidMayLimit,
            value: l10n.stFix,
            showChevron: false,
            onTap: () async {
              await MeshForegroundService.requestIgnoreBatteryOptimization();
              await _refresh();
            },
          ),
      ],
    );
  }
}

/// Feuille expliquant le compromis avant d'activer le service
/// d'arrière-plan.
class _EnableBackgroundSheet extends StatelessWidget {
  const _EnableBackgroundSheet({
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FrostedSheet(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.stKeepActiveTitle,
              style: OuroTypography.title2.copyWith(color: OuroColors.label),
            ),
            const SizedBox(height: DesignTokens.space2),
            Text(
              l10n.stKeepActiveBody,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: DesignTokens.space5),
            OuroRetourIos(child: FilledButton(onPressed: onConfirm, child: Text(l10n.stEnable))),
            const SizedBox(height: DesignTokens.space2),
            SizedBox(
              width: double.infinity,
              child: OuroRetourIos(child: TextButton(
                onPressed: onCancel,
                child: Text(l10n.stCancel),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  À PROPOS
// ─────────────────────────────────────────────────────────────

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FrostedSheet(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Droplet',
              style: OuroTypography.title1.copyWith(color: OuroColors.label),
            ),
            const SizedBox(height: DesignTokens.space1),
            Text(
              l10n.stAboutTagline,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: DesignTokens.space5),
            _AboutPoint(
              icon: Icons.wifi_tethering_rounded,
              text: l10n.stAboutDirect,
            ),
            _AboutPoint(icon: Icons.lock_rounded, text: l10n.stAboutE2E),
            _AboutPoint(
              icon: Icons.visibility_off_rounded,
              text: l10n.stAboutNoThirdParty,
            ),
            const SizedBox(height: DesignTokens.space3),
            // ⚠️ MENTION OBLIGATOIRE, PAS DÉCORATIVE.
            //
            // Les emojis animés du panneau de stickers viennent de Noto
            // Animated Emoji, publié par Google sous licence CC BY 4.0.
            // Cette licence autorise l'usage commercial et la
            // redistribution, mais EXIGE de créditer l'auteur. Retirer
            // cette ligne ferait de Droplet une application en
            // violation de licence — et c'est le genre de manquement qui
            // fait retirer une application d'un magasin.
            _Attribution(),
          ],
        ),
      ),
    );
  }
}

/// La feuille qui montre le journal des erreurs.
///
/// Volontairement austère : c'est un outil de diagnostic, pas une page à
/// consulter tous les jours. Le journal vide est le cas NORMAL, et c'est

/// Les crédits des ressources tierces embarquées.
class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.stAttributionEmoji,
          style: OuroTypography.caption1.copyWith(
            color: OuroColors.tertiaryLabel,
          ),
        ),
        const SizedBox(height: DesignTokens.space2),
        // ⚠️ MENTION OBLIGATOIRE ELLE AUSSI — voir
        // `ai_assistant_service.dart`. La licence Gemma exige que toute
        // redistribution signale la modification apportée (ici : la
        // quantification en int8). Ce paragraphe EST cette mention —
        // sans lui, republier ce fichier quantifié depuis
        // l'infrastructure de Droplet ne respecterait plus les
        // conditions qui autorisent cette redistribution.
        Text(
          l10n.stAttributionGemma,
          style: OuroTypography.caption1.copyWith(
            color: OuroColors.tertiaryLabel,
          ),
        ),
      ],
    );
  }
}

class _AboutPoint extends StatelessWidget {
  const _AboutPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: DesignTokens.iconMd, color: OuroColors.systemGray),
          const SizedBox(width: DesignTokens.space3),
          Expanded(
            child: Text(
              text,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.label,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TOR
// ─────────────────────────────────────────────────────────────

/// Section Tor dans les réglages — explique le mode privé et propose
/// l'activation rapide avec un toggle, tout en gardant l'accès à l'écran
/// complet pour les réglages avancés.
class _TorSection extends ConsumerStatefulWidget {
  const _TorSection();

  @override
  ConsumerState<_TorSection> createState() => _TorSectionState();
}

class _TorSectionState extends ConsumerState<_TorSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final torState = ref.watch(torStateProvider);
    final isConnected = torState.valueOrNull == TorServiceState.connected;
    final isConnecting = torState.valueOrNull == TorServiceState.connecting;
    final l10n = AppLocalizations.of(context);

    // Animer le pouls quand Tor est actif.
    if (isConnected && !_pulseController.isAnimating) {
      _pulseController.bouclerSiAmbiant(reverse: true);
    } else if (!isConnected && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0.4;
    }

    return OuroListSection(
      header: l10n.stPrivateModeHeader,
      footer: l10n.stTorFooter,
      children: [
        OuroListRow(
          icon: Icons.shield_rounded,
          iconColor: isConnected
              ? Colors.green
              : isConnecting
              ? Colors.amber
              : OuroColors.systemGray,
          title: 'Tor',
          subtitle: isConnected
              ? l10n.stTorActiveAnon
              : isConnecting
              ? l10n.stTorConnecting
              : l10n.stTorDisabled,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isConnected)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(
                          alpha: _pulseAnimation.value,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(
                              alpha: _pulseAnimation.value * 0.4,
                            ),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (isConnected || isConnecting) const SizedBox(width: 8),
              Switch(
                value: isConnected || isConnecting,
                onChanged: (value) async {
                  final service = ref.read(torServiceProvider);
                  if (value) {
                    await service.start();
                  } else {
                    await service.stop();
                  }
                },
              ),
            ],
          ),
          onTap: () => context.push('/tor'),
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────
//  TRADUCTION ET TRANSCRIPTION EN LIGNE
// ─────────────────────────────────────────────────────────────

/// Autorise les services gratuits en ligne quand une connexion existe :
/// MyMemory pour traduire, le service vocal d'Apple ou de Google pour
/// transcrire. Désactivé par défaut — c'est un compromis de
/// confidentialité, il se choisit ici, pas en silence.
class _SectionIntelligenceEnLigne extends StatefulWidget {
  const _SectionIntelligenceEnLigne();

  @override
  State<_SectionIntelligenceEnLigne> createState() =>
      _SectionIntelligenceEnLigneState();
}

class _SectionIntelligenceEnLigneState
    extends State<_SectionIntelligenceEnLigne> {
  late bool _on = ServiceIntelligence.enLigneAutorise;

  Future<void> _toggle(bool value) async {
    OuroHaptics.light();
    setState(() => _on = value);
    await ServiceIntelligence.autoriserEnLigne(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroListSection(
      header: l10n.intelOnlineHeader,
      footer: l10n.intelOnlineFooter,
      children: [
        OuroListRow(
          icon: _on ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
          iconColor: _on ? OuroColors.accent : OuroColors.systemGray,
          title: l10n.intelOnlineTitle,
          subtitle: l10n.intelOnlineSubtitle,
          showChevron: false,
          trailing: LiquidGlassSwitch(value: _on, onChanged: _toggle),
        ),
      ],
    );
  }
}
