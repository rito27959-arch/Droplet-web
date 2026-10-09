// LES MESSAGES IMPORTANTS — ce qu'on a mis de côté, toutes discussions
// confondues. Un clic ramène au message, dans sa discussion, et le fait
// clignoter.
import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/modeles.dart';
import 'apercu.dart';
import 'composants.dart';
import 'coquille.dart';
import 'formats.dart';
import 'portee.dart';

class PanneauImportants extends StatefulWidget {
  const PanneauImportants({super.key, this.discussionId});

  /// Limiter aux messages d'une discussion (depuis le panneau d'infos).
  final String? discussionId;

  @override
  State<PanneauImportants> createState() => _PanneauImportantsState();
}

class _PanneauImportantsState extends State<PanneauImportants> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final messages = depot
        .importants()
        .where((m) => widget.discussionId == null || m.discussionId == widget.discussionId)
        .where((m) => _q.isEmpty || m.texte.toLowerCase().contains(_q))
        .toList();
    return ColoredBox(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntetePanneau(titre: l.imTitle, sousTitre: l.imSubtitle, retour: () => Navigator.of(context).pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: ChampRecherche(indication: l.imSearch, onChanged: (v) => setState(() => _q = v.trim().toLowerCase())),
          ),
          Expanded(
            child: messages.isEmpty
                ? EtatVide(icone: Icons.star_outline_rounded, titre: l.imTitle, texte: l.imEmptyBody)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                    itemCount: messages.length,
                    itemBuilder: (context, i) => _CarteImportant(message: messages[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CarteImportant extends StatelessWidget {
  const _CarteImportant({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final m = message;
    final d = depot.discussions[m.discussionId];
    if (d == null) return const SizedBox.shrink();
    final auteur = depot.nom(m.auteurId);
    void menu(Offset p) => montrerMenu(
          context,
          position: p,
          elements: [
            ElementMenu(
              icone: Icons.chat_bubble_outline_rounded,
              libelle: context.t.voirDansDiscussion,
              onTap: () => ouvrirDiscussion(context, d.id, message: m.id),
            ),
            ElementMenu(
              icone: Icons.star_border_rounded,
              libelle: context.l.imRemove,
              destructif: true,
              onTap: () => depot.marquerImportant(m),
            ),
          ],
        );
    return Survol(
      onTap: () => ouvrirDiscussion(context, d.id, message: m.id),
      onClicDroit: menu,
      builder: (context, survol) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: survol ? OuroColors.tertiarySystemFill : OuroColors.quaternarySystemFill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarDroplet(nom: auteur, couleur: depot.contacts[m.auteurId]?.couleur ?? depot.profil.couleur, photo: m.deMoi ? depot.profil.photo : null, taille: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: auteur, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (d.estGroupe || m.deMoi) ...[
                        const TextSpan(text: '  ›  '),
                        TextSpan(text: d.titre),
                      ],
                    ]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.footnote.copyWith(color: OuroColors.label),
                  ),
                ),
                Text(dateListe(context, m.date), style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel)),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: m.deMoi ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: m.deMoi ? OuroColors.bubbleOutgoing : OuroColors.bubbleIncoming,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (iconeMessage(m) != null) ...[
                      Icon(iconeMessage(m), size: 15, color: m.deMoi ? OuroColors.bubbleOutgoingText : OuroColors.secondaryLabel),
                      const SizedBox(width: 5),
                    ],
                    Flexible(
                      child: Text(
                        texteMessage(context, m),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.subheadline.copyWith(
                          color: m.deMoi ? OuroColors.bubbleOutgoingText : OuroColors.bubbleIncomingText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.star_rounded, size: 13, color: m.deMoi ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.8) : OuroColors.systemYellow),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
