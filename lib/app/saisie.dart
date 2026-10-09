// LA BARRE DE SAISIE — en verre, au pied de la discussion.
//
//   [+]  [ 🙂  Message…                 ]  [🎤 / ➤]
//
//   • « + » : photos et vidéos, document — le sélecteur de fichiers du
//     système. On peut aussi glisser-déposer ou coller (Ctrl+V) une image.
//   • 🙂 : le sélecteur d'émojis.
//   • Entrée envoie, Maj+Entrée va à la ligne (réglable) ; ↑ dans un champ
//     vide modifie mon dernier message ; Échap annule une réponse ou une
//     modification.
//   • Le micro enregistre un vocal : point rouge qui bat, chrono, onde en
//     direct ; la corbeille annule, la flèche envoie.
//   • Au-dessus : la réponse en cours, ou le message qu'on modifie.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/depot.dart';
import '../donnees/modeles.dart';
import '../web/navigateur.dart';
import 'apercu.dart';
import 'composants.dart';
import 'emoji.dart';
import 'formats.dart';
import 'portee.dart';

class BarreSaisie extends StatefulWidget {
  const BarreSaisie({
    super.key,
    required this.discussion,
    required this.controleur,
    required this.focus,
    required this.onEnvoyer,
    required this.onPieces,
    required this.onVocal,
    required this.onAnnuler,
    required this.onModifierDernier,
    this.reponse,
    this.edition,
  });

  final Discussion discussion;
  final TextEditingController controleur;
  final FocusNode focus;

  /// Le texte à envoyer (ou la nouvelle version du message modifié).
  final ValueChanged<String> onEnvoyer;
  final ValueChanged<List<PieceJointe>> onPieces;
  final ValueChanged<PieceJointe> onVocal;

  /// Annuler la réponse ou la modification en cours.
  final VoidCallback onAnnuler;
  final VoidCallback onModifierDernier;
  final Message? reponse;
  final Message? edition;

  @override
  State<BarreSaisie> createState() => _BarreSaisieState();
}

class _BarreSaisieState extends State<BarreSaisie> {
  final _plus = GlobalKey();
  final _emoji = GlobalKey();
  Enregistreur? _enregistreur;
  Timer? _chrono;
  bool _demarrage = false;

  @override
  void initState() {
    super.initState();
    widget.focus.onKeyEvent = _touche;
  }

  @override
  void dispose() {
    _chrono?.cancel();
    _enregistreur?.arreter(annuler: true);
    super.dispose();
  }

