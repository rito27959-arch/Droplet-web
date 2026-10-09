// LES COMPOSANTS DE DROPLET WEB — les pièces que tous les écrans
// partagent, dans la grammaire de l'app : verre, avatars à dégradé, menus
// contextuels d'iOS, alertes, bulles d'information.
//
// Ce qui change par rapport au téléphone : la SOURIS. Chaque élément
// cliquable réagit au survol (un voile discret, le curseur main), le clic
// droit ouvre le menu qu'ouvrirait un appui long, et chaque bouton icône
// a sa bulle d'aide.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/ouro_avatar.dart';
import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/depot.dart';

/// La courbe de sortie de l'app : rapide au départ, très douce à
/// l'arrivée.
const Curve kSortie = Cubic(0.16, 1, 0.3, 1);

// ══ LE VERRE ═══════════════════════════════════════════════════════════════

/// Le verre des barres : flou, teinte de fond, liseré d'un demi-point.
class Verre extends StatelessWidget {
  const Verre({
    super.key,
    required this.child,
    this.bordHaut = false,
    this.bordBas = false,
    this.rayon = 0,
    this.opacite = 0.78,
    this.couleur,
    this.flou = 24,
  });

  final Widget child;
  final bool bordHaut;
  final bool bordBas;
  final double rayon;
  final double opacite;
  final Color? couleur;
  final double flou;

  @override
  Widget build(BuildContext context) {
    final trait = BorderSide(color: OuroColors.separator, width: 0.5);
    final forme = BorderRadius.circular(rayon);
    return ClipRRect(
      borderRadius: forme,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: flou, sigmaY: flou),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: (couleur ?? OuroColors.secondarySystemGroupedBackground).withValues(alpha: opacite),
            borderRadius: rayon > 0 ? forme : null,
            border: rayon > 0
                ? Border.all(color: Colors.white.withValues(alpha: OuroColors.isDark ? 0.08 : 0.5), width: 0.5)
                : Border(
                    top: bordHaut ? trait : BorderSide.none,
                    bottom: bordBas ? trait : BorderSide.none,
                  ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ══ LE SURVOL ══════════════════════════════════════════════════════════════

/// Un élément cliquable à la souris : curseur main, état de survol, clic
/// droit.
class Survol extends StatefulWidget {
  const Survol({
    super.key,
    required this.builder,
    this.onTap,
    this.onDoubleTap,
    this.onClicDroit,
    this.curseur = SystemMouseCursors.click,
  });

  final Widget Function(BuildContext context, bool survol) builder;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  /// Clic droit, avec la position du pointeur dans l'écran.
  final ValueChanged<Offset>? onClicDroit;
  final MouseCursor curseur;

  @override
  State<Survol> createState() => _SurvolState();
}

class _SurvolState extends State<Survol> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : widget.curseur,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        onSecondaryTapUp: widget.onClicDroit == null ? null : (d) => widget.onClicDroit!(d.globalPosition),
        onLongPressStart: widget.onClicDroit == null ? null : (d) => widget.onClicDroit!(d.globalPosition),
        child: widget.builder(context, _survol),
      ),
    );
  }
}

// ══ LES BOUTONS ════════════════════════════════════════════════════════════

/// Un bouton icône : un rond qui s'allume au survol, s'enfonce au clic,
/// et sa bulle d'aide.
class BoutonIcone extends StatefulWidget {
  const BoutonIcone({
    super.key,
    required this.icone,
    required this.onTap,
    this.aide,
    this.taille = 22,
    this.couleur,
    this.actif = false,
    this.diametre = 38,
  });

  final IconData icone;
  final VoidCallback? onTap;
  final String? aide;
  final double taille;
  final Color? couleur;

  /// Allumé (panneau ouvert, recherche active…).
  final bool actif;
  final double diametre;

  @override
  State<BoutonIcone> createState() => _BoutonIconeState();
}

class _BoutonIconeState extends State<BoutonIcone> {
  bool _survol = false;
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final couleur = widget.onTap == null
        ? OuroColors.quaternaryLabel
        : widget.couleur ?? (widget.actif ? OuroColors.accent : OuroColors.secondaryLabel);
    final fond = widget.actif
        ? OuroColors.accent.withValues(alpha: 0.14)
        : _survol
            ? OuroColors.tertiarySystemFill
            : Colors.transparent;
    final bouton = MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _appui = true),
        onTapCancel: () => setState(() => _appui = false),
        onTapUp: (_) => setState(() => _appui = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _appui ? 0.88 : 1,
          duration: const Duration(milliseconds: 140),
          curve: kSortie,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: widget.diametre,
            height: widget.diametre,
            decoration: BoxDecoration(color: fond, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(widget.icone, size: widget.taille, color: couleur),
          ),
        ),
      ),
    );
    if (widget.aide == null) return bouton;
    return Tooltip(
      message: widget.aide!,
      waitDuration: const Duration(milliseconds: 450),
      child: bouton,
    );
  }
}

