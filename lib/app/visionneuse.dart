// LA VISIONNEUSE ET LE TRANSFERT.
//
//   • La visionneuse : une photo en grand sur fond noir flouté, zoom à la
//     molette ou au pincement, flèches (← →) pour passer aux autres photos
//     de la discussion, téléchargement, Échap pour fermer.
//   • Le transfert : choisir une ou plusieurs discussions, puis envoyer.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/modeles.dart';
import '../web/navigateur.dart';
import 'composants.dart';
import 'formats.dart';
import 'liste_discussions.dart' show CaseRonde;
import 'portee.dart';

Future<void> ouvrirVisionneuse(BuildContext context, Message depart) {
  final p = context.lire;
  final images = p.depot
      .messages(depart.discussionId)
      .where((m) => !m.supprime && m.type == TypeMessage.image && (m.piece?.url.isNotEmpty ?? false))
      .toList();
  final debut = images.indexWhere((m) => m.id == depart.id);
  return Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
    opaque: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => Portee(
      depot: p.depot,
      ui: p.ui,
      textes: p.textes,
      child: _Visionneuse(images: images, debut: debut < 0 ? 0 : debut),
    ),
    transitionsBuilder: (_, a, __, enfant) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(CurvedAnimation(parent: a, curve: kSortie)), child: enfant),
    ),
  ));
}

class _Visionneuse extends StatefulWidget {
  const _Visionneuse({required this.images, required this.debut});

  final List<Message> images;
  final int debut;

  @override
  State<_Visionneuse> createState() => _VisionneuseState();
}

class _VisionneuseState extends State<_Visionneuse> {
  late int _i = widget.debut;

  void _aller(int sens) {
    final j = _i + sens;
    if (j >= 0 && j < widget.images.length) setState(() => _i = j);
  }

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    if (widget.images.isEmpty) return const SizedBox.shrink();
    final m = widget.images[_i];
    final fermer = Navigator.of(context).pop;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): fermer,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _aller(-1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _aller(1),
      },
      child: Focus(
        autofocus: true,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: fermer,
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: const ColoredBox(color: Color(0xE6000000)),
                  ),
                ),
              ),
              Positioned.fill(
                top: 70,
                bottom: 30,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: InteractiveViewer(
                    key: ValueKey(m.id),
                    maxScale: 5,
                    child: Center(child: Image.network(m.piece!.url, fit: BoxFit.contain)),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      AvatarDroplet(
                        nom: depot.nom(m.auteurId),
                        couleur: m.deMoi ? depot.profil.couleur : depot.contacts[m.auteurId]?.couleur ?? 0,
                        photo: m.deMoi ? depot.profil.photo : null,
                        taille: 38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.deMoi ? context.t.vous : depot.nom(m.auteurId), style: OuroTypography.headline.copyWith(color: Colors.white)),
                            Text(dateComplete(context, m.date), style: OuroTypography.caption1.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ),
                      if (widget.images.length > 1)
                        Text('${_i + 1} / ${widget.images.length}', style: OuroTypography.subheadline.copyWith(color: Colors.white70)),
                      const SizedBox(width: 12),
                      BoutonIcone(
                        icone: Icons.file_download_outlined,
                        couleur: Colors.white,
                        aide: context.t.telechargerFichier,
                        onTap: () => Navigateur.telecharger(m.piece!),
                      ),
                      BoutonIcone(icone: Icons.close_rounded, couleur: Colors.white, aide: context.t.fermer, onTap: fermer),
                    ],
                  ),
                ),
              ),
              if (m.texte.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
                      child: Text(m.texte, textAlign: TextAlign.center, style: OuroTypography.body.copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              if (_i > 0)
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _Fleche(icone: Icons.chevron_left_rounded, onTap: () => _aller(-1))),
                ),
              if (_i < widget.images.length - 1)
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _Fleche(icone: Icons.chevron_right_rounded, onTap: () => _aller(1))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Fleche extends StatelessWidget {
  const _Fleche({required this.icone, required this.onTap});

  final IconData icone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Survol(
        onTap: onTap,
        builder: (context, survol) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: survol ? 0.24 : 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icone, color: Colors.white, size: 30),
        ),
      );
}

// ── Le transfert ───────────────────────────────────────────────────────

/// Choisir les discussions où transférer [message].
Future<void> transferer(BuildContext context, Message message) async {
  final p = context.lire;
  final choix = await showGeneralDialog<List<String>>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => Portee(depot: p.depot, ui: p.ui, textes: p.textes, child: const _ChoixDiscussions()),
    transitionBuilder: (_, a, __, enfant) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 1.06, end: 1.0).animate(CurvedAnimation(parent: a, curve: kSortie)), child: enfant),
    ),
  );
  if (choix == null || choix.isEmpty || !context.mounted) return;
  p.depot.transferer(message, [for (final id in choix) p.depot.discussions[id]!]);
  annoncer(context, choix.length == 1 ? context.l.chForwarded1 : context.l.shSendCount(choix.length), icone: Icons.shortcut_rounded);
}

class _ChoixDiscussions extends StatefulWidget {
  const _ChoixDiscussions();

  @override
  State<_ChoixDiscussions> createState() => _ChoixDiscussionsState();
}

class _ChoixDiscussionsState extends State<_ChoixDiscussions> {
  final List<String> _choisis = [];
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final liste = [...depot.discussionsTriees(), ...depot.discussionsTriees(archivees: true)]
        .where((d) => _q.isEmpty || d.titre.toLowerCase().contains(_q))
        .toList();
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: 420,
          height: 560,
          child: Verre(
            rayon: 18,
            opacite: OuroColors.isDark ? 0.9 : 0.94,
            flou: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(l.chForwardTo, style: OuroTypography.title3.copyWith(color: OuroColors.label))),
                      BoutonIcone(icone: Icons.close_rounded, onTap: () => Navigator.of(context).pop()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: ChampRecherche(
                    indication: l.shSearchConversation,
                    autofocus: true,
                    onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                  ),
                ),
                Expanded(
                  child: liste.isEmpty
                      ? EtatVide(icone: Icons.search_off_rounded, titre: l.shNoConversation)
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          children: [
                            for (final d in liste)
                              Survol(
                                onTap: () => setState(() => _choisis.contains(d.id) ? _choisis.remove(d.id) : _choisis.add(d.id)),
                                builder: (context, survol) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      CaseRonde(cochee: _choisis.contains(d.id)),
                                      const SizedBox(width: 12),
                                      AvatarDroplet(nom: d.titre, couleur: d.couleur, taille: 40, groupe: d.estGroupe),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(d.titre, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
                                      ),
                                      Text(
                                        d.estGroupe ? l.shGroup : l.shDiscussion,
                                        style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: OuroColors.separator, width: 0.5))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _choisis.map((id) => depot.discussions[id]?.titre ?? '').join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      BoutonPlein(
                        texte: _choisis.length > 1 ? l.shSendCount(_choisis.length) : l.shSend,
                        icone: Icons.send_rounded,
                        onTap: _choisis.isEmpty ? null : () => Navigator.of(context).pop(List.of(_choisis)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
