// ============================================================================
// DROPLET PRO EN GLASMIO (Android 13+) — la vitrine native.
// ----------------------------------------------------------------------------
// La route `/premium` passe par cette passerelle : sur Android 13+ avec la
// couche Glasmio, la VITRINE (emblème, accroche, garanties, choix de l'offre,
// avantages, barre d'achat) est un écran natif Glasmio ; sinon, c'est
// `PremiumScreen`, inchangé.
//
// ⚠️ LE PAIEMENT N'EST PAS RÉÉCRIT. « Débloquer », « J'ai déjà payé » et
// chaque avantage ferment la vitrine native et ouvrent le parcours Flutter
// d'origine (`PremiumScreen`, avec l'offre choisie) : Mobile Money, code
// d'appareil, saisie de licence — exactement comme aujourd'hui.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/premium_provider.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/premium_service.dart';
import '../../design_system/ouro_colors.dart';
import 'avantages_pro.dart';
import 'premium_screen.dart';
import 'vitrine_pro.dart' show prixLisible;

/// Les icônes des avantages → les clés de l'écran natif.
final Map<IconData, String> _cles = {
  Icons.graphic_eq_rounded: 'graphic_eq',
  Icons.text_fields_rounded: 'text_fields',
  Icons.wallpaper_rounded: 'wallpaper',
  Icons.translate_rounded: 'translate',
  Icons.auto_awesome_rounded: 'auto_awesome',
  Icons.apps_rounded: 'apps',
  Icons.workspace_premium_rounded: 'workspace_premium',
};

class PasserellePro extends ConsumerStatefulWidget {
  const PasserellePro({super.key});

  @override
  ConsumerState<PasserellePro> createState() => _PasserelleProState();
}

class _PasserelleProState extends EtatPasserelleGlasmio<PasserellePro> {
  bool _proChoisi = true;

  /// L'action à lancer dans l'écran Flutter quand on y bascule.
  String? _action;

  ProviderSubscription<NiveauPremium>? _ecouteNiveau;

  @override
  String get ecran => 'pro';

  @override
  Widget construireRepli(BuildContext context) =>
      PremiumScreen(actionInitiale: _action, proChoisi: _proChoisi);

  // Une licence appliquée ailleurs (code reçu) : la vitrine suit.
  @override
  void surOuvert() {
    _ecouteNiveau?.close();
    _ecouteNiveau = ref.listenManual(premiumProvider, (_, __) => rafraichir());
  }

  @override
  void surFerme() {
    _ecouteNiveau?.close();
    _ecouteNiveau = null;
  }

  /// Le paiement, le code et les avantages : les FEUILLES de PremiumScreen
  /// (le parcours de paiement n'est pas réécrit), ouvertes par-dessus la
  /// vitrine Glasmio figée — plus jamais l'écran Pro Flutter lui-même.
  ReponseGlasmio _versLeParcoursFlutter(String action) {
    _action = action;
    return parcoursFlutterCache(
      (fini) => PremiumScreen(actionInitiale: action, proChoisi: _proChoisi, surActionFinie: fini),
    );
  }

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    switch (id) {
      case 'offre_pro':
        _proChoisi = true;
      case 'offre_pack':
        _proChoisi = false;
      case 'payer':
        return _versLeParcoursFlutter('paiement');
      case 'code':
        return _versLeParcoursFlutter('code');
      default:
        if (id.startsWith('avantage:')) return _versLeParcoursFlutter(id);
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  static int _c(Color c) => c.toARGB32();

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final niveau = ref.read(premiumProvider);
    final actif = niveau != NiveauPremium.aucun;
    final montant = _proChoisi ? kPrixPro : kPrixPack;
    final avantages = avantagesPro();

    return {
      'titre': t.pmTitle,
      'retour': MaterialLocalizations.of(context).closeButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': _c(OuroColors.accent),
      'vitrine': {
        'icone': 'auto_awesome',
        'texte': actif
            ? (niveau.estPro ? t.pmProActiveDescription : t.pmPackActiveDescription)
            : t.pmHeroTagline,
        if (!actif)
          'puces': [
            {'icone': 'all_inclusive', 'texte': t.pmTrustOnce},
            {'icone': 'event_busy', 'texte': t.pmTrustNoSub},
            {'icone': 'wifi_off', 'texte': t.pmTrustOffline},
          ],
      },
      'sections': [
        if (actif)
          {
            'lignes': [
              {
                'id': 'actif',
                'type': 'info',
                'icone': 'verified',
                'teinte': _c(OuroColors.systemGreen),
                'titre': niveau.estPro ? t.pmProIsActive : t.pmPackIsUnlocked,
              },
            ],
            // La licence ne vaut que pour CE téléphone : on le rappelle.
            'pied': t.pmLicenseDeviceBound,
          }
        else ...[
          {
            'lignes': [
              {
                'id': 'offre_pro',
                'type': 'choix',
                'titre': t.pmTitle,
                'sous': t.pmOnceForLife,
                'badge': t.pmBestValue,
                'valeur': prixLisible(kPrixPro),
                'coche': _proChoisi,
              },
              {
                'id': 'offre_pack',
                'type': 'choix',
                'titre': t.pmPackTitle,
                'sous': t.pmOnce,
                'valeur': prixLisible(kPrixPack),
                'coche': !_proChoisi,
              },
            ],
            // Ce que contient l'offre choisie.
            'pied': (_proChoisi
                    ? [t.pmProAdvantage1, t.pmProAdvantage2, t.pmProAdvantage3]
                    : [t.pmPackAdvantage1, t.pmPackAdvantage2])
                .map((l) => '✓ $l')
                .join('\n'),
          },
          {
            'entete': t.avSectionHeader,
            'pied': t.pmNeverAskBody,
            'lignes': [
              for (var i = 0; i < avantages.length; i++)
                {
                  'id': 'avantage:$i',
                  'type': 'nav',
                  'icone': _cles[avantages[i].icone] ?? 'auto_awesome',
                  'teinte': _c(couleurAvantage(i)),
                  'titre': avantages[i].titre(t),
                  'sous': avantages[i].court(t),
                },
            ],
          },
        ],
      ],
      if (!actif)
        'bas': {
          'id': 'payer',
          'titre': t.pmCtaUnlock(prixLisible(montant)),
          'sous': t.pmCtaFootnote,
          'lien': {'id': 'code', 'titre': t.pmAlreadyPaidRestore},
        },
    };
  }
}
