// ============================================================================
// « MES DONNÉES » ET LA POLITIQUE DE CONFIDENTIALITÉ EN GLASMIO (Android 13+).
// Même texte que `DonneesScreen` et `PolitiqueScreen` (les écrans de repli).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/contact_config.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../design_system/ouro_colors.dart';
import 'donnees_screen.dart';
import 'politique_screen.dart';
import 'politique_texte.dart';

class PasserelleDonnees extends ConsumerStatefulWidget {
  const PasserelleDonnees({super.key});

  @override
  ConsumerState<PasserelleDonnees> createState() => _PasserelleDonneesState();
}

class _PasserelleDonneesState extends EtatPasserelleGlasmio<PasserelleDonnees> {
  @override
  String get ecran => 'donnees';

  @override
  Widget construireRepli(BuildContext context) => const DonneesScreen();

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async => ReponseGlasmio.rien;

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final vert = OuroColors.successGreen.toARGB32();
    final ambre = OuroColors.warningAmber.toARGB32();
    Map<String, Object?> ligne(String icone, int teinte, String titre, String sous) =>
        {'id': titre, 'type': 'info', 'icone': icone, 'teinte': teinte, 'titre': titre, 'sous': sous};
    Map<String, Object?> para(String titre, String sous) =>
        {'id': titre, 'type': 'paragraphe', 'titre': titre, 'sous': sous};
    return {
      'titre': t.hlpDataTitle,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': OuroColors.accent.toARGB32(),
      'vitrine': {'icone': 'shield', 'teinte': vert, 'texte': t.hlpDataLead},
      'stats': [
        {'icone': 'visibility', 'teinte': vert, 'valeur': '0', 'titre': t.hlpCountTracking},
        {'icone': 'person_add', 'teinte': vert, 'valeur': '0', 'titre': t.hlpCountAccount},
        {'icone': 'storage', 'teinte': ambre, 'valeur': '4', 'titre': t.hlpCountServers},
      ],
      'sections': [
        {
          'entete': t.hlpDataOnDevice,
          'pied': t.hlpStays,
          'lignes': [
            para(t.hlpRowKeys, t.hlpRowKeysBody),
            para(t.hlpRowMessages, t.hlpRowMessagesBody),
            para(t.hlpRowProfile, t.hlpRowProfileBody),
            para(t.hlpRowSettings, t.hlpRowSettingsBody),
            para(t.hlpRowLog, t.hlpRowLogBody),
          ],
        },
        {
          'entete': t.hlpDataServers,
          'pied': '${t.hlpLeaves}\n\n${t.hlpDataServersFooter}',
          'lignes': [
            para(t.hlpRowDirectory, t.hlpRowDirectoryBody),
            para(t.hlpRowMailbox, t.hlpRowMailboxBody),
            para(t.hlpRowSignalling, t.hlpRowSignallingBody),
            para(t.hlpRowRelay, t.hlpRowRelayBody),
          ],
        },
        {
          'entete': t.hlpDataNone,
          'pied': t.hlpNever,
          'lignes': [
            for (final l in [t.hlpNonePhone, t.hlpNoneEmail, t.hlpNoneContacts, t.hlpNoneLocation, t.hlpNoneAds, t.hlpNoneAnalytics])
              ligne('check', vert, l, '')..remove('sous'),
          ],
        },
      ],
    };
  }
}

class PasserellePolitique extends ConsumerStatefulWidget {
  const PasserellePolitique({super.key});

  @override
  ConsumerState<PasserellePolitique> createState() => _PasserellePolitiqueState();
}

class _PasserellePolitiqueState extends EtatPasserelleGlasmio<PasserellePolitique> {
  String? _langueChoisie;

  @override
  String get ecran => 'politique';

  @override
  Widget construireRepli(BuildContext context) => const PolitiqueScreen();

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    if (id == 'langue') {
      final langueApp = Localizations.localeOf(context).languageCode;
      final actuelle = _langueChoisie ?? (langueApp == 'en' ? 'en' : 'fr');
      _langueChoisie = actuelle == 'fr' ? 'en' : 'fr';
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final langueApp = Localizations.localeOf(context).languageCode;
    final langue = _langueChoisie ?? (langueApp == 'en' ? 'en' : 'fr');
    return {
      'titre': t.hlpPrivacyTitle,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': OuroColors.accent.toARGB32(),
      'sections': [
        // La politique n'existe qu'en français et en anglais.
        if (!politiqueTraduite(langueApp))
          {
            'pied': t.hlpOnlyFrEn,
            'lignes': [
              {'id': 'langue', 'type': 'bouton', 'titre': langue == 'fr' ? t.hlpReadInEnglish : t.hlpReadInFrench},
            ],
          },
        for (final (i, s) in politique(langue).indexed)
          {
            'entete': s.titre,
            if (i == politique(langue).length - 1) 'pied': t.hlpUpdated(kDatePolitique),
            'lignes': [
              for (final p in s.paragraphes) {'id': 'p', 'type': 'paragraphe', 'titre': '', 'sous': p},
            ],
          },
      ],
    };
  }
}
