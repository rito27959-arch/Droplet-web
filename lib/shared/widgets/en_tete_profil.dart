// ============================================================================
// L'EN-TÊTE D'UN PROFIL — celui de Telegram, mesuré dans son code.
// ----------------------------------------------------------------------------
// Repris de `ProfileActivity.java` (dépôt DrKLO/Telegram), qui gère trois
// états d'un même en-tête et passe de l'un à l'autre sans rupture :
//
//   • AU REPOS : la photo est un rond de 100 dp, centré, le nom dessous, la
//     présence sous le nom, puis une rangée d'actions.
//   • REPLIÉ (on fait défiler) : la photo devient le rond de 42 dp de la
//     barre de navigation, le nom se range à sa droite, la barre prend sa
//     couleur. Ce sont les deux tailles de Telegram, au point près.
//   • DÉPLOYÉ (on tire vers le bas) : la photo s'ouvre en carré plein cadre,
//     le nom glisse en bas à gauche par-dessus, grossi de 38 % — le
//     `lerp(1f + 0.12f * diff, 1.38f, value)` de Telegram — à 30 dp du bas,
//     la présence à 10 dp, comme `nameTextViewYEnd` et `onlineTextViewYEnd`.
//
// Tout vient de la HAUTEUR RÉELLE de l'en-tête à cette image : `LayoutBuilder`
// la donne, y compris pendant l'étirement (`OverScrollHeaderStretchConfiguration`).
// Aucun état, aucune animation à piloter : le doigt mène, comme chez Telegram.
// ============================================================================

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
// `OverScrollHeaderStretchConfiguration` n'est pas dans la liste que
// widgets.dart ré-exporte de rendering.dart : il faut l'importer.
import 'package:flutter/rendering.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import 'package:flutter/services.dart';
import '../../design_system/ouro_avatar.dart';

/// Une des actions rondes sous le nom (Message, Appel…).
class ActionProfil {
  const ActionProfil({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;
}

class EnTeteProfil extends StatefulWidget {
  const EnTeteProfil({
    super.key,
    required this.pseudo,
    required this.statut,
    this.enLigne = false,
    this.cheminPhoto,
    this.retour,
    this.actionsBarre = const <Widget>[],
    this.actions = const <ActionProfil>[],
    this.surPhoto,
    this.heroTag,
  });

  /// Le tag partagé avec l'avatar d'où l'on vient (l'en-tête de la
  /// discussion) : la photo vole de l'un à l'autre, comme chez Telegram.
  final Object? heroTag;

  final String pseudo;
  final String statut;
  final bool enLigne;

  /// Le fichier de la photo, déjà sur l'appareil. `null` : on dessine
  /// l'initiale.
  final String? cheminPhoto;

  /// Le bouton de retour, fourni par l'écran (chacun a sa destination).
  final Widget? retour;

  /// Les icônes à droite de la barre.
  final List<Widget> actionsBarre;

  /// La rangée d'actions sous le nom.
  final List<ActionProfil> actions;

  /// Appui sur la photo — ouvrir la visionneuse, par exemple.
  final VoidCallback? surPhoto;

  @override
  State<EnTeteProfil> createState() => _EnTeteProfilState();
}

/// L'état de l'en-tête : seulement la bascule « photo en plein cadre ».
///
/// Chez Telegram, la photo tirée au-delà d'un seuil s'ouvre en plein cadre
/// et Y RESTE quand on relâche ; remonter un peu la liste la referme. Ici,
/// l'en-tête grandit (animé) jusqu'au carré plein cadre : le relâchement ne
/// le fait plus revenir au rond.
class _EnTeteProfilState extends State<EnTeteProfil>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bascule = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  bool _ouvert = false;

  void _basculer(bool ouvrir) {
    if (!mounted || _ouvert == ouvrir) return;
    _ouvert = ouvrir;
    if (ouvrir) {
      _bascule.animateTo(1, curve: Curves.easeOutCubic);
    } else {
      _bascule.animateBack(0, curve: Curves.easeInOutCubic);
    }
  }

  @override
  void dispose() {
    _bascule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return AnimatedBuilder(
      animation: _bascule,
      builder: (context, _) => SliverPersistentHeader(
        pinned: true,
        delegate: _DelegueEnTete(
          heroTag: widget.heroTag,
          pseudo: widget.pseudo,
          statut: widget.statut,
          enLigne: widget.enLigne,
          cheminPhoto: widget.cheminPhoto,
          retour: widget.retour,
          actionsBarre: widget.actionsBarre,
          actions: widget.actions,
          surPhoto: widget.surPhoto,
          hautSysteme: media.padding.top,
          largeur: media.size.width,
          bascule: _bascule.value,
          deployee: _ouvert,
          surBascule: _basculer,
        ),
      ),
    );
  }
}

class _DelegueEnTete extends SliverPersistentHeaderDelegate {
  _DelegueEnTete({
    this.heroTag,
    this.bascule = 0,
    this.deployee = false,
    this.surBascule,
    required this.pseudo,
    required this.statut,
    required this.enLigne,
    required this.cheminPhoto,
    required this.retour,
    required this.actionsBarre,
    required this.actions,
    required this.surPhoto,
    required this.hautSysteme,
    required this.largeur,
  });

