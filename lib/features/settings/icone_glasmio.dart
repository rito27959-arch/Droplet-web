// ============================================================================
// L'ICÔNE DE L'APPLI EN GLASMIO (Android 13+). Même choix et même service que
// `AppIconScreen` (l'écran de repli) : la grille des icônes, celle en place
// cochée, celles de Droplet Pro marquées, la confirmation, le résultat.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/premium_provider.dart';
import '../../core/services/app_icon_service.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../design_system/ouro_colors.dart';
import 'app_icon_screen.dart';

class PasserelleIcone extends ConsumerStatefulWidget {
  const PasserelleIcone({super.key});

  @override
  ConsumerState<PasserelleIcone> createState() => _PasserelleIconeState();
}

class _PasserelleIconeState extends EtatPasserelleGlasmio<PasserelleIcone> {
  String _actuelle = 'Default';

  @override
  String get ecran => 'icone';

  @override
  Widget construireRepli(BuildContext context) => const AppIconScreen();

  @override
  void surOuvert() {
    AppIconService.current().then((a) {
      _actuelle = a;
      rafraichir();
    });
  }

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final t = textes;
    if (id.startsWith('icone:')) {
      final alias = id.substring(6);
      final option = AppIconService.options.where((o) => o.alias == alias).firstOrNull;
      if (option == null || alias == _actuelle) return ReponseGlasmio.rien;
      if (option.premium && !ref.read(packDebloqueProvider)) return allerA('/premium');
      return ReponseGlasmio.alerte({
        'titre': t.aicChangeIconTitle,
        'message': t.aicChangeIconMessage(nomIcone(t, alias)),
        'confirmer': t.aicApply,
        'annuler': t.actionCancel,
        'id': 'appliquer:$alias',
      });
    }
    if (id.startsWith('appliquer:')) {
      final alias = id.substring(10);
      final ok = await AppIconService.apply(alias);
      if (ok) _actuelle = alias;
      if (!mounted) return ReponseGlasmio.rien;
      return ReponseGlasmio.alerte({
        'titre': ok ? t.aicIconApplied(nomIcone(t, alias)) : t.aicChangeIconImpossible,
        'annuler': MaterialLocalizations.of(context).okButtonLabel,
        'choix': <Object>[],
        'description': await decrire(),
      });
    }
    return ReponseGlasmio.rien;
  }

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final supporte = AppIconService.isSupported;
    final pack = ref.read(packDebloqueProvider);
    return {
      'titre': t.aicTitle,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': OuroColors.accent.toARGB32(),
      'sections': [
        {
          'entete': supporte ? t.aicCurrentOnHomeScreen : t.aicUnavailablePlatform,
          'pied': supporte ? t.aicAndroidExplanation : t.aicAndroidOnly,
          'grille': [
            for (final o in AppIconService.options)
              {
                'id': 'icone:${o.alias}',
                'chemin': 'asset:${o.asset}',
                'titre': nomIcone(t, o.alias),
                'coche': o.alias == _actuelle,
                'verrou': o.premium && !pack,
              },
          ],
        },
      ],
    };
  }
}
