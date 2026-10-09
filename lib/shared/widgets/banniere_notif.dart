// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA BANNIÈRE QUI DESCEND DU HAUT quand un message arrive pendant qu'on est
// ailleurs dans Droplet — celle d'iOS, d'iMessage, de WhatsApp.
//
// Sans elle, un message reçu pendant qu'on règle son profil ne se signale
// que par un son. On ne sait ni de qui il vient, ni ce qu'il dit, et il faut
// quitter ce qu'on fait pour aller voir.
//
// ── CE QU'ON PEUT FAIRE AVEC ───────────────────────────────────────────
//
//   • LA TOUCHER — on va dans la conversation.
//   • LA POUSSER VERS LE HAUT, ou sur le côté — elle s'en va.
//   • LA TIRER VERS LE BAS — elle s'ouvre, avec un champ de réponse. On
//     répond sans quitter l'écran où l'on était. C'est le geste d'iOS sur
//     une notification, et c'est celui qui fait gagner le plus de temps.
//   • NE RIEN FAIRE — elle repart seule au bout de cinq secondes. Le
//     compte à rebours S'ARRÊTE tant qu'un doigt est posé dessus ou qu'elle
//     est ouverte : une bannière qui s'enfuit pendant qu'on la lit, ou
//     pendant qu'on tape, est la pire version de ce composant.
//
// ── ⚠️ UNE CONVERSATION = UNE BANNIÈRE ─────────────────────────────────
//
// Trois messages de la même personne en dix secondes ne font pas trois
// bannières qui se chassent. La bannière reste, son texte change, et une
// seconde carte apparaît derrière elle — la pile d'iOS — pour dire « il y
// en a plusieurs ».
//
// ── ⚠️ POURQUOI UN `Overlay` À ELLE ────────────────────────────────────
//
// Cette couche vit AU-DESSUS du navigateur (dans le `builder` de
// `MaterialApp.router`), là où il n'existe aucun `Overlay`. Or un champ de
// texte en a besoin : ses poignées de sélection, son menu « Coller » et sa
// loupe s'y dessinent. Sans lui, le premier appui long dans le champ de
// réponse ferait planter l'application. Elle s'en fournit donc un.
// ============================================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/config/compte_droplet.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'avatar_groupe.dart';
import 'avatar_officiel.dart';
import 'peer_avatar.dart';

/// Ce qu'une bannière montre.
@immutable
class DonneesBanniere {
  const DonneesBanniere({
    required this.cle,
    required this.route,
    required this.titre,
    required this.texte,
    this.auteur,
    this.auteurId,
    this.groupeId,
    this.monId = '',
    this.icone,
    this.couleurIcone,
    this.repondable = false,
    this.nombre = 1,
  });

  /// Deux bannières de même clé se fondent en une (voir l'en-tête).
  final String cle;
  final String route;
  final String titre;
  final String texte;

  /// Qui parle — dans un groupe, ce n'est pas le titre.
  final String? auteur;
  final String? auteurId;
  final String? groupeId;
  final String monId;

  /// À la place d'un avatar : un appel manqué, par exemple.
  final IconData? icone;
  final Color? couleurIcone;

  /// Tirer vers le bas ouvre un champ de réponse.
  final bool repondable;

  /// Combien de messages cette bannière résume.
  final int nombre;

  DonneesBanniere avecNombre(int n) => DonneesBanniere(
        cle: cle,
        route: route,
        titre: titre,
        texte: texte,
        auteur: auteur,
        auteurId: auteurId,
        groupeId: groupeId,
        monId: monId,
        icone: icone,
        couleurIcone: couleurIcone,
        repondable: repondable,
        nombre: n,
      );
}

/// Le point d'entrée : n'importe qui dans l'application peut montrer une
/// bannière, sans contexte.
class Bannieres {
  Bannieres._();

  static final ValueNotifier<DonneesBanniere?> courante = ValueNotifier(null);

  static void montrer(DonneesBanniere d) {
    final c = courante.value;
    courante.value = (c != null && c.cle == d.cle) ? d.avecNombre(c.nombre + 1) : d;
  }

  static void fermer() => courante.value = null;

  /// Retire la bannière si elle concerne cette conversation — on vient
  /// de l'ouvrir par un autre chemin.
  static void fermerSi(String cle) {
    if (courante.value?.cle == cle) courante.value = null;
  }
}