  KeyEventResult _touche(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final clavier = HardwareKeyboard.instance;
    final entreeEnvoie = context.lire.depot.reglages.entreeEnvoie;
    if (e.logicalKey == LogicalKeyboardKey.enter || e.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final envoyer = entreeEnvoie ? !clavier.isShiftPressed : (clavier.isControlPressed || clavier.isMetaPressed);
      if (envoyer) {
        _envoyer();
        return KeyEventResult.handled;
      }
    }
    if (e.logicalKey == LogicalKeyboardKey.escape && (widget.reponse != null || widget.edition != null)) {
      widget.onAnnuler();
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.arrowUp && widget.controleur.text.isEmpty && widget.edition == null) {
      widget.onModifierDernier();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _envoyer() {
    final texte = widget.controleur.text.trim();
    if (texte.isEmpty) return;
    widget.onEnvoyer(texte);
  }

  void _inserer(String e) {
    final c = widget.controleur;
    final sel = c.selection;
    final debut = sel.isValid ? sel.start : c.text.length;
    final fin = sel.isValid ? sel.end : c.text.length;
    c.value = TextEditingValue(
      text: c.text.replaceRange(debut, fin, e),
      selection: TextSelection.collapsed(offset: debut + e.length),
    );
    widget.focus.requestFocus();
  }

  Future<void> _joindre() async {
    final box = _plus.currentContext!.findRenderObject() as RenderBox;
    final l = context.l;
    final t = context.t;
    await montrerMenu(
      context,
      position: box.localToGlobal(Offset(0, 0)),
      elements: [
        ElementMenu(
          icone: Icons.photo_library_outlined,
          libelle: t.photos,
          onTap: () async {
            final p = await Navigateur.choisirFichiers(accepter: 'image/*');
            if (p.isNotEmpty) widget.onPieces(p);
          },
        ),
        ElementMenu(
          icone: Icons.insert_drive_file_outlined,
          libelle: l.chatsDocument,
          onTap: () async {
            final p = await Navigateur.choisirFichiers();
            if (p.isNotEmpty) widget.onPieces(p);
          },
        ),
      ],
    );
  }

  Future<void> _demarrerVocal() async {
    if (_demarrage) return;
    setState(() => _demarrage = true);
    final e = await Navigateur.enregistrer();
    if (!mounted) return;
    setState(() {
      _demarrage = false;
      _enregistreur = e;
    });
    if (e == null) {
      annoncer(context, context.l.chMicPermissionDenied, icone: Icons.mic_off_rounded);
      return;
    }
    _chrono = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _finirVocal({required bool envoyer}) async {
    final e = _enregistreur;
    if (e == null) return;
    _chrono?.cancel();
    setState(() => _enregistreur = null);
    final piece = await e.arreter(annuler: !envoyer);
    if (piece != null) widget.onVocal(piece);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = context.t;
    final depot = context.depot;
    final d = widget.discussion;
    final contexte = widget.reponse ?? widget.edition;
    return Verre(
      bordHaut: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: kSortie,
            child: contexte == null
                ? const SizedBox(width: double.infinity)
                : _Contexte(message: contexte, edition: widget.edition != null, onFermer: widget.onAnnuler),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 12, 11),
            child: _enregistreur != null
                ? _Enregistrement(
                    enregistreur: _enregistreur!,
                    onAnnuler: () => _finirVocal(envoyer: false),
                    onEnvoyer: () => _finirVocal(envoyer: true),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.edition == null)
                        BoutonIcone(key: _plus, icone: Icons.add_rounded, taille: 26, aide: l.chAttachTooltip, couleur: OuroColors.accent, onTap: _joindre),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 40),
                          padding: const EdgeInsets.only(left: 4, right: 14),
                          decoration: BoxDecoration(
                            color: OuroColors.isDark ? OuroColors.tertiarySystemFill : OuroColors.systemBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: OuroColors.separator, width: 0.5),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              BoutonIcone(
                                key: _emoji,
                                icone: Icons.emoji_emotions_outlined,
                                diametre: 36,
                                aide: t.emojis,
                                onTap: () {
                                  final box = _emoji.currentContext!.findRenderObject() as RenderBox;
                                  choisirEmoji(context, position: box.localToGlobal(Offset.zero), onChoix: _inserer);
                                },
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 1),
                                  child: TextField(
                                    controller: widget.controleur,
                                    focusNode: widget.focus,
                                    autofocus: true,
                                    minLines: 1,
                                    maxLines: 8,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.newline,
                                    cursorColor: OuroColors.accent,
                                    style: OuroTypography.body.copyWith(color: OuroColors.label),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                      hintText: d.ephemereSecondes > 0 ? '${l.chMessageHint} · ${dureeEphemere(context, d.ephemereSecondes)}' : l.chMessageHint,
                                      hintStyle: OuroTypography.body.copyWith(color: OuroColors.tertiaryLabel),
                                    ),
                                    onChanged: (v) {
                                      depot.enregistrerBrouillon(d, v);
                                      depot.signalerFrappe(d);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Le bouton devient une flèche d'envoi dès qu'il y a
                      // du texte, comme dans l'app.
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: widget.controleur,
                        builder: (context, valeur, _) {
                          final plein = valeur.text.trim().isNotEmpty;
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (enfant, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: enfant)),
                            child: plein || widget.edition != null
                                ? _BoutonEnvoi(
                                    key: const ValueKey('envoi'),
                                    icone: widget.edition != null ? Icons.check_rounded : Icons.arrow_upward_rounded,
                                    actif: plein,
                                    aide: l.actionSend,
                                    onTap: _envoyer,
                                  )
                                : BoutonIcone(
                                    key: const ValueKey('micro'),
                                    icone: Icons.mic_none_rounded,
                                    taille: 25,
                                    diametre: 40,
                                    aide: t.vocal,
                                    couleur: _demarrage ? OuroColors.accent : null,
                                    onTap: _demarrerVocal,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _BoutonEnvoi extends StatelessWidget {
  const _BoutonEnvoi({super.key, required this.icone, required this.onTap, required this.actif, this.aide});

  final IconData icone;
  final VoidCallback onTap;
  final bool actif;
  final String? aide;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: aide ?? '',
      child: Survol(
        onTap: actif ? onTap : null,
        builder: (context, survol) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: actif ? OuroColors.accentRempli : OuroColors.systemGray3,
            shape: BoxShape.circle,
            boxShadow: actif && survol
                ? [BoxShadow(color: OuroColors.accent.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 4))]
                : null,
          ),
          child: Icon(icone, color: OuroColors.texteSurAccent, size: 22),
        ),
      ),
    );
  }
}

/// La réponse en cours ou le message modifié, au-dessus du champ.
class _Contexte extends StatelessWidget {
  const _Contexte({required this.message, required this.edition, required this.onFermer});

