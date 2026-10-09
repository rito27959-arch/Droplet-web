// ============================================================================
// LA TRANSITION D'ENVOI DE TELEGRAM — reprise au détail près.
// ----------------------------------------------------------------------------
// Source : `TextMessageEnterTransition.java` et `ChatListItemAnimator.java`
// (Telegram Android, dépôt DrKLO/Telegram). Ce que fait Telegram, et donc
// ce que fait ce fichier :
//
//   • DURÉE : 250 ms, horloge linéaire.
//   • DEUX COURBES. Le mouvement VERTICAL suit la courbe maison de la liste
//     de Telegram, cubic-bezier(0.1992, 0.0106, 0.2792, 0.9103). Le
//     mouvement HORIZONTAL suit easeOut(easeOutQuint(t)) : il est presque
//     fini au tiers du temps. C'est ce décalage — et pas un arc dessiné —
//     qui donne au texte sa trajectoire courbe.
//   • LE TEXTE part exactement de là où il était dans le champ, à la taille
//     du champ (17 pt), et rétrécit vers la taille de la bulle (15 pt) au
//     rythme horizontal. Sa couleur passe de celle du champ à celle de la
//     bulle, et il se fond dans le vrai texte de la bulle pendant les 40 %
//     premiers de l'animation.
//   • LE FOND DE LA BULLE naît de la forme du champ : son haut part 4 dp
//     sous le haut du champ, son bas du bas du champ, son bord gauche suit
//     le texte, son bord droit dépasse de 4 dp puis se range. Il part de la
//     couleur de la barre de saisie et prend la couleur de la bulle en 40 %
//     du temps.
//   • LA VRAIE BULLE (heure, coches, texte final) apparaît sur ces mêmes
//     40 %, et voyage avec le texte.
//   • LE CHAMP DE SAISIE, vidé, réapparaît en fondu sur toute la durée.
//   • La cible n'est pas estimée : c'est la VRAIE bulle, mesurée à chaque
//     image — la liste peut défiler pendant l'envoi, la transition suit.
//
// ── Comment c'est découpé ───────────────────────────────────────────────
//
// [EtatEnvoi] porte l'horloge et les mesures. Trois dessinateurs le lisent :
//
//   1. [CoucheFondEnvoi], posée DERRIÈRE la liste : le fond qui se
//      métamorphose. Derrière, parce que le vrai texte de la bulle doit
//      passer devant lui ; au départ il est caché par la pilule de saisie,
//      qui a exactement sa forme et sa couleur — comme chez Telegram, où il
//      se confond avec elle.
//   2. [EntreeEnvoi], autour de la vraie bulle dans la liste : fond masqué,
//      fondu et déplacement.
//   3. Une entrée d'`Overlay`, AU-DESSUS de tout : le texte qui décolle du
//      champ, avant d'entrer dans la zone de la liste.
//
// ⚠️ SI QUOI QUE CE SOIT MANQUE — champ introuvable, bulle jamais apparue —
// la transition s'arrête et [EtatEnvoi.surFin] est appelé. Une bulle ne
// doit jamais rester invisible.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Les réglages de Telegram.
class TransitionEnvoi {
  TransitionEnvoi._();

  /// `ChatListItemAnimator.DEFAULT_DURATION`.
  static const Duration duree = Duration(milliseconds: 250);

  /// `ChatListItemAnimator.DEFAULT_INTERPOLATOR`.
  static const Curve courbeListe = Cubic(
    0.19919472913616398,
    0.010644531250000006,
    0.27920937042459737,
    0.91025390625,
  );

  /// `CubicBezierInterpolator.EASE_OUT_QUINT` puis `EASE_OUT`.
  static const Curve _quint = Cubic(0.23, 1, 0.32, 1);
  static const Curve _easeOut = Cubic(0, 0, 0.58, 1);

  static double horizontale(double t) => _easeOut.transform(_quint.transform(t));

  /// Le fond et le vrai texte sont en place à 40 % du temps.
  static double apparition(double t) => t > 0.4 ? 1 : t / 0.4;

  /// Au-delà, on renonce : le message n'est jamais arrivé dans la liste.
  static const Duration attenteMax = Duration(milliseconds: 700);