/// La couche qui porte les bannières, posée une fois autour de l'app.
class CoucheBannieres extends StatefulWidget {
  const CoucheBannieres({
    super.key,
    required this.child,
    required this.naviguer,
    required this.repondre,
  });

  final Widget child;

  /// Emmène vers une route. Fourni par `main.dart` : cette couche est
  /// au-dessus du routeur et ne peut pas le trouver par son contexte.
  final void Function(String route) naviguer;

  /// Envoie une réponse — le même chemin qu'une réponse tapée dans la
  /// notification système.
  final Future<void> Function(String route, String texte) repondre;

  @override
  State<CoucheBannieres> createState() => _CoucheBannieresState();
}

class _CoucheBannieresState extends State<CoucheBannieres> {
  late final OverlayEntry _app =
      OverlayEntry(builder: (_) => widget.child, maintainState: true);
  late final OverlayEntry _couche = OverlayEntry(
    builder: (_) => _Couche(naviguer: widget.naviguer, repondre: widget.repondre),
  );

  @override
  void didUpdateWidget(CoucheBannieres ancien) {
    super.didUpdateWidget(ancien);
    // ⚠️ LES ENTRÉES NE SE RECONSTRUISENT PAS TOUTES SEULES. Un `Overlay`
    // garde ses entrées d'un passage à l'autre ; sans ces deux lignes,
    // l'application resterait figée sur son tout premier `child` — un
    // changement de thème ou de langue ne s'afficherait jamais.
    _app.markNeedsBuild();
    _couche.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) =>
      Overlay(initialEntries: [_app, _couche]);
}

class _Couche extends StatefulWidget {
  const _Couche({required this.naviguer, required this.repondre});

  final void Function(String route) naviguer;
  final Future<void> Function(String route, String texte) repondre;

  @override
  State<_Couche> createState() => _CoucheState();
}

class _CoucheState extends State<_Couche> with TickerProviderStateMixin {
  /// Combien de temps elle reste sans qu'on y touche. iOS : environ cinq
  /// secondes — assez pour lire deux lignes, pas assez pour gêner.
  static const Duration _duree = Duration(seconds: 5);

