// LES APPELS — le journal de l'onglet Appels, et l'écran d'appel.
//
//   • Le journal : Tous / Manqués, entrants et sortants, durée, rappel en
//     un clic (audio ou vidéo), « Nouvel appel » vers un contact.
//   • L'écran d'appel, plein écran sur fond sombre : la photo qui respire
//     pendant que ça sonne, puis le chrono ; micro, caméra, raccrocher. En
//     vidéo, ma caméra s'affiche en vignette (la vraie, celle du
//     navigateur). Le flux de l'autre arrivera par la signalisation des
//     serveurs ; en démonstration, l'appel « décroche » tout seul.
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/appels_reseau.dart';
import '../donnees/depot.dart';
import '../donnees/modeles.dart';
import '../web/navigateur.dart';
import 'composants.dart';
import 'coquille.dart';
import 'formats.dart';
import 'liste_discussions.dart' show LigneContact;
import 'portee.dart';

/// Lancer un appel depuis n'importe où.
Future<void> lancerAppel(BuildContext context, Discussion d, {required bool video}) async {
  final reseau = context.lire.depot.reseau;
  if (reseau != null) {
    // Les appels de groupe passent encore par le téléphone.
    if (d.estGroupe || !d.id.startsWith('p:')) {
      annoncer(context, context.t.appelGroupeTelephone, icone: Icons.groups_rounded);
      return;
    }
    if (reseau.phase != PhaseAppel.aucune && reseau.phase != PhaseAppel.fin) return;
    unawaited(reseau.appeler(d.id.substring(2), avecVideo: video));
  }
  return _ouvrirEcranAppel(context, d, video: video);
}

Future<void> _ouvrirEcranAppel(BuildContext context, Discussion d, {required bool video}) {
  return Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
    opaque: true,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => EcranAppel(discussion: d, video: video),
    transitionsBuilder: (_, a, __, enfant) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 1.04, end: 1.0).animate(CurvedAnimation(parent: a, curve: kSortie)), child: enfant),
    ),
  ));
}

class ColonneAppels extends StatefulWidget {
  const ColonneAppels({super.key});

  @override
  State<ColonneAppels> createState() => _ColonneAppelsState();
}

