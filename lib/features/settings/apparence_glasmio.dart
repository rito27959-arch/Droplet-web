// ============================================================================
// L'APPARENCE EN GLASMIO (Android 13+). Mêmes réglages et mêmes services que
// `ApparenceScreen` (l'écran de repli) : taille du texte et arrondi des bulles
// (curseurs de verre), thème, couleur d'accent, lignes de la liste, effets,
// icône, réinitialisation.
//
// Les motifs du fond se choisissent ici aussi, en Glasmio (une ligne cochée
// par jeu de motifs). Les fonds propres à une discussion se règlent dans
// les infos de cette discussion.
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
        } else if (id.startsWith('motifs:')) {
          await notifier.modifier(perso.copyWith(packMotifs: int.parse(id.substring(7))));
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
        // Les motifs du fond, choisis ICI, en Glasmio : on ne bascule plus
        // vers l'écran Flutter (qui ne ressemblait pas au reste).
        {
          'entete': t.apPatternsHeader,
          'pied': t.apPatternsFooter,
          'lignes': [
            for (final (i, icone, titre, teinte) in [
              (0, 'water_drop', t.apPatternDroplet, OuroColors.accent),
              (1, 'sports_esports', t.apPatternGames, OuroColors.systemPurple),
              (2, 'home', t.apPatternHome, OuroColors.systemOrange),
              (3, 'local_florist', t.apPatternGarden, OuroColors.systemGreen),
            ])
              {'id': 'motifs:$i', 'type': 'choix', 'icone': icone, 'teinte': _c(teinte), 'titre': titre, 'coche': perso.packMotifs == i},
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