/// Le bouton plein de l'app : une pilule dans la couleur d'accent.
class BoutonPlein extends StatelessWidget {
  const BoutonPlein({super.key, required this.texte, required this.onTap, this.icone, this.destructif = false});

  final String texte;
  final VoidCallback? onTap;
  final IconData? icone;
  final bool destructif;

  @override
  Widget build(BuildContext context) {
    final fond = destructif ? OuroColors.systemRed : OuroColors.accentRempli;
    return Survol(
      onTap: onTap,
      builder: (context, survol) => AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: onTap == null ? 0.4 : (survol ? 0.88 : 1),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(22)),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icone != null) ...[
                Icon(icone, size: 19, color: OuroColors.texteSurRemplissage(fond)),
                const SizedBox(width: 8),
              ],
              Text(
                texte,
                style: OuroTypography.headline.copyWith(color: OuroColors.texteSurRemplissage(fond)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Une pastille de filtre : « Toutes », « Non lues », « Groupes »…
class Puce extends StatelessWidget {
  const Puce({super.key, required this.texte, required this.actif, required this.onTap, this.compte = 0});

  final String texte;
  final bool actif;
  final VoidCallback onTap;
  final int compte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Survol(
        onTap: onTap,
        builder: (context, survol) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: kSortie,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: actif
                ? OuroColors.accent.withValues(alpha: OuroColors.isDark ? 0.24 : 0.14)
                : (survol ? OuroColors.secondarySystemFill : OuroColors.tertiarySystemFill),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            compte > 0 ? '$texte  $compte' : texte,
            style: OuroTypography.subheadline.copyWith(
              color: actif ? OuroColors.accent : OuroColors.secondaryLabel,
              fontWeight: actif ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ══ LES AVATARS ════════════════════════════════════════════════════════════

/// L'avatar de l'app : une photo, ou les initiales sur un dégradé, avec
/// le reflet du verre ; la pastille verte « en ligne » ; l'anneau des
/// statuts (couleur : pas encore vu, gris : vu).
class AvatarDroplet extends StatelessWidget {
  const AvatarDroplet({
    super.key,
    required this.nom,
    this.couleur = 0,
    this.photo,
    this.taille = 48,
    this.enLigne = false,
    this.anneau,
    this.groupe = false,
  });

  final String nom;
  final int couleur;
  final String? photo;
  final double taille;
  final bool enLigne;

  /// null : pas d'anneau ; true : statut non vu ; false : vu.
  final bool? anneau;
  final bool groupe;

  @override
  Widget build(BuildContext context) {
    final palette = palettesAvatar[couleur % palettesAvatar.length];
    final initiales = DegradesAvatar.initiales(nom);
    Widget rond = Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: palette),
        image: photo == null || photo!.isEmpty
            ? null
            : DecorationImage(image: NetworkImage(photo!), fit: BoxFit.cover),
      ),
      foregroundDecoration: const BoxDecoration(shape: BoxShape.circle, gradient: DegradesAvatar.reflet),
      alignment: Alignment.center,
      child: photo != null && photo!.isNotEmpty
          ? null
          : groupe && initiales.isEmpty
              ? Icon(Icons.groups_rounded, color: Colors.white, size: taille * 0.5)
              : Text(
                  initiales,
                  style: TextStyle(
                    fontFamily: OuroTypography.fontFamily,
                    fontSize: DegradesAvatar.tailleInitiales(initiales, taille / 2),
                    fontWeight: FontWeight.w600,
                    fontVariations: const [FontVariation('wght', 600)],
                    color: Colors.white,
                    height: 1,
                  ),
                ),
    );
    if (anneau != null) {
      rond = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: anneau!
              ? LinearGradient(colors: [OuroColors.accent, OuroColors.accent.withValues(alpha: 0.55)])
              : null,
          color: anneau! ? null : OuroColors.systemGray3,
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: OuroColors.secondarySystemGroupedBackground),
          child: SizedBox.square(dimension: taille - 9, child: FittedBox(child: rond)),
        ),
      );
    }
    if (!enLigne) return SizedBox.square(dimension: taille, child: rond);
    return SizedBox.square(
      dimension: taille,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          rond,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: taille * 0.28,
              height: taille * 0.28,
              decoration: BoxDecoration(
                color: OuroColors.systemGreen,
                shape: BoxShape.circle,
                border: Border.all(color: OuroColors.secondarySystemGroupedBackground, width: taille > 60 ? 3 : 2.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══ LES EN-TÊTES ET CHAMPS ═════════════════════════════════════════════════

/// L'en-tête d'un panneau de la colonne de gauche : retour (chevron
/// d'iOS) et titre, ou grand titre à la racine.
class EntetePanneau extends StatelessWidget {
  const EntetePanneau({super.key, required this.titre, this.actions = const [], this.retour, this.sousTitre});

  final String titre;
  final String? sousTitre;
  final List<Widget> actions;
  final VoidCallback? retour;

  @override
  Widget build(BuildContext context) {
    if (retour == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 10, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                titre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.largeTitle.copyWith(color: OuroColors.label),
              ),
            ),
            ...actions,
          ],
        ),
      );
    }
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          const SizedBox(width: 6),
          BoutonIcone(
            icone: Icons.arrow_back_ios_new_rounded,
            onTap: retour,
            couleur: OuroColors.accent,
            taille: 20,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.headline.copyWith(color: OuroColors.label),
                ),
                if (sousTitre != null)
                  Text(
                    sousTitre!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.caption1.copyWith(color: OuroColors.secondaryLabel),
                  ),
              ],
            ),
          ),
          ...actions,
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// Le champ de recherche d'iOS, avec les icônes Material (celles de
/// Cupertino dépendent d'une police que le navigateur peut ne pas avoir).
class ChampRecherche extends StatelessWidget {
  const ChampRecherche({
    super.key,
    required this.indication,
    this.onChanged,
    this.controleur,
    this.focus,
    this.autofocus = false,
    this.onSubmitted,
  });