class _ColonneAppelsState extends State<ColonneAppels> {
  bool _manques = false;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final t = context.t;
    final appels = depot.appels.where((a) => !_manques || a.manque).where((a) => depot.discussions.containsKey(a.discussionId)).toList();
    final menu = GlobalKey();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EntetePanneau(
          titre: l.callsTitle,
          actions: [
            BoutonIcone(
              icone: Icons.add_call,
              aide: l.callsNew,
              couleur: OuroColors.accent,
              onTap: () => pousserPanneau(context, const _PanneauNouvelAppel()),
            ),
            BoutonIcone(
              key: menu,
              icone: Icons.more_horiz_rounded,
              aide: t.plus,
              couleur: OuroColors.accent,
              onTap: depot.appels.isEmpty
                  ? null
                  : () {
                      final box = menu.currentContext!.findRenderObject() as RenderBox;
                      montrerMenu(
                        context,
                        position: box.localToGlobal(Offset(box.size.width, box.size.height)),
                        elements: [
                          ElementMenu(
                            icone: Icons.delete_sweep_outlined,
                            libelle: t.effacerJournal,
                            destructif: true,
                            onTap: () async {
                              final i = await alerte(
                                context,
                                titre: t.effacerJournal,
                                actions: [ActionAlerte(l.actionCancel), ActionAlerte(t.vider, destructif: true)],
                              );
                              if (i == 1) depot.effacerAppels();
                            },
                          ),
                        ],
                      );
                    },
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: CupertinoSlidingSegmentedControl<bool>(
            groupValue: _manques,
            onValueChanged: (v) => setState(() => _manques = v ?? false),
            children: {
              false: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(l.callsAll, style: OuroTypography.subheadline.copyWith(color: OuroColors.label))),
              true: Text(l.callsMissed, style: OuroTypography.subheadline.copyWith(color: OuroColors.label)),
            },
          ),
        ),
        Expanded(
          child: appels.isEmpty
              ? EtatVide(
                  icone: _manques ? Icons.phone_missed_outlined : Icons.phone_outlined,
                  titre: _manques ? l.callsNoneMissed : l.callsNone,
                  texte: _manques ? l.callsMissedEmptyBody : l.callsEmptyBody,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  children: [
                    for (final a in appels) _LigneAppel(appel: a),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_rounded, size: 12, color: OuroColors.tertiaryLabel),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(l.clEndToEndEncrypted, style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel)),
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

class _LigneAppel extends StatelessWidget {
  const _LigneAppel({required this.appel});

  final Appel appel;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final a = appel;
    final d = depot.discussions[a.discussionId]!;
    final libelle = a.manque ? l.callsMissedLabel : (a.entrant ? l.callsIncoming : l.callsOutgoing);
    final infos = GlobalKey();
    return Survol(
      onTap: () => lancerAppel(context, d, video: a.video),
      onClicDroit: (p) => _menu(context, d, p),
      builder: (context, survol) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: survol ? OuroColors.quaternarySystemFill : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            AvatarDroplet(nom: d.titre, couleur: d.couleur, taille: 46, groupe: d.estGroupe),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.titre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.headline.copyWith(color: a.manque ? OuroColors.systemRed : OuroColors.label),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        a.manque
                            ? Icons.call_missed_rounded
                            : a.entrant
                                ? Icons.call_received_rounded
                                : Icons.call_made_rounded,
                        size: 15,
                        color: a.manque ? OuroColors.systemRed : OuroColors.secondaryLabel,
                      ),
                      const SizedBox(width: 4),
                      Icon(a.video ? Icons.videocam_rounded : Icons.phone_rounded, size: 14, color: OuroColors.tertiaryLabel),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          a.dureeSecondes > 0 ? '$libelle · ${dureeAppel(context, a.dureeSecondes)}' : libelle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(dateListe(context, a.date), style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
            BoutonIcone(
              key: infos,
              icone: Icons.info_outline_rounded,
              couleur: OuroColors.accent,
              aide: l.ciInfoTitle,
              onTap: () {
                ouvrirDiscussion(context, d.id);
                context.lire.ui.basculerInfos(true);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _menu(BuildContext context, Discussion d, Offset p) {
    final l = context.l;
    montrerMenu(
      context,
      position: p,
      elements: [
        ElementMenu(icone: Icons.phone_outlined, libelle: l.chVoiceCall, onTap: () => lancerAppel(context, d, video: false)),
        ElementMenu(icone: Icons.videocam_outlined, libelle: l.chVideoCall, onTap: () => lancerAppel(context, d, video: true)),
        ElementMenu(icone: Icons.chat_bubble_outline_rounded, libelle: l.pfMessage, onTap: () => ouvrirDiscussion(context, d.id)),
      ],
    );
  }
}

class _PanneauNouvelAppel extends StatefulWidget {
  const _PanneauNouvelAppel();

  @override
  State<_PanneauNouvelAppel> createState() => _PanneauNouvelAppelState();
}

class _PanneauNouvelAppelState extends State<_PanneauNouvelAppel> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final l = context.l;
    final contacts = depot.contacts.values
        .where((c) => !c.bloque && (_q.isEmpty || c.pseudo.toLowerCase().contains(_q)))
        .toList()
      ..sort((a, b) => a.pseudo.toLowerCase().compareTo(b.pseudo.toLowerCase()));
    return ColoredBox(
      color: OuroColors.secondarySystemGroupedBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EntetePanneau(titre: l.callsNew, retour: () => Navigator.of(context).pop()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: ChampRecherche(indication: l.nmFindByPseudo, autofocus: true, onChanged: (v) => setState(() => _q = v.trim().toLowerCase())),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              children: [
                for (final c in contacts)
                  LigneContact(
                    contact: c,
                    onTap: () => lancerAppel(context, depot.discussionAvec(c.id), video: false),
                    fin: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BoutonIcone(
                          icone: Icons.phone_outlined,
                          couleur: OuroColors.accent,
                          aide: l.chVoiceCall,
                          onTap: () => lancerAppel(context, depot.discussionAvec(c.id), video: false),
                        ),
                        BoutonIcone(
                          icone: Icons.videocam_outlined,
                          couleur: OuroColors.accent,
                          aide: l.chVideoCall,
                          onTap: () => lancerAppel(context, depot.discussionAvec(c.id), video: true),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── L'écran d'appel ────────────────────────────────────────────────────

enum _Phase { sonnerie, enCours, fin }

class EcranAppel extends StatefulWidget {
  const EcranAppel({super.key, required this.discussion, required this.video});

  final Discussion discussion;
  final bool video;

  @override
  State<EcranAppel> createState() => _EcranAppelState();
}

class _EcranAppelState extends State<EcranAppel> with SingleTickerProviderStateMixin {
  late final AnimationController _souffle = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat();
  _Phase _phase = _Phase.sonnerie;
  DateTime? _debut;
  Timer? _tic;
  Timer? _decroche;
  Camera? _camera;
  bool _micro = true;
  late bool _videoActive = widget.video;
  late final Depot _depot;

  /// Le vrai appel, quand ce navigateur est lié à un téléphone.
  AppelsReseau? get _reseau => _depot.reseau;

  @override
  void initState() {
    super.initState();
    _depot = context.lire.depot;
    final r = _reseau;
    if (r != null) {
      r.addListener(_suivre);
      _tic = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && r.phase == PhaseAppel.enCours) setState(() {});
      });
      return;
    }
    _ouvrirMedia();
    // En démonstration, l'autre décroche après quelques sonneries.
    if (_depot.demo) {
      _decroche = Timer(const Duration(milliseconds: 3200), () {
        if (!mounted) return;
        setState(() {
          _phase = _Phase.enCours;
          _debut = DateTime.now();
        });
        _tic = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() {});
        });
      });
    }
  }

  Future<void> _ouvrirMedia() async {
    final c = await Navigateur.camera(video: widget.video);
    if (!mounted) {
      c?.couper();
      return;
    }
    if (c == null) {
      annoncer(context, widget.video ? context.l.camUnavailable : context.l.chMicPermissionDenied, icone: Icons.videocam_off_rounded);
    }
    setState(() => _camera = c);
  }

  bool _ferme = false;

  void _suivre() {
    final r = _reseau;
    if (!mounted || r == null) return;
    setState(() {});
    if ((r.phase == PhaseAppel.fin || r.phase == PhaseAppel.aucune) && !_ferme) {
      _ferme = true;
      if (r.fin == FinAppel.microRefuse) {
        annoncer(context, widget.video ? context.l.camUnavailable : context.l.chMicPermissionDenied, icone: Icons.mic_off_rounded);
      }
      Future<void>.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _raccrocher() {
    final r = _reseau;
    if (r != null) {
      unawaited(r.raccrocher());
      return;
    }
    if (_phase == _Phase.fin) return;
    final duree = _debut == null ? 0 : DateTime.now().difference(_debut!).inSeconds;
    setState(() => _phase = _Phase.fin);
    _tic?.cancel();
    _decroche?.cancel();
    _camera?.couper();
    _depot.enregistrerAppel(widget.discussion, video: widget.video, duree: duree);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _reseau?.removeListener(_suivre);
    _souffle.dispose();
    _tic?.cancel();
    _decroche?.cancel();
    _camera?.couper();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final d = widget.discussion;
    final palette = palettesAvatar[d.couleur % palettesAvatar.length];
    final r = _reseau;
    final String etat;
    final bool sonne;
    if (r != null) {
      sonne = r.phase == PhaseAppel.appel || r.phase == PhaseAppel.sonne;
      etat = switch (r.phase) {
        PhaseAppel.appel => l.clOutgoingCall,
        PhaseAppel.sonne => r.video ? l.clIncomingVideoCall : l.clIncomingCall,
        PhaseAppel.connexion => l.clConnecting,
        PhaseAppel.enCours => r.reconnexion ? l.clReconnecting : chrono(DateTime.now().difference(r.debut ?? DateTime.now())),
        PhaseAppel.fin || PhaseAppel.aucune => switch (r.fin) {
            FinAppel.pasDeReponse => l.callsNoAnswer,
            FinAppel.echec => l.callsConnectionFailed,
            FinAppel.refuse => l.callsNoAnswer,
            _ => l.clCallEnded,
          },
      };
    } else {
      sonne = _phase == _Phase.sonnerie;
      etat = switch (_phase) {
        _Phase.sonnerie => l.clOutgoingCall,
        _Phase.enCours => chrono(DateTime.now().difference(_debut ?? DateTime.now())),
        _Phase.fin => l.clCallEnded,
      };
    }
    final micro = r?.micro ?? _micro;
    final videoActive = r?.camera ?? _videoActive;
    final videoProposee = r?.video ?? widget.video;
    final distante = r != null && r.videoDistante && (r.phase == PhaseAppel.enCours || r.phase == PhaseAppel.connexion);
    final vignette = r != null ? (r.aVideoLocale ? r.vueLocale.typeVue : null) : (_camera != null && _camera!.aVideo ? _camera!.typeVue : null);
    return Scaffold(
      backgroundColor: OuroColors.callBackground,
      body: Stack(
        children: [
          // Le fond : la couleur de l'avatar, très floutée.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.35),
                  radius: 1.1,
                  colors: [palette[0].withValues(alpha: 0.55), palette[1].withValues(alpha: 0.25), OuroColors.callBackground],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: const ColoredBox(color: Color(0x33000000)),
            ),
          ),
          // L'image de l'autre, plein écran, dès qu'elle arrive.
          if (r != null)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: distante ? 1 : 0,
                  duration: const Duration(milliseconds: 420),
                  // Toujours monté : c'est aussi lui qui joue le SON de l'autre.
                  child: HtmlElementView(viewType: r.vueDistante.typeVue),
                ),
              ),
            ),
          if (distante)
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x99000000), Color(0x00000000), Color(0x00000000), Color(0xB3000000)],
                      stops: [0, 0.22, 0.7, 1],
                    ),
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 12, color: OuroColors.callSecondaryLabel),
                    const SizedBox(width: 6),
                    Text(l.clEncryptedShort, style: OuroTypography.footnote.copyWith(color: OuroColors.callSecondaryLabel)),
                  ],
                ),
                const Spacer(),
                // La photo, et ses ondes tant que ça sonne.
                if (distante) const SizedBox(height: 260) else SizedBox(
                  width: 260,
                  height: 260,
                  child: AnimatedBuilder(
                    animation: _souffle,
                    builder: (context, enfant) => CustomPaint(
                      painter: _Ondes(progres: _souffle.value, actif: sonne, couleur: palette[0]),
                      child: enfant,
                    ),
                    child: Center(
                      child: d.estGroupe
                          ? _Mosaique(discussion: d)
                          : AvatarDroplet(nom: d.titre, couleur: d.couleur, taille: 140),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(d.titre, style: OuroTypography.largeTitle.copyWith(color: OuroColors.callLabel)),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    etat,
                    key: ValueKey(r?.phase ?? _phase),
                    style: OuroTypography.title3.copyWith(
                      color: OuroColors.callSecondaryLabel,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Spacer(),
                // Les commandes, dans une barre de verre.
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 0.6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Commande(
                            icone: micro ? Icons.mic_rounded : Icons.mic_off_rounded,
                            libelle: l.clLabelMic,
                            aide: micro ? l.clMuteMic : l.clEnableMic,
                            allume: !micro,
                            onTap: () {
                              if (r != null) {
                                r.basculerMicro();
                                return;
                              }
                              setState(() => _micro = !_micro);
                              _camera?.micro(_micro);
                            },
                          ),
                          const SizedBox(width: 18),
                          _Commande(
                            icone: videoActive ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                            libelle: l.clLabelCamera,
                            aide: videoActive ? l.clDisableCamera : l.clEnableCamera,
                            allume: !videoActive,
                            onTap: videoProposee && (r == null || r.aVideoLocale)
                                ? () {
                                    if (r != null) {
                                      r.basculerCamera();
                                      return;
                                    }
                                    setState(() => _videoActive = !_videoActive);
                                    _camera?.video(_videoActive);
                                  }
                                : null,
                          ),
                          const SizedBox(width: 18),
                          _Commande(
                            icone: Icons.call_end_rounded,
                            libelle: l.clHangUp,
                            aide: l.clHangUp,
                            rouge: true,
                            onTap: _raccrocher,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
          // Ma caméra, en vignette.
          if (vignette != null)
            Positioned(
              right: 24,
              bottom: 130,
              child: AnimatedOpacity(
                opacity: videoActive ? 1 : 0.0,
                duration: const Duration(milliseconds: 240),
                child: Container(
                  width: 220,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: HtmlElementView(viewType: vignette),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Mosaique extends StatelessWidget {
  const _Mosaique({required this.discussion});

  final Discussion discussion;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final membres = discussion.membres.take(4).toList();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (final id in membres) AvatarDroplet(nom: depot.nom(id), couleur: depot.contacts[id]?.couleur ?? 0, taille: membres.length > 2 ? 72 : 96),
      ],
    );
  }
}

class _Ondes extends CustomPainter {
  _Ondes({required this.progres, required this.actif, required this.couleur});

  final double progres;
  final bool actif;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    if (!actif) return;
    final centre = size.center(Offset.zero);
    for (var i = 0; i < 3; i++) {
      final p = (progres + i / 3) % 1;
      final r = 70 + p * 60;
      canvas.drawCircle(
        centre,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.white.withValues(alpha: 0.32 * (1 - p)),
      );
    }
    canvas.drawCircle(centre, 78 + 4 * sin(progres * pi * 2), Paint()..color = couleur.withValues(alpha: 0.18));
  }

  @override
  bool shouldRepaint(_Ondes ancien) => ancien.progres != progres || ancien.actif != actif;
}

class _Commande extends StatelessWidget {
  const _Commande({
    required this.icone,
    required this.libelle,
    required this.onTap,
    this.aide,
    this.allume = false,
    this.rouge = false,
  });

  final IconData icone;
  final String libelle;
  final String? aide;
  final VoidCallback? onTap;
  final bool allume;
  final bool rouge;

  @override
  Widget build(BuildContext context) {
    final fond = rouge
        ? const Color(0xFFFF3B30)
        : allume
            ? Colors.white
            : Colors.white.withValues(alpha: 0.16);
    final encre = allume && !rouge ? Colors.black : Colors.white;
    return Tooltip(
      message: aide ?? libelle,
      child: Survol(
        onTap: onTap,
        builder: (context, survol) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: onTap == null ? Colors.white.withValues(alpha: 0.06) : fond.withValues(alpha: survol ? (fond.a * 0.85) : fond.a),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: onTap == null ? Colors.white38 : encre, size: 28),
            ),
            const SizedBox(height: 6),
            Text(libelle, style: OuroTypography.caption1.copyWith(color: OuroColors.callSecondaryLabel)),
          ],
        ),
      ),
    );
  }
}

// ── L'appel entrant ────────────────────────────────────────────────────

/// Le bandeau qui descend en haut de la fenêtre quand un contact appelle :
/// sa photo, son nom, « Appel vidéo entrant », Refuser et Répondre. Il sonne
/// en même temps que le téléphone ; le premier qui décroche l'emporte.
class BandeauAppelEntrant extends StatelessWidget {
  const BandeauAppelEntrant({super.key});

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final r = depot.reseau;
    if (r == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: r,
      builder: (context, _) {
        final visible = r.phase == PhaseAppel.sonne && r.contact != null;
        final contact = r.contact;
        final d = contact == null ? null : (depot.discussions['p:$contact'] ?? depot.discussionAvec(contact));
        return IgnorePointer(
          ignoring: !visible,
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, -1.4),
            duration: const Duration(milliseconds: 460),
            curve: visible ? kSortie : Curves.easeInCubic,
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 260),
              child: d == null ? const SizedBox(height: 92) : _CarteAppelEntrant(appel: r, discussion: d),
            ),
          ),
        );
      },
    );
  }
}

