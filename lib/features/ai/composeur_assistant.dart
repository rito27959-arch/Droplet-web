// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE COMPOSEUR DE L'ASSISTANT — le champ où l'on écrit, et tout ce qui
// l'entoure.
//
// ── CE QU'ON A REPRIS AUX GRANDS ──────────────────────────────────────
//
// UN SEUL BOUTON « + » À GAUCHE. C'est la forme de Claude, de ChatGPT et
// de Gemini, et elle tient parce que la liste de ce qu'on peut joindre
// grandit toujours : une rangée d'icônes finit par déborder, un menu non.
//
// LE BOUTON D'ENVOI DEVIENT LE BOUTON STOP pendant la génération, au même
// endroit et à la même taille. Deux boutons distincts feraient viser un
// point différent selon l'état, exactement au moment où l'on est pressé.
//
// LES PASTILLES DE DÉPART sous un champ vide, qui disparaissent dès qu'on
// tape — elles servent à quelqu'un qui ne sait pas quoi demander, et
// gênent tous les autres.
//
// ── ET CE QU'ON A REFUSÉ ──────────────────────────────────────────────
//
// ⚠️ PAS DE PASTILLES DE MODE (« recherche », « raisonner », « image »).
// Anthropic les a supprimées en septembre 2026 en disant que les gens
// choisissaient mal. Droplet décide seul quel outil employer. La SEULE
// pastille qui reste est Local / En ligne, parce qu'elle ne parle pas de
// qualité mais de l'endroit où part le message — voir
// `selecteur_moteur.dart`.
//
// ⚠️ ET LE TROMBONE, LUI, DISPARAÎT DANS LE « + ». Le démontage public
// du composeur de ChatGPT reproche ce choix, au motif qu'il va contre
// trente ans d'habitude e-mail — l'objection vaut pour une messagerie,
// où joindre une photo est un geste quotidien. Elle ne vaut pas ici :
// on parle à un assistant, on ne lui envoie pas des photos toute la
// journée. Une icône permanente pour un geste occasionnel coûte de la
// place à chaque écran, et c'est le champ de saisie qui la paie.
//
// ⚠️ IL N'Y A PLUS DE PHOTO DU TOUT, d'ailleurs — voir [ActionJointe].
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/conversations_ia_store.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'selecteur_moteur.dart';
import 'competences_assistant.dart' show texteAccueil;
import '../../core/services/superposition_glasmio.dart';

/// Ce que le « + » propose.
///
/// ⚠️ NI PHOTO NI APPAREIL PHOTO. Groq ne sert plus aucun modèle capable
/// de lire une image depuis juillet 2026 : une photo jointe partait vers
/// un modèle qui ne pouvait rien en faire, et la réponse était inventée
/// à partir du nom du fichier. Un bouton qui promet ce que le moteur ne
/// sait pas faire est pire qu'un bouton absent.
enum ActionJointe { fichier }

class ComposeurAssistant extends StatefulWidget {
  const ComposeurAssistant({
    super.key,
    required this.controller,
    required this.onEnvoyer,
    required this.onArreter,
    required this.genereEnCours,
    required this.moteur,
    required this.enLigneDisponible,
    required this.onChangerMoteur,
    this.localInstalle = true,
    required this.onJoindre,
    this.piecesJointes = const [],
    this.onRetirerPiece,
    this.suggestions = const [],
    this.onSuggestion,
    this.onDicter,
    this.onVocal,
    this.afficherMoteur = true,
    this.modeVocal = false,
    this.onBasculerMode,
    this.onParlerDebut,
    this.onParlerFin,
    this.enregistre = false,
    this.transcrit = false,
    this.niveau = 0,
  });

  /// Faux quand le moteur est choisi ailleurs (la pastille du haut, comme
  /// chez Kimi) : le composeur ne le montre pas deux fois.
  final bool afficherMoteur;

  /// LE COMPOSEUR « MAINTENEZ APPUYÉ POUR PARLER », à la manière de Kimi :
  /// « + » à gauche, la grande zone où l'on garde le doigt pour parler, et
  /// le clavier à droite pour revenir au texte. On relâche : la phrase est
  /// transcrite et envoyée. On glisse vers le haut : on annule.
  final bool modeVocal;
  final VoidCallback? onBasculerMode;
  final VoidCallback? onParlerDebut;
  final void Function(bool annule)? onParlerFin;

