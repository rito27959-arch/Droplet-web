// ============================================================================
// LE RETOUR TACTILE D'iOS POUR LES BOUTONS MATERIAL.
// ----------------------------------------------------------------------------
// Les boutons texte n'avaient AUCUN retour sous le doigt (le thème retire
// l'ondulation et le voile), et les boutons pleins un voile gris d'Android.
// Enveloppés ici, ils se comportent comme sur iPhone :
//
//   • bouton texte : il s'estompe à 35 % sans délai, revient en 0,2 s ;
//   • bouton plein ou bordé : le langage de pression de l'app (celui
//     d'`OuroPressable`) — 97 % de taille, 75 % d'opacité, sur ressort ;
//   • dans une liste qui défile, l'appui ne s'affiche qu'après 100 ms, comme
//     UIKit : un geste de défilement ne fait pas clignoter les boutons ;
//   • un tap très bref laisse un éclair visible, sinon l'appui ne se voit
//     pas ;
//   • un bouton désactivé ne réagit pas.
// ============================================================================

import 'dart:async';

import 'package:flutter/gestures.dart' show kTouchSlop;
import 'package:flutter/material.dart';
import 'package:motor/motor.dart';

import 'ouro_motion.dart';

class OuroRetourIos extends StatefulWidget {
  const OuroRetourIos({super.key, required this.child});

  final Widget child;

  @override
  State<OuroRetourIos> createState() => _OuroRetourIosState();
}

class _OuroRetourIosState extends State<OuroRetourIos> {
  bool _appui = false;
  Timer? _delai;
  Offset? _depart;

  bool get _actif {
    final bouton = widget.child;
    return bouton is ButtonStyleButton ? bouton.enabled : true;
  }

  bool get _plein => widget.child is! TextButton;

  void _poser(bool valeur) {
    if (_appui != valeur && mounted) setState(() => _appui = valeur);
  }

  void _eclair() {
    _poser(true);
    Future.delayed(const Duration(milliseconds: 60), () => _poser(false));
  }

  void _bas(PointerDownEvent e) {
    if (!_actif) return;
    _depart = e.position;
    _delai?.cancel();
    if (Scrollable.maybeOf(context) != null) {
      _delai = Timer(const Duration(milliseconds: 100), () => _poser(true));
    } else {
      _poser(true);
    }
  }

  void _deplace(PointerMoveEvent e) {
    final depart = _depart;
    if (depart == null) return;
    if ((e.position - depart).distance > kTouchSlop) _annuler();
  }

  void _haut(PointerUpEvent e) {
    if (_depart == null) return;
    _depart = null;
    final enAttente = _delai?.isActive ?? false;
    _delai?.cancel();
    if (enAttente || !_appui) {
      _eclair();
    } else {
      _poser(false);
    }
  }

  void _annuler() {
    _depart = null;
    _delai?.cancel();
    _poser(false);
  }

  @override
  void dispose() {
    _delai?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget contenu;
    if (_plein) {
      contenu = SingleMotionBuilder(
        value: _appui ? 1.0 : 0.0,
        motion: OuroMotion.of(context).press,
        builder: (context, enfoncement, enfant) => Transform.scale(
          scale: 1 - 0.03 * enfoncement,
          child: Opacity(opacity: 1 - 0.25 * enfoncement, child: enfant),
        ),
        child: widget.child,
      );
    } else {
      contenu = AnimatedOpacity(
        opacity: _appui ? 0.35 : 1,
        duration: _appui ? Duration.zero : const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: widget.child,
      );
    }
    return Listener(
      onPointerDown: _bas,
      onPointerMove: _deplace,
      onPointerUp: _haut,
      onPointerCancel: (_) => _annuler(),
      child: contenu,
    );
  }
}
