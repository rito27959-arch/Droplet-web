// LA BULLE — un message, avec tout ce que l'app sait y mettre.
//
//   • Mes bulles dans la couleur d'accent, celles des autres en gris
//     système ; la petite queue sur la dernière bulle d'une série ; dans un
//     groupe, le nom de l'auteur (dans sa couleur) en tête de série et son
//     avatar en fin de série.
//   • Une citation quand le message répond à un autre (un clic y ramène),
//     « Transféré », l'heure, « modifié », l'étoile des importants, la
//     minuterie des éphémères et les coches, en bas à droite.
//   • Photo (un clic l'ouvre en grand), fichier (un clic le télécharge),
//     vocal (lecture, onde, vitesse 1× 1,5× 2×).
//   • Les réactions en pastilles sous la bulle.
//   • 1 à 3 émojis seuls : en grand, sans bulle, comme iMessage.
//
// À la souris : au survol, un bouton « réagir » et un chevron apparaissent
// à côté de la bulle ; le clic droit soulève la bulle et ouvre le menu de
// l'app (le même composant que sur iPhone).
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../design_system/reglages_apparence.dart';
import '../donnees/depot.dart';
import '../donnees/modeles.dart';
import '../web/navigateur.dart';
import 'apercu.dart';
import 'composants.dart';
import 'formats.dart';
import 'liste_discussions.dart' show Coches;
import 'portee.dart';
import 'texte_riche.dart';

class Bulle extends StatefulWidget {
  const Bulle({
    super.key,
    required this.message,
    required this.discussion,
    required this.cle,
    required this.debutSerie,
    required this.finSerie,
    required this.largeurMax,
    required this.onMenu,
    required this.onReagir,
    required this.onAllerA,
    required this.onVoirImage,
    this.surligne,
    this.clignote = false,
    this.nouveau = false,
  });

  final Message message;
  final Discussion discussion;

  /// L'ancre du menu contextuel : posée sur le corps de la bulle.
  final GlobalKey cle;
  final bool debutSerie;
  final bool finSerie;
  final double largeurMax;
  final VoidCallback onMenu;

  /// Ouvre la barre de réactions, près de [position].
  final ValueChanged<Offset> onReagir;
  final ValueChanged<String> onAllerA;
  final ValueChanged<Message> onVoirImage;
  final String? surligne;
  final bool clignote;
  final bool nouveau;

  @override
  State<Bulle> createState() => _BulleState();
}

class _BulleState extends State<Bulle> {
  bool _survol = false;
  final _boutonReaction = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final m = widget.message;
    final d = widget.discussion;
    final moi = m.deMoi;
    final avatarGroupe = d.estGroupe && !moi;

    final corps = KeyedSubtree(
      key: widget.cle,
      child: CorpsBulle(
        message: m,
        discussion: d,
        finSerie: widget.finSerie,
        debutSerie: widget.debutSerie,
        largeurMax: widget.largeurMax,
        surligne: widget.surligne,
        onAllerA: widget.onAllerA,
        onVoirImage: widget.onVoirImage,
      ),
    );

    final reactions = m.reactions.entries.where((e) => e.value.isNotEmpty).toList();
    final avecReactions = reactions.isNotEmpty && !m.supprime;