  final String indication;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controleur;
  final FocusNode? focus;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      controller: controleur,
      focusNode: focus,
      autofocus: autofocus,
      placeholder: indication,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: const Icon(Icons.cancel_rounded),
      style: OuroTypography.body.copyWith(color: OuroColors.label),
      placeholderStyle: OuroTypography.body.copyWith(color: OuroColors.tertiaryLabel),
      backgroundColor: OuroColors.tertiarySystemFill,
      borderRadius: BorderRadius.circular(11),
      itemColor: OuroColors.secondaryLabel,
    );
  }
}

/// Un champ de texte de formulaire, sobre : fond gris, coins arrondis.
class ChampTexte extends StatelessWidget {
  const ChampTexte({
    super.key,
    required this.controleur,
    this.indication,
    this.autofocus = false,
    this.lignesMax = 1,
    this.longueurMax,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controleur;
  final String? indication;
  final bool autofocus;
  final int lignesMax;
  final int? longueurMax;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controleur,
      autofocus: autofocus,
      maxLines: lignesMax,
      minLines: 1,
      maxLength: longueurMax,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      placeholder: indication,
      cursorColor: OuroColors.accent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      style: OuroTypography.body.copyWith(color: OuroColors.label),
      placeholderStyle: OuroTypography.body.copyWith(color: OuroColors.tertiaryLabel),
      decoration: BoxDecoration(
        color: OuroColors.tertiarySystemFill,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

/// L'interrupteur d'iOS, dans la couleur d'accent… sauf qu'iOS le veut
/// vert. Droplet suit l'accent, comme ses réglages.
class Interrupteur extends StatelessWidget {
  const Interrupteur({super.key, required this.valeur, required this.onChanged});

  final bool valeur;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => CupertinoSwitch(
        value: valeur,
        onChanged: onChanged,
        activeTrackColor: OuroColors.accent,
      );
}

/// L'état vide d'une colonne : une grande icône grise, un titre, un texte.
class EtatVide extends StatelessWidget {
  const EtatVide({super.key, required this.icone, required this.titre, this.texte, this.action});

  final IconData icone;
  final String titre;
  final String? texte;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(color: OuroColors.tertiarySystemFill, shape: BoxShape.circle),
              child: Icon(icone, size: 36, color: OuroColors.secondaryLabel),
            ),
            const SizedBox(height: 16),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: OuroTypography.title3.copyWith(color: OuroColors.label),
            ),
            if (texte != null) ...[
              const SizedBox(height: 6),
              Text(
                texte!,
                textAlign: TextAlign.center,
                style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

// ══ LES MENUS ══════════════════════════════════════════════════════════════

class ElementMenu {
  const ElementMenu({
    required this.icone,
    required this.libelle,
    required this.onTap,
    this.destructif = false,
    this.section = false,
    this.raccourci,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;
  final bool destructif;

  /// Une bande de séparation au-dessus, comme les sections des menus
  /// d'iOS.
  final bool section;

  /// Le raccourci clavier affiché à droite (« ⌃⌥E »).
  final String? raccourci;
}

/// Un menu contextuel d'iOS, posé près de [position] (un clic droit, un
/// bouton « … »). Il se replie vers l'intérieur de l'écran s'il déborde.
Future<void> montrerMenu(
  BuildContext context, {
  required Offset position,
  required List<ElementMenu> elements,
  Widget? entete,
  double largeur = 250,
}) {
  return montrerPopover(
    context,
    position: position,
    largeur: largeur,
    hauteurEstimee: elements.length * 44.0 + elements.where((e) => e.section).length * 8 + (entete == null ? 0 : 64),
    builder: (fermer) => _CorpsMenu(elements: elements, fermer: fermer, entete: entete),
  );
}

class _CorpsMenu extends StatelessWidget {
  const _CorpsMenu({required this.elements, required this.fermer, this.entete});

  final List<ElementMenu> elements;
  final VoidCallback fermer;
  final Widget? entete;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entete != null) ...[
          entete!,
          Container(height: 8, color: OuroColors.separator.withValues(alpha: 0.3)),
        ],
        for (var i = 0; i < elements.length; i++) ...[
          if (i > 0 && (elements[i].section || (elements[i].destructif && !elements[i - 1].destructif)))
            Container(height: 8, color: OuroColors.separator.withValues(alpha: 0.3))
          else if (i > 0)
            Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator),
          _LigneMenu(
            element: elements[i],
            onTap: () {
              fermer();
              elements[i].onTap();
            },
          ),
        ],
      ],
    );
  }
}

class _LigneMenu extends StatelessWidget {
  const _LigneMenu({required this.element, required this.onTap});

  final ElementMenu element;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = element.destructif ? OuroColors.systemRed : OuroColors.label;
    return Survol(
      onTap: onTap,
      builder: (context, survol) => Container(
        height: 44,
        color: survol ? OuroColors.label.withValues(alpha: 0.07) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                element.libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.body.copyWith(color: couleur),
              ),
            ),
            if (element.raccourci != null) ...[
              Text(element.raccourci!, style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel)),
              const SizedBox(width: 10),
            ],
            Icon(element.icone, size: 19, color: couleur),
          ],
        ),
      ),
    );
  }
}

