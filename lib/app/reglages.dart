// LES RÉGLAGES — l'onglet Réglages de l'app, version navigateur.
//
//   • Profil : photo (choisie sur l'ordinateur), pseudo, « à propos ».
//   • Appareils liés : ce navigateur, le téléphone principal, se
//     déconnecter.
//   • Confidentialité : confirmations de lecture, contacts bloqués.
//   • Discussions : thème, couleur d'accent, taille du texte (avec aperçu),
//     fond d'écran, Entrée pour envoyer.
//   • Notifications : celles du navigateur (avec la demande d'autorisation)
//     et les sons.
//   • Langue, raccourcis clavier, aide.
//
// Tout est enregistré tout de suite, sans bouton « Enregistrer » : comme
// sur iPhone.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../design_system/reglages_apparence.dart';
import '../donnees/modeles.dart';
import '../fond/goutte.dart';
import '../textes.dart';
import '../web/navigateur.dart';
import 'composants.dart';
import 'coquille.dart';
import 'ilots.dart';
import 'portee.dart';

const String kEmailContact = 'contact@dropletmesh.app';
const String kSite = 'https://dropletmesh.app';
const String kVersion = '1.0.0';

class ColonneReglages extends StatelessWidget {
  const ColonneReglages({super.key, required this.onDeconnexion});