    Widget bulle = Column(
      crossAxisAlignment: moi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        corps,
        if (avecReactions)
          Transform.translate(
            offset: const Offset(0, -6),
            child: Padding(
              padding: EdgeInsets.only(left: moi ? 0 : 10 + FormeBulle.debord, right: moi ? 10 + FormeBulle.debord : 0),
              child: _Reactions(message: m, reactions: reactions),
            ),
          ),
      ],
    );

    // Les boutons du survol, du côté libre de la bulle.
    final boutons = AnimatedOpacity(
      opacity: _survol && !m.supprime ? 1 : 0,
      duration: const Duration(milliseconds: 140),
      child: IgnorePointer(
        ignoring: !_survol || m.supprime,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (moi)
                BoutonIcone(
                  icone: Icons.more_horiz_rounded,
                  diametre: 30,
                  taille: 18,
                  aide: context.t.plus,
                  onTap: widget.onMenu,
                ),
              BoutonIcone(
                key: _boutonReaction,
                icone: Icons.add_reaction_outlined,
                diametre: 30,
                taille: 18,
                aide: context.t.reagir,
                onTap: () {
                  final box = _boutonReaction.currentContext!.findRenderObject() as RenderBox;
                  widget.onReagir(box.localToGlobal(box.size.center(Offset.zero)));
                },
              ),
              if (!moi)
                BoutonIcone(
                  icone: Icons.more_horiz_rounded,
                  diametre: 30,
                  taille: 18,
                  aide: context.t.plus,
                  onTap: widget.onMenu,
                ),
            ],
          ),
        ),
      ),
    );

    Widget ligne = Row(
      mainAxisAlignment: moi ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (avatarGroupe)
          SizedBox(
            width: 38,
            child: widget.finSerie
                ? Padding(
                    padding: EdgeInsets.only(bottom: avecReactions ? 18 : 2),
                    child: AvatarDroplet(personne: m.auteurId, 
                      nom: depot.nom(m.auteurId),
                      couleur: depot.contacts[m.auteurId]?.couleur ?? 0,
                      taille: 30,
                    ),
                  )
                : null,
          ),
        if (moi) boutons,
        Flexible(child: bulle),
        if (!moi) boutons,
      ],
    );

    ligne = MouseRegion(
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onSecondaryTapUp: m.supprime ? null : (_) => widget.onMenu(),
        onLongPress: m.supprime ? null : widget.onMenu,
        onDoubleTap: m.supprime
            ? null
            : () {
                final box = widget.cle.currentContext?.findRenderObject() as RenderBox?;
                if (box != null) widget.onReagir(box.localToGlobal(box.size.topCenter(Offset.zero)));
              },
        child: ligne,
      ),
    );

    // Le clignotement d'un message retrouvé : un voile de la couleur
    // d'accent qui s'estompe.
    ligne = TweenAnimationBuilder<double>(
      key: ValueKey(widget.clignote),
      tween: Tween(begin: widget.clignote ? 1 : 0, end: 0),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeInQuad,
      builder: (context, v, enfant) => DecoratedBox(
        decoration: BoxDecoration(
          color: OuroColors.accent.withValues(alpha: 0.16 * v),
          borderRadius: BorderRadius.circular(12),
        ),
        child: enfant,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.finSerie ? 9 : 2, top: 0.5),
        child: ligne,
      ),
    );

    if (!widget.nouveau) return ligne;
    // L'arrivée d'un nouveau message. Envoyé : il jaillit de la barre de
    // saisie avec un léger rebond, comme dans Messages. Reçu : il glisse
    // depuis son côté et s'éclaircit, sans rebond (on ne l'a pas lancé).
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: moi ? 520 : 420),
      curve: Curves.linear,
      builder: (context, t, enfant) {
        final v = (moi ? _rebond : kSortie).transform(t);
        final o = Curves.easeOut.transform((t * 2.2).clamp(0.0, 1.0));
        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: moi ? Offset(0, 26 * (1 - v)) : Offset(-10 * (1 - v), 10 * (1 - v)),
            child: Transform.scale(
              scale: moi ? 0.86 + 0.14 * v : 0.96 + 0.04 * v,
              alignment: moi ? Alignment.bottomRight : Alignment.bottomLeft,
              child: enfant,
            ),
          ),
        );
      },
      child: ligne,
    );
  }
}

/// Un ressort amorti : dépasse d'environ 4 % puis se pose.
const Curve _rebond = Cubic(0.34, 1.32, 0.64, 1);