  /// Lance la transition. Renvoie `null` si elle ne peut pas partir.
  static EtatEnvoi? lancer({
    required BuildContext context,
    required GlobalKey champ,
    required String texte,
    required TextStyle styleChamp,
    required EdgeInsets paddingChamp,
    required TextStyle styleBulle,
    required Color couleurPanneau,
    required VoidCallback surFin,
    VoidCallback? surDemarrage,
    ValueChanged<double>? surProgression,
  }) {
    final rendu = champ.currentContext?.findRenderObject();
    if (rendu is! RenderBox || !rendu.hasSize || !rendu.attached) return null;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return null;

    final origine = rendu.localToGlobal(Offset.zero);
    final rectChamp = origine & rendu.size;
    final echelleDepart =
        (styleChamp.fontSize ?? 17) / (styleBulle.fontSize ?? 15);
    final largeurTexte =
        math.max(1.0, rectChamp.width - paddingChamp.horizontal) / echelleDepart;

    final peintre = TextPainter(
      text: TextSpan(text: texte, style: styleBulle),
      textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: largeurTexte);

    final etat = EtatEnvoi._(
      texte: texte,
      rectChamp: rectChamp,
      origineTexteChamp: rectChamp.topLeft + paddingChamp.topLeft,
      echelleDepart: echelleDepart,
      couleurTexteChamp: styleChamp.color ?? Colors.black,
      couleurTexteBulle: styleBulle.color ?? Colors.white,
      couleurPanneau: couleurPanneau,
      peintre: peintre,
      largeurTexte: largeurTexte,
      surFin: surFin,
      surDemarrage: surDemarrage,
      surProgression: surProgression,
    );
    etat._entree = OverlayEntry(
      builder: (_) => IgnorePointer(child: _TexteVolant(etat: etat)),
    );
    overlay.insert(etat._entree!);
    etat._partir();
    return etat;
  }
}

enum RoleBalise { fond, texte }

/// L'état d'une transition d'envoi.
class EtatEnvoi extends ChangeNotifier {
  EtatEnvoi._({
    required this.texte,
    required this.rectChamp,
    required this.origineTexteChamp,
    required this.echelleDepart,
    required this.couleurTexteChamp,
    required this.couleurTexteBulle,
    required this.couleurPanneau,
    required TextPainter peintre,
    required this.largeurTexte,
    required this.surFin,
    this.surDemarrage,
    this.surProgression,
  }) : _peintre = peintre;

  final String texte;
  final Rect rectChamp;
  final Offset origineTexteChamp;
  final double echelleDepart;
  final Color couleurTexteChamp;
  final Color couleurTexteBulle;
  final Color couleurPanneau;
  final TextPainter _peintre;
  final double largeurTexte;
  final VoidCallback surFin;
  final VoidCallback? surDemarrage;
  final ValueChanged<double>? surProgression;

  OverlayEntry? _entree;
  Ticker? _ticker;
  Duration? _depart;
  bool _fini = false;

  // ── Ce que la vraie bulle déclare ─────────────────────────────────
  RenderBox? _boiteFond;
  RenderBox? _boiteTexte;

  /// La couleur et la forme du fond de la vraie bulle.
  Color? couleurFond;
  ShapeBorder? forme;

  // ── L'instant courant ─────────────────────────────────────────────
  double t = 0;
  bool get demarre => _depart != null;
  bool get fini => _fini;

  /// Le déplacement appliqué à la vraie bulle à cette image.
  Offset decalage = Offset.zero;

  /// Le déplacement effectivement peint à l'image précédente.
  Offset _decalagePeint = Offset.zero;

  /// Le fond en cours de métamorphose, en coordonnées d'écran.
  Rect? rectFond;

  /// Le texte volant : origine, échelle, couleur, opacité.
  Offset origineTexte = Offset.zero;
  double echelleTexte = 1;
  double opaciteTexte = 1;
  Color couleurTexte = Colors.black;

  double get apparition => TransitionEnvoi.apparition(t);
  TextPainter get peintre => _peintre;

  /// Le rectangle de la vraie bulle, en coordonnées d'écran.
  ///
  /// Sert à ce qui doit se poser dessus une fois l'envoi fini — la
  /// mascotte, par exemple. `null` si la bulle n'est pas (ou plus) là.
  Rect? get rectBulle {
    final boite = _boiteFond;
    if (!_utilisable(boite)) return null;
    return boite!.localToGlobal(Offset.zero) & boite.size;
  }

  void enregistrer(RoleBalise role, RenderBox boite) {
    if (role == RoleBalise.fond) {
      _boiteFond = boite;
    } else {
      _boiteTexte = boite;
    }
  }

  void oublier(RenderBox boite) {
    if (_boiteFond == boite) _boiteFond = null;
    if (_boiteTexte == boite) _boiteTexte = null;
  }

  /// Appelé par [EntreeEnvoi] au moment où il applique [decalage].
  void notePeint(Offset d) => _decalagePeint = d;

  void _partir() {
    _ticker = Ticker(_battement)..start();
    // Première image : le texte est encore exactement dans le champ.
    origineTexte = origineTexteChamp;
    echelleTexte = echelleDepart;
    couleurTexte = couleurTexteChamp;
    rectFond = null;
  }

