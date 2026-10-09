// LES INFOS D'UNE DISCUSSION — le panneau de droite, comme l'écran
// « Infos » de l'app et de WhatsApp Web.
//
//   • la grande photo, le nom, « à propos » ou « Groupe · N membres » ;
//   • les boutons Audio, Vidéo, Rechercher ;
//   • médias, liens et documents (les dernières photos, puis tout) ;
//   • les messages importants de cette discussion ;
//   • sourdine, messages éphémères, chiffrement ;
//   • dans un groupe : description, membres (ajouter, retirer, nommer
//     admin), quitter ; avec un contact : groupes en commun, bloquer,
//     signaler.
//
// Le panneau a son propre navigateur : « Médias » et « Importants »
// s'y empilent sans quitter la discussion.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/modeles.dart';
import '../web/navigateur.dart';
import 'apercu.dart';
import 'appels.dart';
import 'composants.dart';
import 'coquille.dart';
import 'formats.dart';
import 'ilots.dart';
import 'importants.dart';
import 'liste_discussions.dart' show CaseRonde, confirmerSuppression;
import 'portee.dart';
import 'visionneuse.dart';

class PanneauInfos extends StatelessWidget {
  const PanneauInfos({super.key, required this.discussion});

  final Discussion discussion;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: OuroColors.systemGroupedBackground,
      child: HeroControllerScope.none(
        child: Navigator(
          key: ValueKey('infos-${discussion.id}'),
          onGenerateInitialRoutes: (_, __) => [
            CupertinoPageRoute<void>(builder: (_) => _Infos(discussionId: discussion.id)),
          ],
        ),
      ),
    );
  }
}

class _Infos extends StatelessWidget {
  const _Infos({required this.discussionId});

  final String discussionId;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final ui = context.ui;
    final l = context.l;
    final t = context.t;
    final d = depot.discussions[discussionId];
    if (d == null) return const SizedBox.shrink();
    final contact = depot.interlocuteur(d);
    final medias = depot.medias(d.id);
    final photos = medias.where((m) => m.type == TypeMessage.image).toList();
    final nbImportants = depot.importants().where((m) => m.discussionId == d.id).length;
    final admin = d.admins.contains(kMoi);

