// ============================================================================
// LA PASTILLE « REVENIR À L'APPEL »
// ----------------------------------------------------------------------------
// L'écran d'appel de groupe a un chevron « Réduire » en haut à gauche : on
// retourne aux discussions sans raccrocher, pour retrouver un numéro ou
// relire un message pendant qu'on parle. Sans chemin de retour, ce chevron
// serait un piège : l'appel continue, et plus rien à l'écran ne le dit ni ne
// permet d'y revenir.
//
// C'est ce chemin. Elle flotte sous la barre de navigation de l'accueil, elle
// ne défile pas, elle ne pousse rien, et elle disparaît d'elle-même quand on
// raccroche (`hangUp()` remet l'état du groupe à zéro).
//
// POURQUOI FLOTTANTE ET PAS ÉPINGLÉE DANS LA LISTE : les slivers de
// `OuroLargeTitleScaffold` passent SOUS la barre de navigation translucide.
// Un en-tête épinglé se serait collé là, derrière le flou — invisible.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/mesh_provider.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_motion.dart';
import '../../l10n/generated/app_localizations.dart';

/// À poser dans l'emplacement flottant de l'accueil. Ne coûte rien quand il
/// n'y a pas d'appel : rien du tout.
class BandeauAppelGroupe extends ConsumerWidget {
  const BandeauAppelGroupe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final call = ref.watch(groupCallProvider);
    if (!call.isActive || call.participants.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _Pastille(
        nom: call.groupName,
        combien: call.participants.length,
      ),
    );
  }
}

class _Pastille extends StatefulWidget {
  const _Pastille({required this.nom, required this.combien});

  final String? nom;
  final int combien;

  @override
  State<_Pastille> createState() => _PastilleState();
}

class _PastilleState extends State<_Pastille>
    with SingleTickerProviderStateMixin {
  bool _enfonce = false;

  /// Le point qui respire : c'est ce qui dit « ça tourne encore » sans
  /// afficher un compteur qu'il faudrait tenir à la seconde.
  late final AnimationController _souffle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..bouclerSiAmbiant(reverse: true);

  @override
  void dispose() {
    _souffle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titre = widget.nom != null && widget.nom!.trim().isNotEmpty
        ? widget.nom!.trim()
        : l10n.gcGroupCall;
    final vert = OuroColors.successGreen;
    return Semantics(
      button: true,
      label: '$titre · ${l10n.gcReturnToCall}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _enfonce = true),
        onTapCancel: () => setState(() => _enfonce = false),
        onTap: () {
          setState(() => _enfonce = false);
          HapticFeedback.selectionClick();
          context.go('/group-call');
        },
        // Pas d'onde Material : la pastille s'enfonce et revient, comme iOS.
        child: AnimatedScale(
          scale: _enfonce ? 0.975 : 1,
          duration: DesignTokens.durationFast,
          curve: DesignTokens.curveSpring,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.radius2xl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  vert.withValues(alpha: _enfonce ? 0.86 : 1.0),
                  vert.withValues(alpha: _enfonce ? 0.76 : 0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: vert.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _souffle,
                  builder: (context, _) => Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white
                          .withValues(alpha: 0.5 + _souffle.value * 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        l10n.gcParticipantsVoiceOnly(widget.combien),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.gcReturnToCall,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 19, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