  /// Le micro écoute (le doigt est posé).
  final bool enregistre;

  /// La phrase part en transcription.
  final bool transcrit;

  /// Le niveau de la voix, de 0 à 1, pour les barres.
  final double niveau;

  final TextEditingController controller;
  final VoidCallback onEnvoyer;
  final VoidCallback onArreter;
  final bool genereEnCours;

  final OrigineReponse moteur;
  final bool enLigneDisponible;

  /// Faux quand le modèle local n'est pas encore sur l'appareil : la
  /// feuille annonce alors ce que le choisir va coûter.
  final bool localInstalle;

  final void Function(OrigineReponse) onChangerMoteur;

  final Future<void> Function(ActionJointe) onJoindre;

  /// Chemins des fichiers déjà attachés, affichés en vignettes.
  final List<String> piecesJointes;
  final void Function(int index)? onRetirerPiece;

  /// Les pastilles sous un champ vide. Vide = aucune.
  final List<String> suggestions;
  final void Function(String)? onSuggestion;

  /// La dictée. `null` masque le micro — mieux qu'un bouton qui ne fait
  /// rien sur un appareil sans reconnaissance vocale.
  final VoidCallback? onDicter;

  /// Le mode vocal — une CONVERSATION à voix haute, pas de la dictée.
  ///
  /// ⚠️ DEUX BOUTONS, ET C'EST VOULU. Le micro écrit dans le champ : on
  /// relit, on corrige, on envoie. L'onde ouvre un écran où l'on parle et
  /// où ça répond à haute voix, sans rien à lire. Claude et ChatGPT les
  /// séparent tous les deux ; les fondre donnerait un bouton qui fait
  /// tantôt l'un tantôt l'autre, et personne ne saurait lequel.
  final VoidCallback? onVocal;

  @override
  State<ComposeurAssistant> createState() => _ComposeurAssistantState();
}