/// Le corps de la bulle, sans les boutons de survol : c'est aussi la copie
/// que le menu contextuel soulève.
class CorpsBulle extends StatelessWidget {
  const CorpsBulle({
    super.key,
    required this.message,
    required this.discussion,
    required this.finSerie,
    required this.debutSerie,
    required this.largeurMax,
    this.surligne,
    this.onAllerA,
    this.onVoirImage,
  });

  final Message message;
  final Discussion discussion;
  final bool finSerie;
  final bool debutSerie;
  final double largeurMax;
  final String? surligne;
  final ValueChanged<String>? onAllerA;
  final ValueChanged<Message>? onVoirImage;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final m = message;
    final moi = m.deMoi;
    // Sur un fond teinté ou dessiné, en clair : les bulles reçues sont
    // blanches et posées d'une ombre d'un pixel (WhatsApp, Telegram). Le
    // gris de Messages n'est fait que pour un fond blanc uni.
    final blanches = !OuroColors.isDark && fondsDiscussion[depot.reglages.fond % fondsDiscussion.length].bullesBlanches;
    final fond = moi ? OuroColors.bubbleOutgoing : (blanches ? Colors.white : OuroColors.bubbleIncoming);
    final encre = moi ? OuroColors.bubbleOutgoingText : OuroColors.bubbleIncomingText;
    final discret = moi ? encre.withValues(alpha: 0.72) : OuroColors.secondaryLabel;
    final taille = ReglagesApparence.tailleTexte;
    final styleTexte = OuroTypography.body.copyWith(color: encre, fontSize: taille, height: ReglagesApparence.interligne);