  final Object? heroTag;

  /// 0 : en-tête normal · 1 : photo ouverte en plein cadre (animé).
  final double bascule;
  final bool deployee;
  final ValueChanged<bool>? surBascule;

  /// La photo est-elle passée en plein cadre ? (pour ne vibrer qu'une fois)
  static bool _deploye = false;

  Widget _avecHero(Widget photo) {
    final tag = heroTag;
    return tag == null ? photo : Hero(tag: tag, child: photo);
  }

  final String pseudo;
  final String statut;
  final bool enLigne;
  final String? cheminPhoto;
  final Widget? retour;
  final List<Widget> actionsBarre;
  final List<ActionProfil> actions;
  final VoidCallback? surPhoto;
  final double hautSysteme;
  final double largeur;

  /// Les deux tailles de Telegram : 100 dp au repos, 42 dp dans la barre.
  static const double _avatarRepos = 100;
  static const double _avatarPetit = 42;
  static const double _barre = 52;
  static const double _hauteurActions = 80;

  double get _contenu => 14 + _avatarRepos + 14 + 24 + 20 + (actions.isEmpty ? 10 : _hauteurActions);

  @override
  double get minExtent => hautSysteme + _barre;

  @override
  double get maxExtent => _reposNormal + (_plein - _reposNormal) * bascule;

  /// La hauteur de repos, photo en rond.
  double get _reposNormal => hautSysteme + _barre + _contenu;

  /// La hauteur photo en plein cadre (un carré de la largeur de l'écran).
  double get _plein => math.max(largeur, _reposNormal + 1);

  @override
  OverScrollHeaderStretchConfiguration? get stretchConfiguration =>
      OverScrollHeaderStretchConfiguration(stretchTriggerOffset: 4000);

