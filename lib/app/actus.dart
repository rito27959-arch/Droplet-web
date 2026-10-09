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

  void _demarrer() {
    final l = _statuts;
    if (l.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fermer());
      return;
    }
    final vu = l[_index.clamp(0, l.length - 1)];
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
                                    : DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fond),
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
                          if (s.image != null && s.texte.isNotEmpty)
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
                                      if (mien)
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

Future<void> creerStatut(BuildContext context, {bool photo = false}) async {
  String? image;
  if (photo) {
    final p = await Navigateur.choisirFichiers(accepter: 'image/*', plusieurs: false);
    if (p.isEmpty || !context.mounted) return;
    image = p.first.url;
  }
  if (!context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
    opaque: false,
    transitionDuration: const Duration(milliseconds: 340),
    pageBuilder: (_, __, ___) => _Createur(image: image),
    transitionsBuilder: (_, a, __, enfant) => FadeTransition(opacity: a, child: enfant),
  ));
}

class _Createur extends StatefulWidget {
  const _Createur({this.image});

  final String? image;

  @override
  State<_Createur> createState() => _CreateurState();
}

class _CreateurState extends State<_Createur> {
  final _texte = TextEditingController();
  int _fond = 0;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  void _publier() {
    final texte = _texte.text.trim();
    if (texte.isEmpty && widget.image == null) return;
    context.lire.depot.publierStatut(texte, _fond, image: widget.image);
    Navigator.of(context).pop();
    annoncer(context, context.l.evPublished(1), icone: Icons.podcasts_rounded);
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
                  gradient: image == null ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: fond) : null,
                  color: image == null ? null : Colors.black,
                ),
              ),
            ),
            if (image != null) Positioned.fill(child: Padding(padding: const EdgeInsets.fromLTRB(40, 80, 40, 140), child: Image.network(image, fit: BoxFit.contain))),
            Positioned.fill(
              child: image != null
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
                  if (image == null)
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
                        if (image != null)
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