  final VoidCallback onDeconnexion;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntetePanneau(titre: l.settingsTitle),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 30),
            children: [
              // La carte du profil, comme en tête des Réglages d'iOS.
              Survol(
                onTap: () => pousserPanneau(context, const PanneauProfil()),
                builder: (context, survol) => AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: survol ? OuroColors.tertiarySystemGroupedBackground : OuroColors.systemGroupedBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      AvatarDroplet(nom: depot.nom(kMoi), couleur: depot.profil.couleur, photo: depot.profil.photo, taille: 62),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(depot.nom(kMoi), style: OuroTypography.title3.copyWith(color: OuroColors.label)),
                            const SizedBox(height: 2),
                            Text(
                              depot.profil.aPropos.isEmpty ? t.profil : depot.profil.aPropos,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: OuroColors.tertiaryLabel),
                    ],
                  ),
                ),
              ),
              Ilot(
                fond: OuroColors.systemGroupedBackground,
                enfants: [
                  LigneIlot(
                    icone: Icons.devices_rounded,
                    couleurIcone: OuroColors.systemGreen,
                    titre: t.appareilsLies,
                    onTap: () => pousserPanneau(context, PanneauAppareils(onDeconnexion: onDeconnexion)),
                  ),
                  LigneIlot(
                    icone: Icons.lock_rounded,
                    couleurIcone: const Color(0xFF0A84FF),
                    titre: t.confidentialite,
                    onTap: () => pousserPanneau(context, const _PanneauConfidentialite()),
                  ),
                  LigneIlot(
                    icone: Icons.chat_bubble_rounded,
                    couleurIcone: OuroColors.accent,
                    titre: l.tabChats,
                    sousTitre: t.discussionsSous,
                    onTap: () => pousserPanneau(context, const _PanneauDiscussions()),
                  ),
                  LigneIlot(
                    icone: Icons.notifications_rounded,
                    couleurIcone: OuroColors.systemRed,
                    titre: l.stNotificationsHeader,
                    onTap: () => pousserPanneau(context, const _PanneauNotifications()),
                  ),
                ],
              ),
              Ilot(
                fond: OuroColors.systemGroupedBackground,
                enfants: [
                  LigneIlot(
                    icone: Icons.language_rounded,
                    couleurIcone: OuroColors.systemIndigo,
                    titre: l.sectionLanguage,
                    valeur: Textes.nomLangue(context.t.code),
                    onTap: () => pousserPanneau(context, const _PanneauLangue()),
                  ),
                  LigneIlot(
                    icone: Icons.keyboard_rounded,
                    couleurIcone: OuroColors.systemGray,
                    titre: t.raccourcis,
                    onTap: () => pousserPanneau(context, const _PanneauRaccourcis()),
                  ),
                  LigneIlot(
                    icone: Icons.help_rounded,
                    couleurIcone: OuroColors.systemTeal,
                    titre: t.aideTitre,
                    onTap: () => pousserPanneau(context, const _PanneauAide()),
                  ),
                ],
              ),
              Ilot(
                fond: OuroColors.systemGroupedBackground,
                enfants: [
                  LigneIlot(
                    icone: Icons.logout_rounded,
                    couleurIcone: OuroColors.systemRed,
                    titre: t.deconnexion,
                    couleurTitre: OuroColors.systemRed,
                    onTap: () => confirmerDeconnexion(context, onDeconnexion),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(child: Goutte(taille: 26, couleur: OuroColors.quaternaryLabel)),
              const SizedBox(height: 6),
              Text(
                'Droplet Web $kVersion',
                textAlign: TextAlign.center,
                style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> confirmerDeconnexion(BuildContext context, VoidCallback onDeconnexion) async {
  final t = context.t;
  final l = context.l;
  final depot = context.lire.depot;
  final i = await alerte(
    context,
    titre: t.deconnexionTitre,
    message: t.deconnexionTexte,
    actions: [ActionAlerte(l.actionCancel), ActionAlerte(t.deconnexion, destructif: true)],
  );
  if (i != 1) return;
  depot.toutEffacer();
  onDeconnexion();
}

/// Le fond d'un panneau de réglages : gris groupé, en-tête avec retour.
class _Page extends StatelessWidget {
  const _Page({required this.titre, required this.enfants});

  final String titre;
  final List<Widget> enfants;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntetePanneau(titre: titre, retour: () => Navigator.of(context).pop()),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(14, 4, 14, 30), children: enfants)),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Text(texte, style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
      );
}

// ── Profil ─────────────────────────────────────────────────────────────

class PanneauProfil extends StatefulWidget {
  const PanneauProfil({super.key});

  @override
  State<PanneauProfil> createState() => _PanneauProfilState();
}

class _PanneauProfilState extends State<PanneauProfil> {
  late final TextEditingController _pseudo = TextEditingController(text: context.lire.depot.profil.pseudo);
  late final TextEditingController _aPropos = TextEditingController(text: context.lire.depot.profil.aPropos);

  @override
  void dispose() {
    _pseudo.dispose();
    _aPropos.dispose();
    super.dispose();
  }

  Future<void> _photo() async {
    final p = await Navigateur.choisirFichiers(accepter: 'image/*', plusieurs: false);
    if (p.isEmpty || !mounted) return;
    context.lire.depot.majProfil(photo: p.first.url);
  }

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    return _Page(
      titre: t.profil,
      enfants: [
        const SizedBox(height: 10),
        Center(
          child: Survol(
            onTap: _photo,
            builder: (context, survol) => Stack(
              children: [
                AvatarDroplet(nom: depot.nom(kMoi), couleur: depot.profil.couleur, photo: depot.profil.photo, taille: 132),
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: survol ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      decoration: const BoxDecoration(color: Color(0x88000000), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 26),
                          const SizedBox(height: 4),
                          Text(
                            depot.profil.photo == null ? l.stAddPhotoSemantics : l.stChangePhotoSemantics,
                            textAlign: TextAlign.center,
                            style: OuroTypography.caption1.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (depot.profil.photo != null)
          Center(
            child: TextButton(
              onPressed: () => depot.majProfil(retirerPhoto: true),
              child: Text(l.obRemovePhoto, style: OuroTypography.subheadline.copyWith(color: OuroColors.systemRed)),
            ),
          )
        else
          const SizedBox(height: 18),
        // La couleur de l'avatar sans photo.
        if (depot.profil.photo == null) ...[
          Center(
            child: Wrap(
              spacing: 10,
              children: [
                for (var i = 0; i < 8; i++)
                  Survol(
                    onTap: () => depot.majProfil(couleur: i),
                    builder: (context, survol) => AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          for (final c in _palette(i)) c,
                        ]),
                        border: Border.all(color: depot.profil.couleur == i ? OuroColors.label : Colors.transparent, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        TitreIlot(t.pseudo),
        ChampTexte(
          controleur: _pseudo,
          indication: l.obPseudoHint,
          longueurMax: 30,
          onChanged: (v) => depot.majProfil(pseudo: v.trim()),
        ),
        const SizedBox(height: 6),
        _Note(t.pseudoNote),
        TitreIlot(t.aPropos),
        ChampTexte(
          controleur: _aPropos,
          indication: t.aProposIndication,
          longueurMax: 140,
          lignesMax: 3,
          onChanged: (v) => depot.majProfil(aPropos: v.trim()),
        ),
        const SizedBox(height: 6),
        _Note(t.profilSynchro),
      ],
    );
  }

  List<Color> _palette(int i) => const [
        [Color(0xFFFF9F0A), Color(0xFFFF375F)],
        [Color(0xFF64D2FF), Color(0xFF0A84FF)],
        [Color(0xFFDA8FFF), Color(0xFF8E4DFF)],
        [Color(0xFF63E6BE), Color(0xFF30B0C7)],
        [Color(0xFFFFD60A), Color(0xFFFF9F0A)],
        [Color(0xFF5E5CE6), Color(0xFFBF5AF2)],
        [Color(0xFF30D158), Color(0xFF00C7BE)],
        [Color(0xFFFF6482), Color(0xFFFF2D55)],
      ][i];
}

// ── Appareils liés ─────────────────────────────────────────────────────

class PanneauAppareils extends StatelessWidget {
  const PanneauAppareils({super.key, required this.onDeconnexion});

  final VoidCallback onDeconnexion;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final depot = context.depot;
    return _Page(
      titre: t.appareilsLies,
      enfants: [
        const SizedBox(height: 6),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(color: OuroColors.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.devices_rounded, size: 40, color: OuroColors.accent),
          ),
        ),
        const SizedBox(height: 14),
        _Note(t.appareilsTexte),
        TitreIlot(t.cetAppareil),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              icone: Icons.laptop_mac_rounded,
              couleurIcone: OuroColors.accent,
              titre: Navigateur.nomAppareil,
              sousTitre: depot.demo ? t.modeDemo : t.actifMaintenant,
            ),
          ],
        ),
        TitreIlot(t.telephonePrincipal),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              icone: Icons.smartphone_rounded,
              couleurIcone: OuroColors.systemGreen,
              titre: 'Droplet',
              sousTitre: depot.demo ? t.aucunTelephone : t.telephoneTexte,
            ),
          ],
        ),
        _Note(t.appareilsNote),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              icone: Icons.logout_rounded,
              couleurIcone: OuroColors.systemRed,
              titre: t.deconnexion,
              couleurTitre: OuroColors.systemRed,
              onTap: () => confirmerDeconnexion(context, onDeconnexion),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Confidentialité ────────────────────────────────────────────────────

class _PanneauConfidentialite extends StatelessWidget {
  const _PanneauConfidentialite();

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final bloques = depot.contacts.values.where((c) => c.bloque).toList();
    return _Page(
      titre: t.confidentialite,
      enfants: [
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              titre: t.confirmationsLecture,
              fin: Interrupteur(
                valeur: depot.reglages.confirmationsLecture,
                onChanged: (v) => depot.majReglages((r) => r.confirmationsLecture = v),
              ),
            ),
          ],
        ),
        _Note(t.confirmationsNote),
        TitreIlot(l.blkListTitle),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            if (bloques.isEmpty) LigneIlot(titre: l.blkNone, couleurTitre: OuroColors.secondaryLabel),
            for (final c in bloques)
              LigneIlot(
                titre: c.pseudo,
                debut: AvatarDroplet(nom: c.pseudo, couleur: c.couleur, taille: 34),
                fin: TextButton(
                  onPressed: () => depot.bloquer(c),
                  child: Text(l.blkUnblock, style: OuroTypography.subheadline.copyWith(color: OuroColors.accent)),
                ),
              ),
          ],
        ),
        _Note(l.blkFooter),
        TitreIlot(l.hlpDataTitle),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(icone: Icons.phone_disabled_rounded, couleurIcone: OuroColors.systemGray, titre: l.hlpNonePhone),
            LigneIlot(icone: Icons.alternate_email_rounded, couleurIcone: OuroColors.systemGray, titre: l.hlpNoneEmail),
            LigneIlot(icone: Icons.ads_click_rounded, couleurIcone: OuroColors.systemGray, titre: l.hlpNoneAds),
            LigneIlot(icone: Icons.insights_rounded, couleurIcone: OuroColors.systemGray, titre: l.hlpNoneAnalytics),
          ],
        ),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              icone: Icons.policy_rounded,
              couleurIcone: const Color(0xFF0A84FF),
              titre: l.hlpPrivacy,
              onTap: () => Navigateur.ouvrir('$kSite/privacy/'),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Discussions (apparence) ────────────────────────────────────────────

class _PanneauDiscussions extends StatelessWidget {
  const _PanneauDiscussions();

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final r = depot.reglages;
    return _Page(
      titre: l.tabChats,
      enfants: [
        TitreIlot(l.sectionAppearance),
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            children: [
              for (final (theme, libelle, icone) in [
                (ThemeChoisi.systeme, l.appearanceAuto, Icons.brightness_auto_rounded),
                (ThemeChoisi.clair, l.appearanceLight, Icons.light_mode_rounded),
                (ThemeChoisi.sombre, l.appearanceDark, Icons.dark_mode_rounded),
              ])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Survol(
                      onTap: () => depot.majReglages((x) => x.theme = theme),
                      builder: (context, survol) => AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: OuroColors.systemGroupedBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: r.theme == theme ? OuroColors.accent : (survol ? OuroColors.separator : Colors.transparent), width: 2),
                        ),
                        child: Column(
                          children: [
                            Icon(icone, color: r.theme == theme ? OuroColors.accent : OuroColors.secondaryLabel),
                            const SizedBox(height: 6),
                            Text(libelle, style: OuroTypography.footnote.copyWith(color: OuroColors.label)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        TitreIlot(l.stAccentHeader),
        Container(
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: OuroColors.systemGroupedBackground, borderRadius: BorderRadius.circular(14)),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final a in ReglagesApparence.accents)
                Tooltip(
                  message: a.cle,
                  child: Survol(
                    onTap: () => depot.majReglages((x) => x.accent = a.cle),
                    builder: (context, survol) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: a.pour(sombre: OuroColors.isDark),
                        shape: BoxShape.circle,
                        border: Border.all(color: OuroColors.systemGroupedBackground, width: 3),
                        boxShadow: [
                          if (r.accent == a.cle) BoxShadow(color: a.pour(sombre: OuroColors.isDark), spreadRadius: 2.5),
                        ],
                      ),
                      child: r.accent == a.cle ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _Note(l.stAccentFooter),
        TitreIlot(l.stTextSize),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(color: OuroColors.systemGroupedBackground, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              // L'aperçu : deux bulles, à la taille choisie.
              Align(
                alignment: Alignment.centerLeft,
                child: _BulleApercu(texte: l.stPreviewIncoming, moi: false),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: _BulleApercu(texte: l.stPreviewOutgoing, moi: true),
              ),
              Row(
                children: [
                  Text('A', style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
                  Expanded(
                    child: CupertinoSlider(
                      value: r.tailleTexte,
                      min: ReglagesApparence.tailleTexteMin,
                      max: 22,
                      divisions: 10,
                      activeColor: OuroColors.accent,
                      onChanged: (v) => depot.majReglages((x) => x.tailleTexte = v),
                    ),
                  ),
                  Text('A', style: OuroTypography.title3.copyWith(color: OuroColors.secondaryLabel)),
                ],
              ),
            ],
          ),
        ),
        TitreIlot(l.stChatBgHeader),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(color: OuroColors.systemGroupedBackground, borderRadius: BorderRadius.circular(14)),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.7,
            children: [
              for (var i = 0; i < fondsDiscussion.length; i++)
                Survol(
                  onTap: () => depot.majReglages((x) => x.fond = i),
                  builder: (context, survol) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: r.fond == i ? OuroColors.accent : OuroColors.separator, width: r.fond == i ? 2.5 : 0.5),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Positioned.fill(child: Fond(index: i)),
                        Positioned(
                          left: 6,
                          top: 10,
                          child: Container(width: 30, height: 10, decoration: BoxDecoration(color: OuroColors.bubbleIncoming, borderRadius: BorderRadius.circular(5))),
                        ),
                        Positioned(
                          right: 6,
                          top: 26,
                          child: Container(width: 26, height: 10, decoration: BoxDecoration(color: OuroColors.accent, borderRadius: BorderRadius.circular(5))),
                        ),
                        if (r.fond == i)
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: Icon(Icons.check_circle_rounded, color: OuroColors.accent, size: 18),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              titre: t.entreeEnvoie,
              fin: Interrupteur(valeur: r.entreeEnvoie, onChanged: (v) => depot.majReglages((x) => x.entreeEnvoie = v)),
            ),
          ],
        ),
        _Note(t.entreeEnvoieNote),
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              titre: l.stResetAppearance,
              couleurTitre: OuroColors.accent,
              onTap: () => depot.majReglages((x) {
                x.theme = ThemeChoisi.systeme;
                x.accent = 'rose';
                x.tailleTexte = ReglagesApparence.tailleTexteDefaut;
                x.fond = 0;
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _BulleApercu extends StatelessWidget {
  const _BulleApercu({required this.texte, required this.moi});

  final String texte;
  final bool moi;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: moi ? OuroColors.bubbleOutgoing : OuroColors.bubbleIncoming,
        borderRadius: BorderRadius.circular(ReglagesApparence.rayonBulles),
      ),
      child: Text(
        texte,
        style: OuroTypography.body.copyWith(
          color: moi ? OuroColors.bubbleOutgoingText : OuroColors.bubbleIncomingText,
          fontSize: ReglagesApparence.tailleTexte,
        ),
      ),
    );
  }
}

// ── Notifications ──────────────────────────────────────────────────────

class _PanneauNotifications extends StatefulWidget {
  const _PanneauNotifications();

  @override
  State<_PanneauNotifications> createState() => _PanneauNotificationsState();
}

class _PanneauNotificationsState extends State<_PanneauNotifications> {
  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final permission = Navigateur.permissionNotifications;
    final actives = depot.reglages.notifications && permission == 'granted';
    return _Page(
      titre: l.stNotificationsHeader,
      enfants: [
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              titre: t.notificationsNavigateur,
              sousTitre: permission == 'denied' ? t.notificationsRefusees : null,
              fin: Interrupteur(
                valeur: actives,
                onChanged: (v) async {
                  if (v && permission != 'granted') {
                    final ok = await Navigateur.demanderNotifications();
                    if (!ok) {
                      if (context.mounted) annoncer(context, t.notificationsRefusees, icone: Icons.notifications_off_rounded);
                      setState(() {});
                      return;
                    }
                  }
                  depot.majReglages((r) => r.notifications = v);
                  setState(() {});
                },
              ),
            ),
            LigneIlot(
              titre: l.stSoundToggle,
              fin: Interrupteur(
                valeur: depot.reglages.sons,
                onChanged: (v) {
                  depot.majReglages((r) => r.sons = v);
                  if (v) Navigateur.ploc();
                },
              ),
            ),
          ],
        ),
        _Note(t.notificationsNote),
      ],
    );
  }
}

