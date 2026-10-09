// ============================================================================
// LE BALAYAGE D'UNE LIGNE — celui d'iOS, au geste près.
// ----------------------------------------------------------------------------
// Dans Mail et Messages, glisser une ligne ne la fait pas disparaître : elle
// RECULE et découvre des boutons dessous. Trois comportements, et ce sont
// eux qui font la différence avec un simple « swipe to dismiss » :
//
//   1. LES BOUTONS SUIVENT LE DOIGT. Ils ne s'affichent pas d'un coup à
//      mi-course : leur largeur est exactement la distance parcourue, ce qui
//      donne l'impression de les tirer hors du bord.
//   2. PASSÉ LEUR LARGEUR, ÇA RÉSISTE. Le doigt continue, la ligne suit au
//      tiers. Sans cette résistance, on arrive au bout de l'écran sans que
//      rien ne signale qu'on est allé trop loin.
//   3. LE BALAYAGE COMPLET. Au-delà de 55 % de la largeur, la PREMIÈRE
//      action prend toute la place et se déclenche au relâchement — avec
//      une vibration à l'instant précis où le seuil est franchi, pas au
//      relâchement : on sait que c'est acquis avant même de lever le doigt.
//
// Et une seule ligne reste ouverte à la fois : en ouvrir une referme la
// précédente, comme sur iOS.
//
// ⚠️ LE GESTE VERTICAL RESTE À LA LISTE. Le drag horizontal est reconnu par
// un `HorizontalDragGestureRecognizer` dédié : le défilement de la liste
// n'est jamais volé, même quand le doigt part en biais.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';

