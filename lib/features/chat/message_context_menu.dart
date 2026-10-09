// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE MENU QUI S'OUVRE QUAND ON RESTE APPUYÉ SUR UN MESSAGE — celui
// d'iMessage et de WhatsApp sur iPhone.
//
// ── Ce qui le distingue d'une feuille qui monte du bas ────────────────
//
// Une feuille modale répond à la question « quelles actions existent ? ».
// Le menu d'iOS répond à une autre : « que veux-tu faire À CE
// MESSAGE-CI ? ». La différence n'est pas cosmétique :
//
//   • TOUT LE RESTE S'EFFACE. L'arrière-plan se floute et s'assombrit,
//     et le message choisi reste NET, seul objet lisible à l'écran. On
//     n'a plus besoin de se souvenir sur lequel on avait appuyé.
//   • LE MESSAGE SE SOULÈVE. Il grossit à peine et se détache par une
//     ombre. C'est ce léger décollement qui fait croire qu'on le tient.
//   • LE MENU EST ANCRÉ À LUI. Les émojis juste au-dessus, les actions
//     juste en dessous — pas à l'autre bout de l'écran.
//
// ── Le point délicat : le placement ───────────────────────────────────
//
// L'ensemble (barre d'émojis + message + actions) est souvent plus haut
// que la place disponible au-dessus ou en dessous du message. iMessage
// résout cela en DÉPLAÇANT LE MESSAGE : il glisse jusqu'à ce que tout
// tienne à l'écran, et l'animation part de sa position réelle, si bien
// que l'œil le suit sans le perdre. C'est ce que fait `_placement()`.
// ============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motor/motor.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/glassmorphism.dart';
import '../../l10n/generated/app_localizations.dart';

/// Une action proposée sous le message.
class MessageAction {
  const MessageAction({
    required this.icon,
    required this.label,
    this.onTap,
    this.destructive = false,
    this.sousActions,
    this.nouvelleSection = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Affichée en rouge, et toujours placée en dernier — convention iOS.
  /// Elle est séparée des autres par une bande épaisse.
  final bool destructive;

  /// Un SOUS-MENU, comme le « Plus » d'iOS : le toucher ne ferme pas le
  /// menu, il le remplace sur place par ces actions-là, avec un retour.
  final List<MessageAction>? sousActions;

  /// Une bande épaisse avant cette action : le séparateur de section des
  /// menus d'iOS, qui regroupe les actions par famille.
  final bool nouvelleSection;
}

/// La hauteur d'une liste d'actions, bandes de section comprises.
double _hauteurActions(List<MessageAction> actions, double ligne, double bande) {
  var h = actions.length * ligne;
  for (var i = 1; i < actions.length; i++) {
    if (actions[i].nouvelleSection || actions[i].destructive) h += bande;
  }
  return h;
}

/// Ouvre le menu contextuel ancré sur la bulle repérée par [anchorKey].
///
/// [preview] est une copie de la bulle : on ne peut pas déplacer
/// l'originale, qui vit dans la liste. La copie est posée exactement à sa
/// place, puis animée — l'illusion tient tant que les deux se
/// ressemblent.
Future<void> showMessageContextMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required Widget preview,
  required bool mine,
  required List<String> current,
  required ValueChanged<String> onReact,
  required List<MessageAction> actions,
  bool avecReactions = true,

  /// La hauteur que l'aperçu doit prendre, s'il ne fait PAS la taille de
  /// l'élément touché.
  ///
  /// ⚠️ SANS CE PARAMÈTRE, L'APERÇU NE PEUT QUE RECOPIER LA LIGNE. Tout
  /// le placement était calculé sur `origin.height` : un aperçu plus haut
  /// se faisait recouvrir par le menu, et un aperçu plus large était
  /// tronqué à la largeur de la ligne. C'est ce qui interdisait de
  /// montrer un vrai coup d'œil DANS la conversation — le geste d'iOS,
  /// où l'élément touché ne se contente pas de se soulever : il
  /// S'AGRANDIT en une carte qui montre la destination.
  double? previewHeight,

  /// Marge latérale de l'aperçu agrandi. Ignorée sans [previewHeight].
  double previewMargin = 16,

  /// Appui sur l'aperçu lui-même : chez Apple, l'aperçu est un coup d'œil
  /// dans la destination, et le toucher y emmène.
  VoidCallback? onPreviewTap,
}) {
  final box = anchorKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return Future<void>.value();
  final origin = box.localToGlobal(Offset.zero) & box.size;

  HapticFeedback.mediumImpact();

  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      // ⚠️ Assez long pour qu'on VOIE le message se soulever. En dessous
      // de ~250 ms le mouvement passe pour un simple changement d'écran.
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      // ⚠️ `Material` OBLIGATOIRE, MÊME TRANSPARENT.
      //
      // Une route poussée sur le navigateur racine n'hérite d'aucun
      // `Material` : les `Text` qu'elle contient retombent alors sur le
      // style de secours de Flutter — SOULIGNÉ DEUX FOIS EN JAUNE. Tout
      // le menu s'affichait ainsi, y compris la copie du message. Le
      // type `transparency` fournit l'ancêtre manquant sans peindre
      // quoi que ce soit par-dessus le flou.
      pageBuilder: (context, animation, _) => Material(
        type: MaterialType.transparency,
        child: _ContextMenuOverlay(
          animation: animation,
          origin: origin,
          preview: preview,
          mine: mine,
          current: current,
          onReact: onReact,
          actions: actions,
          avecReactions: avecReactions,
          previewHeight: previewHeight,
          previewMargin: previewMargin,
          onPreviewTap: onPreviewTap,
        ),
      ),
    ),
  );
}

