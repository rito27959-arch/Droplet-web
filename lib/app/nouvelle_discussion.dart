// NOUVELLE DISCUSSION, NOUVEAU GROUPE, ARCHIVES — les panneaux qui
// glissent dans la colonne de gauche, comme les écrans poussés d'iOS.
//
//   • Nouvelle discussion : nouveau groupe, ajouter un contact, inviter,
//     puis les contacts de A à Z.
//   • Nouveau groupe, en deux temps comme l'app : choisir les membres
//     (les choisis s'alignent en haut, retirables d'un clic), puis le nom
//     et la description.
//   • Archives : les discussions mises de côté.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/modeles.dart';
import 'composants.dart';
import 'coquille.dart';
import 'liste_discussions.dart';
import 'portee.dart';

/// L'adresse d'invitation de l'app (la page du site lit le fragment).
const String kAdresseInvitation = 'https://dropletmesh.app/i/';

class PanneauNouvelleDiscussion extends StatefulWidget {
  const PanneauNouvelleDiscussion({super.key});

  @override
  State<PanneauNouvelleDiscussion> createState() => _PanneauNouvelleDiscussionState();
}

class _PanneauNouvelleDiscussionState extends State<PanneauNouvelleDiscussion> {
  String _q = '';

  void _ouvrir(Contact c) {
    final d = context.lire.depot.discussionAvec(c.id);
    Navigator.of(context).pop();
    ouvrirDiscussion(context, d.id);
  }

  Future<void> _ajouter() async {
    final l = context.l;
    final t = context.t;
    final pseudo = await demanderTexte(
      context,
      titre: t.ajouterContact,
      message: t.ajouterContactTexte,
      indication: l.obPseudoHint,
      valider: l.giAdd,
      annuler: l.actionCancel,
      longueurMax: 30,
    );
    if (pseudo == null || !mounted) return;
    final c = context.lire.depot.ajouterContact(pseudo);
    _ouvrir(c);
  }

  void _inviter() {
    final depot = context.lire.depot;
    Clipboard.setData(ClipboardData(text: context.l.invShareText(depot.nom(kMoi), kAdresseInvitation)));
    annoncer(context, context.l.ivCopied, icone: Icons.link_rounded);
  }

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final contacts = depot.contacts.values
        .where((c) => !c.bloque && (_q.isEmpty || c.pseudo.toLowerCase().contains(_q)))
        .toList()
      ..sort((a, b) => a.pseudo.toLowerCase().compareTo(b.pseudo.toLowerCase()));

    final lignes = <Widget>[
      if (_q.isEmpty) ...[
        _LigneAction(
          icone: Icons.group_add_rounded,
          libelle: l.chatsNewGroup,
          onTap: () => pousserPanneau(context, const PanneauNouveauGroupe()),
        ),
        _LigneAction(icone: Icons.person_add_alt_1_rounded, libelle: t.ajouterContact, onTap: _ajouter),
        _LigneAction(icone: Icons.link_rounded, libelle: l.chatsInviteLink, onTap: _inviter),
        const SizedBox(height: 8),
      ],
    ];
    String? lettre;
    for (final c in contacts) {
      final initiale = c.pseudo.isEmpty ? '#' : c.pseudo.characters.first.toUpperCase();
      if (initiale != lettre) {
        lettre = initiale;
        lignes.add(Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: Text(initiale, style: OuroTypography.footnote.copyWith(color: OuroColors.accent, fontWeight: FontWeight.w700)),
        ));
      }
      lignes.add(LigneContact(contact: c, onTap: () => _ouvrir(c)));
    }

    return ColoredBox(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntetePanneau(titre: l.nmTitle, retour: () => Navigator.of(context).pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: ChampRecherche(
              indication: l.nmFindByPseudo,
              autofocus: true,
              onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: contacts.isEmpty && _q.isNotEmpty
                ? EtatVide(icone: Icons.person_search_rounded, titre: l.nmNoResult)
                : ListView(padding: const EdgeInsets.fromLTRB(8, 0, 8, 16), children: lignes),
          ),
        ],
      ),
    );
  }
}

class _LigneAction extends StatelessWidget {
  const _LigneAction({required this.icone, required this.libelle, required this.onTap});

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: OuroColors.accentRempli, shape: BoxShape.circle),
              child: Icon(icone, color: OuroColors.texteSurAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Text(libelle, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
          ],
        ),
      ),
    );
  }
}

// ── Nouveau groupe ─────────────────────────────────────────────────────

class PanneauNouveauGroupe extends StatefulWidget {
  const PanneauNouveauGroupe({super.key});

  @override
  State<PanneauNouveauGroupe> createState() => _PanneauNouveauGroupeState();
}

class _PanneauNouveauGroupeState extends State<PanneauNouveauGroupe> {
  final List<String> _choisis = [];
  String _q = '';

  void _basculer(String id) => setState(() => _choisis.contains(id) ? _choisis.remove(id) : _choisis.add(id));

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final contacts = depot.contacts.values
        .where((c) => !c.bloque && (_q.isEmpty || c.pseudo.toLowerCase().contains(_q)))
        .toList()
      ..sort((a, b) => a.pseudo.toLowerCase().compareTo(b.pseudo.toLowerCase()));