    // La forme de Messages : des bulles bien rondes, et la QUEUE — une
    // vraie, dessinée — sur la dernière bulle d'une série. Chaque bulle
    // garde la place de la queue de son côté, pour que toutes s'alignent.
    final forme = FormeBulle(moi: moi, queue: finSerie, rayon: ReglagesApparence.rayonBulles);
    final arrondi = BorderRadius.circular(ReglagesApparence.rayonBulles);
    final cote = EdgeInsets.only(left: moi ? 0 : FormeBulle.debord, right: moi ? FormeBulle.debord : 0);
    // Mes bulles : l'accent vif en haut, plus profond vers le bas — la
    // lumière vient d'en haut, comme sur iPhone (voir `bubbleOutgoingTop`
    // pour le contraste).
    final peinture = ShapeDecoration(
      shape: forme,
      color: moi ? null : fond,
      shadows: blanches && !moi ? const [BoxShadow(color: Color(0x1F000000), blurRadius: 1, offset: Offset(0, 1))] : null,
      gradient: moi
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [OuroColors.bubbleOutgoingTop, fond],
            )
          : null,
    );

    final meta = _Meta(message: m, couleur: discret, surImage: false);

    // ── Message supprimé
    if (m.supprime) {
      return Container(
        constraints: BoxConstraints(maxWidth: largeurMax),
        margin: cote,
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 7),
        decoration: BoxDecoration(
          borderRadius: arrondi,
          border: Border.all(color: OuroColors.separator),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block_rounded, size: 15, color: OuroColors.tertiaryLabel),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                texteMessage(context, m),
                style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(width: 8),
            Text(heure(context, m.date), style: OuroTypography.caption2.copyWith(color: OuroColors.tertiaryLabel)),
          ],
        ),
      );
    }

    // ── Émojis seuls : en grand, sans bulle
    if (m.type == TypeMessage.texte && m.reponseA == null && !m.transfere && seulementEmojis(m.texte)) {
      return Column(
        crossAxisAlignment: moi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: cote, child: Text(m.texte.trim(), style: styleEmojis(m.texte))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6) + cote,
            child: _Meta(message: m, couleur: OuroColors.secondaryLabel, surImage: false),
          ),
        ],
      );
    }

    final enTete = <Widget>[
      if (discussion.estGroupe && !moi && debutSerie)
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            depot.nom(m.auteurId),
            style: OuroTypography.footnote.copyWith(
              color: palettesAvatar[(depot.contacts[m.auteurId]?.couleur ?? 0) % palettesAvatar.length][1],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      if (m.transfere)
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shortcut_rounded, size: 14, color: discret),
              const SizedBox(width: 4),
              Text(l.chForwarded, style: OuroTypography.caption1.copyWith(color: discret, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      if (m.reponseA != null)
        _Citation(
          id: m.reponseA!,
          moi: moi,
          onTap: onAllerA == null ? null : () => onAllerA!(m.reponseA!),
        ),
    ];

    Widget contenu;
    switch (m.type) {
      case TypeMessage.image:
        final p = m.piece;
        final ratio = (p?.largeur != null && p?.hauteur != null && p!.hauteur! > 0) ? p.largeur! / p.hauteur! : 4 / 3;
        final largeurImage = (largeurMax < 340 ? largeurMax : 340.0) - 8;
        final hauteurImage = (largeurImage / ratio).clamp(120.0, 420.0);
        contenu = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (enTete.isNotEmpty)
              Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: enTete)),
            Survol(
              onTap: onVoirImage == null ? null : () => onVoirImage!(m),
              curseur: SystemMouseCursors.zoomIn,
              builder: (context, survol) => ClipRRect(
                borderRadius: BorderRadius.circular((ReglagesApparence.rayonBulles - 4).clamp(4, 20).toDouble()),
                child: Stack(
                  children: [
                    SizedBox(
                      width: largeurImage,
                      height: hauteurImage,
                      child: p == null || p.url.isEmpty
                          ? _Attente(message: m)
                          : TweenAnimationBuilder<double>(
                              // La photo apparaît en fondu quand elle arrive du téléphone.
                              tween: Tween(begin: p.distant ? 0 : 1, end: 1),
                              duration: const Duration(milliseconds: 280),
                              builder: (context, v, enfant) => Opacity(opacity: v, child: enfant),
                              child: Image.network(p.url, fit: BoxFit.cover, gaplessPlayback: true),
                            ),
                    ),
                    Positioned.fill(
                      child: AnimatedOpacity(
                        opacity: survol ? 1 : 0,
                        duration: const Duration(milliseconds: 160),
                        child: const ColoredBox(color: Color(0x14000000)),
                      ),
                    ),
                    if (m.texte.isEmpty)
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.42), borderRadius: BorderRadius.circular(10)),
                          child: _Meta(message: m, couleur: Colors.white, surImage: true),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (m.texte.isNotEmpty)
              SizedBox(
                width: largeurImage,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 6, 2),
                  child: _TexteAvecMeta(texte: m.texte, style: styleTexte, meta: meta, message: m, surligne: surligne),
                ),
              ),
          ],
        );
        return Container(
          padding: const EdgeInsets.all(4) + cote,
          decoration: peinture,
          child: contenu,
        );
      case TypeMessage.fichier when m.piece?.estVideo ?? false:
        // Une vidéo : le lecteur du navigateur, dans la bulle.
        final largeurVideo = (largeurMax < 340 ? largeurMax : 340.0) - 8;
        return Container(
          padding: const EdgeInsets.all(4) + cote,
          decoration: peinture,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (enTete.isNotEmpty)
                Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 4), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: enTete)),
              ClipRRect(
                borderRadius: BorderRadius.circular((ReglagesApparence.rayonBulles - 4).clamp(4, 20).toDouble()),
                child: SizedBox(
                  width: largeurVideo,
                  height: largeurVideo * 9 / 16,
                  child: m.piece!.url.isEmpty ? _Attente(message: m, icone: Icons.play_circle_fill_rounded) : LecteurVideo(url: m.piece!.url),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 6, 2),
                child: SizedBox(
                  width: largeurVideo - 14,
                  child: m.texte.isEmpty
                      ? Align(alignment: Alignment.centerRight, child: meta)
                      : _TexteAvecMeta(texte: m.texte, style: styleTexte, meta: meta, message: m, surligne: surligne),
                ),
              ),
            ],
          ),
        );
      case TypeMessage.fichier:
        contenu = _Fichier(message: m, encre: encre, discret: discret, meta: meta);
      case TypeMessage.vocal:
        contenu = _Vocal(message: m, encre: encre, discret: discret, meta: meta);
      default:
        contenu = _TexteAvecMeta(texte: m.texte, style: styleTexte, meta: meta, message: m, surligne: surligne);
    }

    return Container(
      constraints: BoxConstraints(maxWidth: largeurMax + FormeBulle.debord),
      padding: const EdgeInsets.fromLTRB(13, 8, 12, 7) + cote,
      decoration: peinture,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [...enTete, contenu],
      ),
    );
  }
}

