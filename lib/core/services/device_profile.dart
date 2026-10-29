// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE PROFIL DE L'APPAREIL : est-on sur un téléphone qui peut se permettre
// les effets coûteux, ou sur une machine modeste qu'il faut ménager ?
//
// ── Pourquoi ce fichier existe ────────────────────────────────────────
//
// Droplet vise des gens qui n'ont pas de réseau — pas des gens qui ont
// des téléphones neufs. Les deux populations ne se recouvrent pas. Or,
// mesuré sur un Pixel 6 Pro, l'application occupe environ 865 Mo, dont
// 310 Mo de mémoire graphique rien que pour l'écran de carte.
//
// Sur un appareil de 12 Go, personne ne le remarque. Sur un appareil de
// 2 Go — celui de l'utilisateur type — Android tue l'application, sans
// message et sans écran d'erreur. C'est le même symptôme que celui
// rapporté au début : « l'app se ferme quand j'ouvre la carte ».
//
// ── ⚠️ ON DÉCIDE UNE FOIS, PAS EN CONTINU ─────────────────────────────
//
// La capacité totale de l'appareil est une propriété STABLE. La mémoire
// libre, elle, varie à la seconde selon ce que fait le reste du système.
// Se baser sur la seconde donnerait une interface qui change d'apparence
// sans raison visible — les effets qui apparaissent et disparaissent au
// gré des autres applications. On lit donc la capacité une fois au
// démarrage, et on s'y tient pour la session.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'storage_service.dart';

/// Ce que l'appareil peut se permettre.
enum DeviceTier {
  /// 2 Go ou moins, ou marqué « low RAM » par Android. Aucun effet
  /// coûteux : ni shader de verre, ni dégradé calculé, et une réserve
  /// d'images réduite.
  modeste,

  /// Entre 2 et 4 Go. Les effets légers passent, les shaders non.
  moyen,

  /// Plus de 4 Go. Tout est permis.
  confortable,
}

/// Le profil de cet appareil, lu une fois au démarrage.
class DeviceProfile {
  DeviceProfile._();

  static const MethodChannel _channel =
      MethodChannel('com.droplet.droplet/media');

  static DeviceTier _tier = DeviceTier.confortable;
  static int _ramMb = 0;

  /// La catégorie de l'appareil. Vaut `confortable` tant que
  /// [detecter] n'a pas été appelé — on ne bride jamais par défaut.
  static DeviceTier get tier => _tier;

  /// La mémoire vive totale en mégaoctets, 0 si inconnue.
  static int get ramMb => _ramMb;

  /// Vrai quand il faut renoncer aux effets coûteux.
  static bool get menager => _tier == DeviceTier.modeste;

  /// Vrai quand les shaders sont hors de portée (verre liquide).
  ///
  /// Le seuil est plus haut que pour le reste : un shader s'exécute à
  /// chaque image sur le processeur graphique, souvent partagé avec la
  /// mémoire système sur les appareils d'entrée de gamme. C'est l'effet
  /// dont le coût grimpe le plus vite quand la machine faiblit.
  static bool get sansShader => _tier != DeviceTier.confortable;

  /// La taille de la réserve d'images décodées, en octets.
  ///
  /// ⚠️ Le défaut de Flutter est 100 Mo, pensé pour un écran de bureau.
  /// Sur un téléphone de 2 Go, une réserve de cette taille suffit à
  /// elle seule à faire tuer l'application.
  static int get budgetImages => switch (_tier) {
        DeviceTier.modeste => 16 << 20,
        DeviceTier.moyen => 32 << 20,
        DeviceTier.confortable => 48 << 20,
      };

  /// Combien d'images décodées on garde au maximum.
  static int get nombreImages => switch (_tier) {
        DeviceTier.modeste => 60,
        DeviceTier.moyen => 140,
        DeviceTier.confortable => 250,
      };