  @override
  bool shouldRebuild(covariant _DelegueEnTete ancien) =>
      ancien.pseudo != pseudo ||
      ancien.statut != statut ||
      ancien.enLigne != enLigne ||
      ancien.cheminPhoto != cheminPhoto ||
      ancien.actions.length != actions.length ||
      ancien.largeur != largeur ||
      ancien.hautSysteme != hautSysteme ||
      ancien.bascule != bascule ||
      ancien.deployee != deployee;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(
      builder: (context, contraintes) {
        final hauteur = contraintes.maxHeight;
        final repos = _reposNormal;
        final plein = _plein;
        // Un seul des deux est non nul : on tire, ou on replie.
        final etirement =
            ((hauteur - repos) / (plein - repos)).clamp(0.0, 1.0).toDouble();
        final repli =
            ((repos - hauteur) / (repos - minExtent)).clamp(0.0, 1.0).toDouble();
        final ouvert = Curves.easeOut.transform(etirement);

        // Comme Telegram : un léger « clic » quand la photo bascule en plein
        // cadre — le doigt sent le seuil. L'écart entre 0,62 et 0,30 évite de
        // vibrer en boucle quand on hésite autour.
        if (etirement > 0.62 && !_deploye) {
          _deploye = true;
          HapticFeedback.lightImpact();
        } else if (etirement < 0.30 && _deploye) {
          _deploye = false;
        }

        // ── Comme Telegram : la photo RESTE en plein cadre ──────────────
        // Tirée au-delà du seuil, elle s'ouvre et le reste une fois le doigt
        // levé ; remonter la liste de 36 pt la referme. On ne rouvre qu'une
        // fois la fermeture finie (bascule revenue à 0) : pas d'oscillation.
        // Les bascules attendent la fin de l'image en cours : on ne touche
        // pas à un état pendant que la liste se met en page.
        final rappel = surBascule;
        if (rappel != null) {
          if (!deployee && bascule <= 0 && etirement > 0.62) {
            WidgetsBinding.instance.addPostFrameCallback((_) => rappel(true));
          } else if (deployee && bascule >= 1 && hauteur < plein - 36) {
            WidgetsBinding.instance.addPostFrameCallback((_) => rappel(false));
          }
        }

        // ── La photo ────────────────────────────────────────────────────
        final rectRepos = Rect.fromCenter(
          center: Offset(largeur / 2, hautSysteme + _barre + 14 + _avatarRepos / 2),
          width: _avatarRepos,
          height: _avatarRepos,
        );
        final rectPetit = Rect.fromLTWH(
          56,
          hautSysteme + (_barre - _avatarPetit) / 2,
          _avatarPetit,
          _avatarPetit,
        );
        final rectPhoto = etirement > 0
            ? Rect.lerp(rectRepos, Rect.fromLTWH(0, 0, largeur, hauteur), ouvert)!
            : Rect.lerp(rectRepos, rectPetit, repli)!;
        final rayon = (1 - ouvert) * rectPhoto.width / 2;

        // ── Le nom et la présence ───────────────────────────────────────
        final nomRepos = Rect.fromLTWH(
            20, rectRepos.bottom + 14, largeur - 40, 26);
        final nomPetit = Rect.fromLTWH(
            56 + _avatarPetit + 12, hautSysteme + _barre / 2 - 17, largeur - 190, 20);
        final nomPlein = Rect.fromLTWH(20, hauteur - 68, largeur - 40, 30);
        final rectNom = etirement > 0
            ? Rect.lerp(nomRepos, nomPlein, ouvert)!
            : Rect.lerp(nomRepos, nomPetit, repli)!;
        // Telegram : 1 → 1,38 en déployé, et un léger tassement en replié.
        final echelleNom = etirement > 0 ? 1 + 0.38 * ouvert : 1 - 0.14 * repli;
        final versLaGauche = math.max(ouvert, repli);
        final encre = Color.lerp(OuroColors.textPrimary, Colors.white, ouvert)!;
        final encreDouce =
            Color.lerp(OuroColors.textSecondary, Colors.white70, ouvert)!;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: OuroColors.systemGroupedBackground),

              // La photo, du rond centré au carré plein cadre.
              Positioned.fromRect(
                rect: rectPhoto,
                child: GestureDetector(
                  onTap: surPhoto,
                  child: _avecHero(_Photo(
                    chemin: cheminPhoto,
                    pseudo: pseudo,
                    rayon: rayon,
                    tailleInitiale: rectPhoto.width * 0.42,
                  )),
                ),
              ),

              // Le voile sous le nom quand la photo prend toute la place.
              if (ouvert > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: hauteur * 0.45,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: ouvert,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0x99000000)],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Le nom.
              Positioned.fromRect(
                rect: rectNom,
                child: Align(
                  alignment:
                      Alignment.lerp(Alignment.center, Alignment.centerLeft, versLaGauche)!,
                  child: Transform.scale(
                    scale: echelleNom,
                    alignment: Alignment.lerp(
                        Alignment.center, Alignment.centerLeft, versLaGauche)!,
                    child: Text(
                      pseudo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.headline.copyWith(
                        color: encre,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              // La présence : 10 dp sous le nom, comme chez Telegram.
              Positioned.fromRect(
                rect: rectNom.translate(0, rectNom.height + (etirement > 0 ? 6 : 2)),
                child: Align(
                  alignment:
                      Alignment.lerp(Alignment.center, Alignment.centerLeft, versLaGauche)!,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: enLigne ? OuroColors.successGreen : encreDouce,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          statut,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: OuroTypography.footnote.copyWith(color: encreDouce),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // La rangée d'actions : elle s'efface dès qu'on bouge.
              if (actions.isNotEmpty)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: IgnorePointer(
                    ignoring: repli > 0.4 || etirement > 0.2,
                    child: Opacity(
                      opacity: ((1 - repli * 1.8) * (1 - etirement * 2.5))
                          .clamp(0.0, 1.0)
                          .toDouble(),
                      child: Row(
                        children: [
                          for (final action in actions) ...[
                            Expanded(child: _BoutonAction(action: action)),
                            if (action != actions.last) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

              // La barre de navigation : transparente au repos, pleine une
              // fois l'en-tête replié.
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: hautSysteme + _barre,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: OuroColors.systemGroupedBackground
                        .withValues(alpha: repli * (1 - ouvert)),
                    border: Border(
                      bottom: BorderSide(
                        color: OuroColors.separator
                            .withValues(alpha: repli > 0.98 ? 1 : 0),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: hautSysteme),
                    child: IconTheme(
                      data: IconThemeData(
                        color: Color.lerp(OuroColors.label, Colors.white, ouvert),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 48, child: retour),
                          const Spacer(),
                          ...actionsBarre,
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// La photo, ou l'initiale quand il n'y en a pas.
class _Photo extends StatelessWidget {
  const _Photo({
    required this.chemin,
    required this.pseudo,
    required this.rayon,
    required this.tailleInitiale,
  });

  final String? chemin;
  final String pseudo;
  final double rayon;
  final double tailleInitiale;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(rayon),
      child: chemin != null
          ? Image.file(
              File(chemin!),
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => _Initiale(
                nom: pseudo,
                taille: tailleInitiale,
              ),
            )
          : _Initiale(nom: pseudo, taille: tailleInitiale),
    );
  }
}

class _Initiale extends StatelessWidget {
  const _Initiale({required this.nom, required this.taille});

  final String nom;
  final double taille;

  @override
  Widget build(BuildContext context) {
    // Le même dégradé et les mêmes initiales que dans la liste : on
    // reconnaît quelqu'un à sa couleur, d'un écran à l'autre.
    final initiales = DegradesAvatar.initiales(nom);
    return DecoratedBox(
      decoration: BoxDecoration(gradient: DegradesAvatar.pour(nom)),
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: DegradesAvatar.reflet),
        child: Center(
          child: Text(
            initiales,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: initiales.characters.length > 1 ? taille * 0.85 : taille,
              fontWeight: FontWeight.w600,
              letterSpacing: initiales.characters.length > 1 ? 0.6 : 0,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoutonAction extends StatelessWidget {
  const _BoutonAction({required this.action});

  final ActionProfil action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icone, size: 21, color: OuroColors.accent),
            const SizedBox(height: 5),
            Text(
              action.libelle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.caption.copyWith(color: OuroColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
