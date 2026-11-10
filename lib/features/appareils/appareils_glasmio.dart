// ============================================================================
// LES APPAREILS LIÉS EN GLASMIO (Android 13+). Même contenu et mêmes services
// que `AppareilsLiesScreen` (l'écran de repli) : lier un ordinateur, la liste
// des appareils, déconnecter un appareil ou tous.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/appareils_lies.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../design_system/ouro_colors.dart';
import 'appareils_lies_screen.dart';
import 'lier_appareil_screen.dart';

class PasserelleAppareils extends ConsumerStatefulWidget {
  const PasserelleAppareils({super.key});

  @override
  ConsumerState<PasserelleAppareils> createState() => _PasserelleAppareilsState();
}

class _PasserelleAppareilsState extends EtatPasserelleGlasmio<PasserelleAppareils> {
  @override
  String get ecran => 'appareils';

  @override
  Widget construireRepli(BuildContext context) => const AppareilsLiesScreen();

  void _maj() => rafraichir();

  @override
  void surOuvert() => AppareilsLies.revision.addListener(_maj);

  @override
  void surFerme() => AppareilsLies.revision.removeListener(_maj);

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final t = textes;
    final appareils = AppareilsLies.liste();
    switch (id) {
      case 'lier':
        if (appareils.length >= AppareilsLies.maximum) {
          return ReponseGlasmio.alerte({'titre': t.adTitle, 'message': t.adLimit, 'annuler': t.actionDone, 'choix': <Object>[]});
        }
        return pousser(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const LierAppareilScreen()));
      case 'tout':
        return ReponseGlasmio.alerte({
          'titre': t.adLogoutAll,
          'message': t.adLogoutAllBody,
          'confirmer': t.adLogout,
          'annuler': t.actionCancel,
          'destructif': true,
          'id': 'tout_confirme',
        });
      case 'tout_confirme':
        await AppareilsLies.toutDeconnecter();
      default:
        if (id.startsWith('appareil:')) {
          final i = int.tryParse(id.substring(9)) ?? -1;
          if (i < 0 || i >= appareils.length) break;
          return ReponseGlasmio.alerte({
            'titre': t.adLogoutTitle(appareils[i].nom),
            'message': t.adLogoutBody,
            'confirmer': t.adLogout,
            'annuler': t.actionCancel,
            'destructif': true,
            'id': 'deconnecter:$i',
          });
        }
        if (id.startsWith('deconnecter:')) {
          final i = int.tryParse(id.substring(12)) ?? -1;
          if (i >= 0 && i < appareils.length) await AppareilsLies.deconnecter(appareils[i]);
        }
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final langue = Localizations.localeOf(context).toLanguageTag();
    final appareils = AppareilsLies.liste();
    final accent = OuroColors.accent.toARGB32();
    return {
      'titre': t.adTitle,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': accent,
      'vitrine': {'icone': 'devices', 'texte': '${t.adHero}\nweb.dropletmesh.app'},
      'sections': [
        {
          'lignes': [
            {'id': 'lier', 'type': 'bouton', 'titre': t.adLink},
          ],
        },
        {
          'entete': '${t.adDevices} · ${t.adCount(appareils.length, AppareilsLies.maximum)}',
          'pied': t.adFooter,
          'lignes': [
            if (appareils.isEmpty)
              {'id': 'aucun', 'type': 'info', 'titre': t.adNone}
            else
              for (var i = 0; i < appareils.length; i++)
                {
                  'id': 'appareil:$i',
                  'type': 'nav',
                  'icone': 'laptop',
                  'teinte': accent,
                  'titre': appareils[i].nom,
                  'sous': t.adLinkedOn(DateFormat.yMMMd(langue).add_Hm().format(appareils[i].lieLe)),
                },
          ],
        },
        if (appareils.length > 1)
          {
            'lignes': [
              {'id': 'tout', 'type': 'bouton', 'titre': t.adLogoutAll, 'destructif': true},
            ],
          },
      ],
    };
  }
}