  static bool _utilisable(RenderBox? b) => b != null && b.attached && b.hasSize;

  void _battement(Duration ecoule) {
    if (_fini) return;
    if (_depart == null) {
      if (_utilisable(_boiteFond) && _utilisable(_boiteTexte)) {
        _depart = ecoule;
        surDemarrage?.call();
      } else {
        if (ecoule > TransitionEnvoi.attenteMax) terminer();
        return;
      }
    }
    final fond = _boiteFond;
    final boiteTexte = _boiteTexte;
    if (!_utilisable(fond) || !_utilisable(boiteTexte)) {
      // La bulle a quitté l'écran (suppression, changement de conversation).
      terminer();
      return;
    }
    t = ((ecoule - _depart!).inMicroseconds / TransitionEnvoi.duree.inMicroseconds)
        .clamp(0.0, 1.0);
    _calculer(fond!, boiteTexte!);
    surProgression?.call(t);
    notifyListeners();
    if (t >= 1) terminer();
  }

  void _calculer(RenderBox fond, RenderBox boiteTexte) {
    final p = TransitionEnvoi.courbeListe.transform(t);
    final px = TransitionEnvoi.horizontale(t);
    final a = apparition;

    // Les positions FINALES, sans le déplacement déjà peint.
    final fondFinal = (fond.localToGlobal(Offset.zero) - _decalagePeint) & fond.size;
    final texteFinal = boiteTexte.localToGlobal(Offset.zero) - _decalagePeint;

    final depart = origineTexteChamp;
    decalage = Offset(
      (depart.dx - texteFinal.dx) * (1 - px),
      (depart.dy - texteFinal.dy) * (1 - p),
    );

    origineTexte = Offset(
      depart.dx * (1 - px) + texteFinal.dx * px,
      depart.dy * (1 - p) + texteFinal.dy * p,
    );
    echelleTexte = px + echelleDepart * (1 - px);
    couleurTexte = Color.lerp(couleurTexteChamp, couleurTexteBulle, a)!;
    opaciteTexte = 1 - a;

    rectFond = Rect.fromLTRB(
      fondFinal.left + (depart.dx - texteFinal.dx) * (1 - px),
      _lerp(rectChamp.top + 4, fondFinal.top, p),
      fondFinal.right + 4 * (1 - px),
      _lerp(rectChamp.bottom, fondFinal.bottom, p),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Arrête tout et rend la bulle visible. Sans effet si déjà fait.
  void terminer() {
    if (_fini) return;
    _fini = true;
    _ticker?.dispose();
    _ticker = null;
    _entree?.remove();
    _entree = null;
    surProgression?.call(1);
    notifyListeners();
    surFin();
    // Le peintre sert encore à la dernière image éventuelle.
    SchedulerBinding.instance.addPostFrameCallback((_) => _peintre.dispose());
  }
}

/// Donne à la vraie bulle l'état de la transition qui la concerne.
///
/// Sans dépendance : la bulle n'a pas à se reconstruire à chaque image.
/// Elle l'est de toute façon à la fin, quand l'écran retire l'enveloppe.
class EnvoiEnCours extends InheritedWidget {
  const EnvoiEnCours({super.key, required this.etat, required super.child});

  final EtatEnvoi etat;

  static EtatEnvoi? maybeOf(BuildContext context) {
    final etat = context.getInheritedWidgetOfExactType<EnvoiEnCours>()?.etat;
    return etat == null || etat.fini ? null : etat;
  }

  @override
  bool updateShouldNotify(EnvoiEnCours oldWidget) => oldWidget.etat != etat;
}

/// Marque la boîte du fond ou du texte d'une bulle. Toujours présente dans
/// l'arbre : sa présence ne change jamais la structure, seulement l'état
/// qu'elle renseigne.
class BaliseEnvoi extends SingleChildRenderObjectWidget {
  const BaliseEnvoi({super.key, required this.role, super.child});

  final RoleBalise role;

  static EtatEnvoi? _etat(BuildContext context) =>
      context.getInheritedWidgetOfExactType<EnvoiEnCours>()?.etat;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenduBalise(role, _etat(context));

  @override
  void updateRenderObject(BuildContext context, RenduBalise renderObject) {
    renderObject.etat = _etat(context);
  }
}

class RenduBalise extends RenderProxyBox {
  RenduBalise(this.role, this._etat);

  final RoleBalise role;
  EtatEnvoi? _etat;

  set etat(EtatEnvoi? valeur) {
    if (valeur == _etat) return;
    _etat?.oublier(this);
    _etat = valeur;
    if (hasSize) valeur?.enregistrer(role, this);
  }

  @override
  void performLayout() {
    super.performLayout();
    _etat?.enregistrer(role, this);
  }

  @override
  void detach() {
    _etat?.oublier(this);
    super.detach();
  }
}

/// La vraie bulle pendant la transition : invisible avant le départ, puis
/// en fondu et en mouvement.
class EntreeEnvoi extends StatelessWidget {
  const EntreeEnvoi({super.key, required this.etat, required this.child});

  final EtatEnvoi etat;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EnvoiEnCours(
      etat: etat,
      child: ListenableBuilder(
        listenable: etat,
        child: child,
        builder: (context, enfant) {
          if (etat.fini) return enfant!;
          final d = etat.demarre ? etat.decalage : Offset.zero;
          etat.notePeint(d);
          return Opacity(
            opacity: etat.demarre ? etat.apparition : 0,
            child: Transform.translate(offset: d, child: enfant),
          );
        },
      ),
    );
  }
}

/// Le fond qui se métamorphose, à poser DERRIÈRE la liste.
class CoucheFondEnvoi extends StatelessWidget {
  const CoucheFondEnvoi({super.key, required this.etat});