/// Un panneau flottant en verre près de [position] : menus, sélecteur
/// d'emoji, menu des pièces jointes. [builder] reçoit de quoi le fermer.
Future<T?> montrerPopover<T>(
  BuildContext context, {
  required Offset position,
  required Widget Function(VoidCallback fermer) builder,
  double largeur = 250,
  double hauteurEstimee = 300,
  bool auDessus = false,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.04),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (contexte, _, __) {
      final ecran = MediaQuery.sizeOf(contexte);
      var gauche = position.dx;
      if (gauche + largeur > ecran.width - 12) gauche = position.dx - largeur;
      gauche = gauche.clamp(12.0, ecran.width - largeur - 12);
      var haut = auDessus ? position.dy - hauteurEstimee - 8 : position.dy + 4;
      if (haut + hauteurEstimee > ecran.height - 12) haut = position.dy - hauteurEstimee - 4;
      haut = haut.clamp(12.0, (ecran.height - 60).clamp(12.0, double.infinity));
      final origine = Alignment(
        ((position.dx - gauche) / largeur * 2 - 1).clamp(-1.0, 1.0),
        ((position.dy - haut) / hauteurEstimee * 2 - 1).clamp(-1.0, 1.0),
      );
      return Stack(
        children: [
          Positioned(
            left: gauche,
            top: haut,
            width: largeur,
            child: _Animation(
              origine: origine,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: BoxConstraints(maxHeight: ecran.height - haut - 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: OuroColors.isDark ? 0.5 : 0.16),
                        blurRadius: 40,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Verre(
                    rayon: 14,
                    opacite: OuroColors.isDark ? 0.82 : 0.86,
                    flou: 30,
                    child: SingleChildScrollView(child: builder(() => Navigator.of(contexte).pop())),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (_, animation, __, enfant) =>
        FadeTransition(opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut), child: enfant),
  );
}

class _Animation extends StatelessWidget {
  const _Animation({required this.origine, required this.child});

  final Alignment origine;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = ModalRoute.of(context)!.animation!;
    return AnimatedBuilder(
      animation: a,
      builder: (context, enfant) {
        final v = kSortie.transform(a.value);
        return Transform.scale(scale: 0.86 + 0.14 * v, alignment: origine, child: enfant);
      },
      child: child,
    );
  }
}

// ══ LES ALERTES ════════════════════════════════════════════════════════════

class ActionAlerte {
  const ActionAlerte(this.libelle, {this.destructif = false, this.principal = false});

  final String libelle;
  final bool destructif;
  final bool principal;
}

/// L'alerte d'iOS : un titre, un message, des boutons. Rend l'index du
/// bouton choisi, ou null si on la ferme.
Future<int?> alerte(
  BuildContext context, {
  required String titre,
  String? message,
  required List<ActionAlerte> actions,
  Widget? contenu,
}) {
  return showGeneralDialog<int>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (contexte, _, __) {
      final empiles = actions.length > 2;
      Widget bouton(int i) {
        final a = actions[i];
        return Survol(
            onTap: () => Navigator.of(contexte).pop(i),
            builder: (context, survol) => Container(
              height: 46,
              alignment: Alignment.center,
              color: survol ? OuroColors.label.withValues(alpha: 0.06) : Colors.transparent,
              child: Text(
                a.libelle,
                style: (a.principal ? OuroTypography.headline : OuroTypography.body).copyWith(
                  color: a.destructif ? OuroColors.systemRed : OuroColors.accent,
                ),
              ),
            ),
          );
      }

      final trait = Container(color: OuroColors.separator, width: 0.5, height: 46);
      return Center(
        child: Material(
          type: MaterialType.transparency,
          child: Shortcuts(
            shortcuts: const {SingleActivator(LogicalKeyboardKey.enter): ActivateIntent()},
            child: Actions(
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    final i = actions.indexWhere((a) => a.principal);
                    Navigator.of(contexte).pop(i < 0 ? actions.length - 1 : i);
                    return null;
                  },
                ),
              },
              child: Focus(
                autofocus: true,
                child: SizedBox(
                  width: contenu == null ? 300 : 340,
                  child: Verre(
                    rayon: 16,
                    opacite: OuroColors.isDark ? 0.86 : 0.9,
                    flou: 40,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                          child: Column(
                            children: [
                              Text(
                                titre,
                                textAlign: TextAlign.center,
                                style: OuroTypography.headline.copyWith(color: OuroColors.label),
                              ),
                              if (message != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
                                ),
                              ],
                              if (contenu != null) ...[const SizedBox(height: 14), contenu],
                            ],
                          ),
                        ),
                        Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator),
                        if (empiles)
                          for (var i = 0; i < actions.length; i++) ...[
                            if (i > 0) Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator),
                            bouton(i),
                          ]
                        else
                          Row(
                            children: [
                              for (var i = 0; i < actions.length; i++) ...[
                                if (i > 0) trait,
                                Expanded(child: bouton(i)),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, a, __, enfant) {
      final v = CurvedAnimation(parent: a, curve: kSortie);
      return FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 1.12, end: 1.0).animate(v), child: enfant),
      );
    },
  );
}

/// Une alerte avec un champ de texte (renommer, ajouter un contact…).
Future<String?> demanderTexte(
  BuildContext context, {
  required String titre,
  String? message,
  String initial = '',
  String? indication,
  required String valider,
  required String annuler,
  int longueurMax = 60,
}) async {
  final controleur = TextEditingController(text: initial);
  final i = await alerte(
    context,
    titre: titre,
    message: message,
    contenu: ChampTexte(controleur: controleur, indication: indication, autofocus: true, longueurMax: longueurMax),
    actions: [ActionAlerte(annuler), ActionAlerte(valider, principal: true)],
  );
  final texte = controleur.text.trim();
  controleur.dispose();
  return i == 1 && texte.isNotEmpty ? texte : null;
}

// ══ LES BULLES D'INFORMATION ═══════════════════════════════════════════════

OverlayEntry? _annonce;
Timer? _minuteurAnnonce;

/// Une pilule en verre, en bas au centre, qui disparaît d'elle-même :
/// « Message copié », « Contact bloqué ».
void annoncer(BuildContext context, String texte, {IconData icone = Icons.check_circle_rounded}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _annonce?.remove();
  _minuteurAnnonce?.cancel();
  final entree = OverlayEntry(
    builder: (_) => Positioned(
      left: 0,
      right: 0,
      bottom: 36,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 360),
            curve: kSortie,
            builder: (context, v, enfant) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: enfant),
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: Verre(
                  rayon: 24,
                  opacite: 0.88,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icone, size: 18, color: OuroColors.accent),
                        const SizedBox(width: 10),
                        Text(texte, style: OuroTypography.subheadline.copyWith(color: OuroColors.label)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  _annonce = entree;
  overlay.insert(entree);
  _minuteurAnnonce = Timer(const Duration(milliseconds: 2200), () {
    if (_annonce == entree) {
      entree.remove();
      _annonce = null;
    }
  });
}

// ══ LE FOND DES DISCUSSIONS ════════════════════════════════════════════════

/// Les fonds proposés dans Réglages › Discussions. Le premier est celui de
/// l'app : de très petites gouttes en quinconce, à peine visibles.
class FondDiscussion {
  const FondDiscussion(this.clair, this.sombre, {this.motif = true});

  final List<Color> clair;
  final List<Color> sombre;
  final bool motif;

  List<Color> couleurs() => OuroColors.isDark ? sombre : clair;
}

const List<FondDiscussion> fondsDiscussion = [
  FondDiscussion([Color(0xFFFFFFFF), Color(0xFFFFFFFF)], [Color(0xFF000000), Color(0xFF000000)]),
  FondDiscussion([Color(0xFFF2F2F7), Color(0xFFF2F2F7)], [Color(0xFF1C1C1E), Color(0xFF1C1C1E)], motif: false),
  FondDiscussion([Color(0xFFFFF1E6), Color(0xFFFFE3EC)], [Color(0xFF2A1A12), Color(0xFF2A1220)]),
  FondDiscussion([Color(0xFFE6F4FF), Color(0xFFEDE7FF)], [Color(0xFF0E1A2B), Color(0xFF1A1430)]),
  FondDiscussion([Color(0xFFE8F8EE), Color(0xFFE3F6F5)], [Color(0xFF0F2117), Color(0xFF0E2222)]),
  FondDiscussion([Color(0xFFFFF8DC), Color(0xFFFFEFD5)], [Color(0xFF26200E), Color(0xFF2A1E0E)]),
  FondDiscussion([Color(0xFFEDEDF2), Color(0xFFD9D9E3)], [Color(0xFF16161A), Color(0xFF26262E)], motif: false),
  FondDiscussion([Color(0xFFFCE4EC), Color(0xFFE1F5FE)], [Color(0xFF2B1220), Color(0xFF0E1E2B)]),
];

class PeintreMotif extends CustomPainter {
  PeintreMotif(this.encre);

  final Color encre;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = encre.withValues(alpha: 0.04);
    const pas = 38.0;
    var ligne = 0;
    for (var y = 0.0; y < size.height + pas; y += pas, ligne++) {
      final decalage = ligne.isOdd ? pas / 2 : 0.0;
      for (var x = decalage; x < size.width + pas; x += pas) {
        // Une goutte minuscule : un rond et sa pointe.
        canvas.drawCircle(Offset(x, y + 1), 1.7, p);
        canvas.drawPath(
          Path()
            ..moveTo(x - 1.4, y)
            ..lineTo(x, y - 3)
            ..lineTo(x + 1.4, y)
            ..close(),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(PeintreMotif ancien) => ancien.encre != encre;
}

class Fond extends StatelessWidget {
  const Fond({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final f = fondsDiscussion[index % fondsDiscussion.length];
    final c = f.couleurs();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: c),
      ),
      child: f.motif ? CustomPaint(painter: PeintreMotif(OuroColors.label), size: Size.infinite) : const SizedBox.expand(),
    );
  }
}

/// Le raccourci clavier à afficher : ⌘ sur Mac, Ctrl ailleurs.
String touche(String lettres, {required bool mac}) =>
    mac ? lettres.replaceAll('Ctrl+', '⌃').replaceAll('Alt+', '⌥').replaceAll('Maj+', '⇧') : lettres;
