// LA LISTE DES DISCUSSIONS — la colonne de gauche de l'onglet Discussions.
//
//   • le grand titre, « Nouveau » et le menu « … » ;
//   • la recherche, qui trouve les discussions, les contacts ET les
//     messages (avec le mot cherché en couleur) ;
//   • les filtres de l'app : Toutes, Non lues, Épinglées, Groupes ;
//   • la ligne « Archivées » en tête, s'il y en a ;
//   • chaque ligne : avatar (avec l'anneau des actus non vues), nom, date,
//     aperçu (« écrit… », « Brouillon : », les coches de mon dernier
//     message, l'auteur dans un groupe), pastille, épingle, sourdine.
//
// À la souris : un chevron apparaît au survol d'une ligne, et le clic droit
// ouvre le même menu (archiver, épingler, couper le son…).
import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_spinner.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/depot.dart';
import '../donnees/modeles.dart';
import '../donnees/transport.dart';
import 'apercu.dart';
import 'composants.dart';
import 'coquille.dart';
import 'formats.dart';
import 'importants.dart';
import 'nouvelle_discussion.dart';
import 'portee.dart';

enum _Filtre { toutes, nonLues, epinglees, groupes }

class ListeDiscussions extends StatefulWidget {
  const ListeDiscussions({super.key});

  @override
  State<ListeDiscussions> createState() => _ListeDiscussionsState();
}

class _ListeDiscussionsState extends State<ListeDiscussions> {
  _Filtre _filtre = _Filtre.toutes;
  String _recherche = '';
  final _champ = TextEditingController();

  @override
  void dispose() {
    _champ.dispose();
    super.dispose();
  }

  bool _garder(Depot depot, Discussion d) => switch (_filtre) {
        _Filtre.toutes => true,
        _Filtre.nonLues => d.nonLus > 0,
        _Filtre.epinglees => d.epinglee,
        _Filtre.groupes => d.estGroupe,
      };

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final ui = context.ui;
    final l = context.l;
    final t = context.t;
    final q = _recherche.trim().toLowerCase();
    final toutes = depot.discussionsTriees();
    final visibles = toutes.where((d) => _garder(depot, d)).toList();
    final nonLues = toutes.where((d) => d.nonLus > 0).length;

