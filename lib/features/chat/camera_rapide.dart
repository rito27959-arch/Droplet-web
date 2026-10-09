// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'APPAREIL PHOTO EN UN TOUCHER, depuis la barre de saisie — le bouton que
// WhatsApp met à côté du champ.
//
// Prendre une photo pour l'envoyer était à trois gestes : trombone, puis
// « Photo ou vidéo », puis l'appareil du système. C'est pourtant, après le
// texte, ce qu'on envoie le plus. Ici : un toucher, le viseur, le
// déclencheur — et la photo passe par le même aperçu d'envoi que toutes les
// autres (légende, dessin, vue unique).
//
// ⚠️ PLEIN ÉCRAN, SANS RIEN D'AUTRE. Un viseur encadré de boutons rapetisse
// ce qu'on photographie. Trois commandes seulement : fermer, retourner,
// déclencher — là où le pouce les trouve.
// ============================================================================

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/ouro_haptics.dart';
import '../../l10n/generated/app_localizations.dart';

/// Ouvre le viseur ; renvoie le chemin de la photo prise, ou `null`.
Future<String?> ouvrirCameraRapide(BuildContext context) {
  return Navigator.of(context).push<String>(
    PageRouteBuilder<String>(
      opaque: true,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => const _CameraRapide(),
      transitionsBuilder: (_, animation, _, enfant) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: enfant,
        ),
      ),
    ),
  );
}

class _CameraRapide extends StatefulWidget {
  const _CameraRapide();

  @override
  State<_CameraRapide> createState() => _CameraRapideState();
}

class _CameraRapideState extends State<_CameraRapide>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controleur;
  int _index = 0;
  bool _prise = false;
  bool _echec = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _demarrer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controleur?.dispose();
    super.dispose();
  }

  /// ⚠️ LA CAMÉRA EST RENDUE QUAND ON QUITTE L'APPLICATION. Garder le
  /// capteur ouvert en arrière-plan allume le témoin vert d'Android et
  /// empêche toute autre application de s'en servir.
  @override
  void didChangeAppLifecycleState(AppLifecycleState etat) {
    final c = _controleur;
    if (c == null || !c.value.isInitialized) return;
    if (etat == AppLifecycleState.inactive || etat == AppLifecycleState.paused) {
      c.dispose();
      _controleur = null;
      if (mounted) setState(() {});
    } else if (etat == AppLifecycleState.resumed) {
      _ouvrir(_index);
    }
  }

  Future<void> _demarrer() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) throw StateError('aucune caméra');
      // L'appareil arrière d'abord : on photographie ce qu'on voit.
      final arriere = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      await _ouvrir(arriere < 0 ? 0 : arriere);
    } catch (_) {
      if (mounted) setState(() => _echec = true);
    }
  }

  Future<void> _ouvrir(int index) async {
    final ancien = _controleur;
    _controleur = null;
    await ancien?.dispose();
    final c = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() {
        _index = index;
        _controleur = c;
        _echec = false;
      });
    } catch (_) {
      await c.dispose();
      if (mounted) setState(() => _echec = true);
    }
  }

  Future<void> _retourner() async {
    if (_cameras.length < 2) return;
    OuroHaptics.selection();
    await _ouvrir((_index + 1) % _cameras.length);
  }

  Future<void> _declencher() async {
    final c = _controleur;
    if (c == null || !c.value.isInitialized || _prise) return;
    setState(() => _prise = true);
    HapticFeedback.mediumImpact();
    try {
      final photo = await c.takePicture();
      if (mounted) Navigator.of(context).pop(photo.path);
    } catch (_) {
      if (mounted) setState(() => _prise = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = _controleur;
    final marges = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (c != null && c.value.isInitialized)
            // Le viseur remplit l'écran sans être déformé : on le met à
            // l'échelle de la plus grande dimension et on rogne le reste.
            ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: c.value.previewSize?.height ?? 1080,
                  height: c.value.previewSize?.width ?? 1920,
                  child: CameraPreview(c),
                ),
              ),
            )
          else if (_echec)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.camUnavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
            ),
          // Le flash blanc du déclenchement : on SAIT que la photo est prise.
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _prise ? 0.55 : 0,
              duration: const Duration(milliseconds: 90),
              child: const ColoredBox(color: Colors.white),
            ),
          ),
          Positioned(
            top: marges.top + 8,
            left: 8,
            child: _BoutonRond(
              icone: Icons.close_rounded,
              libelle: l10n.actionClose,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: marges.bottom + 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 48),
                Semantics(
                  button: true,
                  label: l10n.camTakePhoto,
                  child: GestureDetector(
                    onTap: _declencher,
                    child: Container(
                      width: 78,
                      height: 78,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: AnimatedScale(
                        scale: _prise ? 0.82 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _cameras.length > 1
                    ? _BoutonRond(
                        icone: Icons.flip_camera_ios_rounded,
                        libelle: l10n.camFlip,
                        onTap: _retourner,
                      )
                    : const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonRond extends StatelessWidget {
  const _BoutonRond({required this.icone, required this.libelle, required this.onTap});

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: libelle,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.35),
          ),
          child: Icon(icone, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