class _ContextMenuOverlay extends StatelessWidget {
  const _ContextMenuOverlay({
    required this.animation,
    required this.origin,
    required this.preview,
    required this.mine,
    required this.current,
    required this.onReact,
    required this.actions,
    this.avecReactions = true,
    this.previewHeight,
    this.previewMargin = 16,
    this.onPreviewTap,
  });

  final Animation<double> animation;
  final Rect origin;
  final Widget preview;
  final bool mine;
  final List<String> current;
  final ValueChanged<String> onReact;
  final List<MessageAction> actions;

  /// La barre d'émojis n'a de sens que sur un message : une conversation
  /// de la liste d'accueil ne se réagit pas.
  final bool avecReactions;

  /// Non nul : l'aperçu grandit de la ligne vers une carte de cette
  /// hauteur, large de tout l'écran moins [previewMargin] de chaque côté.
  final double? previewHeight;
  final double previewMargin;
  final VoidCallback? onPreviewTap;

  /// iMessage tapback : ❤️ 👍 👎 😂 ‼️ ❓
  static const List<String> _emojis = ['❤️', '👍', '👎', '😂', '‼️', '❓'];

  static const double _barHeight = 56;
  static const double _gap = 10;
  static const double _menuWidth = 250;
  static const double _rowHeight = 46;

  /// La bande entre deux sections — 8 points, comme dans les menus d'iOS.
  static const double _bandeSection = 8;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeTop = media.padding.top + 8;
    final safeBottom = media.size.height - media.padding.bottom - 8;

    // La place réservée est celle du plus haut des deux menus — le
    // principal ou un sous-menu (plus sa ligne de retour) : s'ouvrir sur
    // place ne doit jamais faire déborder le menu sous l'écran.
    var menuHeight = actions.isEmpty
        ? 0.0
        : _hauteurActions(actions, _rowHeight, _bandeSection);
    for (final a in actions) {
      final sous = a.sousActions;
      if (sous == null) continue;
      final h = _rowHeight + _bandeSection + _hauteurActions(sous, _rowHeight, _bandeSection);
      if (h > menuHeight) menuHeight = h;
    }

