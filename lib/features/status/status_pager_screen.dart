// ============================================================================
// LE LECTEUR DE STATUTS EN PAGES — le glissé entre contacts suit le doigt.
// ----------------------------------------------------------------------------
// Chaque contact est une page : glisser montre le suivant pendant le geste,
// sur un cube, comme WhatsApp et Instagram. Seule la page au premier plan lit
// et avance ; les autres ont leur média prêt (la première image est là quand
// on arrive) mais attendent leur tour.
//
// Le lecteur s'ouvre en ZOOM depuis la carte touchée et s'y referme. La page
// est posée PAR-DESSUS les onglets (non opaque) : pendant le glissé vers le
// bas, la liste réapparaît derrière le statut qui rétrécit.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/mesh_provider.dart';
import 'ordre_statuts.dart';
import 'status_viewer_screen.dart';

class StatusPagerScreen extends ConsumerStatefulWidget {
  const StatusPagerScreen({super.key, required this.authorId});

  final String authorId;

  /// Le rectangle, à l'écran, de la carte touchée : le zoom part de là et y
  /// revient. `null` (ouverture depuis une notification) : simple fondu.
  static Rect? rectCarte;

  /// Où se trouve, maintenant, la carte de chaque contact dans le carrousel
  /// (enregistré par les cartes elles-mêmes) : en changeant de contact, le
  /// lecteur sait vers quelle carte se refermer.
  static final Map<String, Rect? Function()> rectsCartes = {};

  @override
  ConsumerState<StatusPagerScreen> createState() => _StatusPagerScreenState();
}

class _StatusPagerScreenState extends ConsumerState<StatusPagerScreen> {
  late final List<String> _ordre;
  late final PageController _controleur;
  late int _page;
  late final int _pageInitiale;

  @override
  void initState() {
    super.initState();
    final monId = ref.read(meshRepositoryProvider).myId;
    if (widget.authorId == monId) {
      _ordre = [monId];
    } else {
      final ordre = ordreDesContacts(monId);
      if (!ordre.contains(widget.authorId)) ordre.insert(0, widget.authorId);
      _ordre = ordre;
    }
    StatusViewerScreen.ordreDeSeance = _ordre;
    _page = _pageInitiale = _ordre.indexOf(widget.authorId);
    _controleur = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  /// Le contact voisin, demandé par la page (fin du dernier statut, tap au
  /// bord). `false` s'il n'y en a pas : la page ferme ou recommence.
  bool _voisin(int sens) {
    final cible = _page + sens;
    if (cible < 0 || cible >= _ordre.length) return false;
    _controleur.animateToPage(
      cible,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
    return true;
  }

  double get _position {
    if (_controleur.hasClients && _controleur.position.haveDimensions) {
      return _controleur.page ?? _page.toDouble();
    }
    return _page.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return AnimatedBuilder(
      animation: _controleur,
      // Noir derrière le cube pendant le glissé ; transparent au repos, pour
      // que la liste réapparaisse quand on referme vers le bas.
      builder: (context, pages) {
        final p = _position;
        final enMouvement = (p - p.roundToDouble()).abs() > 0.001;
        return ColoredBox(
          color: enMouvement ? Colors.black : Colors.transparent,
          child: pages,
        );
      },
      child: PageView.builder(
        controller: _controleur,
        itemCount: _ordre.length,
        onPageChanged: (i) {
          setState(() => _page = i);
          // Un autre contact que celui de la carte : on ne revient plus
          // « dans » la carte en fermant, on s'efface en fondu.
          StatusPagerScreen.rectCarte =
              StatusPagerScreen.rectsCartes[_ordre[i]]?.call();
        },
        itemBuilder: (context, i) => AnimatedBuilder(
          animation: _controleur,
          builder: (context, page) {
            final delta = (i - _position).clamp(-1.0, 1.0).toDouble();
            final sens = rtl ? -1.0 : 1.0;
            // Le cube : chaque face tourne autour de l'arête qu'elle partage
            // avec sa voisine. Identité au repos — la structure ne change pas.
            return Transform(
              alignment: delta * sens > 0 ? Alignment.centerLeft : Alignment.centerRight,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(-math.pi / 2 * delta * sens),
              child: Stack(
                children: [
                  page!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.45 * delta.abs()),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: StatusViewerScreen(
            key: ValueKey('statut-${_ordre[i]}'),
            authorId: _ordre[i],
            actif: i == _page,
            onContactVoisin: _voisin,
          ),
        ),
      ),
    );
  }
}

/// La page du lecteur : posée par-dessus (non opaque), ouverte en zoom depuis
/// la carte touchée.
Page<void> pageZoomStatut({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    opaque: false,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    child: child,
    transitionsBuilder: (context, animation, _, child) =>
        _ZoomDepuisCarte(animation: animation, child: child),
  );
}

class _ZoomDepuisCarte extends StatelessWidget {
  const _ZoomDepuisCarte({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final courbe = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return AnimatedBuilder(
      animation: courbe,
      child: child,
      builder: (context, enfant) {
        final t = courbe.value;
        final taille = MediaQuery.sizeOf(context);
        final plein = Offset.zero & taille;
        final depart = StatusPagerScreen.rectCarte;
        // ⚠️ UNE SEULE ARBORESCENCE, avec ou sans carte : sans carte, le
        // rectangle de départ est l'écran entier et seule l'opacité joue.
        final r = Rect.lerp(depart ?? plein, plein, t)!;
        final echelle = math.max(r.width / taille.width, r.height / taille.height);
        return Stack(
          children: [
            Positioned.fromRect(
              rect: r,
              child: Opacity(
                opacity: depart == null ? t : (t * 3).clamp(0.0, 1.0).toDouble(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(depart == null ? 0 : 14 * (1 - t)),
                  child: OverflowBox(
                    minWidth: taille.width,
                    maxWidth: taille.width,
                    minHeight: taille.height,
                    maxHeight: taille.height,
                    child: Transform.scale(scale: echelle, child: enfant),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Fermer le lecteur : revenir à l'écran d'en dessous quand il existe.
void fermerLecteurStatuts(BuildContext context, String retour) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(retour);
  }
}
