// L'ÉCRAN DE LIAISON — la première chose qu'on voit sur web.dropletmesh.app.
//
// La grammaire de WhatsApp Web et de l'app Messages sur Mac, à la finition
// d'iOS :
//   • en haut, la rue de Droplet (`scene_accueil.dart`) en attente : la
//     fenêtre de cet ordinateur clignote, les messages s'arrêtent chez le
//     voisin — elle s'allumera une fois le téléphone lié ;
//   • dessous, une seule carte de verre : à gauche les trois étapes, chacune
//     avec l'icône de ce qu'on touche (l'app, Réglages, le viseur), reliées
//     par un fil comme les écrans de configuration d'iOS ; à droite le code
//     QR sur son carré blanc (toujours blanc, même en sombre : un scanner lit
//     mal un code clair sur fond noir), encadré par les coins d'un viseur ;
//   • le temps qui reste, dans une petite capsule sous le code.
//
// Sur un écran étroit (un téléphone qui ouvre le site), on ne montre PAS de
// code : il ne pourrait pas se scanner lui-même. On explique, simplement.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr/qr.dart' show QrErrorCorrectLevel;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web/web.dart' as web;

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../fond/goutte.dart';
import '../donnees/transport.dart' show EtatConnexion;
import '../fond/scene_accueil.dart';
import '../textes.dart';
import 'compte_lie.dart';
import 'invitation_liaison.dart';

/// La courbe de sortie d'Apple : rapide au départ, très douce à l'arrivée.
const Curve kSortie = Cubic(0.16, 1, 0.3, 1);

class EcranLiaison extends StatefulWidget {
  const EcranLiaison({super.key, required this.textes, this.onDemo, this.onLie});

  final Textes textes;

  /// Le téléphone a lié ce navigateur : le compte, et « Rester connecté ».
  final void Function(CompteLie compte, bool rester)? onLie;

  /// « Essayer la démonstration » : l'interface complète, avec des
  /// discussions d'exemple, sans téléphone.
  final VoidCallback? onDemo;

  @override
  State<EcranLiaison> createState() => _EcranLiaisonState();
}

class _EcranLiaisonState extends State<EcranLiaison> {
  static const _duree = 60;

  InvitationLiaison? _invitation;
  int _restant = _duree;
  bool _rester = false;
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _renouveler();
    _minuteur = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_restant <= 1) {
        _renouveler();
      } else {
        setState(() => _restant--);
      }
    });
  }

  AttenteLiaison? _attente;

  Future<void> _renouveler() async {
    final nouvelle = await InvitationLiaison.nouvelle();
    if (!mounted) return;
    // Un nouveau code, un nouveau canal : on écoute celui-là.
    _attente?.arreter();
    _attente = AttenteLiaison(nouvelle, onLie: (compte) {
      _minuteur?.cancel();
      widget.onLie?.call(compte, _rester);
    })
      ..demarrer();
    setState(() {
      _invitation = nouvelle;
      _restant = _duree;
    });
  }

  @override
  void dispose() {
    _attente?.arreter();
    _minuteur?.cancel();
    super.dispose();
  }

  void _ouvrir(String url) => web.window.open(url, '_blank');

  @override
  Widget build(BuildContext context) {
    final t = widget.textes;
    final largeur = MediaQuery.sizeOf(context).width;
    final etroit = largeur < 760;

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      body: Stack(
        children: [
          // Un léger dégradé d'accent en haut : la page a une lumière.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -1.1),
                    radius: 1.2,
                    colors: [
                      OuroColors.accent.withValues(alpha: OuroColors.isDark ? 0.16 : 0.10),
                      OuroColors.accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, etroit ? 76 : 84, 20, 32),
                child: _Apparition(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 940),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: etroit ? 560 : 620),
                          child: SceneAccueil(
                            etat: EtatConnexion.connexion,
                            accent: OuroColors.accent,
                            encre: OuroColors.label,
                            carte: OuroColors.secondarySystemGroupedBackground,
                            sombre: OuroColors.isDark,
                          ),
                        ),
                        SizedBox(height: etroit ? 24 : 32),
                        if (etroit)
                          _GrandEcran(
                            textes: t,
                            onTelecharger: () => _ouvrir('https://dropletmesh.app/'),
                            onDemo: widget.onDemo,
                          )
                        else
                          _CarteVerre(
                            child: _Contenu(
                              textes: t,
                              invitation: _invitation,
                              restant: _restant,
                              duree: _duree,
                              rester: _rester,
                              onRester: (v) => setState(() => _rester = v),
                              onRenouveler: _renouveler,
                            ),
                          ),
                        const SizedBox(height: 22),
                        _PiedDePage(
                          textes: t,
                          onAide: () => _ouvrir('https://dropletmesh.app/support/'),
                          onTelecharger: () => _ouvrir('https://dropletmesh.app/'),
                        ),
                        if (widget.onDemo != null && !etroit) ...[
                          const SizedBox(height: 14),
                          _LienDemo(texte: t.essayerDemo, onTap: widget.onDemo!),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // La marque en haut à gauche, comme WhatsApp Web, sur une barre
          // de verre quand la page défile dessous.
          Positioned(
            top: 22,
            left: 28,
            child: SafeArea(child: _Marque(textes: t)),
          ),
        ],
      ),
    );
  }
}