    return ColoredBox(
      color: OuroColors.systemGroupedBackground,
      child: Column(
        children: [
          SizedBox(
            height: 64,
            child: Row(
              children: [
                const SizedBox(width: 8),
                BoutonIcone(icone: Icons.close_rounded, aide: t.fermer, onTap: () => ui.basculerInfos(false)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    d.estGroupe ? l.giGroupInfo : l.ciInfoTitle,
                    style: OuroTypography.headline.copyWith(color: OuroColors.label),
                  ),
                ),
                if (d.estGroupe && admin && !d.quitte)
                  TextButton(
                    onPressed: () => _renommer(context, d),
                    child: Text(l.actionEdit, style: OuroTypography.body.copyWith(color: OuroColors.accent)),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                // ── L'identité
                Center(
                  child: AvatarDroplet(
                    nom: d.titre,
                    couleur: d.couleur,
                    taille: 116,
                    groupe: d.estGroupe,
                    anneau: contact != null && depot.statutsDe(contact.id).isNotEmpty ? !depot.statutsTousVus(contact.id) : null,
                  ),
                ),
                const SizedBox(height: 14),
                Text(d.titre, textAlign: TextAlign.center, style: OuroTypography.title2.copyWith(color: OuroColors.label)),
                const SizedBox(height: 4),
                Text(
                  d.estGroupe ? '${l.shGroup} · ${l.giMemberCount(d.membres.length + (d.quitte ? 0 : 1))}' : (contact == null ? '' : vuA(context, contact)),
                  textAlign: TextAlign.center,
                  style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _BoutonAction(icone: Icons.phone_rounded, libelle: l.pfCall, onTap: () => lancerAppel(context, d, video: false)),
                    const SizedBox(width: 8),
                    _BoutonAction(icone: Icons.videocam_rounded, libelle: l.chVideoCall, onTap: () => lancerAppel(context, d, video: true)),
                    const SizedBox(width: 8),
                    _BoutonAction(
                      icone: Icons.search_rounded,
                      libelle: l.actionSearch,
                      onTap: () {
                        if (MediaQuery.sizeOf(context).width < 1280) ui.infos = false;
                        ui.basculerRecherche(true);
                      },
                    ),
                    const SizedBox(width: 8),
                    _BoutonAction(
                      icone: d.sourdine ? Icons.notifications_off_rounded : Icons.notifications_rounded,
                      libelle: d.sourdine ? l.chatsUnmute : l.chatsMute,
                      onTap: () => depot.sourdine(d),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Description ou « à propos »
                if (d.estGroupe)
                  Ilot(
                    enfants: [
                      LigneIlot(
                        titre: d.description.isEmpty ? l.giDescriptionAdd : d.description,
                        couleurTitre: d.description.isEmpty ? OuroColors.accent : null,
                        sousTitre: d.description.isEmpty ? null : l.giDescription,
                        lignesTitre: 6,
                        onTap: admin && !d.quitte ? () => _description(context, d) : null,
                      ),
                    ],
                  )
                else if (contact != null && contact.aPropos.isNotEmpty)
                  Ilot(enfants: [LigneIlot(titre: contact.aPropos, sousTitre: t.aPropos)]),

                // ── Médias
                Ilot(
                  enfants: [
                    LigneIlot(
                      icone: Icons.photo_library_rounded,
                      couleurIcone: const Color(0xFF0A84FF),
                      titre: t.mediasLiensDocs,
                      valeur: '${medias.length}',
                      onTap: () => Navigator.of(context).push(CupertinoPageRoute<void>(builder: (_) => _Medias(discussionId: d.id))),
                    ),
                    if (photos.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: [
                            for (final m in photos.take(4))
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Survol(
                                      onTap: () => ouvrirVisionneuse(context, m),
                                      curseur: SystemMouseCursors.zoomIn,
                                      builder: (context, survol) => ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(m.piece!.url, fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            for (var i = photos.length; i < 4; i++) const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    LigneIlot(
                      icone: Icons.star_rounded,
                      couleurIcone: OuroColors.systemYellow,
                      titre: l.imTitle,
                      valeur: nbImportants == 0 ? l.epOff : '$nbImportants',
                      onTap: () => Navigator.of(context).push(CupertinoPageRoute<void>(builder: (_) => PanneauImportants(discussionId: d.id))),
                    ),
                  ],
                ),

                // ── Réglages de la discussion
                Ilot(
                  enfants: [
                    LigneIlot(
                      icone: Icons.volume_off_rounded,
                      couleurIcone: OuroColors.systemIndigo,
                      titre: l.chatsMute,
                      fin: Interrupteur(valeur: d.sourdine, onChanged: (_) => depot.sourdine(d)),
                    ),
                    LigneIlot(
                      icone: Icons.timer_rounded,
                      couleurIcone: OuroColors.systemTeal,
                      titre: l.ciEphemeralMessages,
                      valeur: dureeEphemere(context, d.ephemereSecondes),
                      onTap: d.quitte ? null : () => choisirEphemere(context, d),
                    ),
                    LigneIlot(
                      icone: Icons.lock_rounded,
                      couleurIcone: OuroColors.systemGreen,
                      titre: d.estGroupe ? l.giEncryptedMessages : l.ciSecurityCode,
                      sousTitre: t.chiffrementDetail,
                      onTap: () => _codeSecurite(context, d),
                    ),
                  ],
                ),

                // ── Membres du groupe
                if (d.estGroupe) ...[
                  TitreIlot(l.giMemberCount(d.membres.length + (d.quitte ? 0 : 1))),
                  Ilot(
                    enfants: [
                      if (admin && !d.quitte)
                        LigneIlot(
                          icone: Icons.person_add_alt_1_rounded,
                          couleurIcone: OuroColors.accent,
                          titre: l.giAdd,
                          couleurTitre: OuroColors.accent,
                          onTap: () => _ajouterMembres(context, d),
                        ),
                      if (!d.quitte)
                        _LigneMembre(
                          nom: '${depot.nom(kMoi)} (${l.giMe})',
                          couleur: depot.profil.couleur,
                          photo: depot.profil.photo,
                          aPropos: depot.profil.aPropos,
                          admin: d.admins.contains(kMoi),
                        ),
                      for (final id in d.membres)
                        _LigneMembre(
                          nom: depot.nom(id),
                          couleur: depot.contacts[id]?.couleur ?? 0,
                          aPropos: depot.contacts[id]?.aPropos ?? '',
                          admin: d.admins.contains(id),
                          enLigne: depot.contacts[id]?.enLigne ?? false,
                          onTap: (pos) => _menuMembre(context, d, id, pos),
                        ),
                    ],
                  ),
                ],

                // ── Groupes en commun
                if (contact != null) ...[
                  Builder(builder: (context) {
                    final communs = depot.discussions.values.where((g) => g.estGroupe && g.membres.contains(contact.id)).toList();
                    if (communs.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TitreIlot(t.groupesCommun(communs.length)),
                        Ilot(
                          enfants: [
                            for (final g in communs)
                              LigneIlot(
                                titre: g.titre,
                                sousTitre: [...g.membres.map(depot.nom), t.vous].join(', '),
                                debut: AvatarDroplet(nom: g.titre, couleur: g.couleur, taille: 36, groupe: true),
                                onTap: () => ouvrirDiscussion(context, g.id),
                              ),
                          ],
                        ),
                      ],
                    );
                  }),
                ],

                // ── Actions destructives
                Ilot(
                  enfants: [
                    if (contact != null)
                      LigneIlot(
                        icone: Icons.block_rounded,
                        couleurIcone: OuroColors.systemRed,
                        titre: contact.bloque ? l.ciUnblock : '${l.ciBlock} ${contact.pseudo}',
                        couleurTitre: OuroColors.systemRed,
                        onTap: () async {
                          if (contact.bloque) {
                            depot.bloquer(contact);
                            annoncer(context, l.ciContactUnblocked(contact.pseudo));
                            return;
                          }
                          final i = await alerte(
                            context,
                            titre: l.ciBlockContactTitle,
                            message: l.ciBlockContactBody(contact.pseudo),
                            actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.ciBlock, destructif: true)],
                          );
                          if (i == 1) {
                            depot.bloquer(contact);
                            if (context.mounted) annoncer(context, l.ciContactBlocked(contact.pseudo), icone: Icons.block_rounded);
                          }
                        },
                      ),
                    if (d.estGroupe && !d.quitte)
                      LigneIlot(
                        icone: Icons.logout_rounded,
                        couleurIcone: OuroColors.systemRed,
                        titre: l.giLeaveGroup,
                        couleurTitre: OuroColors.systemRed,
                        onTap: () async {
                          final i = await alerte(
                            context,
                            titre: l.giLeaveGroupTitle,
                            message: l.giLeaveGroupBody,
                            actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.giLeave, destructif: true)],
                          );
                          if (i == 1) depot.quitterGroupe(d);
                        },
                      ),
                    LigneIlot(
                      icone: Icons.thumb_down_alt_rounded,
                      couleurIcone: OuroColors.systemRed,
                      titre: l.ciReport,
                      couleurTitre: OuroColors.systemRed,
                      onTap: () => _signaler(context, d),
                    ),
                    LigneIlot(
                      icone: Icons.delete_rounded,
                      couleurIcone: OuroColors.systemRed,
                      titre: l.chatsDelete,
                      couleurTitre: OuroColors.systemRed,
                      onTap: () => confirmerSuppression(context, d),
                    ),
                  ],
                ),
                if (d.estGroupe)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      t.creeLe(dateComplete(context, d.creeeLe)),
                      textAlign: TextAlign.center,
                      style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _renommer(BuildContext context, Discussion d) async {
    final l = context.l;
    final nom = await demanderTexte(
      context,
      titre: l.giRenameGroup,
      initial: d.titre,
      indication: l.gcNameHint,
      valider: l.actionSave,
      annuler: l.actionCancel,
    );
    if (nom != null && context.mounted) context.lire.depot.renommer(d, nom);
  }

  Future<void> _description(BuildContext context, Discussion d) async {
    final l = context.l;
    final controleur = TextEditingController(text: d.description);
    final i = await alerte(
      context,
      titre: l.giDescription,
      contenu: ChampTexte(controleur: controleur, indication: l.giDescriptionHint, lignesMax: 5, longueurMax: 500, autofocus: true),
      actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.actionSave, principal: true)],
    );
    if (i == 1 && context.mounted) context.lire.depot.renommer(d, d.titre, description: controleur.text.trim());
    controleur.dispose();
  }

  Future<void> _ajouterMembres(BuildContext context, Discussion d) async {
    final depot = context.lire.depot;
    final l = context.l;
    final candidats = depot.contacts.values.where((c) => !d.membres.contains(c.id) && !c.bloque).toList()
      ..sort((a, b) => a.pseudo.compareTo(b.pseudo));
    if (candidats.isEmpty) {
      annoncer(context, l.giNoPeerToAdd, icone: Icons.info_outline_rounded);
      return;
    }
    final choisis = <String>{};
    final i = await alerte(
      context,
      titre: l.giAddMemberHeader,
      contenu: StatefulBuilder(
        builder: (context, maj) => SizedBox(
          height: (candidats.length * 52.0).clamp(52, 320),
          child: ListView(
            children: [
              for (final c in candidats)
                Survol(
                  onTap: () => maj(() => choisis.contains(c.id) ? choisis.remove(c.id) : choisis.add(c.id)),
                  builder: (context, survol) => Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        CaseRonde(cochee: choisis.contains(c.id)),
                        const SizedBox(width: 10),
                        AvatarDroplet(nom: c.pseudo, couleur: c.couleur, taille: 34),
                        const SizedBox(width: 10),
                        Expanded(child: Text(c.pseudo, style: OuroTypography.body.copyWith(color: OuroColors.label))),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.giAdd, principal: true)],
    );
    if (i == 1 && choisis.isNotEmpty) depot.ajouterMembres(d, choisis.toList());
  }

  void _menuMembre(BuildContext context, Discussion d, String id, Offset position) {
    final depot = context.lire.depot;
    final l = context.l;
    final t = context.t;
    final admin = d.admins.contains(kMoi) && !d.quitte;
    montrerMenu(
      context,
      position: position,
      elements: [
        ElementMenu(
          icone: Icons.chat_bubble_outline_rounded,
          libelle: t.envoyerMessageA(depot.nom(id)),
          onTap: () => ouvrirDiscussion(context, depot.discussionAvec(id).id),
        ),
        if (admin)
          ElementMenu(
            icone: Icons.shield_outlined,
            libelle: d.admins.contains(id) ? t.retirerAdmin : t.nommerAdmin,
            onTap: () => depot.basculerAdmin(d, id),
          ),
        if (admin)
          ElementMenu(
            icone: Icons.person_remove_outlined,
            libelle: l.giRemove,
            destructif: true,
            onTap: () async {
              final i = await alerte(
                context,
                titre: l.giRemoveMemberTitle,
                message: l.giRemoveMemberBody,
                actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.giRemove, destructif: true)],
              );
              if (i == 1) depot.retirerMembre(d, id);
            },
          ),
      ],
    );
  }

  Future<void> _codeSecurite(BuildContext context, Discussion d) async {
    final l = context.l;
    // Le code de sécurité : 60 chiffres en 12 groupes, comme Signal. En
    // démonstration, dérivé des identifiants ; avec les serveurs, des clés.
    final graine = '${d.id}:${d.membres.join(',')}'.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);
    var x = graine;
    final chiffres = StringBuffer();
    for (var i = 0; i < 12; i++) {
      x = (x * 1103515245 + 12345) & 0x7fffffff;
      chiffres.write((x % 100000).toString().padLeft(5, '0'));
      chiffres.write(i % 4 == 3 ? '\n' : '  ');
    }
    await alerte(
      context,
      titre: l.ciSecurityCode,
      message: context.t.codeSecuriteTexte,
      contenu: Text(
        chiffres.toString().trim(),
        textAlign: TextAlign.center,
        style: OuroTypography.monospacedDigits.copyWith(color: OuroColors.label, fontSize: 15, height: 1.6, letterSpacing: 0.6),
      ),
      actions: [ActionAlerte(l.actionDone, principal: true)],
    );
  }

  Future<void> _signaler(BuildContext context, Discussion d) async {
    final l = context.l;
    final raisons = [l.ciReportReasonSpam, l.ciReportReasonHarassment, l.ciReportReasonIllegal, l.ciReportReasonOther];
    final i = await alerte(
      context,
      titre: l.ciReportContactTitle,
      message: l.ciReportContactBody(d.titre),
      actions: [for (final r in raisons) ActionAlerte(r), ActionAlerte(l.actionCancel, principal: true)],
    );
    if (i != null && i < raisons.length && context.mounted) annoncer(context, l.ciReportSent, icone: Icons.flag_rounded);
  }
}

/// Choisir la durée des messages éphémères.
Future<void> choisirEphemere(BuildContext context, Discussion d) async {
  final l = context.l;
  final depot = context.lire.depot;
  var choix = d.ephemereSecondes;
  final i = await alerte(
    context,
    titre: l.epTitle,
    message: l.epBody,
    contenu: StatefulBuilder(
      builder: (context, maj) => Column(
        children: [
          for (final s in dureesEphemeres)
            Survol(
              onTap: () => maj(() => choix = s),
              builder: (context, survol) => Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(dureeEphemere(context, s), style: OuroTypography.body.copyWith(color: OuroColors.label))),
                    if (choix == s) Icon(Icons.check_rounded, color: OuroColors.accent, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
    actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.actionDone, principal: true)],
  );
  if (i == 1 && choix != d.ephemereSecondes) depot.definirEphemere(d, choix);
}

// ── Les médias ─────────────────────────────────────────────────────────

class _Medias extends StatefulWidget {
  const _Medias({required this.discussionId});

  final String discussionId;

  @override
  State<_Medias> createState() => _MediasState();
}

class _MediasState extends State<_Medias> {
  int _onglet = 0;

  static final _lien = RegExp(r'(https?://|www\.)[^\s<>"]+', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final medias = depot.medias(widget.discussionId);
    final photos = medias.where((m) => m.type == TypeMessage.image).toList();
    final docs = medias.where((m) => m.type == TypeMessage.fichier).toList();
    final liens = [
      for (final m in depot.messages(widget.discussionId).reversed)
        if (!m.supprime)
          for (final x in _lien.allMatches(m.texte)) (m, x.group(0)!),
    ];
    return ColoredBox(
      color: OuroColors.systemGroupedBackground,
      child: Column(
        children: [
          EntetePanneau(titre: t.mediasLiensDocs, retour: () => Navigator.of(context).pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: CupertinoSlidingSegmentedControl<int>(
              groupValue: _onglet,
              onValueChanged: (v) => setState(() => _onglet = v ?? 0),
              children: {
                0: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(l.ciMedia, style: OuroTypography.footnote.copyWith(color: OuroColors.label))),
                1: Text(l.stoDocuments, style: OuroTypography.footnote.copyWith(color: OuroColors.label)),
                2: Text(l.ciLinks, style: OuroTypography.footnote.copyWith(color: OuroColors.label)),
              },
            ),
          ),
          Expanded(
            child: switch (_onglet) {
              0 => photos.isEmpty
                  ? EtatVide(icone: Icons.photo_outlined, titre: l.ciNoMediaSharedYet)
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 3, crossAxisSpacing: 3),
                      itemCount: photos.length,
                      itemBuilder: (context, i) => Survol(
                        onTap: () => ouvrirVisionneuse(context, photos[i]),
                        curseur: SystemMouseCursors.zoomIn,
                        builder: (context, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(photos[i].piece!.url, fit: BoxFit.cover),
                        ),
                      ),
                    ),
              1 => docs.isEmpty
                  ? EtatVide(icone: Icons.insert_drive_file_outlined, titre: l.stoEmpty)
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Ilot(
                          enfants: [
                            for (final m in docs)
                              LigneIlot(
                                icone: Icons.insert_drive_file_rounded,
                                couleurIcone: OuroColors.systemIndigo,
                                titre: m.piece?.nom ?? l.chatsDocument,
                                sousTitre: '${taille(context, m.piece?.taille ?? 0)} · ${dateListe(context, m.date)}',
                                onTap: m.piece == null ? null : () => Navigateur.telecharger(m.piece!),
                              ),
                          ],
                        ),
                      ],
                    ),
              _ => liens.isEmpty
                  ? EtatVide(icone: Icons.link_rounded, titre: l.stoEmpty)
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        Ilot(
                          enfants: [
                            for (final (m, lien) in liens)
                              LigneIlot(
                                icone: Icons.link_rounded,
                                couleurIcone: const Color(0xFF0A84FF),
                                titre: lien,
                                sousTitre: '${depot.nom(m.auteurId)} · ${dateListe(context, m.date)}',
                                onTap: () => Navigateur.ouvrir(lien.startsWith('http') ? lien : 'https://$lien'),
                              ),
                          ],
                        ),
                      ],
                    ),
            },
          ),
        ],
      ),
    );
  }
}