    // ⚠️ LA PLACE DE LA BARRE D'ÉMOJIS N'EST RÉSERVÉE QUE SI ELLE EXISTE.
    // Elle était comptée dans tous les cas : sur la liste d'accueil, où
    // il n'y a rien à réagir, cela laissait 66 points de vide au-dessus de
    // l'aperçu — invisible tant que l'aperçu était minuscule, mais c'est
    // autant de hauteur volée à un coup d'œil dans la conversation.
    final hauteurBarre = avecReactions ? _barHeight + _gap : 0.0;

    // ⚠️ LA HAUTEUR DE L'APERÇU N'EST PLUS CELLE DE LA LIGNE. Un coup
    // d'œil dans la conversation est bien plus haut qu'une ligne de
    // liste ; calculer la place avec `origin.height` le faisait recouvrir
    // par le menu. Et on la borne à ce qui reste vraiment : sur un petit
    // écran, un aperçu de 340 points plus la barre et le menu ne tiennent
    // pas, et c'est l'aperçu qui doit céder, pas le menu — sans les
    // actions, l'appui long ne sert à rien.
    final hauteurDemandee = previewHeight ?? origin.height;
    final dispo = safeBottom - safeTop - hauteurBarre - _gap - menuHeight;
    final hauteurApercu = hauteurDemandee.clamp(origin.height, dispo.clamp(origin.height, double.infinity));

    final total = hauteurBarre + hauteurApercu + _gap + menuHeight;

    // Position idéale : la barre d'émojis juste au-dessus du message.
    var top = origin.top - hauteurBarre;
    // Puis on ramène l'ensemble dans l'écran, sans jamais le couper.
    if (top + total > safeBottom) top = safeBottom - total;
    if (top < safeTop) top = safeTop;

    final bubbleTop = top + hauteurBarre;
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final t = curved.value;
        final agrandi = previewHeight != null;