  // ══ LES EFFETS ALLÉGÉS ════════════════════════════════════════════════
  //
  // ⚠️ LA MÉMOIRE NE SUFFIT PAS À JUGER UN TÉLÉPHONE. Les téléphones
  // d'entrée de gamme vendus aujourd'hui annoncent 4, 6 ou 8 Go (souvent
  // « 4 Go + 4 Go virtuels ») autour d'un processeur graphique très
  // faible. Classés « confortables » sur leur seule mémoire, ils gardaient
  // tous les flous — et saccadaient. On juge donc comme Telegram : le
  // nombre de cœurs, leur fréquence maximale, la version d'Android, la
  // « classe de performance » qu'Android publie depuis la version 12, et
  // la puce elle-même quand elle est connue pour son graphisme modeste.
  //
  // Et parce qu'aucune règle ne connaît tous les téléphones, on MESURE
  // aussi : si l'interface rate trop d'images pendant l'usage, elle passe
  // d'elle-même en effets allégés, et s'en souvient (voir `surveiller`).

  /// Vrai quand les flous et autres effets coûteux sont remplacés par
  /// leur version pleine (voir `design_system/flou.dart`).
  static final ValueNotifier<bool> effetsAlleges = ValueNotifier(false);

  /// Le choix de l'utilisateur dans Apparence : `auto`, `complets` ou
  /// `alleges`.
  static String get modeEffets => StorageService.getString(_cleMode) ?? 'auto';

  /// Vrai si la mesure a jugé ce téléphone trop lent pour les flous.
  static bool get mesureLente => StorageService.getString(_cleLent) == '1';

  /// Vrai si les règles (puce, cœurs, mémoire) classent l'appareil
  /// d'entrée de gamme, avant toute mesure.
  static bool get modesteSelonRegles => _modesteRegles;

  static const String _cleMode = 'effets_mode';
  static const String _cleLent = 'effets_mesure_lente';
  static bool _modesteRegles = false;

  static Future<void> changerModeEffets(String mode) async {
    await StorageService.setString(_cleMode, mode);
    if (mode == 'auto') await StorageService.setString(_cleLent, '0');
    _appliquer();
  }

  static void _appliquer() {
    effetsAlleges.value = switch (modeEffets) {
      'complets' => false,
      'alleges' => true,
      _ => _modesteRegles || _tier != DeviceTier.confortable || mesureLente,
    };
  }

  /// À appeler une fois la mémoire permanente ouverte : relit le choix de
  /// l'utilisateur et la mesure des sessions précédentes.
  static void appliquerPreferences() => _appliquer();

  // Les puces connues pour un graphisme trop faible pour le verre, même
  // avec beaucoup de mémoire (Build.SOC_MODEL, Android 12 et plus).
  static const Set<String> _pucesModestes = {
    // MediaTek Helio A/P d'entrée de gamme (PowerVR GE8320).
    'MT6761', 'MT6762', 'MT6762V', 'MT6765', 'MT6765V', 'MT6762G',
    // Unisoc (Itel, Tecno Pop, Infinix Smart…).
    'SC9863A', 'SC9863', 'T606', 'T610', 'T612', 'T616', 'T618', 'UMS512', 'UMS9230', 'UMS9230E',
    // Qualcomm d'entrée de gamme (Adreno 610 et moins).
    'SM4250', 'SM6115', 'SM6125', 'SM4350', 'QM215', 'MSM8917', 'MSM8937', 'SDM439', 'SDM450',
    // Helio G35/G37/G25 (PowerVR GE8320).
    'MT6765G', 'MT6769V', 'MT6769Z',
  };

  static const MethodChannel _canalAppareil =
      MethodChannel('com.droplet.droplet/appareil');