  final EtatEnvoi? etat;

  @override
  Widget build(BuildContext context) {
    final e = etat;
    if (e == null) return const SizedBox.shrink();
    return IgnorePointer(child: _Dessin(etat: e, dessiner: _dessinerFond));
  }
}

void _dessinerFond(Canvas canvas, EtatEnvoi etat, Offset Function(Offset) versLocal) {
  final rect = etat.rectFond;
  final forme = etat.forme;
  if (!etat.demarre || rect == null || forme == null) return;
  final local = rect.shift(versLocal(rect.topLeft) - rect.topLeft);
  final chemin = forme.getOuterPath(local);
  final a = etat.apparition;
  if (a < 1) {
    canvas.drawPath(chemin, Paint()..color = etat.couleurPanneau);
  }
  final couleur = etat.couleurFond ?? Colors.blue;
  canvas.drawPath(
    chemin,
    Paint()..color = couleur.withValues(alpha: couleur.a * a),
  );
}

/// Le texte qui décolle du champ, au-dessus de tout.
class _TexteVolant extends StatelessWidget {
  const _TexteVolant({required this.etat});

  final EtatEnvoi etat;

  @override
  Widget build(BuildContext context) => _Dessin(etat: etat, dessiner: _dessinerTexte);
}

void _dessinerTexte(Canvas canvas, EtatEnvoi etat, Offset Function(Offset) versLocal) {
  if (etat.opaciteTexte <= 0) return;
  final peintre = etat.peintre;
  // Couleur et opacité du moment : le style est recalculé à chaque image.
  final style = (peintre.text as TextSpan).style!;
  peintre.text = TextSpan(
    text: etat.texte,
    style: style.copyWith(
      color: etat.couleurTexte.withValues(
        alpha: etat.couleurTexte.a * etat.opaciteTexte,
      ),
    ),
  );
  peintre.layout(maxWidth: etat.largeurTexte);

  canvas.save();
  // Telegram rogne le texte au fond de la bulle, 4 dp à l'intérieur.
  final rect = etat.rectFond;
  if (rect != null) {
    final r = rect.deflate(4);
    canvas.clipRect(r.shift(versLocal(r.topLeft) - r.topLeft));
  }
  final o = versLocal(etat.origineTexte);
  canvas.translate(o.dx, o.dy);
  canvas.scale(etat.echelleTexte);
  peintre.paint(canvas, Offset.zero);
  canvas.restore();
}

typedef _FonctionDessin = void Function(
  Canvas canvas,
  EtatEnvoi etat,
  Offset Function(Offset global) versLocal,
);

/// Une surface qui se repeint à chaque image de la transition, et qui sait
/// convertir les coordonnées d'écran dans son propre repère — y compris
/// pendant une transition de page, où l'écran entier est déplacé.
class _Dessin extends LeafRenderObjectWidget {
  const _Dessin({required this.etat, required this.dessiner});

  final EtatEnvoi etat;
  final _FonctionDessin dessiner;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenduDessin(etat, dessiner);

  @override
  void updateRenderObject(BuildContext context, _RenduDessin renderObject) {
    renderObject
      ..etat = etat
      ..dessiner = dessiner;
  }
}

class _RenduDessin extends RenderBox {
  _RenduDessin(this._etat, this.dessiner);

  EtatEnvoi _etat;
  _FonctionDessin dessiner;

  set etat(EtatEnvoi valeur) {
    if (valeur == _etat) return;
    if (attached) {
      _etat.removeListener(markNeedsPaint);
      valeur.addListener(markNeedsPaint);
    }
    _etat = valeur;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _etat.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _etat.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTestSelf(Offset position) => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_etat.fini) return;
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    dessiner(canvas, _etat, globalToLocal);
    canvas.restore();
  }
}