/// L'entrée de la page : la carte monte de 18 points et s'éclaircit, sur la
/// courbe de sortie d'Apple.
class _Apparition extends StatelessWidget {
  const _Apparition({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: kSortie,
      child: child,
      builder: (context, v, enfant) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: Transform.scale(scale: 0.97 + 0.03 * v, child: enfant),
        ),
      ),
    );
  }
}

class _Marque extends StatelessWidget {
  const _Marque({required this.textes});

  final Textes textes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Goutte(taille: 30, couleur: OuroColors.accent),
        const SizedBox(width: 10),
        Text(
          textes.titre,
          style: OuroTypography.title2.copyWith(color: OuroColors.label),
        ),
      ],
    );
  }
}

/// La carte de verre : un flou d'arrière-plan, une teinte de surface, un
/// liseré d'un demi-point et une ombre très large — la matière des
/// panneaux de macOS et d'iOS.
class _CarteVerre extends StatelessWidget {
  const _CarteVerre({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    const rayon = BorderRadius.all(Radius.circular(28));
    return Container(
      constraints: const BoxConstraints(maxWidth: 940),
      decoration: BoxDecoration(
        borderRadius: rayon,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: OuroColors.isDark ? 0.5 : 0.10),
            blurRadius: 60,
            offset: const Offset(0, 24),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: rayon,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: rayon,
              color: OuroColors.secondarySystemGroupedBackground
                  .withValues(alpha: OuroColors.isDark ? 0.78 : 0.82),
              border: Border.all(color: OuroColors.separator, width: 0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({
    required this.textes,
    required this.invitation,
    required this.restant,
    required this.duree,
    required this.rester,
    required this.onRester,
    required this.onRenouveler,
  });

  final Textes textes;
  final InvitationLiaison? invitation;
  final int restant;
  final int duree;
  final bool rester;
  final ValueChanged<bool> onRester;
  final VoidCallback onRenouveler;

  @override
  Widget build(BuildContext context) {
    final t = textes;
    return Padding(
      padding: const EdgeInsets.fromLTRB(48, 44, 44, 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.connexion,
                  style: OuroTypography.largeTitle.copyWith(color: OuroColors.label, height: 1.1),
                ),
                const SizedBox(height: 10),
                Text(
                  t.sousTitre,
                  style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel),
                ),
                const SizedBox(height: 30),
                _Etape(icone: const _IconeApp(), texte: t.etape1, fil: true),
                _Etape(icone: const _IconeReglages(), texte: t.etape2, fil: true),
                _Etape(icone: const _IconeViseur(), texte: t.etape3, fil: false),
                const SizedBox(height: 26),
                Container(height: 0.5, color: OuroColors.separator),
                const SizedBox(height: 18),
                _Rester(textes: t, valeur: rester, onChanged: onRester),
              ],
            ),
          ),
          const SizedBox(width: 52),
          _BlocQr(
            textes: t,
            invitation: invitation,
            restant: restant,
            duree: duree,
            onRenouveler: onRenouveler,
          ),
        ],
      ),
    );
  }
}

/// Une étape : l'icône de ce qu'on touche, à la manière de l'écran
/// d'accueil d'iOS, reliée à la suivante par un fil fin.
class _Etape extends StatelessWidget {
  const _Etape({required this.icone, required this.texte, required this.fil});