  final Message message;
  final bool edition;
  final VoidCallback onFermer;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final m = message;
    final couleur = edition
        ? OuroColors.accent
        : m.deMoi
            ? OuroColors.accent
            : palettesAvatar[(depot.contacts[m.auteurId]?.couleur ?? 0) % palettesAvatar.length][1];
    final titre = edition ? l.chEditMessageTitle : l.chReplyingTo(m.deMoi ? context.t.vous : depot.nom(m.auteurId));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 0),
      child: Row(
        children: [
          Icon(edition ? Icons.edit_rounded : Icons.reply_rounded, color: couleur, size: 22),
          const SizedBox(width: 12),
          Container(width: 3, height: 38, decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: OuroTypography.footnote.copyWith(color: couleur, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  texteMessage(context, m).replaceAll('\n', ' '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                ),
              ],
            ),
          ),
          if (m.type == TypeMessage.image && (m.piece?.url.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(m.piece!.url, width: 40, height: 40, fit: BoxFit.cover),
              ),
            ),
          BoutonIcone(icone: Icons.close_rounded, onTap: onFermer, aide: l.actionCancel),
        ],
      ),
    );
  }
}

/// L'enregistrement d'un vocal en cours.
class _Enregistrement extends StatelessWidget {
  const _Enregistrement({required this.enregistreur, required this.onAnnuler, required this.onEnvoyer});

  final Enregistreur enregistreur;
  final VoidCallback onAnnuler;
  final VoidCallback onEnvoyer;

  @override
  Widget build(BuildContext context) {
    final onde = enregistreur.onde;
    final visibles = onde.length > 60 ? onde.sublist(onde.length - 60) : onde;
    return Row(
      children: [
        BoutonIcone(
          icone: Icons.delete_outline_rounded,
          couleur: OuroColors.systemRed,
          aide: context.l.chDeleteRecordingTooltip,
          onTap: onAnnuler,
        ),
        const SizedBox(width: 8),
        const _PointRouge(),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          child: Text(
            chrono(enregistreur.duree),
            style: OuroTypography.monospacedDigits.copyWith(color: OuroColors.label, fontSize: 15),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 34,
            child: CustomPaint(
              painter: _OndeDirecte(valeurs: List.of(visibles), couleur: OuroColors.accent),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _BoutonEnvoi(icone: Icons.arrow_upward_rounded, actif: true, aide: context.l.actionSend, onTap: onEnvoyer),
      ],
    );
  }
}

class _PointRouge extends StatefulWidget {
  const _PointRouge();

  @override
  State<_PointRouge> createState() => _PointRougeState();
}

class _PointRougeState extends State<_PointRouge> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 0.25, end: 1.0).animate(_c),
        child: Container(width: 10, height: 10, decoration: BoxDecoration(color: OuroColors.systemRed, shape: BoxShape.circle)),
      );
}

class _OndeDirecte extends CustomPainter {
  _OndeDirecte({required this.valeurs, required this.couleur});

  final List<double> valeurs;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    const pas = 5.0;
    final p = Paint()
      ..color = couleur
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    final n = (size.width / pas).floor();
    final debut = valeurs.length > n ? valeurs.length - n : 0;
    for (var i = debut; i < valeurs.length; i++) {
      final x = size.width - (valeurs.length - i) * pas;
      final h = (valeurs[i] * 3).clamp(0.08, 1.0) * size.height;
      canvas.drawLine(Offset(x, (size.height - h) / 2), Offset(x, (size.height + h) / 2), p);
    }
  }

  @override
  bool shouldRepaint(_OndeDirecte ancien) => true;
}
