// LES ACTUS — les statuts de 24 heures, comme l'onglet de l'app.
//
//   • La colonne : « Mon statut » (publier, revoir le mien), puis les
//     contacts — non vus d'abord, avec l'anneau de couleur ; déjà vus en
//     dessous, anneau gris.
//   • La visionneuse, plein écran : barres de progression, défilement
//     automatique (5 s), clic à gauche/à droite ou ← → pour naviguer,
//     maintenir pour mettre en pause, ♥ et réponse (qui part en message
//     privé) ; sur le mien, « Vu par » et la corbeille.
//   • La création : un texte sur un fond de couleur, ou une photo avec
//     légende.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/depot.dart';
import '../donnees/modeles.dart';
import '../shared/widgets/story_progress_bar.dart';
import '../web/navigateur.dart';
import 'composants.dart';
import 'portee.dart';

String ilYa(BuildContext context, DateTime d) {
  final l = context.l;
  final e = DateTime.now().difference(d);
  if (e.inMinutes < 1) return l.svJustNow;
  if (e.inHours < 1) return l.svMinutesAgo(e.inMinutes);
  return l.svHoursAgo(e.inHours);
}

class ColonneActus extends StatelessWidget {
  const ColonneActus({super.key});

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final auteurs = depot.auteursStatuts();
    final nonVus = auteurs.where((a) => !depot.statutsTousVus(a)).toList();
    final vus = auteurs.where(depot.statutsTousVus).toList();
    final miens = depot.statutsDe(kMoi);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntetePanneau(
          titre: l.nwTitle,
          actions: [
            BoutonIcone(icone: Icons.edit_outlined, aide: l.nwPublishStatus, couleur: OuroColors.accent, onTap: () => creerStatut(context)),
            BoutonIcone(
              icone: Icons.photo_camera_outlined,
              aide: l.nwPhoto,
              couleur: OuroColors.accent,
              onTap: () => creerStatut(context, photo: true),
            ),
            BoutonIcone(
              icone: Icons.videocam_outlined,
              aide: t.statutVideo,
              couleur: OuroColors.accent,
              onTap: () => creerStatut(context, mode: 'video'),
            ),
            BoutonIcone(
              icone: Icons.mic_none_rounded,
              aide: t.statutVocal,
              couleur: OuroColors.accent,
              onTap: () => creerStatut(context, mode: 'voice'),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
            children: [
              Survol(
                onTap: () => miens.isEmpty ? creerStatut(context) : voirStatuts(context, [kMoi]),
                builder: (context, survol) => AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          AvatarDroplet(
                            nom: depot.nom(kMoi),
                            couleur: depot.profil.couleur,
                            photo: depot.profil.photo,
                            taille: 54,
                            anneau: miens.isEmpty ? null : false,
                          ),
                          if (miens.isEmpty)
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: OuroColors.accentRempli,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: OuroColors.secondarySystemGroupedBackground, width: 2.5),
                                ),
                                child: Icon(Icons.add_rounded, size: 14, color: OuroColors.texteSurAccent),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.nwMyStatus, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
                            Text(
                              miens.isEmpty ? l.nwTapToPublish : '${l.nwStatusesCount(miens.length)} · ${ilYa(context, miens.last.date)}',
                              style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                            ),
                          ],
                        ),
                      ),
                      if (miens.isNotEmpty)
                        BoutonIcone(icone: Icons.add_circle_outline_rounded, couleur: OuroColors.accent, aide: l.nwAddStatus, onTap: () => creerStatut(context)),
                    ],
                  ),
                ),
              ),
              if (nonVus.isNotEmpty) ...[
                _Titre(l.nwRecent),
                for (final a in nonVus) _LigneStatut(auteur: a, tous: [...nonVus, ...vus]),
              ],
              if (vus.isNotEmpty) ...[
                _Titre(l.nwSeenSection),
                for (final a in vus) _LigneStatut(auteur: a, tous: [...nonVus, ...vus]),
              ],
              if (auteurs.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: EtatVide(icone: Icons.podcasts_rounded, titre: l.nwNoNewsYet, texte: l.nwStatusesAppearHere),
                ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: OuroColors.tertiaryLabel),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(t.statutsChiffres, textAlign: TextAlign.center, style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Titre extends StatelessWidget {
  const _Titre(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
        child: Text(texte.toUpperCase(), style: OuroTypography.sectionHeader.copyWith(color: OuroColors.secondaryLabel)),
      );
}

class _LigneStatut extends StatelessWidget {
  const _LigneStatut({required this.auteur, required this.tous});

  final String auteur;
  final List<String> tous;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final statuts = depot.statutsDe(auteur);
    final c = depot.contacts[auteur];
    return Survol(
      onTap: () => voirStatuts(context, tous.sublist(tous.indexOf(auteur))),
      builder: (context, survol) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            AvatarDroplet(nom: depot.nom(auteur), couleur: c?.couleur ?? 0, taille: 54, anneau: !depot.statutsTousVus(auteur)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(depot.nom(auteur), style: OuroTypography.headline.copyWith(color: OuroColors.label)),
                  Text(
                    statuts.isEmpty ? '' : ilYa(context, statuts.last.date),
                    style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                  ),
                ],
              ),
            ),
            if (statuts.length > 1)
              Text('${statuts.length}', style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel)),
          ],
        ),
      ),
    );
  }
}