    return ColoredBox(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EntetePanneau(
                titre: l.gcNewGroup,
                sousTitre: _choisis.isEmpty ? l.gcSelectOneMember : l.gcSelectedCount(_choisis.length),
                retour: () => Navigator.of(context).pop(),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: kSortie,
                child: _choisis.isEmpty
                    ? const SizedBox(width: double.infinity)
                    : SizedBox(
                        height: 86,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          children: [
                            for (final id in _choisis)
                              _Choisi(
                                key: ValueKey(id),
                                contact: depot.contacts[id]!,
                                onRetirer: () => _basculer(id),
                              ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: ChampRecherche(
                  indication: l.nmFindByPseudo,
                  autofocus: true,
                  onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 96),
                  children: [
                    for (final c in contacts)
                      LigneContact(contact: c, coche: _choisis.contains(c.id), onTap: () => _basculer(c.id)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 24,
            child: AnimatedScale(
              scale: _choisis.isEmpty ? 0 : 1,
              duration: const Duration(milliseconds: 320),
              curve: kSortie,
              child: _BoutonRond(
                icone: Icons.arrow_forward_rounded,
                aide: l.actionNext,
                onTap: () => pousserPanneau(context, _PanneauNomGroupe(membres: List.of(_choisis))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Choisi extends StatelessWidget {
  const _Choisi({super.key, required this.contact, required this.onRetirer});

  final Contact contact;
  final VoidCallback onRetirer;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: kSortie,
      builder: (context, v, enfant) => Transform.scale(scale: 0.6 + 0.4 * v, child: Opacity(opacity: v, child: enfant)),
      child: Survol(
        onTap: onRetirer,
        builder: (context, survol) => SizedBox(
          width: 66,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AvatarDroplet(nom: contact.pseudo, couleur: contact.couleur, taille: 50),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: survol ? OuroColors.systemRed : OuroColors.systemGray,
                        shape: BoxShape.circle,
                        border: Border.all(color: OuroColors.secondarySystemGroupedBackground, width: 2),
                      ),
                      child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                contact.pseudo,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoutonRond extends StatelessWidget {
  const _BoutonRond({required this.icone, required this.onTap, this.aide});

  final IconData icone;
  final VoidCallback? onTap;
  final String? aide;

  @override
  Widget build(BuildContext context) {
    final bouton = Survol(
      onTap: onTap,
      builder: (context, survol) => AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: onTap == null ? OuroColors.systemGray3 : OuroColors.accentRempli,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: OuroColors.accent.withValues(alpha: survol ? 0.45 : 0.3),
              blurRadius: survol ? 22 : 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icone, color: OuroColors.texteSurAccent, size: 26),
      ),
    );
    return aide == null ? bouton : Tooltip(message: aide!, child: bouton);
  }
}

class _PanneauNomGroupe extends StatefulWidget {
  const _PanneauNomGroupe({required this.membres});

  final List<String> membres;

  @override
  State<_PanneauNomGroupe> createState() => _PanneauNomGroupeState();
}

class _PanneauNomGroupeState extends State<_PanneauNomGroupe> {
  final _nom = TextEditingController();
  final _description = TextEditingController();

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    super.dispose();
  }

  void _creer() {
    final nom = _nom.text.trim();
    if (nom.isEmpty) return;
    final d = context.lire.depot.creerGroupe(nom, widget.membres, description: _description.text.trim());
    context.lire.ui.cleGauche.currentState?.popUntil((r) => r.isFirst);
    ouvrirDiscussion(context, d.id);
  }

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    return ColoredBox(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EntetePanneau(titre: l.gcNewGroup, retour: () => Navigator.of(context).pop()),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  children: [
                    Center(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _nom,
                        builder: (context, v, _) => AvatarDroplet(
                          nom: v.text.isEmpty ? '' : v.text,
                          couleur: widget.membres.length,
                          taille: 96,
                          groupe: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(l.gcGroupName.toUpperCase(), style: OuroTypography.sectionHeader.copyWith(color: OuroColors.secondaryLabel)),
                    const SizedBox(height: 6),
                    ChampTexte(
                      controleur: _nom,
                      indication: l.gcNameHint,
                      autofocus: true,
                      longueurMax: 60,
                      onSubmitted: (_) => _creer(),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    Text(l.giDescription.toUpperCase(), style: OuroTypography.sectionHeader.copyWith(color: OuroColors.secondaryLabel)),
                    const SizedBox(height: 6),
                    ChampTexte(controleur: _description, indication: l.giDescriptionHint, lignesMax: 4, longueurMax: 300),
                    const SizedBox(height: 20),
                    Text(
                      '${l.gcMembers.toUpperCase()} · ${widget.membres.length + 1}',
                      style: OuroTypography.sectionHeader.copyWith(color: OuroColors.secondaryLabel),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final id in widget.membres)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AvatarDroplet(nom: depot.nom(id), couleur: depot.contacts[id]?.couleur ?? 0, taille: 46),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 56,
                                child: Text(
                                  depot.nom(id),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 24,
            child: _BoutonRond(
              icone: Icons.check_rounded,
              aide: l.gcCreateGroup,
              onTap: _nom.text.trim().isEmpty ? null : _creer,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Archives ───────────────────────────────────────────────────────────

class PanneauArchives extends StatelessWidget {
  const PanneauArchives({super.key});

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final archivees = depot.discussionsTriees(archivees: true);
    return ColoredBox(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntetePanneau(titre: l.chatsArchivedTitle, retour: () => Navigator.of(context).pop()),
          Expanded(
            child: archivees.isEmpty
                ? EtatVide(icone: Icons.archive_outlined, titre: l.chatsNoArchived, texte: context.t.archivesNote)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Text(
                          context.t.archivesNote,
                          style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
                        ),
                      ),
                      for (final d in archivees) LigneDiscussion(key: ValueKey(d.id), discussion: d),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