class _ComposeurAssistantState extends State<ComposeurAssistant> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  Future<void> _menuPlus() async {
    OuroHaptics.light();
    // La feuille d'actions de verre Glasmio (Android 13+), comme le « + »
    // de Kimi qui ouvre une feuille ; sinon la feuille Flutter.
    final l10n = AppLocalizations.of(context);
    final verre = await SuperpositionGlasmio.feuille(
      message: l10n.cpNoPhoto,
      boutons: [
        BoutonGlasmio('fichier', l10n.cpFile),
        BoutonGlasmio('annuler', l10n.actionCancel, annuler: true),
      ],
    );
    if (verre != null) {
      if (verre.id == 'fichier') await widget.onJoindre(ActionJointe.fichier);
      return;
    }
    if (!mounted) return;
    final choix = await showModalBottomSheet<ActionJointe>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MenuPlus(),
    );
    if (choix != null) await widget.onJoindre(choix);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: widget.controller,
      builder: (context, valeur, _) {
        final vide = valeur.text.trim().isEmpty;
        final peutEnvoyer = !vide || widget.piecesJointes.isNotEmpty;

        if (widget.modeVocal && !widget.genereEnCours) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.space3,
              DesignTokens.space2,
              DesignTokens.space3,
              DesignTokens.space2,
            ),
            child: _BarreVocale(
              langue: l10n.localeName,
              onPlus: _menuPlus,
              onClavier: widget.onBasculerMode,
              onDebut: widget.onParlerDebut,
              onFin: widget.onParlerFin,
              enregistre: widget.enregistre,
              transcrit: widget.transcrit,
              niveau: widget.niveau,
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Les pastilles de départ : seulement sur un champ vraiment
            // vide, sans pièce jointe et sans génération en cours.
            if (vide &&
                widget.piecesJointes.isEmpty &&
                !widget.genereEnCours &&
                widget.suggestions.isNotEmpty)
              _Suggestions(
                items: widget.suggestions,
                onChoisir: (s) {
                  OuroHaptics.selection();
                  widget.onSuggestion?.call(s);
                },
              ),

            if (widget.piecesJointes.isNotEmpty)
              _Vignettes(
                chemins: widget.piecesJointes,
                onRetirer: widget.onRetirerPiece,
              ),

            // ⚠️ LE CHAMP EN HAUT, LES COMMANDES EN DESSOUS. Les mettre
            // sur la même ligne oblige à rétrécir le champ à chaque
            // bouton ajouté, et c'est ce qui finit par donner une barre
            // où l'on écrit dans un couloir. Les grandes applications
            // ont toutes basculé sur deux étages : le texte occupe
            // toute la largeur, les commandes vivent sous lui.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.space3,
                DesignTokens.space2,
                DesignTokens.space3,
                DesignTokens.space2,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
                decoration: BoxDecoration(
                  color: OuroColors.secondarySystemBackground,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSheet),
                  border: Border.all(color: OuroColors.separator, width: 0.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focus,
                        minLines: 1,
                        // ⚠️ SIX LIGNES AU PLUS, PUIS ÇA DÉFILE. Sans
                        // cette borne, un texte collé depuis un autre
                        // écran pousse le composeur jusqu'en haut et
                        // fait disparaître la conversation entière.
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: OuroTypography.body.copyWith(
                          color: OuroColors.label,
                          height: 1.3,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: l10n.cpHint,
                          hintStyle: OuroTypography.body.copyWith(
                            color: OuroColors.tertiaryLabel,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _BoutonRond(
                          icone: Icons.add_rounded,
                          libelle: l10n.cpAdd,
                          onTap: widget.genereEnCours ? null : _menuPlus,
                        ),
                        const SizedBox(width: 2),
                        if (widget.afficherMoteur)
                          SelecteurMoteur(
                            moteur: widget.moteur,
                            enLigneDisponible: widget.enLigneDisponible,
                            localInstalle: widget.localInstalle,
                            onChanger: widget.onChangerMoteur,
                          ),
                        const Spacer(),
                        if (widget.onBasculerMode != null && vide && widget.piecesJointes.isEmpty)
                          _BoutonRond(
                            icone: Icons.mic_none_rounded,
                            libelle: texteAccueil(l10n.localeName, 'voix'),
                            onTap: widget.genereEnCours ? null : widget.onBasculerMode,
                          ),
                        if (widget.onDicter != null)
                          _BoutonRond(
                            icone: Icons.mic_none_rounded,
                            libelle: l10n.cpDictate,
                            onTap: widget.genereEnCours
                                ? null
                                : widget.onDicter,
                          ),
                        if (widget.onVocal != null) ...[
                          const SizedBox(width: 2),
                          _BoutonRond(
                            icone: Icons.graphic_eq_rounded,
                            libelle: l10n.mvOpen,
                            onTap: widget.genereEnCours
                                ? null
                                : widget.onVocal,
                          ),
                        ],
                        const SizedBox(width: 4),
                        _BoutonEnvoi(
                          genereEnCours: widget.genereEnCours,
                          actif: peutEnvoyer,
                          onEnvoyer: widget.onEnvoyer,
                          onArreter: widget.onArreter,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ══ LE BOUTON D'ENVOI, QUI DEVIENT STOP ════════════════════════════════

class _BoutonEnvoi extends StatelessWidget {
  const _BoutonEnvoi({
    required this.genereEnCours,
    required this.actif,
    required this.onEnvoyer,
    required this.onArreter,
  });

  final bool genereEnCours;
  final bool actif;
  final VoidCallback onEnvoyer;
  final VoidCallback onArreter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final peut = genereEnCours || actif;

    return Semantics(
      button: true,
      label: genereEnCours ? l10n.cpStop : l10n.cpSend,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: peut
            ? () {
                OuroHaptics.light();
                genereEnCours ? onArreter() : onEnvoyer();
              }
            : null,
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          curve: DesignTokens.curveEnter,
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: peut
                ? OuroColors.accentRempli
                : OuroColors.quaternarySystemFill,
          ),
          child: AnimatedSwitcher(
            duration: DesignTokens.durationFast,
            transitionBuilder: (enfant, anim) =>
                ScaleTransition(scale: anim, child: enfant),
            child: genereEnCours
                ? Icon(
                    Icons.stop_rounded,
                    key: const ValueKey('stop'),
                    size: DesignTokens.iconMd,
                    color: OuroColors.texteSurAccent,
                  )
                : Icon(
                    Icons.arrow_upward_rounded,
                    key: const ValueKey('envoyer'),
                    size: DesignTokens.iconMd,
                    color: peut
                        ? OuroColors.texteSurAccent
                        : OuroColors.tertiaryLabel,
                  ),
          ),
        ),
      ),
    );
  }
}

// ══ LE MENU DU « + » ═══════════════════════════════════════════════════

class _MenuPlus extends StatelessWidget {
  const _MenuPlus();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OuroListSection(
              footer: l10n.cpNoPhoto,
              children: [
                OuroListRow(
                  icon: Icons.attach_file_rounded,
                  iconColor: OuroColors.accent,
                  title: l10n.cpFile,
                  subtitle: l10n.cpFileHint,
                  showChevron: false,
                  onTap: () => Navigator.pop(context, ActionJointe.fichier),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space2),
            OuroListSection(
              children: [
                OuroListRow(
                  title: l10n.actionCancel,
                  showChevron: false,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══ LES VIGNETTES DE PIÈCES JOINTES ════════════════════════════════════

class _Vignettes extends StatelessWidget {
  const _Vignettes({required this.chemins, required this.onRetirer});

  final List<String> chemins;
  final void Function(int)? onRetirer;

  static const _images = {'.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic'};

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space3,
        ),
        itemCount: chemins.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: DesignTokens.space2),
        itemBuilder: (context, i) {
          final chemin = chemins[i];
          final point = chemin.lastIndexOf('.');
          final ext =
              point < 0 ? '' : chemin.substring(point).toLowerCase();
          final estImage = _images.contains(ext);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                child: Container(
                  width: 54,
                  height: 54,
                  color: OuroColors.tertiarySystemFill,
                  child: estImage
                      ? Image.file(
                          File(chemin),
                          fit: BoxFit.cover,
                          // Une image effacée entre-temps ne doit pas
                          // faire éclater le composeur.
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            size: DesignTokens.iconMd,
                            color: OuroColors.tertiaryLabel,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: DesignTokens.iconMd,
                              color: OuroColors.secondaryLabel,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ext.replaceFirst('.', '').toUpperCase(),
                              style: OuroTypography.caption1.copyWith(
                                fontSize: 9,
                                color: OuroColors.tertiaryLabel,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (onRetirer != null)
                Positioned(
                  top: -5,
                  right: -5,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      OuroHaptics.light();
                      onRetirer!(i);
                    },
                    // Une zone de 28 points autour d'une croix de 18 :
                    // la croix doit rester petite, la cible non.
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: OuroColors.label,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 12,
                          color: OuroColors.systemBackground,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ══ LES PASTILLES DE DÉPART ════════════════════════════════════════════

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.items, required this.onChoisir});

  final List<String> items;
  final void Function(String) onChoisir;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space3,
          ),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, i) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChoisir(items[i]),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: OuroColors.tertiarySystemFill,
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
              child: Text(
                items[i],
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.label,
                ),
              ),
            ),
          ),
        ),
      );
}