  /// Interroge le système. À appeler une fois, au démarrage.
  static Future<void> detecter() async {
    if (!(defaultTargetPlatform == TargetPlatform.android)) return;
    try {
      final p = await _canalAppareil.invokeMapMethod<String, Object?>('profil');
      if (p != null) {
        final ram = (p['ramMb'] as int?) ?? 0;
        final coeurs = (p['coeurs'] as int?) ?? 0;
        final freq = (p['freqMaxMhz'] as int?) ?? 0;
        final sdk = (p['sdk'] as int?) ?? 0;
        final classe = (p['classePerf'] as int?) ?? 0;
        final puce = ((p['puce'] as String?) ?? '').toUpperCase();
        final lowRam = p['lowRam'] == true;
        _ramMb = ram;
        // Les règles de Telegram (SharedConfig.getDevicePerformanceClass),
        // un cran plus prudentes sur la fréquence : c'est le graphisme
        // qu'on ménage, et il suit la gamme du processeur.
        final faible = lowRam ||
            (ram > 0 && ram <= 2200) ||
            sdk < 26 ||
            (coeurs > 0 && coeurs <= 4) ||
            (freq > 0 && freq <= 2000) ||
            _pucesModestes.contains(puce);
        final haut = !faible &&
            ram > 5500 &&
            coeurs >= 8 &&
            (freq == 0 || freq > 2400) &&
            // Android 12+ : la classe de performance « média » publiée par
            // le constructeur (31 = Android 12, etc.). 0 = non déclarée.
            (classe == 0 || classe >= 31);
        _tier = faible
            ? (ram > 0 && ram <= 2200 || lowRam ? DeviceTier.modeste : DeviceTier.moyen)
            : haut
                ? DeviceTier.confortable
                : DeviceTier.moyen;
        _modesteRegles = faible;
        debugPrint('[Appareil] $ram Mo, $coeurs cœurs à $freq MHz, Android $sdk, '
            'classe $classe, puce « $puce » → ${_tier.name}');
        effetsAlleges.value = _tier != DeviceTier.confortable;
        return;
      }
    } catch (_) {
      // Ancienne partie native : on retombe sur la seule mémoire.
    }
    try {
      final mb = await _channel.invokeMethod<int>('deviceMemoryMb');
      _ramMb = mb ?? 0;
      // Zéro veut dire « je n'ai pas pu savoir ». On traite alors
      // l'appareil comme modeste : une interface sobre sur un téléphone
      // puissant se remarque à peine, l'inverse le fait planter.
      _tier = _ramMb == 0
          ? DeviceTier.modeste
          : _ramMb <= 2200
              ? DeviceTier.modeste
              : _ramMb <= 4200
                  ? DeviceTier.moyen
                  : DeviceTier.confortable;
      debugPrint('[Appareil] $_ramMb Mo de RAM → ${_tier.name}');
    } catch (e) {
      debugPrint('[Appareil] mémoire indisponible: $e');
      _tier = DeviceTier.modeste;
    }
    effetsAlleges.value = _tier != DeviceTier.confortable;
  }

  // ══ LA MESURE ═════════════════════════════════════════════════════════

  static bool _surveille = false;
  static final List<bool> _fenetre = [];
  static DateTime _debut = DateTime.now();

  /// Écoute le temps de chaque image pendant l'usage. Si, sur 120 images
  /// d'affilée (deux secondes d'animation ou de défilement), plus d'une
  /// sur quatre a dépassé 22 ms — une image sautée à 60 Hz —, l'appareil
  /// passe en effets allégés et le retient pour les sessions suivantes.
  ///
  /// Les 12 premières secondes ne comptent pas : au démarrage, la
  /// compilation des shaders et le chargement des données font sauter
  /// des images sur tous les téléphones, rapides compris.
  static void surveiller() {
    if (_surveille) return;
    _surveille = true;
    _debut = DateTime.now();
    SchedulerBinding.instance.addTimingsCallback(_surImages);
  }

  static void _surImages(List<FrameTiming> images) {
    if (effetsAlleges.value || modeEffets != 'auto') return;
    if (DateTime.now().difference(_debut).inSeconds < 12) return;
    for (final i in images) {
      // Construction et dessin se font en parallèle (sur deux fils) : une
      // image est sautée dès que L'UN des deux dépasse le budget.
      _fenetre.add(i.buildDuration.inMicroseconds > 20000 || i.rasterDuration.inMicroseconds > 20000);
    }
    if (_fenetre.length < 120) return;
    final ratees = _fenetre.where((r) => r).length;
    _fenetre.clear();
    if (ratees > 30) {
      debugPrint('[Appareil] $ratees images sur 120 trop lentes → effets allégés');
      effetsAlleges.value = true;
      StorageService.setString(_cleLent, '1');
    }
  }
}