// ── La visionneuse ─────────────────────────────────────────────────────

/// Ouvre les statuts des [auteurs], à la suite.
Future<void> voirStatuts(BuildContext context, List<String> auteurs) {
  return Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
    opaque: false,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (_, __, ___) => _Visionneuse(auteurs: auteurs),
    transitionsBuilder: (_, a, __, enfant) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(CurvedAnimation(parent: a, curve: kSortie)), child: enfant),
    ),
  ));
}

class _Visionneuse extends StatefulWidget {
  const _Visionneuse({required this.auteurs});

  final List<String> auteurs;

  @override
  State<_Visionneuse> createState() => _VisionneuseState();
}

class _VisionneuseState extends State<_Visionneuse> with SingleTickerProviderStateMixin {
  late final AnimationController _temps = AnimationController(vsync: this, duration: const Duration(seconds: 5))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _suivant();
    });
  int _auteur = 0;
  int _index = 0;
  final _reponse = TextEditingController();
  final _focusReponse = FocusNode();
  late final Depot _depot;

  @override
  void initState() {
    super.initState();
    _depot = context.lire.depot;
    // Ses propres statuts : du premier. Ceux des autres : du premier non vu.
    final l = _statuts;
    final premier = l.indexWhere((s) => !s.vuPar.contains(kMoi));
    _index = widget.auteurs.first == kMoi || premier < 0 ? 0 : premier;
    _demarrer();
    _focusReponse.addListener(() {
      _focusReponse.hasFocus ? _temps.stop() : _temps.forward();
    });
  }

  List<Statut> get _statuts => _depot.statutsDe(widget.auteurs[_auteur]);

  /// Une vidéo ou un vocal : la barre suit sa vraie durée (bornée), au
  /// lieu des 5 secondes d'une photo.
  void _dureeMedia(Duration d) {
    final borne = Duration(milliseconds: d.inMilliseconds.clamp(3000, 60000));
    if (_temps.duration == borne) return;
    final avancement = _temps.value;
    _temps.duration = borne;
    if (_temps.isAnimating) _temps.forward(from: avancement);
  }

  void _demarrer() {
    final l = _statuts;
    if (l.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fermer());
      return;
    }
    final vu = l[_index.clamp(0, l.length - 1)];
    final p = vu.piece;
    _temps.duration = switch (vu.type) {
      'voice' when p?.dureeMs != null => Duration(milliseconds: p!.dureeMs!.clamp(3000, 60000)),
      'video' || 'voice' => const Duration(seconds: 15),
      _ => const Duration(seconds: 5),
    };
    // Hors de la construction : le dépôt prévient tous les écrans.
    Future.microtask(() => _depot.marquerStatutVu(vu));
    _temps.forward(from: 0);
  }

  void _suivant() {
    if (_index < _statuts.length - 1) {
      setState(() => _index++);
    } else if (_auteur < widget.auteurs.length - 1) {
      setState(() {
        _auteur++;
        _index = 0;
      });
    } else {
      _fermer();
      return;
    }
    _demarrer();
  }

  void _precedent() {
    if (_index > 0) {
      setState(() => _index--);
    } else if (_auteur > 0) {
      setState(() {
        _auteur--;
        _index = _statuts.length - 1;
      });
    }
    _demarrer();
  }

  /// Aller directement aux statuts de l'auteur [i].
  void _allerA(int i) {
    if (i < 0 || i >= widget.auteurs.length || i == _auteur) return;
    setState(() {
      _auteur = i;
      final l = _statuts;
      final premier = l.indexWhere((s) => !s.vuPar.contains(kMoi));
      _index = premier < 0 ? 0 : premier;
    });
    _demarrer();
  }

  List<Widget> _cotes(BuildContext context) {
    final taille = MediaQuery.sizeOf(context);
    final hCarte = taille.height - 40;
    final lCarte = hCarte * 9 / 16;
    final hVignette = hCarte * 0.5;
    final lVignette = hVignette * 9 / 16;
    const ecart = 64.0;
    // Pas la place : la carte seule, comme sur téléphone.
    if (taille.width < lCarte + 2 * (ecart + lVignette) + 48) return const [];
    final cx = taille.width / 2;
    Widget fleche(IconData icone, VoidCallback? onTap, double x) => Positioned(
          left: x - 22,
          top: taille.height / 2 - 22,
          child: AnimatedOpacity(
            opacity: onTap == null ? 0 : 1,
            duration: const Duration(milliseconds: 200),
            child: Survol(
              onTap: onTap,
              builder: (context, survol) => AnimatedScale(
                scale: survol ? 1.08 : 1,
                duration: const Duration(milliseconds: 160),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: 44,
                      height: 44,
                      color: Colors.white.withValues(alpha: survol ? 0.28 : 0.18),
                      child: Icon(icone, color: Colors.white, size: 26),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    final premierStatut = _index == 0 && _auteur == 0;
    final dernierStatut = _auteur == widget.auteurs.length - 1 && _index >= _statuts.length - 1;
    return [
      if (_auteur > 0)
        Positioned(
          left: cx - lCarte / 2 - ecart - lVignette,
          top: (taille.height - hVignette) / 2,
          width: lVignette,
          height: hVignette,
          child: _Vignette(auteur: widget.auteurs[_auteur - 1], onTap: () => _allerA(_auteur - 1)),
        ),
      if (_auteur < widget.auteurs.length - 1)
        Positioned(
          left: cx + lCarte / 2 + ecart,
          top: (taille.height - hVignette) / 2,
          width: lVignette,
          height: hVignette,
          child: _Vignette(auteur: widget.auteurs[_auteur + 1], onTap: () => _allerA(_auteur + 1)),
        ),
      fleche(Icons.chevron_left_rounded, premierStatut ? null : _precedent, cx - lCarte / 2 - ecart / 2),
      fleche(Icons.chevron_right_rounded, dernierStatut ? null : _suivant, cx + lCarte / 2 + ecart / 2),
    ];
  }

  bool _ferme = false;
  void _fermer() {
    if (_ferme) return;
    _ferme = true;
    _temps.stop();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _temps.dispose();
    _reponse.dispose();
    _focusReponse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final statuts = _statuts;
    if (statuts.isEmpty) return const SizedBox.shrink();
    final s = statuts[_index.clamp(0, statuts.length - 1)];
    final mien = s.auteurId == kMoi;
    final fond = fondsStatut[s.fond % fondsStatut.length];

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _fermer,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _suivant,
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _precedent,
        const SingleActivator(LogicalKeyboardKey.space): () => _temps.isAnimating ? _temps.stop() : _temps.forward(),
      },
      child: Focus(
        autofocus: true,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: const ColoredBox(color: Color(0xF0000000)),
                ),
              ),
              // Le halo : les couleurs du statut, immenses et floues, derrière
              // la carte — l'écran entier prend la teinte de ce qu'on regarde.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: SizedBox.expand(
                      key: ValueKey('halo-${s.id}'),
                      child: Opacity(
                        opacity: 0.42,
                        child: ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(sigmaX: 90, sigmaY: 90, tileMode: TileMode.decal),
                          child: s.image != null
                              ? Image.network(s.image!, fit: BoxFit.cover)
                              : DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: s.couleur != null ? Color(s.couleur!) : null,
                                    gradient: s.couleur != null
                                        ? null
                                        : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fond),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: IgnorePointer(child: ColoredBox(color: Colors.black.withValues(alpha: 0.35)))),
              // Sur grand écran : le contact précédent et le suivant, en
              // vignettes de part et d'autre, et des flèches pour avancer.
              ..._cotes(context),
              Center(
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          // Le contenu.
                          Positioned.fill(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              child: KeyedSubtree(
                                key: ValueKey(s.id),
                                child: s.image != null
                                    ? ColoredBox(
                                        color: Colors.black,
                                        child: Image.network(s.image!, fit: BoxFit.contain),
                                      )
                                    : s.piece != null
                                    ? _MediaStatut(statut: s, fond: fond, surDuree: _dureeMedia)
                                    : DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: s.couleur != null ? Color(s.couleur!) : null,
                                          gradient: s.couleur != null ? null : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fond),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(32),
                                            child: Text(
                                              s.texte,
                                              textAlign: TextAlign.center,
                                              style: OuroTypography.title1.copyWith(
                                                color: Colors.white,
                                                fontSize: s.texte.length < 40 ? 32 : 24,
                                                height: 1.25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          if ((s.image != null || s.type == 'photo' || s.type == 'video') && s.texte.isNotEmpty)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 90,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                color: Colors.black45,
                                child: Text(s.texte, textAlign: TextAlign.center, style: OuroTypography.body.copyWith(color: Colors.white)),
                              ),
                            ),
                          // Les zones de clic : à gauche, précédent ; à
                          // droite, suivant ; maintenir, pause.
                          Positioned.fill(
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _precedent,
                                    onLongPressStart: (_) => _temps.stop(),
                                    onLongPressEnd: (_) => _temps.forward(),
                                    child: const MouseRegion(cursor: SystemMouseCursors.click, child: ColoredBox(color: Colors.transparent)),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: GestureDetector(
                                    onTap: _suivant,
                                    onLongPressStart: (_) => _temps.stop(),
                                    onLongPressEnd: (_) => _temps.forward(),
                                    child: const MouseRegion(cursor: SystemMouseCursors.click, child: ColoredBox(color: Colors.transparent)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // En haut : barres, auteur, fermer.
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 10, 6, 20),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x66000000), Color(0x00000000)]),
                              ),
                              child: Column(
                                children: [
                                  AnimatedBuilder(
                                    animation: _temps,
                                    builder: (context, _) => StoryProgressBar(count: statuts.length, currentIndex: _index, progress: _temps.value),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      AvatarDroplet(
                                        nom: depot.nom(s.auteurId),
                                        couleur: mien ? depot.profil.couleur : depot.contacts[s.auteurId]?.couleur ?? 0,
                                        photo: mien ? depot.profil.photo : null,
                                        taille: 34,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(mien ? l.nwMyStatus : depot.nom(s.auteurId), style: OuroTypography.subheadline.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                                            Text(ilYa(context, s.date), style: OuroTypography.caption1.copyWith(color: Colors.white70)),
                                          ],
                                        ),
                                      ),
                                      BoutonIcone(
                                        icone: _temps.isAnimating ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        couleur: Colors.white,
                                        onTap: () => setState(() => _temps.isAnimating ? _temps.stop() : _temps.forward()),
                                      ),
                                      // L'app ne sait pas supprimer un statut publié :
                                      // pas de bouton pour ceux du téléphone.
                                      if (mien && !s.distant)
                                        BoutonIcone(
                                          icone: Icons.delete_outline_rounded,
                                          couleur: Colors.white,
                                          aide: l.actionDelete,
                                          onTap: () {
                                            depot.supprimerStatut(s);
                                            if (depot.statutsDe(kMoi).isEmpty) {
                                              _fermer();
                                            } else {
                                              setState(() => _index = _index.clamp(0, depot.statutsDe(kMoi).length - 1));
                                              _demarrer();
                                            }
                                          },
                                        ),
                                      BoutonIcone(icone: Icons.close_rounded, couleur: Colors.white, aide: t.fermer, onTap: _fermer),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // En bas : vu par (le mien), ou réponse et ♥.
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 24, 12, 14),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0x80000000), Color(0x00000000)]),
                              ),
                              child: mien
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.visibility_outlined, color: Colors.white, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          s.vuPar.where((v) => v != kMoi).isEmpty ? l.svNoViewsYet : l.svSeenBy(s.vuPar.where((v) => v != kMoi).length),
                                          style: OuroTypography.subheadline.copyWith(color: Colors.white),
                                        ),
                                        if (s.aimePar.isNotEmpty) ...[
                                          const SizedBox(width: 14),
                                          const Icon(Icons.favorite_rounded, color: Color(0xFFFF375F), size: 18),
                                          const SizedBox(width: 4),
                                          Text('${s.aimePar.length}', style: OuroTypography.subheadline.copyWith(color: Colors.white)),
                                        ],
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _reponse,
                                            focusNode: _focusReponse,
                                            cursorColor: Colors.white,
                                            style: OuroTypography.body.copyWith(color: Colors.white),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: l.svReplyHint,
                                              hintStyle: OuroTypography.body.copyWith(color: Colors.white60),
                                              filled: true,
                                              fillColor: Colors.white.withValues(alpha: 0.14),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                                            ),
                                            onSubmitted: (v) {
                                              if (v.trim().isEmpty) return;
                                              depot.repondreStatut(s, v.trim());
                                              _reponse.clear();
                                              _focusReponse.unfocus();
                                              annoncer(context, l.svReplySent(depot.nom(s.auteurId)), icone: Icons.send_rounded);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        BoutonIcone(
                                          icone: s.aimePar.contains(kMoi) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          couleur: s.aimePar.contains(kMoi) ? const Color(0xFFFF375F) : Colors.white,
                                          aide: s.aimePar.contains(kMoi) ? l.svUnlikeStatus : l.svLikeStatus,
                                          onTap: () => depot.aimerStatut(s),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── La création ────────────────────────────────────────────────────────

Future<void> creerStatut(BuildContext context, {bool photo = false, String? mode}) async {
  final type = photo ? 'photo' : (mode ?? 'texte');
  PieceJointe? piece;
  if (type == 'photo' || type == 'video') {
    final p = await Navigateur.choisirFichiers(accepter: type == 'photo' ? 'image/*' : 'video/*', plusieurs: false);
    if (p.isEmpty || !context.mounted) return;
    piece = p.first;
    // Le téléphone ne fait pas passer plus de 16 Mo par Internet.
    if (piece.taille > 16 * 1024 * 1024) {
      annoncer(context, context.t.fichierTropLourd, icone: Icons.error_outline_rounded);
      return;
    }
  }
  if (!context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
    opaque: false,
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (_, __, ___) => _Createur(image: type == 'photo' ? piece?.url : null, piece: piece, type: type),
    transitionsBuilder: (_, a, __, enfant) => FadeTransition(opacity: a, child: enfant),
  ));
}

/// Les statuts d'un autre contact, en vignette à côté de la visionneuse :
/// son premier statut, assombri, sa photo et son nom par-dessus.
class _Vignette extends StatelessWidget {
  const _Vignette({required this.auteur, required this.onTap});

  final String auteur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = depot.statutsDe(auteur);
    if (l.isEmpty) return const SizedBox.shrink();
    final s = l.firstWhere((x) => !x.vuPar.contains(kMoi), orElse: () => l.first);
    final fond = fondsStatut[s.fond % fondsStatut.length];
    final contact = depot.contacts[auteur];
    return Survol(
      onTap: onTap,
      builder: (context, survol) => AnimatedScale(
        scale: survol ? 1.03 : 1,
        duration: const Duration(milliseconds: 200),
        curve: kSortie,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (s.image != null)
                Image.network(s.image!, fit: BoxFit.cover)
              else
                DecoratedBox(
                  // Le fond seul : le texte du statut se lit en l'ouvrant,
                  // il ne se mêle pas au nom posé par-dessus.
                  decoration: BoxDecoration(
                    color: s.couleur != null ? Color(s.couleur!) : null,
                    gradient: s.couleur != null ? null : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fond),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: Colors.black.withValues(alpha: survol ? 0.25 : 0.45),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarDroplet(nom: depot.nom(auteur), couleur: contact?.couleur ?? 0, taille: 52, anneau: !depot.statutsTousVus(auteur)),
                    const SizedBox(height: 8),
                    Text(
                      depot.nom(auteur),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.subheadline.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      ilYa(context, s.date),
                      style: OuroTypography.caption1.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Createur extends StatefulWidget {
  const _Createur({this.image, this.piece, this.type = 'texte'});

  final String? image;
  final PieceJointe? piece;

  /// texte | photo | video | voice.
  final String type;

  @override
  State<_Createur> createState() => _CreateurState();
}

class _CreateurState extends State<_Createur> {
  final _texte = TextEditingController();
  int _fond = 0;

  /// Le vocal : en cours d'enregistrement, puis enregistré.
  Enregistreur? _enregistreur;
  PieceJointe? _vocal;
  Timer? _chrono;

  bool get _vocalMode => widget.type == 'voice';
  bool get _videoMode => widget.type == 'video';

  @override
  void dispose() {
    _chrono?.cancel();
    unawaited(_enregistreur?.arreter(annuler: true));
    _texte.dispose();
    super.dispose();
  }

  Future<void> _basculerEnregistrement() async {
    final e = _enregistreur;
    if (e == null) {
      final nouveau = await Navigateur.enregistrer();
      if (nouveau == null || !mounted) return;
      setState(() {
        _enregistreur = nouveau;
        _vocal = null;
      });
      _chrono = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (mounted) setState(() {});
        // Comme l'app : un statut vocal dure une minute au plus.
        if (nouveau.duree > const Duration(seconds: 60)) unawaited(_basculerEnregistrement());
      });
      return;
    }
    _chrono?.cancel();
    final piece = await e.arreter();
    if (!mounted) return;
    setState(() {
      _enregistreur = null;
      _vocal = piece;
    });
  }

  Future<void> _publier() async {
    final texte = _texte.text.trim();
    final media = _vocalMode ? _vocal : widget.piece;
    if (_vocalMode && media == null) return;
    if (texte.isEmpty && media == null) return;
    final depot = context.lire.depot;
    final l = context.l;
    final t = context.t;
    final navigateur = Navigator.of(context);
    navigateur.pop();
    final ok = await depot.publierStatut(texte, _fond, image: widget.image, media: media, type: widget.type);
    if (!navigateur.mounted) return;
    annoncer(navigateur.context, ok ? l.evPublished(1) : t.fichierTropLourd,
        icone: ok ? Icons.podcasts_rounded : Icons.error_outline_rounded);
  }

  /// Le grand bouton du vocal : enregistrer, arrêter, et ce qui a été pris.
  Widget _zoneVocal(BuildContext context) {
    final t = context.t;
    final e = _enregistreur;
    final duree = e?.duree ?? Duration(milliseconds: _vocal?.dureeMs ?? 0);
    final mm = duree.inMinutes.toString().padLeft(1, '0');
    final ss = (duree.inSeconds % 60).toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Survol(
          onTap: _basculerEnregistrement,
          builder: (context, survol) => AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: e != null ? const Color(0xFFFF3B30) : Colors.white.withValues(alpha: survol ? 0.32 : 0.22),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(e != null ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 48),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          e != null || _vocal != null ? '$mm:$ss' : t.statutEnregistrer,
          style: OuroTypography.title2.copyWith(color: Colors.white, fontFeatures: const [ui.FontFeature.tabularFigures()]),
        ),
        if (e != null) ...[
          const SizedBox(height: 6),
          Text(t.statutArreter, style: OuroTypography.footnote.copyWith(color: Colors.white70)),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = context.t;
    final fond = fondsStatut[_fond];
    final image = widget.image;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop()},
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  gradient: image == null && !_videoMode ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fond) : null,
                  color: image == null && !_videoMode ? null : Colors.black,
                ),
              ),
            ),
            if (image != null) Positioned.fill(child: Padding(padding: const EdgeInsets.fromLTRB(40, 80, 40, 140), child: Image.network(image, fit: BoxFit.contain))),
            if (_videoMode && widget.piece != null)
              Positioned.fill(child: Padding(padding: const EdgeInsets.fromLTRB(40, 80, 40, 140), child: LecteurVideo(url: widget.piece!.url, contenir: true))),
            Positioned.fill(
              child: _vocalMode
                  ? Center(child: _zoneVocal(context))
                  : image != null || _videoMode
                  ? const SizedBox.shrink()
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _texte,
                            builder: (context, v, _) => TextField(
                              controller: _texte,
                              autofocus: true,
                              maxLines: null,
                              maxLength: 300,
                              textAlign: TextAlign.center,
                              cursorColor: Colors.white,
                              style: OuroTypography.title1.copyWith(color: Colors.white, fontSize: v.text.length < 40 ? 38 : 28, height: 1.25),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                hintText: l.cpWriteStatusHint,
                                hintStyle: OuroTypography.title1.copyWith(color: Colors.white54, fontSize: 38),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            Positioned(
              top: 18,
              left: 18,
              right: 18,
              child: Row(
                children: [
                  BoutonIcone(icone: Icons.close_rounded, couleur: Colors.white, aide: l.actionCancel, onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  if (image == null && !_videoMode)
                    BoutonIcone(
                      icone: Icons.palette_outlined,
                      couleur: Colors.white,
                      aide: t.changerFond,
                      onTap: () => setState(() => _fond = (_fond + 1) % fondsStatut.length),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (image != null || _videoMode)
                          Expanded(
                            child: TextField(
                              controller: _texte,
                              autofocus: true,
                              cursorColor: Colors.white,
                              style: OuroTypography.body.copyWith(color: Colors.white),
                              onSubmitted: (_) => _publier(),
                              decoration: InputDecoration(
                                hintText: l.apCaptionHint,
                                hintStyle: OuroTypography.body.copyWith(color: Colors.white60),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.14),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Row(
                              children: [
                                for (var i = 0; i < fondsStatut.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Survol(
                                      onTap: () => setState(() => _fond = i),
                                      builder: (context, survol) => AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(colors: fondsStatut[i]),
                                          border: Border.all(color: Colors.white, width: _fond == i ? 3 : (survol ? 1.5 : 0.6)),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_rounded, size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(t.contacts, style: OuroTypography.footnote.copyWith(color: Colors.white70)),
                            const SizedBox(width: 12),
                          ],
                        ),
                        Survol(
                          onTap: _publier,
                          builder: (context, survol) => AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: survol ? 1 : 0.92),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 18, offset: const Offset(0, 6))],
                            ),
                            child: Icon(Icons.send_rounded, color: fond.first, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Le média d'un statut venu du téléphone ─────────────────────────────

/// Photo, vidéo ou vocal d'un statut publié depuis l'app : le contenu est
/// demandé au téléphone à l'ouverture, puis montré (ou joué) tel quel.
class _MediaStatut extends StatefulWidget {
  const _MediaStatut({required this.statut, required this.fond, required this.surDuree});

  final Statut statut;
  final List<Color> fond;
  final void Function(Duration) surDuree;

  @override
  State<_MediaStatut> createState() => _MediaStatutState();
}

class _MediaStatutState extends State<_MediaStatut> {
  Lecteur? _lecteur;
  String _urlLue = '';

  @override
  void dispose() {
    _lecteur?.liberer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.statut;
    final p = s.piece!;
    final depot = context.depot;
    if (p.url.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) depot.chargerStatut(s);
      });
    }
    final fondUni = s.couleur != null ? Color(s.couleur!) : null;

    if (s.type == 'voice') {
      // Le vocal démarre dès que son contenu est là, comme dans l'app.
      if (p.url.isNotEmpty && p.url != _urlLue) {
        _urlLue = p.url;
        _lecteur?.liberer();
        final l = Lecteur(p.url);
        _lecteur = l;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) l.basculer();
        });
      }
      final lecteur = _lecteur;
      return DecoratedBox(
        decoration: BoxDecoration(
          color: fondUni,
          gradient: fondUni != null ? null : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.fond),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (lecteur == null)
                const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
              else
                ValueListenableBuilder<bool>(
                  valueListenable: lecteur.enCours,
                  builder: (context, joue, _) => Survol(
                    onTap: lecteur.basculer,
                    builder: (context, survol) => ValueListenableBuilder<double>(
                      valueListenable: lecteur.position,
                      builder: (context, pos, _) => SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(child: CircularProgressIndicator(value: pos, strokeWidth: 4, color: Colors.white, backgroundColor: Colors.white24)),
                            Icon(joue ? Icons.pause_rounded : Icons.mic_rounded, color: Colors.white, size: 52),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (s.texte.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(s.texte, textAlign: TextAlign.center, style: OuroTypography.title3.copyWith(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (p.url.isEmpty) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
              const SizedBox(height: 14),
              Text(context.t.statutChargement, style: OuroTypography.footnote.copyWith(color: Colors.white70)),
            ],
          ),
        ),
      );
    }
    return ColoredBox(
      color: Colors.black,
      child: s.type == 'video'
          ? LecteurVideo(url: p.url, contenir: true, auto: true)
          : Image.network(p.url, fit: BoxFit.contain),
    );
  }
}