/// Une action révélée par le balayage.
class ActionGlissee {
  const ActionGlissee({
    required this.icone,
    required this.libelle,
    required this.couleur,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final Color couleur;
  final VoidCallback onTap;
}

/// La ligne ouverte en ce moment — il ne peut y en avoir qu'une.
final ValueNotifier<Object?> _ligneOuverte = ValueNotifier(null);

class GlissementActions extends StatefulWidget {
  const GlissementActions({
    super.key,
    required this.child,
    this.debut = const [],
    this.fin = const [],
    this.largeurAction = 78,
  });

  /// Les actions révélées en tirant vers la DROITE (bord gauche).
  final List<ActionGlissee> debut;

  /// Les actions révélées en tirant vers la GAUCHE (bord droit).
  final List<ActionGlissee> fin;

  final double largeurAction;
  final Widget child;

  @override
  State<GlissementActions> createState() => _GlissementActionsState();
}

class _GlissementActionsState extends State<GlissementActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController.unbounded(vsync: this)
    ..addListener(() => setState(() {}));

  /// Le décalage courant : négatif vers la gauche.
  double get _decalage => _ctrl.value;

  bool _seuilFranchi = false;
  double _largeurLigne = 0;

  static const double _fractionBalayageComplet = 0.55;

  /// Le ressort de révélation de Telegram (ItemListRevealOptionsNode.swift :
  /// raideur 420, amortissement 40) : il part avec la vitesse du doigt et se
  /// pose sans rebond, au lieu d'une durée fixe qui ignorait le geste.
  static final SpringDescription _ressort =
      SpringDescription(mass: 1, stiffness: 420, damping: 40);

  void _vers(double cible, [double vitesse = 0]) {
    _ctrl.animateWith(SpringSimulation(_ressort, _ctrl.value, cible, vitesse));
  }

  @override
  void initState() {
    super.initState();
    _ligneOuverte.addListener(_refermerSiAutre);
  }

  @override
  void dispose() {
    _ligneOuverte.removeListener(_refermerSiAutre);
    if (_ligneOuverte.value == this) _ligneOuverte.value = null;
    _ctrl.dispose();
    super.dispose();
  }

  void _refermerSiAutre() {
    if (_ligneOuverte.value != this && _decalage != 0) _fermer();
  }

  List<ActionGlissee> get _actives =>
      _decalage < 0 ? widget.fin : widget.debut;

  double get _ouverture => _actives.length * widget.largeurAction;

  void _fermer([double vitesse = 0]) {
    _vers(0, vitesse);
    if (_ligneOuverte.value == this) _ligneOuverte.value = null;
  }

  void _majDecalage(double delta) {
    var valeur = _decalage + delta;
    // Rien à découvrir de ce côté-là : la ligne ne bouge pas.
    if (valeur > 0 && widget.debut.isEmpty) valeur = 0;
    if (valeur < 0 && widget.fin.isEmpty) valeur = 0;

    final max = _ouverture;
    if (valeur.abs() > max && max > 0) {
      // ── LA RÉSISTANCE ──
      final excedent = valeur.abs() - max;
      valeur = (max + excedent * 0.35) * valeur.sign;
    }
    _ctrl.value = valeur;

    final seuil = _largeurLigne * _fractionBalayageComplet;
    final franchi = valeur.abs() >= seuil && _actives.isNotEmpty;
    if (franchi != _seuilFranchi) {
      _seuilFranchi = franchi;
      // La vibration AU SEUIL, pas au relâchement.
      if (franchi) OuroHaptics.medium();
    }
  }

  void _relacher(double vitesse) {
    final actions = _actives;
    if (actions.isEmpty) {
      _fermer();
      return;
    }
    if (_seuilFranchi) {
      _seuilFranchi = false;
      _fermer();
      actions.first.onTap();
      return;
    }
    // Un geste vif ouvre ou referme, même court : c'est la vitesse qui
    // décide, pas seulement la distance parcourue.
    final ouvrir = _decalage.abs() > _ouverture / 2 ||
        (vitesse.abs() > 500 && vitesse.sign == _decalage.sign);
    if (ouvrir) {
      _vers(_ouverture * _decalage.sign, vitesse);
      _ligneOuverte.value = this;
    } else {
      _fermer(vitesse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        _largeurLigne = contraintes.maxWidth;
        final actions = _actives;
        final decouvert = _decalage.abs();
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Seul l'axe horizontal est capté : la liste garde le vertical.
          onHorizontalDragUpdate: (d) => _majDecalage(d.delta.dx),
          onHorizontalDragEnd: (d) => _relacher(d.primaryVelocity ?? 0),
          onHorizontalDragCancel: _fermer,
          // Une ligne ouverte se referme au premier appui ailleurs sur elle.
          onTap: _decalage == 0 ? null : _fermer,
          child: Stack(
            children: [
              if (actions.isNotEmpty)
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: _decalage < 0
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      for (var i = 0; i < actions.length; i++)
                        _Bouton(
                          action: actions[i],
                          // Au balayage complet, la première action prend
                          // toute la place découverte.
                          largeur: _seuilFranchi
                              ? (i == 0 ? decouvert : 0)
                              : decouvert / actions.length,
                          largeurPleine: widget.largeurAction,
                          onTap: () {
                            _fermer();
                            actions[i].onTap();
                          },
                        ),
                    ],
                  ),
                ),
              Transform.translate(
                offset: Offset(_decalage, 0),
                child: AbsorbPointer(
                  absorbing: _decalage != 0,
                  child: widget.child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Bouton extends StatelessWidget {
  const _Bouton({
    required this.action,
    required this.largeur,
    required this.largeurPleine,
    required this.onTap,
  });

  final ActionGlissee action;
  final double largeur;
  final double largeurPleine;
  final VoidCallback onTap;

  /// 0 quand le bouton commence à se montrer, 1 quand il est entier
  /// (10 pt de marge à chaque bout, comme Telegram).
  double get _progression =>
      ((largeur - 10) / (largeurPleine - 20)).clamp(0.0, 1.0).toDouble();

  @override
  Widget build(BuildContext context) {
    if (largeur <= 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: largeur,
        color: action.couleur,
        alignment: Alignment.center,
        // Le contenu ne se comprime pas quand le bouton est encore étroit :
        // il est rogné, comme sur iOS, et se révèle en tirant.
        child: ClipRect(
          child: OverflowBox(
            maxWidth: 78,
            minWidth: 78,
            alignment: Alignment.center,
            // Comme Telegram : l'icône et le titre grandissent de 30 % à
            // 100 % à mesure que le bouton se découvre, au lieu d'être
            // tranchés par le bord.
            child: Opacity(
              opacity: _progression,
              child: Transform.scale(
                scale: 0.3 + 0.7 * _progression,
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icone, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Text(
                  action.libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.caption2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
