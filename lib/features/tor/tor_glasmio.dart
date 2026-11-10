// ============================================================================
// TOR EN GLASMIO (Android 13+). Même contenu et mêmes services que
// `TorSettingsScreen` (l'écran de repli) : l'état, l'interrupteur, le circuit,
// la raison d'un échec, les contacts par Tor, les informations, et « Comment
// ça marche » (en alerte Glasmio).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/tor_providers.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/tor_service.dart';
import '../../design_system/ouro_colors.dart';
import 'tor_settings_screen.dart';

class PasserelleTor extends ConsumerStatefulWidget {
  const PasserelleTor({super.key});

  @override
  ConsumerState<PasserelleTor> createState() => _PasserelleTorState();
}

class _PasserelleTorState extends EtatPasserelleGlasmio<PasserelleTor> {
  ProviderSubscription<AsyncValue<TorServiceState>>? _ecoute;

  /// Pendant un démarrage ou un arrêt, l'interrupteur est bloqué.
  bool _occupe = false;

  @override
  String get ecran => 'tor';

  @override
  Widget construireRepli(BuildContext context) => const TorSettingsScreen();

  @override
  void surOuvert() {
    _ecoute?.close();
    _ecoute = ref.listenManual(torStateProvider, (_, __) => rafraichir());
  }

  @override
  void surFerme() {
    _ecoute?.close();
    _ecoute = null;
  }

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final t = textes;
    switch (id) {
      case 'tor':
        final service = ref.read(torServiceProvider);
        _occupe = true;
        await rafraichir();
        try {
          if (valeur == true) {
            await service.start();
          } else {
            await service.stop();
          }
        } catch (_) {
          // L'état d'erreur (et sa raison) s'affiche dans la section État.
        }
        _occupe = false;
      case 'scanner':
        return allerA('/tor/scan');
      case 'mon_qr':
        return allerA('/tor/qr');
      case 'annuaire':
        return allerA('/discover');
      case 'comment':
        return ReponseGlasmio.alerte({
          'titre': t.torHowItWorksTitle,
          'message': '${t.torEncryptedCircuit}\n${t.torEncryptedCircuitDesc}\n\n'
              '${t.torHiddenIp}\n${t.torHiddenIpDesc}\n\n'
              '${t.torMeshPreserved}\n${t.torMeshPreservedDesc}',
          'annuler': t.torUnderstood,
          'choix': <Object>[],
        });
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final etat = ref.read(torStateProvider).valueOrNull;
    final connecte = etat == TorServiceState.connected;
    final enCours = etat == TorServiceState.connecting;
    final erreur = etat == TorServiceState.error;
    final actif = connecte || enCours;
    final raison = ref.read(torServiceProvider).lastError ?? '';
    final vert = const Color(0xFF34C759).toARGB32();
    final gris = OuroColors.systemGray.toARGB32();
    final accent = OuroColors.accent.toARGB32();

    Map<String, Object?> ligne(String id, String type, String icone, int teinte, String titre,
            {String? sous, String? valeur, bool coche = false, bool actif = true}) =>
        {
          'id': id,
          'type': type,
          'icone': icone,
          'teinte': teinte,
          'titre': titre,
          'sous': ?sous,
          'valeur': ?valeur,
          'coche': coche,
          'actif': actif,
        };

    return {
      'titre': 'Tor',
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': accent,
      'vitrine': {
        'icone': 'shield',
        'teinte': connecte ? vert : (enCours ? const Color(0xFFFFC107).toARGB32() : gris),
        'titre': connecte ? t.torProtected : (enCours ? t.torConnecting : t.torInactiveTitle),
        'texte': connecte ? t.torDataThroughTor : (enCours ? t.torEstablishingCircuit : t.torActivateToProtect),
      },
      'sections': [
        {
          'lignes': [
            ligne('tor', 'interrupteur', 'shield', connecte ? vert : gris, t.torEnable,
                sous: actif ? t.torProtected : t.torDisabled, coche: actif, actif: !_occupe),
          ],
        },
        {
          'entete': t.torStateHeader,
          'lignes': [
            ligne('circuit', 'info', erreur ? 'warning' : 'wifi_tethering',
                connecte ? vert : (erreur ? OuroColors.systemRed.toARGB32() : const Color(0xFFFFC107).toARGB32()),
                t.torCircuit,
                valeur: connecte ? t.torActive : (enCours ? t.torInProgress : (erreur ? t.torFailed : t.torInactive))),
            if (erreur && raison.isNotEmpty)
              ligne('raison', 'info', 'info', OuroColors.systemRed.toARGB32(), t.torReason, sous: raison),
            ligne('chiffrement', 'info', 'lock', accent, t.torEncryption, valeur: 'AES-256'),
            ligne('latence', 'info', 'pie_chart', gris, t.torLatency, valeur: connecte ? '10-30s' : '—'),
          ],
        },
        if (connecte)
          {
            'entete': t.torContactsHeader,
            'pied': t.torScanQrFooter,
            'lignes': [
              ligne('scanner', 'nav', 'qr_code_scanner', accent, t.torScanQrCode),
              ligne('mon_qr', 'nav', 'qr_code', accent, t.torMyQrCode),
              ligne('annuaire', 'nav', 'person_search', accent, t.torSearchDirectory),
            ],
          },
        {
          'entete': t.torInformationHeader,
          'lignes': [
            ligne('version', 'info', 'info', gris, t.torVersion, valeur: 'Tor Arti (Rust)'),
            ligne('comment', 'nav', 'help', gris, t.torHowItWorks),
          ],
        },
      ],
    };
  }
}