// ── Les pièces du panneau ──────────────────────────────────────────────

class _BoutonAction extends StatelessWidget {
  const _BoutonAction({required this.icone, required this.libelle, required this.onTap});

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Survol(
        onTap: onTap,
        builder: (context, survol) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 64,
          decoration: BoxDecoration(
            color: survol ? OuroColors.tertiarySystemGroupedBackground : OuroColors.secondarySystemGroupedBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, color: OuroColors.accent, size: 22),
              const SizedBox(height: 5),
              Text(
                libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.caption1.copyWith(color: OuroColors.accent, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LigneMembre extends StatelessWidget {
  const _LigneMembre({
    required this.nom,
    required this.couleur,
    required this.aPropos,
    required this.admin,
    this.photo,
    this.enLigne = false,
    this.onTap,
  });

  final String nom;
  final int couleur;
  final String aPropos;
  final bool admin;
  final String? photo;
  final bool enLigne;
  final ValueChanged<Offset>? onTap;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Survol(
        onTap: onTap == null
            ? null
            : () {
                final box = context.findRenderObject() as RenderBox;
                onTap!(box.localToGlobal(Offset(box.size.width - 40, box.size.height / 2)));
              },
        onClicDroit: onTap,
        builder: (context, survol) => Container(
          color: survol && onTap != null ? OuroColors.label.withValues(alpha: 0.04) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              AvatarDroplet(nom: nom, couleur: couleur, photo: photo, taille: 36, enLigne: enLigne),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom, maxLines: 1, overflow: TextOverflow.ellipsis, style: OuroTypography.body.copyWith(color: OuroColors.label)),
                    if (aPropos.isNotEmpty)
                      Text(aPropos, maxLines: 1, overflow: TextOverflow.ellipsis, style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
                  ],
                ),
              ),
              if (admin)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: OuroColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(context.l.giAdministrator, style: OuroTypography.caption2.copyWith(color: OuroColors.accent, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      );
    });
  }
}
