// ============================================================================
// LES RÉGLAGES DES NOTIFICATIONS EN GLASMIO (Android 13+).
// ----------------------------------------------------------------------------
// Même contenu et mêmes services que `ReglagesNotifsScreen` (qui reste
// l'écran de repli) : mode concentration, mentions, bannières, centre des
// notifications, aperçu, conversations en sourdine, réglages du système.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/journal_notifs.dart';
import '../../core/services/notifs_conversation.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/reglages_notifs.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import 'notifs_conversation_screen.dart';
import 'reglages_notifs_screen.dart';

class PasserelleNotifs extends ConsumerStatefulWidget {
  const PasserelleNotifs({super.key});

  @override
  ConsumerState<PasserelleNotifs> createState() => _PasserelleNotifsState();
}

class _PasserelleNotifsState extends EtatPasserelleGlasmio<PasserelleNotifs> {
  /// Les choix de fin de concentration affichés, par identifiant.
  final Map<String, DateTime> _fins = {};

  @override
  String get ecran => 'notifications';

  @override
  Widget construireRepli(BuildContext context) => const ReglagesNotifsScreen();

  void _maj() => rafraichir();

  @override
  void surOuvert() {
    ReglagesNotifs.revision.addListener(_maj);
    JournalNotifs.instance.addListener(_maj);
  }

  @override
  void surFerme() {
    ReglagesNotifs.revision.removeListener(_maj);
    JournalNotifs.instance.removeListener(_maj);
  }

  String _nom(String id) => StorageService.getGroup(id)?.name ?? StorageService.getPeerRecord(id)?.pseudo ?? id;

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    switch (id) {
      case 'arreter':
        await ReglagesNotifs.definirConcentration(null);
      case 'mentions':
        await ReglagesNotifs.definirConcentrationLaisseMentions(valeur == true);
      case 'bannieres':
        await ReglagesNotifs.definirBannieres(valeur == true);
      case 'apercu':
        await ReglagesNotifs.definirApercuGeneral(valeur == true);
      case 'centre':
        return allerA('/notifications');
      case 'systeme':
        unawaited(NotifsConversation.ouvrirReglagesBulles());
      default:
        final fin = _fins[id];
        if (fin != null) {
          await ReglagesNotifs.definirConcentration(fin);
        } else if (id.startsWith('sourdine:')) {
          final conv = id.substring(9);
          return pousser(MaterialPageRoute<void>(
            builder: (_) => NotifsConversationScreen(
              conversationId: conv,
              nom: _nom(conv),
              groupe: StorageService.getGroup(conv) != null,
            ),
          ));
        }
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  static int _c(Color c) => c.toARGB32();

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final langue = Localizations.localeOf(context).toLanguageTag();
    final heure = DateFormat.Hm(langue);
    final fin = ReglagesNotifs.concentrationJusqua;
    final instantane = ReglagesNotifs.instantane();
    final maintenant = DateTime.now();
    final enSourdine = [
      for (final id in {...instantane.sourdinesPermanentes, ...instantane.conversations.keys})
        if (instantane.pour(id).enSourdine(maintenant)) id,
    ];
    final ceSoir = DateTime(maintenant.year, maintenant.month, maintenant.day, 19);
    _fins
      ..clear()
      ..['fin:1h'] = maintenant.add(const Duration(hours: 1));
    if (ceSoir.isAfter(maintenant.add(const Duration(minutes: 30)))) _fins['fin:soir'] = ceSoir;
    _fins['fin:demain'] = DateTime(maintenant.year, maintenant.month, maintenant.day + 1, 8);
    final libelles = {'fin:1h': t.rnFocus1h, 'fin:soir': t.rnFocusEvening, 'fin:demain': t.rnFocusTomorrow};
    final nonLues = JournalNotifs.instance.nonLues;

    Map<String, Object?> ligne(String id, String type, String icone, Color teinte, String titre,
            {String? sous, String? valeur, bool coche = false}) =>
        {
          'id': id,
          'type': type,
          'icone': icone,
          'teinte': _c(teinte),
          'titre': titre,
          'sous': ?sous,
          'valeur': ?valeur,
          'coche': coche,
        };

    return {
      'titre': t.ncTitle,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': _c(OuroColors.accent),
      'sections': [
        // L'état de la concentration, en tête (la carte de l'écran Flutter).
        {
          'lignes': [
            ligne(fin != null ? 'arreter' : 'etat', fin != null ? 'action' : 'info',
                fin != null ? 'nightlight' : 'notifications_active',
                fin != null ? OuroColors.systemIndigo : OuroColors.systemGray,
                fin != null ? t.rnFocusOn : t.rnFocusOff,
                sous: fin != null ? t.rnFocusUntil(heure.format(fin)) : t.rnFocusOffSub,
                valeur: fin != null ? t.rnFocusStopShort : null),
          ],
        },
        {
          'entete': t.rnFocusHeader,
          'pied': t.rnFocusFooter,
          'lignes': [
            if (fin == null)
              for (final e in _fins.entries)
                ligne(e.key, 'action', 'nightlight', OuroColors.systemIndigo, libelles[e.key]!, valeur: heure.format(e.value))
            else
              ligne('arreter', 'action', 'stop_circle', OuroColors.systemRed, t.rnFocusStop),
            ligne('mentions', 'interrupteur', 'alternate_email', OuroColors.accent, t.rnFocusMentions,
                sous: t.rnFocusMentionsSub, coche: ReglagesNotifs.concentrationLaisseMentions),
          ],
        },
        {
          'entete': t.rnInAppHeader,
          'lignes': [
            ligne('bannieres', 'interrupteur', 'view_day', OuroColors.accent, t.rnBanners,
                sous: t.rnBannersSub, coche: ReglagesNotifs.bannieres),
            ligne('centre', 'nav', 'inbox', OuroColors.systemRed, t.cnTitle, valeur: nonLues > 0 ? '$nonLues' : null),
          ],
        },
        {
          'entete': t.ncPreviewHeader,
          'pied': t.rnPreviewFooter,
          'lignes': [
            ligne('apercu', 'interrupteur', 'visibility', OuroColors.systemGray, t.rnPreview, coche: ReglagesNotifs.apercuGeneral),
          ],
        },
        {
          'entete': t.rnMutedHeader,
          if (enSourdine.isEmpty) 'pied': t.rnMutedEmpty,
          'lignes': [
            for (final id in enSourdine)
              ligne('sourdine:$id', 'nav', 'notifications_off', OuroColors.systemGray, _nom(id),
                  sous: instantane.pour(id).sourdineJusqua != null
                      ? libelleFinSourdine(t, langue, instantane.pour(id).sourdineJusqua!)
                      : t.ncMuteAlways),
          ],
        },
        if (Platform.isAndroid)
          {
            'pied': t.rnSystemFooter,
            'lignes': [ligne('systeme', 'nav', 'settings_applications', OuroColors.systemGray, t.rnSystem)],
          },
      ],
    };
  }
}