  final Widget icone;
  final String texte;
  final bool fil;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              icone,
              if (fil)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: OuroColors.separator,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 7, bottom: fil ? 22 : 0),
              child: Text(
                texte,
                style: OuroTypography.body.copyWith(color: OuroColors.label, height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Le carré arrondi d'une icône d'app iOS, à la taille d'une ligne.
class _Tuile extends StatelessWidget {
  const _Tuile({required this.couleurs, required this.child});

  final List<Color> couleurs;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: couleurs),
        boxShadow: [
          BoxShadow(color: couleurs.last.withValues(alpha: 0.30), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _IconeApp extends StatelessWidget {
  const _IconeApp();

  @override
  Widget build(BuildContext context) {
    final a = OuroColors.accent;
    return _Tuile(
      couleurs: [Color.lerp(a, Colors.white, 0.12)!, Color.lerp(a, Colors.black, 0.18)!],
      child: const Goutte(taille: 24, couleur: Colors.white),
    );
  }
}

class _IconeReglages extends StatelessWidget {
  const _IconeReglages();

  @override
  Widget build(BuildContext context) {
    return const _Tuile(
      couleurs: [Color(0xFFA2A2A8), Color(0xFF6C6C72)],
      child: Icon(Icons.settings_rounded, size: 23, color: Colors.white),
    );
  }
}

class _IconeViseur extends StatelessWidget {
  const _IconeViseur();

  @override
  Widget build(BuildContext context) {
    return const _Tuile(
      couleurs: [Color(0xFF3A3A3C), Color(0xFF1C1C1E)],
      child: Icon(Icons.qr_code_scanner_rounded, size: 21, color: Colors.white),
    );
  }
}

class _Rester extends StatelessWidget {
  const _Rester({required this.textes, required this.valeur, required this.onChanged});

  final Textes textes;
  final bool valeur;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CupertinoSwitch(
          value: valeur,
          onChanged: onChanged,
          activeTrackColor: OuroColors.accent,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(textes.rester,
                  style: OuroTypography.subheadline.copyWith(color: OuroColors.label)),
              const SizedBox(height: 2),
              Text(textes.resterAide,
                  style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlocQr extends StatelessWidget {
  const _BlocQr({
    required this.textes,
    required this.invitation,
    required this.restant,
    required this.duree,
    required this.onRenouveler,
  });

  final Textes textes;
  final InvitationLiaison? invitation;
  final int restant;
  final int duree;
  final VoidCallback onRenouveler;

  static const double _cote = 248;

  @override
  Widget build(BuildContext context) {
    final inv = invitation;
    final reduit = MediaQuery.disableAnimationsOf(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Les coins d'un viseur, comme l'appareil photo d'iOS quand il
        // repère un code : ils respirent à peine.
        _Respire(
          actif: !reduit,
          builder: (context, v) => CustomPaint(
            foregroundPainter: _Coins(couleur: OuroColors.accent, ecart: 2 + 3 * v),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                width: _cote,
                height: _cote,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: OuroColors.isDark ? 0.35 : 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: kSortie,
                  transitionBuilder: (enfant, a) => FadeTransition(
                    opacity: a,
                    child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(a), child: enfant),
                  ),
                  child: inv == null
                      ? const Center(key: ValueKey('attente'), child: CupertinoActivityIndicator(color: Color(0xFF8E8E93)))
                      : Stack(
                          key: ValueKey(inv.canal),
                          alignment: Alignment.center,
                          children: [
                            Semantics(
                              label: textes.codeLiaison,
                              image: true,
                              child: QrImageView(
                                data: inv.contenuQr,
                                version: QrVersions.auto,
                                errorCorrectionLevel: QrErrorCorrectLevel.H,
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.circle,
                                  color: Color(0xFF1C1C1E),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.circle,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                            // Le logo au centre, sur sa pastille blanche.
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Goutte(taille: 32, couleur: OuroColors.accent),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Le temps qui reste : une capsule avec un petit cadran qui se vide,
        // et le renouvellement à portée de main.
        Container(
          padding: const EdgeInsets.fromLTRB(10, 5, 4, 5),
          decoration: BoxDecoration(
            color: OuroColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: restant / duree),
                duration: const Duration(milliseconds: 950),
                builder: (context, p, _) => SizedBox.square(
                  dimension: 14,
                  child: CustomPaint(painter: _Cadran(progres: p, couleur: OuroColors.accent, fond: OuroColors.separator)),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                textes.renouvele(restant),
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.secondaryLabel,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 2),
              Semantics(
                button: true,
                label: textes.nouveauCode,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(28, 28),
                  onPressed: onRenouveler,
                  child: Icon(Icons.refresh_rounded, size: 17, color: OuroColors.accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Une valeur qui va et vient entre 0 et 1, doucement (2,4 s l'aller).
class _Respire extends StatefulWidget {
  const _Respire({required this.actif, required this.builder});

  final bool actif;
  final Widget Function(BuildContext, double) builder;

  @override
  State<_Respire> createState() => _RespireState();
}

class _RespireState extends State<_Respire> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));

  @override
  void initState() {
    super.initState();
    if (widget.actif) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => widget.builder(context, Curves.easeInOut.transform(_c.value)),
      );
}

/// Les quatre coins du viseur, autour du carré blanc.
class _Coins extends CustomPainter {
  _Coins({required this.couleur, required this.ecart});

  final Color couleur;
  final double ecart;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(ecart);
    const l = 30.0, rayon = 18.0;
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..color = couleur;
    for (final (x, y, sx, sy) in [
      (r.left, r.top, 1.0, 1.0),
      (r.right, r.top, -1.0, 1.0),
      (r.left, r.bottom, 1.0, -1.0),
      (r.right, r.bottom, -1.0, -1.0),
    ]) {
      final chemin = Path()
        ..moveTo(x, y + sy * l)
        ..lineTo(x, y + sy * rayon)
        ..quadraticBezierTo(x, y, x + sx * rayon, y)
        ..lineTo(x + sx * l, y);
      canvas.drawPath(chemin, p);
    }
  }

  @override
  bool shouldRepaint(_Coins a) => a.ecart != ecart || a.couleur != couleur;
}

/// Le petit cadran du temps qui reste : un disque qui se vide.
class _Cadran extends CustomPainter {
  _Cadran({required this.progres, required this.couleur, required this.fond});

  final double progres;
  final Color couleur;
  final Color fond;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = fond);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.5708,
      6.28318 * progres.clamp(0.0, 1.0),
      true,
      Paint()..color = couleur,
    );
  }

  @override
  bool shouldRepaint(_Cadran a) => a.progres != progres || a.couleur != couleur || a.fond != fond;
}

/// Sur un téléphone : pas de code à scanner, une explication et l'app.
class _GrandEcran extends StatelessWidget {
  const _GrandEcran({required this.textes, required this.onTelecharger, this.onDemo});

  final Textes textes;
  final VoidCallback onTelecharger;
  final VoidCallback? onDemo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            textes.sousTitre,
            textAlign: TextAlign.center,
            style: OuroTypography.title1.copyWith(color: OuroColors.label),
          ),
          const SizedBox(height: 12),
          Text(
            textes.grandEcran,
            textAlign: TextAlign.center,
            style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel, height: 1.4),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 15),
              color: OuroColors.accentRempli,
              borderRadius: BorderRadius.circular(14),
              onPressed: onTelecharger,
              child: Text(
                textes.telecharger,
                style: OuroTypography.headline.copyWith(color: OuroColors.texteSurAccent),
              ),
            ),
          ),
          if (onDemo != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: OuroColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                onPressed: onDemo,
                child: Text(
                  textes.essayerDemo,
                  style: OuroTypography.headline.copyWith(color: OuroColors.accent),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PiedDePage extends StatelessWidget {
  const _PiedDePage({required this.textes, required this.onAide, required this.onTelecharger});

  final Textes textes;
  final VoidCallback onAide;
  final VoidCallback onTelecharger;

  @override
  Widget build(BuildContext context) {
    final discret = OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel);
    final lien = OuroTypography.footnote.copyWith(color: OuroColors.accent);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, size: 13, color: OuroColors.secondaryLabel),
            const SizedBox(width: 6),
            Text(textes.chiffre, style: discret),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(textes.pasEncore, style: discret),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 28),
              onPressed: onTelecharger,
              child: Text(textes.telecharger, style: lien),
            ),
            Text('·', style: discret),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 28),
              onPressed: onAide,
              child: Text(textes.aide, style: lien),
            ),
          ],
        ),
      ],
    );
  }
}


/// Le lien discret vers la démonstration, sous le pied de page.
class _LienDemo extends StatefulWidget {
  const _LienDemo({required this.texte, required this.onTap});

  final String texte;
  final VoidCallback onTap;

  @override
  State<_LienDemo> createState() => _LienDemoState();
}

class _LienDemoState extends State<_LienDemo> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: _survol ? OuroColors.accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_outline_rounded, size: 18, color: OuroColors.accent),
              const SizedBox(width: 8),
              Text(widget.texte, style: OuroTypography.subheadline.copyWith(color: OuroColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