  /// L'entrée et la sortie. ⚠️ ASYMÉTRIQUES, comme sur iOS : on arrive
  /// avec un ressort (on doit remarquer), on repart vite et sans rebond
  /// (on ne doit pas distraire une seconde fois).
  late final AnimationController _presence = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    reverseDuration: const Duration(milliseconds: 260),
  );

  /// Le retour en place après un geste qui n'a pas abouti.
  late final AnimationController _ressort = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  /// Le petit tressaillement quand un nouveau message arrive dans une
  /// bannière déjà affichée.
  late final AnimationController _sursaut = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  final TextEditingController _reponse = TextEditingController();
  final FocusNode _focus = FocusNode();

  DonneesBanniere? _affichee;
  Timer? _minuteur;
  bool _doigt = false;
  bool _deplie = false;
  bool _envoi = false;

  double _dx = 0;
  double _dy = 0;
  double _dxDepart = 0;
  double _dyDepart = 0;

  /// Vers où elle s'en va : vers le haut, ou sur un côté.
  Offset _fuite = const Offset(0, -1);

  @override
  void initState() {
    super.initState();
    Bannieres.courante.addListener(_surChangement);
    _ressort.addListener(() {
      final t = Curves.easeOutBack.transform(_ressort.value);
      setState(() {
        _dx = _dxDepart * (1 - t);
        _dy = _dyDepart * (1 - t);
      });
    });
  }

  @override
  void dispose() {
    Bannieres.courante.removeListener(_surChangement);
    _minuteur?.cancel();
    _presence.dispose();
    _ressort.dispose();
    _sursaut.dispose();
    _reponse.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _surChangement() {
    final d = Bannieres.courante.value;
    if (d == null) {
      if (_affichee != null && _presence.status != AnimationStatus.reverse) {
        unawaited(_partir());
      }
      return;
    }
    // Une autre conversation arrive pendant qu'on répond à celle-ci : on
    // ne remplace pas le texte sous les doigts de quelqu'un qui écrit. La
    // nouvelle est quand même rangée dans le volet par la notification
    // système, discrète — rien n'est perdu.
    if (_deplie && _affichee != null && _affichee!.cle != d.cle) return;
    final dejaLa = _affichee != null && _presence.value > 0;
    setState(() {
      _affichee = d;
      _fuite = const Offset(0, -1);
    });
    if (dejaLa) {
      unawaited(_sursaut.forward(from: 0));
    } else {
      _dx = 0;
      _dy = 0;
      unawaited(_presence.forward(from: 0));
    }
    _armer();
  }

  void _armer() {
    _minuteur?.cancel();
    if (_doigt || _deplie) return;
    _minuteur = Timer(_duree, () {
      if (!_doigt && !_deplie) Bannieres.fermer();
    });
  }

  Future<void> _partir() async {
    _minuteur?.cancel();
    _focus.unfocus();
    await _presence.reverse();
    if (!mounted) return;
    setState(() {
      _affichee = null;
      _deplie = false;
      _envoi = false;
      _dx = 0;
      _dy = 0;
      _reponse.clear();
    });
    // La bannière a pu être remplacée pendant qu'elle partait.
    if (Bannieres.courante.value != null) _surChangement();
  }

  void _ouvrir() {
    final d = _affichee;
    if (d == null) return;
    OuroHaptics.selection();
    widget.naviguer(d.route);
    Bannieres.fermer();
  }

  void _deplier() {
    if (_deplie || !(_affichee?.repondable ?? false)) return;
    OuroHaptics.selection();
    setState(() => _deplie = true);
    _minuteur?.cancel();
    // Le clavier une fois la carte ouverte, pas pendant : le faire monter
    // en même temps que la carte s'étire donne deux mouvements opposés.
    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (mounted && _deplie) _focus.requestFocus();
    });
  }

  Future<void> _envoyer() async {
    final d = _affichee;
    final texte = _reponse.text.trim();
    if (d == null || texte.isEmpty || _envoi) return;
    setState(() => _envoi = true);
    OuroHaptics.light();
    try {
      await widget.repondre(d.route, texte);
      OuroHaptics.success();
    } catch (_) {}
    if (!mounted) return;
    Bannieres.fermer();
  }

  // ── LES GESTES ─────────────────────────────────────────────────────

  void _poser() {
    _doigt = true;
    _minuteur?.cancel();
    _ressort.stop();
  }

  void _lever() {
    _doigt = false;
    _armer();
  }

  void _glisserVertical(DragUpdateDetails d) {
    setState(() {
      if (d.delta.dy > 0 && _dy >= 0) {
        // Vers le bas : la carte résiste, comme un élastique — elle doit
        // donner l'impression qu'on l'étire, pas qu'on la déplace.
        _dy += d.delta.dy * 0.45;
        if (_dy > 34 && !_deplie && (_affichee?.repondable ?? false)) {
          _deplier();
        }
        _dy = math.min(_dy, 56);
      } else {
        _dy += d.delta.dy;
      }
    });
  }

  void _finVertical(DragEndDetails d) {
    _lever();
    final v = d.velocity.pixelsPerSecond.dy;
    if (v < -260 || _dy < -26) {
      _fuite = const Offset(0, -1);
      Bannieres.fermer();
      return;
    }
    _revenir();
  }

  void _glisserHorizontal(DragUpdateDetails d) {
    if (_deplie) return;
    setState(() => _dx += d.delta.dx);
  }

  void _finHorizontal(DragEndDetails d) {
    _lever();
    final v = d.velocity.pixelsPerSecond.dx;
    if (_dx.abs() > 96 || v.abs() > 700) {
      _fuite = Offset((_dx + v * 0.1).sign, 0);
      Bannieres.fermer();
      return;
    }
    _revenir();
  }

  void _revenir() {
    _dxDepart = _dx;
    _dyDepart = _dy;
    unawaited(_ressort.forward(from: 0));
  }

  // ── LE DESSIN ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final d = _affichee;
    if (d == null) return const SizedBox.shrink();
    final media = MediaQuery.of(context);
    final reduit = media.disableAnimations;
    final largeur = media.size.width;

    return Stack(
      children: [
        // Ouverte, la bannière prend la main : un voile léger, et un
        // toucher à côté la referme — comme sur iOS.
        if (_deplie)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: Bannieres.fermer,
              child: AnimatedBuilder(
                animation: _presence,
                builder: (context, _) => ColoredBox(
                  color: Colors.black.withValues(alpha: 0.22 * _presence.value),
                ),
              ),
            ),
          ),
        Positioned(
          top: media.padding.top + 6,
          left: 8,
          right: 8,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AnimatedBuilder(
                animation: Listenable.merge([_presence, _sursaut]),
                builder: (context, carte) {
                  final p = _presence.value;
                  final entree = _presence.status == AnimationStatus.reverse
                      ? Curves.easeInCubic.transform(p)
                      // Un ressort d'iOS : un léger dépassement, une fois.
                      : Curves.easeOutBack.transform(p);
                  final sortie = 1 - entree;
                  final dx = _dx + _fuite.dx * sortie * largeur;
                  final dy = _dy + _fuite.dy * sortie * 160;
                  // Le sursaut : un millimètre de recul, puis retour.
                  final s = 1 -
                      0.035 * math.sin(math.pi * _sursaut.value) -
                      (reduit ? 0 : 0.06 * sortie);
                  return Opacity(
                    opacity: p,
                    child: Transform.translate(
                      offset: reduit ? Offset(_dx, _dy) : Offset(dx, dy),
                      child: Transform.scale(scale: s, child: carte),
                    ),
                  );
                },
                child: Listener(
                  onPointerDown: (_) => _poser(),
                  onPointerUp: (_) => _lever(),
                  onPointerCancel: (_) => _lever(),
                  child: GestureDetector(
                    onTap: _deplie ? null : _ouvrir,
                    onVerticalDragUpdate: _glisserVertical,
                    onVerticalDragEnd: _finVertical,
                    onHorizontalDragUpdate: _glisserHorizontal,
                    onHorizontalDragEnd: _finHorizontal,
                    child: _Carte(
                      donnees: d,
                      deplie: _deplie,
                      envoi: _envoi,
                      reponse: _reponse,
                      focus: _focus,
                      onEnvoyer: _envoyer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// La carte elle-même.
class _Carte extends StatelessWidget {
  const _Carte({
    required this.donnees,
    required this.deplie,
    required this.envoi,
    required this.reponse,
    required this.focus,
    required this.onEnvoyer,
  });

  final DonneesBanniere donnees;
  final bool deplie;
  final bool envoi;
  final TextEditingController reponse;
  final FocusNode focus;
  final VoidCallback onEnvoyer;

  static const double _rayon = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = donnees;
    final sombre = OuroColors.isDark;

    final carte = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_rayon),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: sombre ? 0.45 : 0.16),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: OuroBlurSurface(
        // ⚠️ ÉPAIS, PAS « REGULAR ». Vu sur la maquette : en verre normal,
        // le grand titre « Discussions » transparaissait sous le texte du
        // message, et les deux se lisaient l'un sur l'autre. Une bannière
        // se lit en une seconde ; rien ne doit lui disputer le regard.
        material: OuroMaterial.thick,
        borderRadius: BorderRadius.circular(_rayon),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_rayon),
            // Le liseré : sans lui, une carte de verre sur un fond de la
            // même teinte n'a plus de bord.
            border: Border.all(
              color: Colors.white.withValues(alpha: sombre ? 0.10 : 0.55),
              width: 0.5,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 14, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Visage(donnees: d),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    d.titre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: OuroTypography.subheadline.copyWith(
                                      color: OuroColors.label,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.ntfNow,
                                  style: OuroTypography.caption1.copyWith(
                                    color: OuroColors.secondaryLabel,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 1),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.topLeft,
                              child: Text(
                                // Dans un groupe, l'auteur précède le texte —
                                // sinon on ne sait pas qui parle.
                                d.groupeId != null && d.auteur != null
                                    ? '${d.auteur} : ${d.texte}'
                                    : d.texte,
                                maxLines: deplie ? 8 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: OuroTypography.subheadline.copyWith(
                                  color: OuroColors.label,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (d.nombre > 1 && !deplie)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  l10n.ntfMoreMessages(d.nombre - 1),
                                  style: OuroTypography.caption1.copyWith(
                                    color: OuroColors.secondaryLabel,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: deplie
                        ? Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: _ChampReponse(
                              controleur: reponse,
                              focus: focus,
                              envoi: envoi,
                              onEnvoyer: onEnvoyer,
                              indice: l10n.ntfYourReply,
                              libelleEnvoyer: l10n.actionSend,
                            ),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                  // La poignée : elle dit qu'on peut tirer. Absente quand
                  // il n'y a rien à ouvrir.
                  if (d.repondable && !deplie)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 34,
                        height: 4,
                        decoration: BoxDecoration(
                          color: OuroColors.tertiaryLabel.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final libelle = d.groupeId != null && d.auteur != null
        ? '${d.titre}, ${d.auteur} : ${d.texte}'
        : '${d.titre}, ${d.texte}';

    return Semantics(
      container: true,
      liveRegion: true,
      button: !deplie,
      label: libelle,
      child: d.nombre > 1 && !deplie
          // ── LA PILE ────────────────────────────────────────────────
          //
          // Une seconde carte dépasse sous la première : « il y en a
          // d'autres ». C'est le dessin d'iOS pour un groupe de
          // notifications, et il se lit avant même le texte.
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: -7,
                  height: 30,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_rayon),
                      color: (sombre ? const Color(0xFF2C2C2E) : Colors.white)
                          .withValues(alpha: 0.72),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: sombre ? 0.3 : 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                carte,
              ],
            )
          : carte,
    );
  }
}

/// L'avatar de la bannière.
class _Visage extends StatelessWidget {
  const _Visage({required this.donnees});

  final DonneesBanniere donnees;

  static const double _rayon = 20;

  @override
  Widget build(BuildContext context) {
    final d = donnees;
    if (d.icone != null) {
      final c = d.couleurIcone ?? OuroColors.accent;
      return Container(
        width: _rayon * 2,
        height: _rayon * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: c.withValues(alpha: 0.16),
        ),
        child: Icon(d.icone, color: c, size: 21),
      );
    }
    if (d.auteurId == CompteDroplet.id) {
      return const AvatarOfficiel(rayon: _rayon, avecBadge: false);
    }
    final auteur = PeerAvatar(
      pseudo: d.auteur ?? d.titre,
      radius: d.groupeId != null ? 9 : _rayon,
      imagePath: AvatarService.cheminPair(d.auteurId),
    );
    if (d.groupeId == null) return auteur;
    // ── GROUPE : LE GROUPE, ET QUI PARLE ────────────────────────────────
    //
    // La notification de communication d'iOS : le visage du groupe, et
    // en pastille celui de l'auteur. On sait d'un coup d'œil OÙ et QUI.
    return SizedBox(
      width: _rayon * 2,
      height: _rayon * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AvatarGroupe(
            groupe: StorageService.getGroup(d.groupeId!),
            monId: d.monId,
            rayon: _rayon,
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: OuroColors.systemBackground, width: 2),
              ),
              child: auteur,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChampReponse extends StatelessWidget {
  const _ChampReponse({
    required this.controleur,
    required this.focus,
    required this.envoi,
    required this.onEnvoyer,
    required this.indice,
    required this.libelleEnvoyer,
  });

  final TextEditingController controleur;
  final FocusNode focus;
  final bool envoi;
  final VoidCallback onEnvoyer;
  final String indice;
  final String libelleEnvoyer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: OuroColors.tertiarySystemFill,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: controleur,
              focusNode: focus,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onEnvoyer(),
              cursorColor: OuroColors.accent,
              style: OuroTypography.body.copyWith(color: OuroColors.label),
              decoration: InputDecoration(
                hintText: indice,
                hintStyle: OuroTypography.body.copyWith(
                  color: OuroColors.tertiaryLabel,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controleur,
          builder: (context, valeur, _) {
            final actif = valeur.text.trim().isNotEmpty && !envoi;
            return Semantics(
              button: true,
              label: libelleEnvoyer,
              child: GestureDetector(
                onTap: actif ? onEnvoyer : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: actif
                        ? OuroColors.accentRempli
                        : OuroColors.tertiarySystemFill,
                  ),
                  child: envoi
                      ? Padding(
                          padding: const EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: OuroColors.texteSurAccent,
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          size: 21,
                          color: actif
                              ? OuroColors.texteSurAccent
                              : OuroColors.tertiaryLabel,
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