// ══ PETITS BOUTONS ═════════════════════════════════════════════════════

class _BoutonRond extends StatelessWidget {
  const _BoutonRond({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: libelle,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icone,
              size: DesignTokens.iconLg,
              color: onTap == null
                  ? OuroColors.tertiaryLabel
                  : OuroColors.secondaryLabel,
            ),
          ),
        ),
      );
}

/// Le petit indicateur montré tant que la réponse n'a pas commencé à
/// s'écrire — entre l'envoi et le premier mot, il ne se passe rien à
/// l'écran, et c'est le moment où l'on croit que ça a raté.
class AttenteReponse extends StatelessWidget {
  const AttenteReponse({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.screenMargin,
        vertical: DesignTokens.space2,
      ),
      child: Row(
        children: [
          OuroSpinner(color: OuroColors.tertiaryLabel, radius: 8),
          const SizedBox(width: DesignTokens.space2),
          Text(
            l10n.cpThinking,
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
            ),
          ),
        ],
      ),
    );
  }
}


// ══ LA BARRE « MAINTENEZ APPUYÉ POUR PARLER » ══════════════════════════

class _BarreVocale extends StatefulWidget {
  const _BarreVocale({
    required this.langue,
    required this.onPlus,
    required this.onClavier,
    required this.onDebut,
    required this.onFin,
    required this.enregistre,
    required this.transcrit,
    required this.niveau,
  });