/// Le texte, avec l'heure et les coches calées en bas à droite : un
/// espace invisible de la largeur de la ligne d'infos est ajouté à la fin
/// du texte, et la ligne est posée par-dessus. Le texte s'enroule autour,
/// comme dans iMessage et WhatsApp.
class _TexteAvecMeta extends StatelessWidget {
  const _TexteAvecMeta({required this.texte, required this.style, required this.meta, required this.message, this.surligne});

  final String texte;
  final TextStyle style;
  final Widget meta;
  final Message message;
  final String? surligne;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final l = context.l;
    var largeur = 36.0;
    if (m.deMoi) largeur += 19;
    if (m.modifie) largeur += l.chEditedBadge.length * 6.2 + 6;
    if (m.important) largeur += 15;
    if (m.expireLe != null) largeur += 15;
    final couleurLien = m.deMoi ? OuroColors.bubbleOutgoingText : OuroColors.accent;
    return Stack(
      children: [
        Text.rich(
          TextSpan(children: [
            ...texteRiche(texte, style: style, couleurLien: couleurLien, surligne: surligne),
            WidgetSpan(child: SizedBox(width: largeur + 6, height: 10)),
          ]),
        ),
        Positioned(right: 0, bottom: 0, child: meta),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.message, required this.couleur, required this.surImage});

  final Message message;
  final Color couleur;
  final bool surImage;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final style = OuroTypography.caption2.copyWith(color: couleur, height: 1.1);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (m.important) ...[
          Icon(Icons.star_rounded, size: 12, color: couleur),
          const SizedBox(width: 3),
        ],
        if (m.expireLe != null) ...[
          Icon(Icons.timer_outlined, size: 12, color: couleur),
          const SizedBox(width: 3),
        ],
        if (m.modifie) ...[
          Text(context.l.chEditedBadge, style: style),
          const SizedBox(width: 4),
        ],
        Text(heure(context, m.date), style: style),
        if (m.deMoi) ...[
          const SizedBox(width: 3),
          Coches(statut: m.statut, taille: 15, couleur: surImage ? Colors.white : couleur),
        ],
      ],
    );
  }
}

/// La citation d'un message auquel on répond.
class _Citation extends StatelessWidget {
  const _Citation({required this.id, required this.moi, this.onTap});