        return Stack(
          children: [
            // ── Le fond : flou + assombrissement, tous deux progressifs.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 22 * t, sigmaY: 22 * t),
                  child: ColoredBox(
                    color: Colors.black.withValues(
                      alpha: (OuroColors.isDark ? 0.5 : 0.28) * t,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),

            // ── Le message, soulevé et amené à sa place.
            //
            // Il part de sa position réelle dans la liste et glisse vers
            // la position calculée : l'œil ne le lâche pas. Il grossit de
            // 3 % — assez pour qu'on sente qu'on le tient, pas assez pour
            // qu'on remarque le changement d'échelle.
            // ⚠️ DEUX RÉGIMES, ET UN SEUL CODE. Sans `previewHeight`,
            // l'aperçu garde la taille de l'élément et ne fait que
            // glisser — le comportement d'avant, inchangé pour les
            // bulles de message. Avec, il GRANDIT de la ligne vers une
            // carte : c'est le geste d'iOS, où l'élément touché devient
            // la destination.
            Positioned(
              left: ui.lerpDouble(origin.left, previewMargin, agrandi ? t : 0)!,
              top: ui.lerpDouble(origin.top, bubbleTop, t)!,
              width: ui.lerpDouble(
                origin.width,
                media.size.width - previewMargin * 2,
                agrandi ? t : 0,
              )!,
              height: agrandi
                  ? ui.lerpDouble(origin.height, hauteurApercu, t)
                  : null,
              child: IgnorePointer(
                // L'aperçu agrandi se touche : c'est lui qui emmène dans
                // la conversation.
                ignoring: !agrandi || onPreviewTap == null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onPreviewTap == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onPreviewTap!();
                        },
                  child: Transform.scale(
                    scale: agrandi ? 1 : 1 + 0.03 * t,
                    alignment: mine
                        ? AlignmentDirectional.centerEnd
                        : AlignmentDirectional.centerStart,
                    child: Opacity(
                      // ⚠️ L'APERÇU N'APPARAÎT QU'UNE FOIS LA CARTE
                      // OUVERTE. Peint dès le premier pixel, son contenu
                      // (un fil de discussion entier) se tasserait dans
                      // la hauteur d'une ligne pendant toute la montée :
                      // on verrait des bulles écrasées, puis se détendre.
                      // Le fondu couvre la déformation.
                      opacity: agrandi ? Curves.easeIn.transform(t) : 1,
                      child: preview,
                    ),
                  ),
                ),
              ),
            ),

            // ── La barre d'émojis, au-dessus.
            if (avecReactions)
              Positioned(
              left: 12,
              right: 12,
              top: top,
              child: Align(
                alignment: mine
                    ? AlignmentDirectional.centerEnd
                    : AlignmentDirectional.centerStart,
                child: Opacity(
                  opacity: t,
                  child: _ReactionBar(
                    emojis: _emojis,
                    current: current,
                    progress: t,
                    onSelect: (emoji) {
                      OuroHaptics.light();
                      Navigator.of(context).pop();
                      onReact(emoji);
                    },
                  ),
                ),
              ),
            ),

            // ── Les actions, en dessous.
            if (actions.isNotEmpty)
              Positioned(
                left: 12,
                right: 12,
                top: bubbleTop + hauteurApercu + _gap,
                child: Align(
                  alignment: mine
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Opacity(
                    opacity: t,
                    child: Transform.scale(
                      // Le menu s'ouvre DEPUIS LE MESSAGE : il grandit à
                      // partir de son bord haut, du côté du message.
                      scale: 0.86 + 0.14 * t,
                      alignment: mine ? Alignment.topRight : Alignment.topLeft,
                      child: _ActionMenu(
                        width: _menuWidth,
                        rowHeight: _rowHeight,
                        actions: actions,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// La capsule d'émojis iMessage : capsule avec shadow, 24pt radius.
class _ReactionBar extends StatelessWidget {
  const _ReactionBar({
    required this.emojis,
    required this.current,
    required this.progress,
    required this.onSelect,
  });

  final List<String> emojis;
  final List<String> current;
  final double progress;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // iMessage tapback strip : capsule with shadow.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: OuroColors.isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        // iMessage : shadow in light, border in dark.
        boxShadow: OuroColors.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
        border: OuroColors.isDark
            ? Border.all(color: OuroColors.separator, width: 0.5)
            : null,
      ),
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < emojis.length; i++)
              Semantics(
                button: true,
                label: l10n.mcReactWith(emojis[i]),
                child: _Emoji(
                  emoji: emojis[i],
                  selected: current.contains(emojis[i]),
                  progress: ((progress - i * 0.07) / 0.6).clamp(0.0, 1.0),
                  onTap: () => onSelect(emojis[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Emoji extends StatefulWidget {
  const _Emoji({
    required this.emoji,
    required this.selected,
    required this.progress,
    required this.onTap,
  });

  final String emoji;
  final bool selected;
  final double progress;
  final VoidCallback onTap;

  @override
  State<_Emoji> createState() => _EmojiState();
}

class _EmojiState extends State<_Emoji> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // iMessage : 28pt glyph, 44pt hit target.
    // Quand l'émojis est déjà sélectionné, appuyer fait rétrécir (0.85)
    // pour signaler « tap pour retirer ». Sinon, grossir (1.25) pour
    // signaler « tap pour ajouter ».
    final pressScale = widget.selected ? 0.85 : 1.25;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: SingleMotionBuilder(
        motion: const CupertinoMotion.snappy(),
        value: _pressed ? pressScale : 1.0,
        builder: (context, scale, child) =>
            Transform.scale(scale: widget.progress * scale, child: child),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.selected
                    ? OuroColors.accent.withValues(alpha: 0.22)
                    : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Le petit panneau d'actions, dessiné comme un menu contextuel iOS :
/// intitulé à gauche, icône à droite, filets de séparation entre les
/// lignes, et la destruction en rouge tout en bas.
class _ActionMenu extends StatefulWidget {
  const _ActionMenu({
    required this.width,
    required this.rowHeight,
    required this.actions,
  });

  final double width;
  final double rowHeight;
  final List<MessageAction> actions;

  @override
  State<_ActionMenu> createState() => _ActionMenuState();
}

/// Le menu, et le sous-menu « Plus » qui s'ouvre SUR PLACE.
///
/// ⚠️ C'EST LE GESTE D'iOS, PAS UNE SECONDE FEUILLE. Le menu garde sa
/// position ; son contenu glisse et laisse place aux actions secondaires,
/// avec une ligne « ‹ Plus » en tête pour revenir. On reste au même
/// endroit, sous le même message — le regard n'a rien à rechercher.
class _ActionMenuState extends State<_ActionMenu> {
  MessageAction? _ouvert;

  @override
  Widget build(BuildContext context) {
    final ouvert = _ouvert;
    final liste = ouvert?.sousActions ?? widget.actions;
    return OuroCard(
      child: SizedBox(
        width: widget.width,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (enfant, animation) {
              // Le sous-menu arrive de la droite, le principal revient
              // de la gauche — le sens de la navigation iOS.
              final versSous = enfant.key == const ValueKey('sous');
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(versSous ? 0.18 : -0.18, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: enfant,
                ),
              );
            },
            layoutBuilder: (actuel, precedents) => Stack(
              alignment: Alignment.topCenter,
              children: [...precedents, if (actuel != null) actuel],
            ),
            child: Column(
              key: ValueKey(ouvert == null ? 'principal' : 'sous'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (ouvert != null) ...[
                  _LigneRetour(
                    label: ouvert.label,
                    height: widget.rowHeight,
                    onTap: () => setState(() => _ouvert = null),
                  ),
                  const _Bande(),
                ],
                for (var i = 0; i < liste.length; i++) ...[
                  if (i > 0)
                    (liste[i].nouvelleSection || liste[i].destructive)
                        ? const _Bande()
                        : Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: OuroColors.separator,
                          ),
                  Semantics(
                    button: true,
                    label: liste[i].label,
                    child: _ActionRow(
                      action: liste[i],
                      height: widget.rowHeight,
                      onOuvrir: liste[i].sousActions == null
                          ? null
                          : () => setState(() => _ouvert = liste[i]),
                    ),
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

/// La bande de section : 8 points d'un gris plus soutenu que le fond du
/// menu, comme dans iOS.
class _Bande extends StatelessWidget {
  const _Bande();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _ContextMenuOverlay._bandeSection,
      color: OuroColors.isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.06),
    );
  }
}

/// « ‹ Plus » : la ligne qui ramène au menu principal.
class _LigneRetour extends StatelessWidget {
  const _LigneRetour({
    required this.label,
    required this.height,
    required this.onTap,
  });

  final String label;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          OuroHaptics.selection();
          onTap();
        },
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 10, end: 16),
            child: Row(
              children: [
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_right_rounded
                      : Icons.chevron_left_rounded,
                  size: 24,
                  color: OuroColors.label,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.callout.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w600,
                    ),
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

class _ActionRow extends StatefulWidget {
  const _ActionRow({required this.action, required this.height, this.onOuvrir});

  final MessageAction action;
  final double height;

  /// Présent pour une action à sous-menu : le toucher l'ouvre au lieu de
  /// fermer le menu.
  final VoidCallback? onOuvrir;

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.action.destructive
        ? OuroColors.systemRed
        : OuroColors.label;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        setState(() => _pressed = false);
        final ouvrir = widget.onOuvrir;
        if (ouvrir != null) {
          OuroHaptics.selection();
          ouvrir();
          return;
        }
        OuroHaptics.light();
        Navigator.of(context).pop();
        widget.action.onTap?.call();
      },
      child: AnimatedContainer(
        duration: DesignTokens.durationFast,
        height: widget.height,
        // L'enfoncement iOS : la ligne s'assombrit sous le doigt, sans
        // onde qui se propage.
        color: _pressed ? OuroColors.systemFill : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Une seule ligne, toujours : un libellé sur deux lignes
            // casse le rythme du menu (« Marquer comme important »).
            Expanded(
              child: Text(
                widget.action.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.callout.copyWith(color: color),
              ),
            ),
            Icon(widget.action.icon, size: 20, color: color),
            if (widget.onOuvrir != null) ...[
              const SizedBox(width: 6),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                size: 18,
                color: OuroColors.tertiaryLabel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