  final String langue;
  final VoidCallback onPlus;
  final VoidCallback? onClavier;
  final VoidCallback? onDebut;
  final void Function(bool annule)? onFin;
  final bool enregistre;
  final bool transcrit;
  final double niveau;

  @override
  State<_BarreVocale> createState() => _BarreVocaleState();
}

class _BarreVocaleState extends State<_BarreVocale> {
  /// Le doigt est monté assez haut : relâcher annulera.
  bool _annuler = false;

  @override
  Widget build(BuildContext context) {
    final ecoute = widget.enregistre;
    final fond = ecoute
        ? (_annuler ? OuroColors.systemRed : OuroColors.accent)
        : OuroColors.secondarySystemBackground;
    final encre = ecoute ? Colors.white : OuroColors.label;
    final texte = widget.transcrit
        ? texteAccueil(widget.langue, 'transcription')
        : ecoute
            ? (_annuler ? texteAccueil(widget.langue, 'annuler') : texteAccueil(widget.langue, 'relacher'))
            : texteAccueil(widget.langue, 'maintenir');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: OuroColors.separator.withValues(alpha: ecoute ? 0 : 0.7), width: 0.5),
        boxShadow: [
          if (ecoute)
            BoxShadow(color: fond.withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          _Rond(
            icone: Icons.add_rounded,
            libelle: AppLocalizations.of(context).cpAdd,
            couleur: encre,
            onTap: ecoute || widget.transcrit ? null : widget.onPlus,
          ),
          Expanded(
            child: Semantics(
              button: true,
              label: texte,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: widget.transcrit
                    ? null
                    : (_) {
                        OuroHaptics.medium();
                        setState(() => _annuler = false);
                        widget.onDebut?.call();
                      },
                onLongPressMoveUpdate: (d) {
                  final a = d.offsetFromOrigin.dy < -70;
                  if (a != _annuler) {
                    OuroHaptics.selection();
                    setState(() => _annuler = a);
                  }
                },
                onLongPressEnd: (_) {
                  widget.onFin?.call(_annuler);
                  setState(() => _annuler = false);
                },
                onLongPressCancel: () {
                  if (widget.enregistre) widget.onFin?.call(true);
                },
                child: SizedBox(
                  height: 64,
                  child: Center(
                    child: ecoute && !_annuler
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _Ondes(niveau: widget.niveau, couleur: encre),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  texte,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: OuroTypography.headline.copyWith(color: encre),
                                ),
                              ),
                            ],
                          )
                        : widget.transcrit
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const OuroSpinner(radius: 8),
                                  const SizedBox(width: 10),
                                  Text(texte, style: OuroTypography.headline.copyWith(color: OuroColors.secondaryLabel)),
                                ],
                              )
                            : Text(
                                texte,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: OuroTypography.headline.copyWith(color: encre),
                              ),
                  ),
                ),
              ),
            ),
          ),
          _Rond(
            icone: Icons.keyboard_alt_outlined,
            libelle: texteAccueil(widget.langue, 'clavier'),
            couleur: encre,
            onTap: ecoute || widget.transcrit ? null : widget.onClavier,
          ),
        ],
      ),
    );
  }
}

/// Un bouton rond de la barre vocale, sur un disque légèrement plus clair.
class _Rond extends StatelessWidget {
  const _Rond({required this.icone, required this.libelle, required this.couleur, this.onTap});

  final IconData icone;
  final String libelle;
  final Color couleur;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: libelle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null
            ? null
            : () {
                OuroHaptics.light();
                onTap!();
              },
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: OuroColors.tertiarySystemFill,
          ),
          child: Icon(icone, size: 26, color: couleur.withValues(alpha: onTap == null ? 0.4 : 1)),
        ),
      ),
    );
  }
}

/// Cinq barres qui suivent la voix.
class _Ondes extends StatelessWidget {
  const _Ondes({required this.niveau, required this.couleur});

  final double niveau;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    const formes = [0.45, 0.8, 1.0, 0.7, 0.4];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final f in formes)
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 3.5,
            height: 6 + 20 * f * niveau.clamp(0.08, 1.0),
            decoration: BoxDecoration(color: couleur, borderRadius: BorderRadius.circular(2)),
          ),
      ],
    );
  }
}