// ── Langue ─────────────────────────────────────────────────────────────

class _PanneauLangue extends StatelessWidget {
  const _PanneauLangue();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final actuelle = Textes.langueStockee;
    return _Page(
      titre: l.sectionLanguage,
      enfants: [
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              titre: l.languageAuto,
              fin: actuelle == null ? Icon(Icons.check_rounded, color: OuroColors.accent) : null,
              onTap: actuelle == null ? null : () => Textes.choisirLangue(null),
            ),
            for (final code in Textes.codes)
              LigneIlot(
                titre: Textes.nomLangue(code),
                fin: actuelle == code ? Icon(Icons.check_rounded, color: OuroColors.accent) : null,
                onTap: actuelle == code ? null : () => Textes.choisirLangue(code),
              ),
          ],
        ),
        _Note(l.languageFooter),
      ],
    );
  }
}

// ── Raccourcis ─────────────────────────────────────────────────────────

class _PanneauRaccourcis extends StatelessWidget {
  const _PanneauRaccourcis();

  @override
  Widget build(BuildContext context) {
    final raccourcis = listeRaccourcis(context);
    return _Page(
      titre: context.t.raccourcis,
      enfants: [
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            for (final (action, touches) in raccourcis)
              LigneIlot(
                titre: action,
                fin: Wrap(
                  spacing: 4,
                  children: [
                    for (final k in touches.split('+'))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: OuroColors.tertiarySystemFill,
                          borderRadius: BorderRadius.circular(6),
                          border: Border(bottom: BorderSide(color: OuroColors.separator, width: 1.5)),
                        ),
                        child: Text(k, style: OuroTypography.footnote.copyWith(color: OuroColors.label, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Aide ───────────────────────────────────────────────────────────────

class _PanneauAide extends StatelessWidget {
  const _PanneauAide();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = context.t;
    return _Page(
      titre: t.aideTitre,
      enfants: [
        Ilot(
          fond: OuroColors.systemGroupedBackground,
          enfants: [
            LigneIlot(
              icone: Icons.help_center_rounded,
              couleurIcone: OuroColors.systemTeal,
              titre: t.centreAide,
              onTap: () => Navigateur.ouvrir('$kSite/support/'),
            ),
            LigneIlot(
              icone: Icons.mail_rounded,
              couleurIcone: const Color(0xFF0A84FF),
              titre: l.hlpContact,
              sousTitre: kEmailContact,
              onTap: () => Navigateur.ouvrir('mailto:$kEmailContact'),
            ),
            LigneIlot(
              icone: Icons.policy_rounded,
              couleurIcone: OuroColors.systemIndigo,
              titre: l.hlpPrivacy,
              onTap: () => Navigateur.ouvrir('$kSite/privacy/'),
            ),
            LigneIlot(
              icone: Icons.description_rounded,
              couleurIcone: OuroColors.systemGray,
              titre: t.conditions,
              onTap: () => Navigateur.ouvrir('$kSite/terms/'),
            ),
            LigneIlot(
              icone: Icons.shield_rounded,
              couleurIcone: OuroColors.systemGreen,
              titre: t.securite,
              onTap: () => Navigateur.ouvrir('$kSite/security/'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(child: Goutte(taille: 44, couleur: OuroColors.accent)),
        const SizedBox(height: 10),
        Text('Droplet Web', textAlign: TextAlign.center, style: OuroTypography.title3.copyWith(color: OuroColors.label)),
        Text('$kVersion · ${l.stAboutTagline}', textAlign: TextAlign.center, style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
      ],
    );
  }
}
