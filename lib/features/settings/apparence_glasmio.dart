// ============================================================================
// L'APPARENCE EN GLASMIO (Android 13+). Mêmes réglages et mêmes services que
// `ApparenceScreen` (l'écran de repli) : taille du texte et arrondi des bulles
// (curseurs de verre), thème, couleur d'accent, lignes de la liste, effets,
// icône, réinitialisation.
//
// L'APERÇU DES BULLES, LES MOTIFS ET LES FONDS DE DISCUSSION sont dessinés par
// Flutter (ce sont de vraies bulles, avec les vrais fonds animés) : la ligne
// « Aperçu, motifs et fonds » ouvre l'écran Flutter, où ils sont tous.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/appearance_provider.dart';
import '../../core/providers/personnalisation_provider.dart';
import '../../core/services/device_profile.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/reglages_apparence.dart';
import 'apparence_screen.dart';

class PasserelleApparence extends ConsumerStatefulWidget {
  const PasserelleApparence({super.key});

  @override
  ConsumerState<PasserelleApparence> createState() => _PasserelleApparenceState();
}

class _PasserelleApparenceState extends EtatPasserelleGlasmio<PasserelleApparence> {
  @override
  String get ecran => 'apparence';

  @override
  Widget construireRepli(BuildContext context) => const ApparenceScreen();

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final perso = ref.read(personnalisationProvider);
    final notifier = ref.read(personnalisationProvider.notifier);
    switch (id) {
      case 'taille':
        await notifier.modifier(perso.copyWith(tailleTexte: (valeur as num).toDouble()));
      case 'rayon':
        await notifier.modifier(perso.copyWith(rayonBulles: (valeur as num).toDouble()));
      case 'apercu':
        return basculerVersFlutter();
      case 'icone':
        return allerA('/settings/icon');
      case 'reinitialiser':
        await notifier.reinitialiser();
      default:
        if (id.startsWith('theme:')) {
          final mode = AppearanceMode.values.byName(id.substring(6));
          await ref.read(appearanceProvider.notifier).set(mode);
          // Le clair/sombre a changé : l'écran natif le suit aussitôt.
        } else if (id.startsWith('accent:')) {
          await notifier.modifier(perso.copyWith(accent: id.substring(7)));
        } else if (id.startsWith('lignes:')) {
          await notifier.modifier(perso.copyWith(lignesListe: int.parse(id.substring(7))));
        } else if (id.startsWith('effets:')) {
          await DeviceProfile.changerModeEffets(id.substring(7));
        }
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  static int _c(Color c) => c.toARGB32();

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final perso = ref.read(personnalisationProvider);
    final mode = ref.read(appearanceProvider);
    final effets = DeviceProfile.modeEffets;
    final alleges = DeviceProfile.effetsAlleges.value;
    // Calculés ici, pas lus dans OuroColors : Flutter ne redessine pas
    // pendant que l'écran natif le couvre, et ces deux réglages doivent se
    // voir tout de suite.
    final sombre = switch (mode) {
      AppearanceMode.light => false,
      AppearanceMode.dark => true,
      _ => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
    };
    final accent = ReglagesApparence.accents.where((a) => a.cle == perso.accent).firstOrNull?.pour(sombre: sombre) ?? OuroColors.accent;
    return {
      'titre': t.sectionAppearance,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': sombre,
      'accent': _c(accent),
      'sections': [
        {
          'lignes': [
            {'id': 'apercu', 'type': 'nav', 'icone': 'chat_bubble', 'teinte': _c(OuroColors.accent), 'titre': t.apPatternsHeader, 'sous': t.apPatternsFooter},
          ],
        },
        {
          'lignes': [
            {
              'id': 'taille',
              'type': 'curseur',
              'titre': t.stTextSize,
              'valeur': perso.tailleTexte,
              'min': ReglagesApparence.tailleTexteMin,
              'max': ReglagesApparence.tailleTexteMax,
            },
            {
              'id': 'rayon',
              'type': 'curseur',
              'titre': t.stBubbleCorners,
              'valeur': perso.rayonBulles,
              'min': ReglagesApparence.rayonMin,
              'max': ReglagesApparence.rayonMax,
            },
          ],
        },
        {
          'entete': t.sectionAppearance,
          'pied': t.appearanceFooter,
          'lignes': [
            for (final (m, titre) in [
              (AppearanceMode.system, t.appearanceAuto),
              (AppearanceMode.light, t.appearanceLight),
              (AppearanceMode.dark, t.appearanceDark),
            ])
              {'id': 'theme:${m.name}', 'type': 'choix', 'titre': titre, 'coche': mode == m},
          ],
        },
        {
          'entete': t.stAccentHeader,
          'pied': t.stAccentFooter,
          'lignes': [
            {
              'id': 'accents',
              'type': 'couleurs',
              'options': [
                for (final a in ReglagesApparence.accents)
                  {'id': 'accent:${a.cle}', 'teinte': _c(a.pour(sombre: sombre)), 'coche': a.cle == perso.accent},
              ],
            },
          ],
        },
        {
          'entete': t.stChatListHeader,
          'lignes': [
            for (final n in [2, 3])
              {'id': 'lignes:$n', 'type': 'choix', 'titre': n == 2 ? t.stChatListTwoLines : t.stChatListThreeLines, 'coche': n == perso.lignesListe},
          ],
        },
        {
          'entete': t.apEffectsHeader,
          'pied': effets == 'auto' ? (alleges ? t.apEffectsAutoLight : t.apEffectsAutoFull) : t.apEffectsManual,
          'lignes': [
            for (final (cle, titre) in [('auto', t.apEffectsAuto), ('complets', t.apEffectsFull), ('alleges', t.apEffectsLight)])
              {'id': 'effets:$cle', 'type': 'choix', 'titre': titre, 'coche': cle == effets},
          ],
        },
        {
          'entete': t.stIconHeader,
          'lignes': [
            {'id': 'icone', 'type': 'nav', 'icone': 'apps', 'teinte': _c(OuroColors.systemPink), 'titre': t.stAppIcon, 'sous': t.stVariants13},
          ],
        },
        {
          'lignes': [
            {'id': 'reinitialiser', 'type': 'bouton', 'titre': t.stResetAppearance},
          ],
        },
      ],
    };
  }
}
