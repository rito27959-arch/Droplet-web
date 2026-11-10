// ============================================================================
// MA CONTRIBUTION EN GLASMIO (Android 13+). Même contenu que
// `ContributionScreen` (l'écran de repli) : le palier, les points, la jauge
// vers le palier suivant, les messages relayés, les minutes de passerelle.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mesh_message.dart' show ContributionRank;
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import 'contribution_screen.dart';

class PasserelleContribution extends ConsumerStatefulWidget {
  const PasserelleContribution({super.key});

  @override
  ConsumerState<PasserelleContribution> createState() => _PasserelleContributionState();
}

class _PasserelleContributionState extends EtatPasserelleGlasmio<PasserelleContribution> {
  @override
  String get ecran => 'contribution';

  @override
  Widget construireRepli(BuildContext context) => const ContributionScreen();

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async => ReponseGlasmio.rien;

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final points = StorageService.getContributionPoints();
    final rang = points.rank;
    final suivant = rang.next;
    final teinte = rankColor(rang).toARGB32();
    final progression = suivant == null
        ? 1.0
        : ((points.totalPoints - rang.minPoints) / (suivant.minPoints - rang.minPoints)).clamp(0.0, 1.0);
    final bleu = OuroColors.meshBlueBright.toARGB32();
    return {
      'titre': t.stMyContribution,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': OuroColors.accent.toARGB32(),
      'vitrine': {
        'icone': rang == ContributionRank.diamant ? 'diamond' : 'workspace_premium',
        'teinte': teinte,
        'titre': rankLabel(t, rang),
        'sous': t.cnPointsCount(points.totalPoints),
        if (suivant != null) ...{
          'progression': progression,
          'legende': t.cnPointsBeforeTier(t.cnPointsCount(suivant.minPoints - points.totalPoints), rankLabel(t, suivant)),
        },
      },
      'sections': [
        {
          'pied': t.cnExplanation,
          'lignes': [
            {
              'id': 'relais',
              'type': 'info',
              'icone': 'forward_to_inbox',
              'teinte': bleu,
              'titre': t.cnRelayedMessages,
              'sous': t.cnPointsSuffix(points.relaysCount * 10),
              'valeur': '${points.relaysCount}',
            },
            {
              'id': 'passerelle',
              'type': 'info',
              'icone': 'podcasts',
              'teinte': bleu,
              'titre': t.cnGatewayMinutes,
              'sous': t.cnPointsSuffix(points.gatewayMinutes * 2),
              'valeur': '${points.gatewayMinutes}',
            },
          ],
        },
      ],
    };
  }
}
