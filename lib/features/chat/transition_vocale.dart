// ============================================================================
// LA TRANSITION D'ENVOI D'UN VOCAL — le cercle d'enregistrement qui devient
// la bulle.
// ----------------------------------------------------------------------------
// Source : `VoiceMessageEnterTransition.java` (Telegram Android). Mesuré,
// pas recopié : le Java peint sur un `Canvas` Android, aucune ligne n'est
// transposable. Et le dépôt est en GPL v2 — recopier obligerait Droplet à
// publier toutes ses sources.
//
// ── CE QUI SE PASSE, ET POURQUOI CE N'EST PAS LA MÊME QUE POUR LE TEXTE ─
//
// Pour un message texte, Telegram fait voyager DEUX rendus du texte et DEUX
// fonds, sur 250 ms. Pour un vocal, il n'y a rien à faire voyager : le
// cercle d'enregistrement EST déjà un disque, et la bulle vocale contient
// déjà un disque — le bouton de lecture. L'animation se réduit donc à
// déplacer un cercle d'un disque vers l'autre, en changeant son rayon et
// sa couleur.
//
// C'est plus court — **220 ms contre 250** — et c'est cohérent : il n'y a
// pas de métamorphose de forme à digérer, juste un trajet.
//
// ── ⚠️ DEUX HORLOGES, PAS UNE, ET PAS LES MÊMES QUE POUR LE TEXTE ──────
//
//   • la VERTICALE, le RAYON, la COULEUR et l'OPACITÉ suivent la courbe
//     par défaut de Telegram, cubic-bezier(0.25, 0.1, 0.25, 1) ;
//   • l'HORIZONTALE suit easeOutQuint, qui file beaucoup plus vite.
//
// Même principe que pour le texte — l'horizontale devance la verticale, et
// c'est ce décalage qui courbe la trajectoire — mais avec **une seule**
// courbe sur l'horizontale, là où le texte en compose deux. Les deux
// animations ne sont donc PAS interchangeables, et les mélanger donnerait
// un vocal qui part comme un texte : trop vif pour un trajet aussi court.
//
// ── ⚠️ LES ONDES DISPARAISSENT SUR LES 60 % PREMIERS ──────────────────
//
// Pas sur toute la durée. Les gouttes doivent avoir fini de se résorber
// AVANT que le cercle n'arrive à destination : une bulle vocale qui se
// pose avec des ondes encore accrochées autour ressemble à un
// enregistrement qui continue.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Les réglages de Telegram pour le vocal.
class TransitionVocale {
  TransitionVocale._();

  /// `VoiceMessageEnterTransition:75`.
  static const Duration duree = Duration(milliseconds: 220);

  /// `CubicBezierInterpolator.DEFAULT` — verticale, rayon, couleur, opacité.
  static const Curve courbePrincipale = Cubic(0.25, 0.1, 0.25, 1);

  /// `CubicBezierInterpolator.EASE_OUT_QUINT` — l'horizontale, seule.
  static const Curve courbeHorizontale = Cubic(0.23, 1, 0.32, 1);

  /// Les ondes ont disparu à 60 % du trajet.
  /// (`VoiceMessageEnterTransition:101-103`)
  static const double finDesOndes = 0.6;

  static double ondes(double t) =>
      1 - (t / finDesOndes).clamp(0.0, 1.0);

  /// Au-delà, on renonce : la bulle n'est jamais apparue.
  static const Duration attenteMax = Duration(milliseconds: 700);

  /// Lance la transition. Renvoie `null` si elle ne peut pas partir.
  ///
  /// [centreDepart] et [rayonDepart] décrivent le cercle d'enregistrement
  /// au moment où le doigt se lève — c'est l'appelant qui les connaît.
  static EtatVocal? lancer({
    required BuildContext context,
    required Offset centreDepart,
    required double rayonDepart,
    required Color couleurDepart,
    required Color couleurArrivee,
    required VoidCallback surFin,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return null;
    final etat = EtatVocal._(
      centreDepart: centreDepart,
      rayonDepart: rayonDepart,
      couleurDepart: couleurDepart,
      couleurArrivee: couleurArrivee,
      surFin: surFin,
    );
    etat._entree = OverlayEntry(
      builder: (_) => IgnorePointer(child: _DisqueVolant(etat: etat)),
    );
    overlay.insert(etat._entree!);
    etat._partir();
    return etat;
  }
}

/// L'état d'une transition vocale.
class EtatVocal extends ChangeNotifier {
  EtatVocal._({
    required this.centreDepart,
    required this.rayonDepart,
    required this.couleurDepart,
    required this.couleurArrivee,
    required this.surFin,
  });

  final Offset centreDepart;
  final double rayonDepart;
  final Color couleurDepart;
  final Color couleurArrivee;
  final VoidCallback surFin;

  OverlayEntry? _entree;
  Ticker? _ticker;
  Duration? _debut;
  bool _fini = false;

  /// La boîte du bouton de lecture de la vraie bulle, déclarée par elle.
  RenderBox? _cible;

  /// ⚠️ LA DERNIÈRE CIBLE CONNUE EST CONSERVÉE. Chez Telegram, la variante
  /// vocale réutilise `lastToCx/lastToCy` quand la cellule disparaît en
  /// cours de route, là où la variante texte abandonne le dessin. Deux
  /// politiques différentes pour le même problème — et celle du vocal est
  /// la bonne ici : un disque qui s'arrête net au milieu de l'écran se
  /// remarque beaucoup plus qu'un disque qui finit son trajet vers un
  /// endroit devenu approximatif.
  Rect? _derniereCible;