    final menu = GlobalKey();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntetePanneau(
          titre: l.chatsTitle,
          actions: [
            BoutonIcone(
              icone: Icons.add_comment_outlined,
              aide: l.chatsNew,
              couleur: OuroColors.accent,
              onTap: () => pousserPanneau(context, const PanneauNouvelleDiscussion()),
            ),
            BoutonIcone(
              key: menu,
              icone: Icons.more_horiz_rounded,
              aide: t.plus,
              couleur: OuroColors.accent,
              onTap: () {
                final box = menu.currentContext!.findRenderObject() as RenderBox;
                montrerMenu(
                  context,
                  position: box.localToGlobal(Offset(box.size.width, box.size.height)),
                  elements: [
                    ElementMenu(
                      icone: Icons.group_add_outlined,
                      libelle: l.chatsNewGroup,
                      onTap: () => pousserPanneau(context, const PanneauNouveauGroupe()),
                    ),
                    ElementMenu(
                      icone: Icons.star_outline_rounded,
                      libelle: l.imTitle,
                      onTap: () => pousserPanneau(context, const PanneauImportants()),
                    ),
                    ElementMenu(
                      icone: Icons.archive_outlined,
                      libelle: l.chatsArchivedTitle,
                      onTap: () => pousserPanneau(context, const PanneauArchives()),
                    ),
                    ElementMenu(
                      icone: Icons.mark_chat_read_outlined,
                      libelle: t.toutMarquerLu,
                      section: true,
                      onTap: () {
                        for (final d in depot.discussions.values) {
                          if (d.nonLus > 0) depot.marquerNonLue(d);
                        }
                      },
                    ),
                    ElementMenu(
                      icone: Icons.settings_outlined,
                      libelle: l.settingsTitle,
                      onTap: () => ui.changerOnglet(Onglet.reglages),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        _EtatConnexion(etat: depot.transport.etat),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: ChampRecherche(
            controleur: _champ,
            focus: ui.focusRecherche,
            indication: l.chatsSearchHint,
            onChanged: (v) => setState(() => _recherche = v),
          ),
        ),
        if (q.isEmpty)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              children: [
                Puce(texte: l.chatsFilterAll, actif: _filtre == _Filtre.toutes, onTap: () => setState(() => _filtre = _Filtre.toutes)),
                Puce(
                  texte: l.chatsFilterUnread,
                  compte: nonLues,
                  actif: _filtre == _Filtre.nonLues,
                  onTap: () => setState(() => _filtre = _Filtre.nonLues),
                ),
                Puce(texte: l.chatsFilterPinned, actif: _filtre == _Filtre.epinglees, onTap: () => setState(() => _filtre = _Filtre.epinglees)),
                Puce(texte: l.chatsFilterGroups, actif: _filtre == _Filtre.groupes, onTap: () => setState(() => _filtre = _Filtre.groupes)),
              ],
            ),
          ),
        Expanded(
          child: q.isNotEmpty
              ? _Resultats(requete: q)
              : visibles.isEmpty && depot.nombreArchivees == 0
                  ? _vide(context)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      itemCount: visibles.length + 1 + (visibles.isEmpty ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return depot.nombreArchivees > 0 && _filtre == _Filtre.toutes
                              ? _LigneArchives(nombre: depot.nombreArchivees)
                              : const SizedBox.shrink();
                        }
                        if (visibles.isEmpty) return SizedBox(height: 360, child: _vide(context));
                        final d = visibles[i - 1];
                        return LigneDiscussion(key: ValueKey(d.id), discussion: d);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _vide(BuildContext context) {
    final l = context.l;
    return switch (_filtre) {
      _Filtre.nonLues => EtatVide(icone: Icons.mark_chat_read_outlined, titre: l.cfEmptyUnreadTitle, texte: l.cfEmptyUnreadBody),
      _Filtre.groupes => EtatVide(
          icone: Icons.groups_outlined,
          titre: l.cfEmptyGroupsTitle,
          action: BoutonPlein(
            texte: l.chatsNewGroup,
            icone: Icons.group_add_rounded,
            onTap: () => pousserPanneau(context, const PanneauNouveauGroupe()),
          ),
        ),
      _Filtre.epinglees => EtatVide(icone: Icons.push_pin_outlined, titre: l.cfEmptyOtherTitle),
      _Filtre.toutes => EtatVide(
          icone: Icons.chat_bubble_outline_rounded,
          titre: l.chatsEmptyTitle,
          texte: context.t.videListe,
          action: BoutonPlein(
            texte: l.chatsNew,
            icone: Icons.add_comment_rounded,
            onTap: () => pousserPanneau(context, const PanneauNouvelleDiscussion()),
          ),
        ),
    };
  }
}

/// « Connexion… » sous le titre, tant que le transport n'est pas prêt.
class _EtatConnexion extends StatelessWidget {
  const _EtatConnexion({required this.etat});

  final ValueListenable<EtatConnexion> etat;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EtatConnexion>(
      valueListenable: etat,
      builder: (context, e, _) => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: kSortie,
        child: e == EtatConnexion.connecte
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    if (e == EtatConnexion.connexion)
                      OuroSpinner(radius: 7, color: OuroColors.secondaryLabel)
                    else
                      Icon(Icons.cloud_off_rounded, size: 15, color: OuroColors.systemOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e == EtatConnexion.connexion ? context.t.connexionEnCours : context.t.horsLigne,
                        style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LigneArchives extends StatelessWidget {
  const _LigneArchives({required this.nombre});

  final int nombre;

  @override
  Widget build(BuildContext context) {
    return Survol(
      onTap: () => pousserPanneau(context, const PanneauArchives()),
      builder: (context, survol) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Icon(Icons.archive_outlined, size: 22, color: OuroColors.secondaryLabel),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(context.l.chatsArchivedTitle, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
            ),
            Text('$nombre', style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel)),
          ],
        ),
      ),
    );
  }
}

/// Une ligne de la liste, réutilisée par les archives.
class LigneDiscussion extends StatelessWidget {
  const LigneDiscussion({super.key, required this.discussion, this.surligne});

  final Discussion discussion;

  /// Le mot cherché, à mettre en couleur dans le nom.
  final String? surligne;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final d = discussion;
    final selectionnee = depot.discussionOuverte == d.id;
    final contact = depot.interlocuteur(d);
    final dernier = depot.dernierMessage(d.id);
    final ecrivent = depot.enTrainDecrire[d.id] ?? const <String>{};
    final aStatut = contact != null && depot.statutsDe(contact.id).isNotEmpty;
    final chevron = GlobalKey();

    void menu(Offset position) => menuDiscussion(context, d, position);

    return Survol(
      onTap: () => ouvrirDiscussion(context, d.id),
      onClicDroit: menu,
      builder: (context, survol) {
        final fond = selectionnee
            ? OuroColors.tertiarySystemFill
            : (survol ? OuroColors.quaternarySystemFill : Colors.transparent);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              AvatarDroplet(
                nom: d.titre,
                couleur: d.couleur,
                taille: 52,
                groupe: d.estGroupe,
                enLigne: contact?.enLigne ?? false,
                anneau: aStatut ? !depot.statutsTousVus(contact.id) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _TexteSurligne(
                            texte: d.titre,
                            surligne: surligne,
                            style: OuroTypography.headline.copyWith(color: OuroColors.label),
                          ),
                        ),
                        if (dernier != null)
                          Text(
                            dateListe(context, dernier.date),
                            style: OuroTypography.footnote.copyWith(
                              color: d.nonLus > 0 && !d.sourdine ? OuroColors.accent : OuroColors.secondaryLabel,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(child: _Apercu(discussion: d, dernier: dernier, ecrivent: ecrivent)),
                        if (d.ephemereSecondes > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.timer_outlined, size: 14, color: OuroColors.tertiaryLabel),
                          ),
                        if (d.sourdine)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.volume_off_rounded, size: 15, color: OuroColors.tertiaryLabel),
                          ),
                        if (d.epinglee && d.nonLus == 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Transform.rotate(
                              angle: 0.6,
                              child: Icon(Icons.push_pin_rounded, size: 14, color: OuroColors.tertiaryLabel),
                            ),
                          ),
                        if (d.nonLus > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Pastille(compte: d.nonLus, grise: d.sourdine),
                          ),
                        // Le chevron du survol, comme WhatsApp Web.
                        AnimatedSize(
                          duration: const Duration(milliseconds: 160),
                          child: survol
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: BoutonIcone(
                                    key: chevron,
                                    icone: Icons.keyboard_arrow_down_rounded,
                                    diametre: 24,
                                    taille: 20,
                                    onTap: () {
                                      final box = chevron.currentContext!.findRenderObject() as RenderBox;
                                      menu(box.localToGlobal(Offset(0, box.size.height)));
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Apercu extends StatelessWidget {
  const _Apercu({required this.discussion, required this.dernier, required this.ecrivent});

  final Discussion discussion;
  final Message? dernier;
  final Set<String> ecrivent;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final d = discussion;
    final gris = OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel);

    if (ecrivent.isNotEmpty) {
      final texte = d.estGroupe ? l.chGroupTyping(ecrivent.map(depot.nom).join(', ')) : l.chTypingNow;
      return Text(texte, maxLines: 1, overflow: TextOverflow.ellipsis, style: gris.copyWith(color: OuroColors.accent));
    }
    if (d.brouillon.isNotEmpty && depot.discussionOuverte != d.id) {
      return Text.rich(
        TextSpan(children: [
          TextSpan(text: '${l.chDraftLabel} ', style: gris.copyWith(color: OuroColors.systemRed)),
          TextSpan(text: d.brouillon.replaceAll('\n', ' ')),
        ]),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: gris,
      );
    }
    final m = dernier;
    if (m == null) {
      return Text(d.description.isNotEmpty ? d.description : l.apcNothingYet, maxLines: 1, overflow: TextOverflow.ellipsis, style: gris);
    }
    final icone = iconeMessage(m);
    final auteur = m.type == TypeMessage.systeme
        ? ''
        : m.deMoi
            ? ''
            : d.estGroupe
                ? '${depot.nom(m.auteurId)} : '
                : '';
    return Row(
      children: [
        if (m.deMoi && m.type != TypeMessage.systeme && !m.supprime) ...[
          Coches(statut: m.statut, taille: 16),
          const SizedBox(width: 3),
        ],
        if (icone != null) ...[
          Icon(icone, size: 15, color: OuroColors.tertiaryLabel),
          const SizedBox(width: 3),
        ],
        Expanded(
          child: Text(
            '$auteur${texteMessage(context, m).replaceAll('\n', ' ')}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: gris.copyWith(fontStyle: m.supprime ? FontStyle.italic : null),
          ),
        ),
      ],
    );
  }
}

/// Les coches de l'app : horloge, une coche, deux coches, deux coches de
/// couleur (lu), point d'exclamation rouge (échec).
class Coches extends StatelessWidget {
  const Coches({super.key, required this.statut, this.taille = 15, this.couleur});

  final StatutMessage statut;
  final double taille;

  /// La couleur des coches non lues (blanc translucide dans mes bulles).
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final lu = context.depot.reglages.confirmationsLecture;
    final gris = couleur ?? OuroColors.tertiaryLabel;
    final (icone, teinte) = switch (statut) {
      StatutMessage.envoi => (Icons.schedule_rounded, gris),
      StatutMessage.envoye => (Icons.done_rounded, gris),
      StatutMessage.recu => (Icons.done_all_rounded, gris),
      StatutMessage.lu => (Icons.done_all_rounded, lu ? (couleur == null ? OuroColors.accent : const Color(0xFF7FE3FF)) : gris),
      StatutMessage.echec => (Icons.error_rounded, OuroColors.systemRed),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (enfant, a) => ScaleTransition(scale: a, child: enfant),
      child: Icon(icone, key: ValueKey(statut), size: statut == StatutMessage.envoi ? taille - 3 : taille, color: teinte),
    );
  }
}

/// Le menu d'une discussion (clic droit, chevron).
void menuDiscussion(BuildContext context, Discussion d, Offset position) {
  final p = context.lire;
  final depot = p.depot;
  final l = context.l;
  final t = context.t;
  montrerMenu(
    context,
    position: position,
    elements: [
      ElementMenu(
        icone: d.archivee ? Icons.unarchive_outlined : Icons.archive_outlined,
        libelle: d.archivee ? l.chatsUnarchive : l.chatsArchive,
        onTap: () => depot.archiver(d),
      ),
      ElementMenu(
        icone: d.sourdine ? Icons.volume_up_outlined : Icons.volume_off_outlined,
        libelle: d.sourdine ? l.chatsUnmute : l.chatsMute,
        onTap: () => depot.sourdine(d),
      ),
      if (!d.archivee)
        ElementMenu(
          icone: Icons.push_pin_outlined,
          libelle: d.epinglee ? l.chatsUnpin : l.chatsPin,
          onTap: () => depot.epinglerDiscussion(d),
        ),
      ElementMenu(
        icone: d.nonLus > 0 ? Icons.mark_chat_read_outlined : Icons.mark_chat_unread_outlined,
        libelle: d.nonLus > 0 ? t.marquerLue : t.marquerNonLue,
        onTap: () {
          if (d.nonLus == 0 && depot.discussionOuverte == d.id) depot.ouvrir(null);
          depot.marquerNonLue(d);
        },
      ),
      ElementMenu(
        icone: Icons.delete_outline_rounded,
        libelle: l.chatsDelete,
        destructif: true,
        onTap: () => confirmerSuppression(context, d),
      ),
    ],
  );
}

Future<void> confirmerSuppression(BuildContext context, Discussion d) async {
  final l = context.l;
  final depot = context.lire.depot;
  final i = await alerte(
    context,
    titre: l.chatsDeleteTitle(d.titre),
    message: context.t.suppressionDiscussion,
    actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.chatsDeleteConfirm, destructif: true)],
  );
  if (i == 1) depot.supprimerDiscussion(d);
}

// ── La recherche ───────────────────────────────────────────────────────

class _Resultats extends StatelessWidget {
  const _Resultats({required this.requete});

  final String requete;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final discussions = depot.discussions.values.where((d) => d.titre.toLowerCase().contains(requete)).toList();
    final avecDiscussion = {
      for (final d in depot.discussions.values)
        if (!d.estGroupe && d.membres.length == 1) d.membres.first,
    };
    final contacts = depot.contacts.values
        .where((c) => !avecDiscussion.contains(c.id) && c.pseudo.toLowerCase().contains(requete))
        .toList();
    final messages = depot.rechercher(requete).take(60).toList();

    if (discussions.isEmpty && contacts.isEmpty && messages.isEmpty) {
      return EtatVide(icone: Icons.search_rounded, titre: l.chatsSearchEmptyTitle, texte: l.chatsSearchEmptySubtitle);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      children: [
        if (discussions.isNotEmpty) ...[
          _TitreSection(l.chatsTitle),
          for (final d in discussions) LigneDiscussion(discussion: d, surligne: requete),
        ],
        if (contacts.isNotEmpty) ...[
          _TitreSection(l.nmContacts),
          for (final c in contacts) LigneContact(contact: c, onTap: () => ouvrirDiscussion(context, depot.discussionAvec(c.id).id)),
        ],
        if (messages.isNotEmpty) ...[
          _TitreSection(l.csMessagesSection),
          for (final m in messages) _LigneResultat(message: m, requete: requete),
        ],
      ],
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
        child: Text(texte.toUpperCase(), style: OuroTypography.sectionHeader.copyWith(color: OuroColors.secondaryLabel)),
      );
}

class _LigneResultat extends StatelessWidget {
  const _LigneResultat({required this.message, required this.requete});

  final Message message;
  final String requete;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final m = message;
    final d = depot.discussions[m.discussionId];
    if (d == null) return const SizedBox.shrink();
    return Survol(
      onTap: () => ouvrirDiscussion(context, d.id, message: m.id),
      builder: (context, survol) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    d.estGroupe ? '${depot.nom(m.auteurId)} · ${d.titre}' : d.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.subheadline.copyWith(color: OuroColors.label, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(dateListe(context, m.date), style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                if (m.deMoi) ...[Coches(statut: m.statut, taille: 15), const SizedBox(width: 3)],
                Expanded(
                  child: _TexteSurligne(
                    texte: m.texte.replaceAll('\n', ' '),
                    surligne: requete,
                    lignes: 2,
                    style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Un texte où le mot cherché ressort dans la couleur d'accent.
class _TexteSurligne extends StatelessWidget {
  const _TexteSurligne({required this.texte, required this.style, this.surligne, this.lignes = 1});

  final String texte;
  final String? surligne;
  final TextStyle style;
  final int lignes;

  @override
  Widget build(BuildContext context) {
    final q = surligne?.toLowerCase() ?? '';
    final i = q.isEmpty ? -1 : texte.toLowerCase().indexOf(q);
    if (i < 0) return Text(texte, maxLines: lignes, overflow: TextOverflow.ellipsis, style: style);
    // Si le mot est loin, on coupe le début pour qu'il soit visible.
    final debut = i > 40 ? i - 20 : 0;
    final prefixe = debut > 0 ? '…' : '';
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: prefixe + texte.substring(debut, i)),
        TextSpan(
          text: texte.substring(i, i + q.length),
          style: TextStyle(color: OuroColors.accent, fontWeight: FontWeight.w600),
        ),
        TextSpan(text: texte.substring(i + q.length)),
      ]),
      maxLines: lignes,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

/// Une ligne de contact : avatar, pseudo, « à propos ».
class LigneContact extends StatelessWidget {
  const LigneContact({super.key, required this.contact, required this.onTap, this.fin, this.coche});

  final Contact contact;
  final VoidCallback onTap;
  final Widget? fin;

  /// Pour les listes à sélection : null = pas de case, sinon cochée ou non.
  final bool? coche;

  @override
  Widget build(BuildContext context) {
    final c = contact;
    return Survol(
      onTap: onTap,
      builder: (context, survol) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (coche != null) ...[
              CaseRonde(cochee: coche!),
              const SizedBox(width: 12),
            ],
            AvatarDroplet(nom: c.pseudo, couleur: c.couleur, taille: 44, enLigne: c.enLigne),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.pseudo, maxLines: 1, overflow: TextOverflow.ellipsis, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
                  if (c.aPropos.isNotEmpty)
                    Text(
                      c.aPropos,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                    ),
                ],
              ),
            ),
            if (fin != null) fin!,
          ],
        ),
      ),
    );
  }
}

/// La case ronde d'iOS, cochée dans la couleur d'accent.
class CaseRonde extends StatelessWidget {
  const CaseRonde({super.key, required this.cochee});

  final bool cochee;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: kSortie,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cochee ? OuroColors.accentRempli : Colors.transparent,
        border: Border.all(color: cochee ? OuroColors.accentRempli : OuroColors.systemGray3, width: 1.6),
      ),
      child: cochee ? Icon(Icons.check_rounded, size: 16, color: OuroColors.texteSurAccent) : null,
    );
  }
}