  final String id;
  final bool moi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final cite = depot.message(id);
    final encre = moi ? OuroColors.bubbleOutgoingText : OuroColors.label;
    final barre = moi
        ? OuroColors.bubbleOutgoingText
        : palettesAvatar[(depot.contacts[cite?.auteurId]?.couleur ?? 0) % palettesAvatar.length][1];
    final fond = moi ? Colors.black.withValues(alpha: 0.12) : OuroColors.label.withValues(alpha: 0.06);
    final auteur = cite == null ? '' : (cite.deMoi ? context.t.vous : depot.nom(cite.auteurId));
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 2),
      child: Survol(
        onTap: onTap,
        builder: (context, survol) => Container(
          decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(9)),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3.5, color: barre),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(9, 5, 10, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(auteur, style: OuroTypography.footnote.copyWith(color: barre, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 1),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (cite != null && iconeMessage(cite) != null) ...[
                              Icon(iconeMessage(cite), size: 14, color: encre.withValues(alpha: 0.7)),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                cite == null ? context.t.messageIntrouvable : texteMessage(context, cite),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: OuroTypography.footnote.copyWith(color: encre.withValues(alpha: 0.78)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (cite?.type == TypeMessage.image && cite?.piece != null && cite!.piece!.url.isNotEmpty)
                  SizedBox(width: 46, child: Image.network(cite.piece!.url, fit: BoxFit.cover)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Fichier extends StatelessWidget {
  const _Fichier({required this.message, required this.encre, required this.discret, required this.meta});

  final Message message;
  final Color encre;
  final Color discret;
  final Widget meta;

  @override
  Widget build(BuildContext context) {
    final p = message.piece;
    final ext = extension(p?.nom ?? '');
    final couleurExt = switch (ext) {
      'PDF' => const Color(0xFFFF3B30),
      'DOC' || 'DOCX' => const Color(0xFF0A84FF),
      'XLS' || 'XLSX' || 'CSV' => const Color(0xFF30D158),
      'PPT' || 'PPTX' => const Color(0xFFFF9F0A),
      'ZIP' || 'RAR' || '7Z' => const Color(0xFF8E8E93),
      _ => OuroColors.systemIndigo,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Survol(
          onTap: p == null
              ? null
              : p.url.isNotEmpty
                  ? () => Navigateur.telecharger(p)
                  : (p.distant ? () => context.depot.charger(message) : null),
          builder: (context, survol) => AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 270,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (message.deMoi ? Colors.black : OuroColors.label).withValues(alpha: survol ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 46,
                  decoration: BoxDecoration(color: couleurExt, borderRadius: BorderRadius.circular(7)),
                  alignment: Alignment.center,
                  child: Text(
                    ext.isEmpty ? '?' : (ext.length > 4 ? ext.substring(0, 4) : ext),
                    style: OuroTypography.caption2.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p?.nom ?? context.l.chatsDocument,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.subheadline.copyWith(color: encre, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p == null ? '' : '${taille(context, p.taille)}${ext.isEmpty ? '' : ' · $ext'}',
                        style: OuroTypography.caption1.copyWith(color: discret),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: discret, width: 1.4)),
                  child: context.depot.enChargement(message)
                      ? Padding(padding: const EdgeInsets.all(7), child: CircularProgressIndicator(strokeWidth: 1.6, color: discret))
                      : Icon(p != null && p.url.isNotEmpty ? Icons.arrow_downward_rounded : Icons.cloud_download_outlined, size: 17, color: discret),
                ),
              ],
            ),
          ),
        ),
        if (message.texte.isNotEmpty)
          SizedBox(
            width: 270,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(message.texte, style: OuroTypography.body.copyWith(color: encre, fontSize: ReglagesApparence.tailleTexte)),
            ),
          ),
        const SizedBox(height: 4),
        meta,
      ],
    );
  }
}

class _Vocal extends StatefulWidget {
  const _Vocal({required this.message, required this.encre, required this.discret, required this.meta});

  final Message message;
  final Color encre;
  final Color discret;
  final Widget meta;

  @override
  State<_Vocal> createState() => _VocalState();
}

class _VocalState extends State<_Vocal> {
  Lecteur? _lecteur;
  double _vitesse = 1;

  Lecteur get _l {
    final url = widget.message.piece?.url ?? '';
    return _lecteur ??= Lecteur(url);
  }