  bool get fini => _fini;
  bool get demarre => _debut != null;

  double _brut = 0;

  /// La progression principale : verticale, rayon, couleur, opacité.
  double get principale => TransitionVocale.courbePrincipale.transform(_brut);

  /// La progression horizontale, en avance sur l'autre.
  double get horizontale => TransitionVocale.courbeHorizontale.transform(_brut);

  /// Ce qui reste des ondes, de 1 à 0.
  double get ondes => TransitionVocale.ondes(_brut);

  /// La bulle vocale déclare où se trouve son bouton de lecture.
  void declarerCible(RenderBox? boite) {
    if (boite == null || !boite.hasSize || !boite.attached) return;
    _cible = boite;
  }

  void oublierCible(RenderBox boite) {
    if (_cible == boite) _cible = null;
  }

  Rect? get _rectCible {
    final b = _cible;
    if (b == null || !b.hasSize || !b.attached) return _derniereCible;
    final r = b.localToGlobal(Offset.zero) & b.size;
    _derniereCible = r;
    return r;
  }

  void _partir() {
    _ticker = Ticker(_tic)..start();
  }

  void _tic(Duration temps) {
    if (_fini) return;
    _debut ??= temps;
    final ecoule = temps - _debut!;

    // La bulle n'est pas encore là : on attend, sans avancer. Le disque
    // reste posé sur le cercle d'enregistrement, ce qui est exactement
    // l'image qu'il y avait avant.
    if (_rectCible == null) {
      if (ecoule > TransitionVocale.attenteMax) _terminer();
      _debut = temps;
      return;
    }

    _brut = (ecoule.inMicroseconds / TransitionVocale.duree.inMicroseconds)
        .clamp(0.0, 1.0);
    notifyListeners();
    if (_brut >= 1) _terminer();
  }

  /// Coupe court : un nouvel envoi arrive alors que le précédent n'a pas
  /// fini son trajet. Deux disques en vol se croiseraient à l'écran.
  void terminerMaintenant() => _terminer();

  void _terminer() {
    if (_fini) return;
    _fini = true;
    _ticker?.dispose();
    _ticker = null;
    _entree?.remove();
    _entree = null;
    surFin();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _entree?.remove();
    super.dispose();
  }
}

/// Le disque qui voyage, posé au-dessus de tout.
class _DisqueVolant extends StatelessWidget {
  const _DisqueVolant({required this.etat});

  final EtatVocal etat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: etat,
      builder: (context, _) {
        if (etat.fini) return const SizedBox.shrink();
        final cible = etat._rectCible;
        if (cible == null) return const SizedBox.shrink();
        return CustomPaint(
          size: Size.infinite,
          painter: _PeintreDisque(etat: etat, cible: cible),
        );
      },
    );
  }
}

class _PeintreDisque extends CustomPainter {
  _PeintreDisque({required this.etat, required this.cible});

  final EtatVocal etat;
  final Rect cible;

  @override
  void paint(Canvas toile, Size taille) {
    final p = etat.principale;
    final px = etat.horizontale;

    // ⚠️ LE RAYON D'ARRIVÉE EST LA MOITIÉ DE LA HAUTEUR, PAS DE LA
    // LARGEUR. Le bouton de lecture est rond ; si sa boîte ne l'est pas
    // tout à fait — un point de marge d'un côté suffit — prendre la
    // largeur ferait finir le disque légèrement trop gros, et le raccord
    // avec le vrai bouton se verrait au dernier instant.
    final rayonArrivee = cible.height / 2;

    final cx = etat.centreDepart.dx +
        (cible.center.dx - etat.centreDepart.dx) * px;
    final cy = etat.centreDepart.dy +
        (cible.center.dy - etat.centreDepart.dy) * p;
    final rayon = etat.rayonDepart + (rayonArrivee - etat.rayonDepart) * p;

    final couleur =
        Color.lerp(etat.couleurDepart, etat.couleurArrivee, p) ??
            etat.couleurArrivee;

    toile.drawCircle(Offset(cx, cy), rayon, Paint()..color = couleur);
  }

  @override
  bool shouldRepaint(_PeintreDisque vieux) => true;
}

/// À poser autour du bouton de lecture de la bulle vocale, pour qu'elle
/// dise où elle est.
///
/// ⚠️ ELLE SE MESURE ELLE-MÊME À CHAQUE IMAGE. La liste défile pendant
/// l'envoi — elle vient justement de gagner une ligne — et une cible figée
/// au départ ferait atterrir le disque à côté.
class CibleVocale extends StatefulWidget {
  const CibleVocale({super.key, required this.etat, required this.child});

  final EtatVocal? etat;
  final Widget child;

  @override
  State<CibleVocale> createState() => _CibleVocaleState();
}

class _CibleVocaleState extends State<CibleVocale> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _declarer();
  }

  void _declarer() {
    final e = widget.etat;
    if (e == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final r = context.findRenderObject();
      if (r is RenderBox) e.declarerCible(r);
    });
  }

  @override
  void dispose() {
    final r = context.findRenderObject();
    if (r is RenderBox) widget.etat?.oublierCible(r);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _declarer();
    final e = widget.etat;
    if (e == null || e.fini) return widget.child;
    // Pendant le trajet, le vrai bouton est masqué : c'est le disque de
    // la surcouche qui le représente, et les voir tous les deux donnerait
    // deux boutons de lecture à l'arrivée.
    return ListenableBuilder(
      listenable: e,
      child: widget.child,
      builder: (context, enfant) => Opacity(
        opacity: e.fini ? 1 : math.max(0.0, e.principale * 2 - 1),
        child: enfant,
      ),
    );
  }
}
