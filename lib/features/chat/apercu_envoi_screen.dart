// ============================================================================
// L'APERÇU AVANT ENVOI — ce que toutes les grandes messageries montrent, et
// que Droplet ne montrait pas.
// ----------------------------------------------------------------------------
// Avant : on choisissait une photo, elle PARTAIT. Aucun moyen de la regarder
// en grand d'abord, d'écrire un mot avec, de barrer un visage, de redresser
// une photo prise de travers, ou simplement de renoncer.
//
// Ici, comme WhatsApp et Telegram :
//   • la photo (ou la vidéo) en grand, sur fond noir ;
//   • une LÉGENDE, qui part avec le fichier (voir
//     `MeshRepository.mimeAvecLegende`) ;
//   • le DESSIN et les EMOJIS par-dessus (`DrawingCanvas`, déjà utilisé par
//     les statuts) ;
//   • la ROTATION par quarts de tour et le RECADRAGE au doigt ;
//   • un bouton d'envoi, et une croix pour abandonner.
//
// ⚠️ LE FICHIER D'ORIGINE N'EST JAMAIS MODIFIÉ. Tant qu'on ne touche à rien,
// c'est lui qui part, tel quel. Dès qu'on dessine, tourne ou recadre, une
// COPIE est écrite dans le dossier temporaire ; la photo de la galerie reste
// intacte.
// ============================================================================

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_spinner.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/drawing_canvas.dart';
import '../editeur/filtres_photo.dart';
import '../editeur/outils_retouche.dart';
import '../status/editeur_video_statut.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';
import 'vue_unique.dart';

/// Ce que l'aperçu rapporte : le fichier à envoyer (l'original, ou la copie
/// annotée) et la légende éventuelle.
class ApercuEnvoi {
  const ApercuEnvoi({required this.chemin, this.legende});

  final String chemin;
  final String? legende;
}

/// Ouvre l'aperçu. `null` si la personne renonce.
Future<ApercuEnvoi?> ouvrirApercuEnvoi(
  BuildContext context, {
  required String chemin,
  required bool video,
  bool vueUniquePossible = false,
}) {
  return Navigator.of(context).push<ApercuEnvoi>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ApercuEnvoiScreen(
        chemin: chemin,
        video: video,
        vueUniquePossible: vueUniquePossible,
      ),
    ),
  );
}

class ApercuEnvoiScreen extends StatefulWidget {
  const ApercuEnvoiScreen({
    super.key,
    required this.chemin,
    required this.video,
    this.vueUniquePossible = false,
  });

  final String chemin;
  final bool video;

  /// Une discussion peut proposer la vue unique ; un statut, non.
  final bool vueUniquePossible;

  @override
  State<ApercuEnvoiScreen> createState() => _ApercuEnvoiScreenState();
}

enum _Mode { apercu, dessin, recadrage, filtres, reglages }

class _ApercuEnvoiScreenState extends State<ApercuEnvoiScreen> {
  final _legende = TextEditingController();
  final _cleRendu = GlobalKey();
  final GlobalKey<DrawingCanvasState> _cleDessin = GlobalKey<DrawingCanvasState>();

  _Mode _mode = _Mode.apercu;
  DrawTool _outil = DrawTool.pen;
  Color _couleur = Colors.white;
  double _epaisseur = 4;

  /// Le fichier actuellement affiché : l'original, ou la dernière copie
  /// tournée / recadrée.
  late String _chemin = widget.chemin;

  /// Vrai pendant une opération longue (rotation, recadrage, envoi).
  bool _travail = false;

  /// Le média s'effacera après avoir été vu une fois.
  bool _vueUnique = false;

  VideoPlayerController? _lecteur;

  /// Le cadre de recadrage, en proportions de l'image affichée (0 à 1).
  Rect _cadre = const Rect.fromLTRB(0.08, 0.08, 0.92, 0.92);