  @override
  void dispose() {
    _lecteur?.liberer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.message.piece;
    final onde = (p?.onde.isNotEmpty ?? false) ? p!.onde : List.filled(40, 0.25);
    final duree = Duration(milliseconds: p?.dureeMs ?? 0);
    final disponible = p != null && p.url.isNotEmpty;
    if (p != null && p.distant && p.url.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.depot.charger(widget.message);
      });
    }
    final lecteur = _lecteur;
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          Survol(
            onTap: disponible
                ? () => setState(() {
                      _l.basculer();
                    })
                : null,
            builder: (context, survol) => Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.message.deMoi ? widget.encre.withValues(alpha: survol ? 0.32 : 0.22) : OuroColors.accent.withValues(alpha: survol ? 0.9 : 1),
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: lecteur?.enCours ?? ValueNotifier(false),
                builder: (context, enCours, _) => Icon(
                  enCours ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: widget.message.deMoi ? widget.encre : OuroColors.texteSurAccent,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 30,
                  child: ValueListenableBuilder<double>(
                    valueListenable: lecteur?.position ?? ValueNotifier(0),
                    builder: (context, pos, _) => LayoutBuilder(
                      builder: (context, c) => GestureDetector(
                        onTapDown: disponible ? (d) => _l.aller((d.localPosition.dx / c.maxWidth).clamp(0, 1)) : null,
                        child: CustomPaint(
                          size: Size(c.maxWidth, 30),
                          painter: PeintreOnde(
                            onde: onde,
                            progres: pos,
                            actif: widget.message.deMoi ? widget.encre : OuroColors.accent,
                            inactif: widget.discret.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(chrono(duree), style: OuroTypography.caption2.copyWith(color: widget.discret)),
                    const Spacer(),
                    widget.meta,
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Survol(
            onTap: disponible
                ? () => setState(() {
                      _vitesse = _vitesse == 1 ? 1.5 : (_vitesse == 1.5 ? 2 : 1);
                      _l.vitesse = _vitesse;
                    })
                : null,
            builder: (context, survol) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: widget.discret.withValues(alpha: survol ? 0.3 : 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_vitesse == 1.5 ? '1,5' : _vitesse.toStringAsFixed(0)}×',
                style: OuroTypography.caption2.copyWith(color: widget.encre, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Les barres d'un vocal : remplies jusqu'à la position de lecture.
class PeintreOnde extends CustomPainter {
  PeintreOnde({required this.onde, required this.progres, required this.actif, required this.inactif});

  final List<double> onde;
  final double progres;
  final Color actif;
  final Color inactif;

  @override
  void paint(Canvas canvas, Size size) {
    if (onde.isEmpty) return;
    final pas = size.width / onde.length;
    final largeur = (pas * 0.55).clamp(1.5, 3.5);
    final p = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = largeur;
    for (var i = 0; i < onde.length; i++) {
      final x = i * pas + pas / 2;
      final h = (onde[i].clamp(0.06, 1.0)) * (size.height - 4);
      p.color = (i / onde.length) <= progres ? actif : inactif;
      canvas.drawLine(Offset(x, size.height / 2 - h / 2), Offset(x, size.height / 2 + h / 2), p);
    }
  }

  @override
  bool shouldRepaint(PeintreOnde ancien) => ancien.progres != progres || ancien.onde != onde || ancien.actif != actif;
}

class _Reactions extends StatelessWidget {
  const _Reactions({required this.message, required this.reactions});

  final Message message;
  final List<MapEntry<String, List<String>>> reactions;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final e in reactions)
          Tooltip(
            message: e.value.map((id) => id == kMoi ? context.t.vous : depot.nom(id)).join(', '),
            child: Survol(
              onTap: () => depot.reagir(message, e.key),
              builder: (context, survol) {
                final mienne = e.value.contains(kMoi);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: mienne
                        ? Color.alphaBlend(OuroColors.accent.withValues(alpha: 0.18), OuroColors.secondarySystemGroupedBackground)
                        : OuroColors.secondarySystemGroupedBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: mienne ? OuroColors.accent.withValues(alpha: 0.5) : OuroColors.systemBackground,
                      width: 1.6,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: survol ? 0.16 : 0.08), blurRadius: 6, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.key, style: const TextStyle(fontSize: 14, height: 1.1)),
                      if (e.value.length > 1) ...[
                        const SizedBox(width: 3),
                        Text(
                          '${e.value.length}',
                          style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}


/// Le contenu arrive du téléphone : une surface qui respire doucement, et
/// la demande part dès que la bulle s'affiche.
class _Attente extends StatefulWidget {
  const _Attente({required this.message, this.icone = Icons.photo_outlined});

  final Message message;
  final IconData icone;

  @override
  State<_Attente> createState() => _AttenteState();
}

class _AttenteState extends State<_Attente> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Les photos et les vidéos courtes se chargent seules ; au-delà de
      // 8 Mo, on attend le clic.
      final p = widget.message.piece;
      if (mounted && p != null && p.distant && p.taille <= 8 * 1024 * 1024) context.depot.charger(widget.message);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.message.piece;
    final enCours = context.depot.enChargement(widget.message);
    return Survol(
      onTap: p != null && p.distant && !enCours ? () => context.depot.charger(widget.message) : null,
      builder: (context, survol) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => ColoredBox(
          color: Color.lerp(OuroColors.tertiarySystemFill, OuroColors.secondarySystemFill, enCours ? _c.value : 0)!,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(p != null && p.distant ? widget.icone : Icons.image_not_supported_outlined, color: OuroColors.tertiaryLabel, size: 34),
                if (p != null && p.distant) ...[
                  const SizedBox(height: 6),
                  Text(
                    enCours ? '…' : taille(context, p.taille),
                    style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/// La bulle de Messages : un rectangle très arrondi et, en fin de série,
/// la queue qui s'échappe du coin inférieur, du côté de l'auteur.
///
/// La forme réserve [debord] points de son côté pour la queue, qu'elle
/// soit dessinée ou non : toutes les bulles d'une série restent alignées.
class FormeBulle extends ShapeBorder {
  const FormeBulle({required this.moi, required this.queue, required this.rayon});

  final bool moi;
  final bool queue;
  final double rayon;

  static const double debord = 6;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final corps = moi
        ? Rect.fromLTRB(rect.left, rect.top, rect.right - debord, rect.bottom)
        : Rect.fromLTRB(rect.left + debord, rect.top, rect.right, rect.bottom);
    final r = math.min(rayon, corps.shortestSide / 2);
    final bulle = Path()..addRRect(RRect.fromRectAndRadius(corps, Radius.circular(r)));
    // Une queue n'a de sens que sur une bulle arrondie.
    if (!queue || rayon < 8) return bulle;
    final b = corps.bottom;
    final h = math.min(16.0, corps.height * 0.6);
    final Path q;
    if (moi) {
      final x = corps.right;
      q = Path()
        ..moveTo(x - 1, b - h)
        ..quadraticBezierTo(x, b - 3, x + debord, b)
        ..quadraticBezierTo(x - 3, b + 0.5, x - 13, b - 3.5)
        ..lineTo(x - 13, b - h)
        ..close();
    } else {
      final x = corps.left;
      q = Path()
        ..moveTo(x + 1, b - h)
        ..quadraticBezierTo(x, b - 3, x - debord, b)
        ..quadraticBezierTo(x + 3, b + 0.5, x + 13, b - 3.5)
        ..lineTo(x + 13, b - h)
        ..close();
    }
    return Path.combine(PathOperation.union, bulle, q);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => FormeBulle(moi: moi, queue: queue, rayon: rayon * t);

  @override
  bool operator ==(Object other) => other is FormeBulle && other.moi == moi && other.queue == queue && other.rayon == rayon;

  @override
  int get hashCode => Object.hash(moi, queue, rayon);
}