class _CarteAppelEntrant extends StatelessWidget {
  const _CarteAppelEntrant({required this.appel, required this.discussion});

  final AppelsReseau appel;
  final Discussion discussion;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final d = discussion;
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 34, sigmaY: 34),
            child: Container(
              width: 420,
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              decoration: BoxDecoration(
                color: const Color(0xE61C1C1E),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 0.6),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 40, offset: const Offset(0, 14))],
              ),
              child: Row(
                children: [
                  AvatarDroplet(nom: d.titre, couleur: d.couleur, taille: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(d.titre, maxLines: 1, overflow: TextOverflow.ellipsis, style: OuroTypography.headline.copyWith(color: Colors.white)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(appel.video ? Icons.videocam_rounded : Icons.phone_rounded, size: 14, color: Colors.white60),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                appel.video ? l.clIncomingVideoCall : l.clIncomingCall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: OuroTypography.subheadline.copyWith(color: Colors.white60),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _RondAppel(
                    couleur: const Color(0xFFFF3B30),
                    icone: Icons.call_end_rounded,
                    aide: l.ntfDecline,
                    onTap: () => unawaited(appel.refuser()),
                  ),
                  const SizedBox(width: 10),
                  _RondAppel(
                    couleur: const Color(0xFF34C759),
                    icone: appel.video ? Icons.videocam_rounded : Icons.phone_rounded,
                    aide: l.ntfAnswer,
                    pulse: true,
                    onTap: () {
                      final video = appel.video;
                      unawaited(appel.decrocher());
                      unawaited(_ouvrirEcranAppel(context, d, video: video));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RondAppel extends StatefulWidget {
  const _RondAppel({required this.couleur, required this.icone, required this.aide, required this.onTap, this.pulse = false});

  final Color couleur;
  final IconData icone;
  final String aide;
  final VoidCallback onTap;
  final bool pulse;

  @override
  State<_RondAppel> createState() => _RondAppelState();
}

class _RondAppelState extends State<_RondAppel> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.aide,
      child: Survol(
        onTap: widget.onTap,
        builder: (context, survol) => AnimatedBuilder(
          animation: _c,
          builder: (context, enfant) {
            final t = widget.pulse ? _c.value : 0.0;
            return CustomPaint(
              painter: _Halo(progres: t, couleur: widget.couleur, actif: widget.pulse),
              child: enfant,
            );
          },
          child: AnimatedScale(
            scale: survol ? 1.06 : 1,
            duration: const Duration(milliseconds: 160),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: widget.couleur, shape: BoxShape.circle),
              child: Icon(widget.icone, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _Halo extends CustomPainter {
  _Halo({required this.progres, required this.couleur, required this.actif});

  final double progres;
  final Color couleur;
  final bool actif;

  @override
  void paint(Canvas canvas, Size size) {
    if (!actif) return;
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final p = Curves.easeOutCubic.transform(progres);
    canvas.drawCircle(c, r + 10 * p, Paint()..color = couleur.withValues(alpha: 0.45 * (1 - p)));
  }

  @override
  bool shouldRepaint(_Halo o) => o.progres != progres || o.actif != actif;
}