  // ── L'ÉDITEUR ──────────────────────────────────────────────────────────
  // Filtres, réglages et textes ne touchent PAS au fichier : ils restent des
  // paramètres, appliqués par le processeur graphique à l'affichage, et
  // recomposés une seule fois à l'export, à la résolution de la photo.
  FiltrePhoto _filtre = filtresPhoto.first;
  double _intensite = 1;
  final Map<Reglage, double> _reglages = <Reglage, double>{};
  Reglage _reglageActif = Reglage.luminosite;
  final List<CalqueTexte> _textes = <CalqueTexte>[];
  int _prochainTexte = 1;

  /// Où la photo est réellement dessinée à l'écran : sert à placer les
  /// textes, et à passer des points de l'écran aux pixels de l'image.
  Rect? _rectImage;

  final Map<String, Future<ui.Image>> _images = <String, Future<ui.Image>>{};
  final List<_Instantane> _historique = <_Instantane>[];

  Matrice get _matrice => matriceFinale(_filtre, _intensite, _reglages);
  double get _vignette => _reglages[Reglage.vignette] ?? 0;
  bool get _retouchee =>
      (!_filtre.original && _intensite > 0) ||
      _reglages.values.any((v) => v != 0) ||
      _textes.isNotEmpty;

  Future<ui.Image> _decoder(String chemin) => _images.putIfAbsent(chemin, () async {
        final octets = await File(chemin).readAsBytes();
        return decodeImageFromList(octets);
      });

  void _memoriser() {
    _historique.add(_Instantane(
      chemin: _chemin,
      filtre: _filtre,
      intensite: _intensite,
      reglages: Map.of(_reglages),
      textes: [for (final t in _textes) t.copie()],
    ));
    if (_historique.length > 20) _historique.removeAt(0);
  }

  void _annuler() {
    if (_historique.isEmpty) return;
    final e = _historique.removeLast();
    OuroHaptics.light();
    setState(() {
      _chemin = e.chemin;
      _filtre = e.filtre;
      _intensite = e.intensite;
      _reglages
        ..clear()
        ..addAll(e.reglages);
      _textes
        ..clear()
        ..addAll(e.textes);
    });
  }

  Future<String?> _exporter() async {
    final direction = Directionality.of(context);
    try {
      final source = await _decoder(_chemin);
      final image = await composerRetouche(
        source: source,
        matrice: _matrice,
        vignette: _vignette,
        textes: _textes,
        largeurAffichee: _rectImage?.width ?? source.width.toDouble(),
        direction: direction,
      );
      final chemin = await _ecrire(image);
      image.dispose();
      return chemin;
    } catch (_) {
      return null;
    }
  }

  /// Fige les retouches dans le fichier. Indispensable avant de recadrer, de
  /// pivoter ou de dessiner : sinon un texte posé resterait à sa place alors
  /// que l'image, elle, aurait tourné.
  Future<void> _aplatir() async {
    if (widget.video || !_retouchee) return;
    final chemin = await _exporter();
    if (chemin == null || !mounted) return;
    setState(() {
      _chemin = chemin;
      _filtre = filtresPhoto.first;
      _intensite = 1;
      _reglages.clear();
      _textes.clear();
    });
  }

  Future<void> _ajouterTexte([CalqueTexte? existant]) async {
    final resultat = await saisirTexte(context, existant: existant, nouvelId: _prochainTexte);
    if (!mounted || resultat == null) return;
    _memoriser();
    setState(() {
      if (existant == null) {
        if (!resultat.supprime) {
          _textes.add(resultat.calque);
          _prochainTexte++;
        }
      } else {
        final i = _textes.indexWhere((t) => t.id == existant.id);
        if (i < 0) return;
        if (resultat.supprime) {
          _textes.removeAt(i);
        } else {
          _textes[i] = resultat.calque;
        }
      }
    });
  }

  Future<void> _entrerDessin() async {
    _memoriser();
    await _aplatir();
    if (mounted) setState(() => _mode = _Mode.dessin);
  }

  Future<void> _sortirDessin() async {
    final chemin = await _appliquerDessin();
    if (!mounted) return;
    setState(() {
      if (chemin != null) _chemin = chemin;
      _mode = _Mode.apercu;
    });
  }

  Future<void> _decouperVideo() async {
    final resultat = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => EditeurVideoStatut(
          chemin: _chemin,
          maxSegment: const Duration(hours: 2),
        ),
      ),
    );
    if (!mounted || resultat == null || resultat.isEmpty) return;
    final ancien = _lecteur;
    setState(() {
      _chemin = resultat.first;
      _lecteur = null;
    });
    await ancien?.dispose();
    await _preparerVideo();
  }

  void _basculer(_Mode mode) =>
      setState(() => _mode = _mode == mode ? _Mode.apercu : mode);

  Widget _rail(AppLocalizations l10n) {
    if (widget.video) {
      return RailOutils(outils: [
        OutilRail(icone: Icons.content_cut_rounded, libelle: l10n.edTrim, surTap: _decouperVideo),
      ]);
    }
    return RailOutils(outils: [
      OutilRail(
        icone: Icons.crop_rounded,
        libelle: l10n.edCrop,
        surTap: () => setState(() => _mode = _Mode.recadrage),
      ),
      OutilRail(icone: Icons.rotate_right_rounded, libelle: l10n.edRotate, surTap: _tourner),
      OutilRail(
        icone: Icons.photo_filter_rounded,
        libelle: l10n.edFilters,
        actif: _mode == _Mode.filtres,
        surTap: () => _basculer(_Mode.filtres),
      ),
      OutilRail(
        icone: Icons.tune_rounded,
        libelle: l10n.edAdjust,
        actif: _mode == _Mode.reglages,
        surTap: () => _basculer(_Mode.reglages),
      ),
      OutilRail(icone: Icons.text_fields_rounded, libelle: l10n.edText, surTap: _ajouterTexte),
      OutilRail(icone: Icons.brush_rounded, libelle: l10n.edDraw, surTap: _entrerDessin),
    ]);
  }

  @override
  void initState() {
    super.initState();
    if (widget.video) _preparerVideo();
  }

  @override
  void dispose() {
    _legende.dispose();
    _lecteur?.dispose();
    for (final image in _images.values) {
      image.then((i) => i.dispose()).ignore();
    }
    super.dispose();
  }

  Future<void> _preparerVideo() async {
    final lecteur = VideoPlayerController.file(File(_chemin));
    try {
      await lecteur.initialize();
      await lecteur.setLooping(true);
      if (!mounted) {
        await lecteur.dispose();
        return;
      }
      setState(() => _lecteur = lecteur);
      await lecteur.play();
    } catch (_) {
      await lecteur.dispose();
    }
  }

  // ── Écriture des copies modifiées ────────────────────────────────────

  Future<String> _ecrire(ui.Image image) async {
    final octets = await image.toByteData(format: ui.ImageByteFormat.png);
    final dossier = await getTemporaryDirectory();
    final fichier = File(
      '${dossier.path}/apercu_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await fichier.writeAsBytes((octets!.buffer.asUint8List()), flush: true);
    return fichier.path;
  }

  Future<ui.Image?> _lireImage() async {
    try {
      final octets = await File(_chemin).readAsBytes();
      return await decodeImageFromList(Uint8List.fromList(octets));
    } catch (_) {
      return null;
    }
  }

  /// Quart de tour à droite.
  Future<void> _tourner() async {
    _memoriser();
    await _aplatir();
    if (_travail) return;
    setState(() => _travail = true);
    OuroHaptics.light();
    try {
      final source = await _lireImage();
      if (source == null) return;
      final enregistreur = ui.PictureRecorder();
      final toile = ui.Canvas(enregistreur);
      toile
        ..translate(source.height.toDouble(), 0)
        ..rotate(math.pi / 2);
      toile.drawImage(source, ui.Offset.zero, ui.Paint());
      final tournee = await enregistreur
          .endRecording()
          .toImage(source.height, source.width);
      final chemin = await _ecrire(tournee);
      source.dispose();
      tournee.dispose();
      if (!mounted) return;
      setState(() => _chemin = chemin);
    } finally {
      if (mounted) setState(() => _travail = false);
    }
  }

  /// Applique le cadre de recadrage.
  Future<void> _recadrer() async {
    _memoriser();
    await _aplatir();
    if (_travail) return;
    setState(() => _travail = true);
    OuroHaptics.light();
    try {
      final source = await _lireImage();
      if (source == null) return;
      final l = source.width.toDouble();
      final h = source.height.toDouble();
      final zone = Rect.fromLTRB(
        (_cadre.left * l).clamp(0, l - 1),
        (_cadre.top * h).clamp(0, h - 1),
        (_cadre.right * l).clamp(1, l),
        (_cadre.bottom * h).clamp(1, h),
      );
      final enregistreur = ui.PictureRecorder();
      final toile = ui.Canvas(enregistreur);
      toile.drawImageRect(
        source,
        zone,
        Rect.fromLTWH(0, 0, zone.width, zone.height),
        ui.Paint(),
      );
      final coupee = await enregistreur
          .endRecording()
          .toImage(zone.width.round(), zone.height.round());
      final chemin = await _ecrire(coupee);
      source.dispose();
      coupee.dispose();
      if (!mounted) return;
      setState(() {
        _chemin = chemin;
        _mode = _Mode.apercu;
        _cadre = const Rect.fromLTRB(0.08, 0.08, 0.92, 0.92);
      });
    } finally {
      if (mounted) setState(() => _travail = false);
    }
  }

  /// Fige le dessin et les emojis dans une copie de l'image.
  Future<String?> _appliquerDessin() async {
    final contexte = _cleRendu.currentContext;
    if (contexte == null) return null;
    try {
      final limite = contexte.findRenderObject()! as RenderRepaintBoundary;
      final image = await limite.toImage(pixelRatio: 2.5);
      final chemin = await _ecrire(image);
      image.dispose();
      return chemin;
    } catch (_) {
      return null;
    }
  }

  Future<void> _envoyer() async {
    if (_travail) return;
    setState(() => _travail = true);
    OuroHaptics.medium();
    var chemin = _chemin;
    // Le dessin n'existe qu'à l'écran tant qu'on ne l'a pas figé.
    if (_mode == _Mode.dessin && !widget.video) {
      chemin = await _appliquerDessin() ?? chemin;
    } else if (!widget.video && _retouchee) {
      chemin = await _exporter() ?? chemin;
    }
    if (!mounted) return;
    final texte = _legende.text.trim();
    Navigator.of(context).pop(
      ApercuEnvoi(
        chemin: chemin,
        // La marque voyage en tête de la légende : rien de nouveau ne
        // circule sur le réseau (voir `vue_unique.dart`).
        legende: _vueUnique
            ? '${VueUnique.marque}$texte'
            : (texte.isEmpty ? null : texte),
      ),
    );
  }

  // ── Affichage ────────────────────────────────────────────────────────

  Widget _image() {
    if (widget.video) {
      final lecteur = _lecteur;
      if (lecteur == null || !lecteur.value.isInitialized) {
        return const Center(child: OuroSpinner(color: Colors.white38, radius: 14));
      }
      return Center(
        child: AspectRatio(
          aspectRatio: lecteur.value.aspectRatio,
          child: GestureDetector(
            onTap: () => setState(() {
              lecteur.value.isPlaying ? lecteur.pause() : lecteur.play();
            }),
            child: VideoPlayer(lecteur),
          ),
        ),
      );
    }
    final image = Image.file(
      File(_chemin),
      key: ValueKey(_chemin),
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
    if (_mode == _Mode.dessin) {
      return RepaintBoundary(
        key: _cleRendu,
        child: DrawingCanvas(key: _cleDessin, imageProvider: FileImage(File(_chemin))),
      );
    }
    if (_mode == _Mode.recadrage) {
      return _CadreRecadrage(
        cadre: _cadre,
        surChangement: (c) => setState(() => _cadre = c),
        child: image,
      );
    }
    return LayoutBuilder(
      builder: (context, contraintes) => FutureBuilder<ui.Image>(
        future: _decoder(_chemin),
        builder: (context, instantane) {
          final source = instantane.data;
          final boite = contraintes.biggest;
          final rect = source == null
              ? Offset.zero & boite
              : Alignment.center.inscribe(
                  applyBoxFit(
                    BoxFit.contain,
                    Size(source.width.toDouble(), source.height.toDouble()),
                    boite,
                  ).destination,
                  Offset.zero & boite,
                );
          _rectImage = rect;
          return Stack(
            children: [
              Positioned.fromRect(
                rect: rect,
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_matrice),
                  child: Image.file(
                    File(_chemin),
                    key: ValueKey(_chemin),
                    fit: BoxFit.fill,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              if (_vignette > 0)
                Positioned.fromRect(
                  rect: rect,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: degradeVignette(_vignette)),
                    ),
                  ),
                ),
              Positioned.fill(
                child: CoucheTextes(
                  calques: _textes,
                  rectImage: rect,
                  surTap: _ajouterTexte,
                  surDebutGeste: _memoriser,
                  surChangement: () => setState(() {}),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final clavier = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(bottom: clavier, child: _image()),

          // Barre du haut : renoncer, et les outils d'image.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 4,
                left: 4,
                right: 8,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  OuroIconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (_mode == _Mode.recadrage)
                    OuroRetourIos(
                      child: TextButton(
                        onPressed: _travail ? null : _recadrer,
                        child: Text(
                          l10n.apValidateCrop,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  else if (_mode == _Mode.dessin)
                    OuroRetourIos(
                      child: TextButton(
                        onPressed: _travail ? null : _sortirDessin,
                        child: Text(
                          l10n.edDone,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  else if (_historique.isNotEmpty)
                    OuroIconButton(
                      icon: const Icon(Icons.undo_rounded, color: Colors.white),
                      tooltip: l10n.edUndo,
                      onPressed: _annuler,
                    ),
                ],
              ),
            ),
          ),

          // Les outils de dessin, à droite, comme dans les statuts.
          if (_mode == _Mode.dessin)
            DrawingToolbar(
              activeTool: _outil,
              selectedColor: _couleur,
              strokeWidth: _epaisseur,
              onToolChanged: (outil) {
                setState(() => _outil = outil);
                _cleDessin.currentState?.setTool(outil);
              },
              onColorChanged: (couleur) {
                setState(() => _couleur = couleur);
                _cleDessin.currentState?.setColor(couleur);
              },
              onStrokeWidthChanged: (e) {
                setState(() => _epaisseur = e);
                _cleDessin.currentState?.setStrokeWidth(e);
              },
              onUndo: () => _cleDessin.currentState?.undo(),
              onClear: () => _cleDessin.currentState?.clear(),
            ),

          // La légende et le bouton d'envoi.
          if (_mode != _Mode.recadrage)
            Positioned(
              left: 0,
              right: 0,
              bottom: clavier,
              child: Container(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 14,
                  bottom: MediaQuery.paddingOf(context).bottom + 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.video && _mode == _Mode.filtres)
                      BandeFiltres(
                        image: ResizeImage(FileImage(File(_chemin)), width: 160),
                        actif: _filtre,
                        intensite: _intensite,
                        surFiltre: (f) {
                          _memoriser();
                          setState(() {
                            _filtre = f;
                            _intensite = 1;
                          });
                        },
                        surIntensite: (v) => setState(() => _intensite = v),
                        surDebutIntensite: _memoriser,
                      ),
                    if (!widget.video && _mode == _Mode.reglages)
                      PanneauReglages(
                        reglages: _reglages,
                        actif: _reglageActif,
                        surChoix: (r) => setState(() => _reglageActif = r),
                        surValeur: (r, v) => setState(() => _reglages[r] = v),
                        surDebut: _memoriser,
                      ),
                    if (_mode != _Mode.dessin && clavier == 0) _rail(l10n),
                    Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Le « 1 » de la vue unique : le média s'efface après
                    // avoir été vu une seule fois.
                    if (widget.vueUniquePossible)
                      Padding(
                        padding: const EdgeInsets.only(right: 6, bottom: 2),
                        child: Semantics(
                          button: true,
                          selected: _vueUnique,
                          label: l10n.vuOnce,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              OuroHaptics.light();
                              setState(() => _vueUnique = !_vueUnique);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _vueUnique ? Colors.white : Colors.white24,
                              ),
                              child: Icon(
                                Icons.looks_one_rounded,
                                size: 22,
                                color: _vueUnique ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: TextField(
                          controller: _legende,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          cursorColor: Colors.white,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: l10n.apCaptionHint,
                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _envoyer,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: OuroColors.accentRempli,
                        ),
                        child: _travail
                            ? Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: OuroSpinner(color: OuroColors.texteSurAccent, radius: 8),
                                ),
                              )
                            : Icon(Icons.send_rounded, color: OuroColors.texteSurAccent, size: 24),
                      ),
                    ),
                  ],
                ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Outil extends StatelessWidget {
  const _Outil({required this.icone, required this.actif, required this.onTap});

  final IconData icone;
  final bool actif;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OuroIconButton(
      icon: Icon(icone, color: actif ? OuroColors.accent : Colors.white),
      onPressed: onTap,
    );
  }
}

/// Le cadre de recadrage : quatre coins qu'on déplace au doigt, le reste
/// assombri — la disposition que tout le monde connaît.
class _CadreRecadrage extends StatelessWidget {
  const _CadreRecadrage({
    required this.cadre,
    required this.surChangement,
    required this.child,
  });

  final Rect cadre;
  final ValueChanged<Rect> surChangement;
  final Widget child;

  static const double _prise = 34;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        final l = contraintes.maxWidth;
        final h = contraintes.maxHeight;
        final zone = Rect.fromLTRB(cadre.left * l, cadre.top * h, cadre.right * l, cadre.bottom * h);

        void bouger(Offset delta, {required bool gauche, required bool haut}) {
          var c = cadre;
          final dx = delta.dx / l;
          final dy = delta.dy / h;
          const marge = 0.12;
          if (gauche) {
            c = Rect.fromLTRB((c.left + dx).clamp(0.0, c.right - marge), c.top, c.right, c.bottom);
          } else {
            c = Rect.fromLTRB(c.left, c.top, (c.right + dx).clamp(c.left + marge, 1.0), c.bottom);
          }
          if (haut) {
            c = Rect.fromLTRB(c.left, (c.top + dy).clamp(0.0, c.bottom - marge), c.right, c.bottom);
          } else {
            c = Rect.fromLTRB(c.left, c.top, c.right, (c.bottom + dy).clamp(c.top + marge, 1.0));
          }
          surChangement(c);
        }

        Widget coin({required bool gauche, required bool haut}) => Positioned(
              left: (gauche ? zone.left : zone.right) - _prise / 2,
              top: (haut ? zone.top : zone.bottom) - _prise / 2,
              width: _prise,
              height: _prise,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => bouger(d.delta, gauche: gauche, haut: haut),
                child: Center(
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            );

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(child: child),
            // Le voile sombre autour du cadre.
            IgnorePointer(
              child: CustomPaint(painter: _VoileRecadrage(zone), size: Size(l, h)),
            ),
            Positioned.fromRect(
              rect: zone,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ),
            coin(gauche: true, haut: true),
            coin(gauche: false, haut: true),
            coin(gauche: true, haut: false),
            coin(gauche: false, haut: false),
          ],
        );
      },
    );
  }
}

class _VoileRecadrage extends CustomPainter {
  const _VoileRecadrage(this.zone);

  final Rect zone;

  @override
  void paint(Canvas canvas, Size size) {
    final dehors = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(zone),
    );
    canvas.drawPath(dehors, Paint()..color = Colors.black.withValues(alpha: 0.55));
  }

  @override
  bool shouldRepaint(_VoileRecadrage ancien) => ancien.zone != zone;
}


/// Un état de l'édition, pour revenir en arrière.
class _Instantane {
  const _Instantane({
    required this.chemin,
    required this.filtre,
    required this.intensite,
    required this.reglages,
    required this.textes,
  });

  final String chemin;
  final FiltrePhoto filtre;
  final double intensite;
  final Map<Reglage, double> reglages;
  final List<CalqueTexte> textes;
}
