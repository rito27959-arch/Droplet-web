// ============================================================================
// QUAND LA CAMÉRA DU SCANNER NE DÉMARRE PAS — l'erreur EXACTE, lisible.
// ----------------------------------------------------------------------------
// Le widget d'erreur par défaut de mobile_scanner ne montrait qu'une icône et
// un mot : impossible de savoir pourquoi la caméra refusait de s'ouvrir. On
// affiche ici le code ET le détail renvoyé par Android (de quoi le corriger
// à partir d'une simple capture d'écran), avec deux sorties :
//   • Réessayer (relance la caméra) ;
//   • Réglages (si l'autorisation Caméra a été refusée).
// Le même détail est écrit dans le Journal d'erreurs.
//
// `CoucheErreurCamera` la pose AU-DESSUS du viseur (et non dessous, dans
// `errorBuilder`, où le cadre et le titre se dessinaient par-dessus le
// texte et le bouton). « Copier le détail » ajoute la pile Android exacte,
// lue dans le journal du système (seulement celui de l'app).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/generated/app_localizations.dart';

/// Au-dessus du viseur : rien tant que la caméra marche, l'erreur sinon.
class CoucheErreurCamera extends StatelessWidget {
  const CoucheErreurCamera({super.key, required this.controleur});

  final MobileScannerController controleur;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controleur,
      builder: (context, etat, _) {
        final erreur = etat.error;
        if (erreur == null) return const SizedBox.shrink();
        return ErreurCamera(erreur: erreur, controleur: controleur);
      },
    );
  }
}

/// Pour `errorBuilder` : un fond noir (l'erreur est dessinée par
/// `CoucheErreurCamera`, au-dessus).
Widget fondErreurCamera(BuildContext context, MobileScannerException erreur, Widget? enfant) =>
    const ColoredBox(color: Colors.black);

const _canalJournal = MethodChannel('com.droplet.droplet/journal');

/// Les dernières erreurs Android de l'app (avec leur pile), ou '' si
/// indisponibles.
Future<String> journalAndroid() async {
  try {
    return await _canalJournal.invokeMethod<String>('logcat') ?? '';
  } catch (_) {
    return '';
  }
}

class ErreurCamera extends StatelessWidget {
  const ErreurCamera({super.key, required this.erreur, required this.controleur});

  final MobileScannerException erreur;
  final MobileScannerController controleur;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final refusee = erreur.errorCode == MobileScannerErrorCode.permissionDenied;
    final details = [
      erreur.errorCode.name,
      if (erreur.errorDetails?.code != null) erreur.errorDetails!.code,
      if (erreur.errorDetails?.message != null) erreur.errorDetails!.message!,
      if (erreur.errorDetails?.details != null) '${erreur.errorDetails!.details}',
    ].join('\n');
    debugPrint('[Caméra] $details');
    journalAndroid().then((pile) {
      if (pile.isNotEmpty) debugPrint('[Caméra] pile Android :\n$pile');
    });
    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(refusee ? Icons.no_photography_rounded : Icons.error_outline_rounded, color: Colors.white70, size: 48),
                const SizedBox(height: 16),
                SelectableText(
                  details,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(minimumSize: const Size(120, 44)),
                      onPressed: () async {
                        try {
                          await controleur.stop();
                        } catch (_) {}
                        try {
                          await controleur.start();
                        } catch (_) {}
                      },
                      child: Text(l10n.actionRetry),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () async {
                        final pile = await journalAndroid();
                        await Clipboard.setData(ClipboardData(text: '$details\n\n$pile'.trim()));
                        if (!context.mounted) return;
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l10n.ivCopied)));
                      },
                      child: Text(l10n.chCopy),
                    ),
                    if (refusee)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: openAppSettings,
                        child: Text(l10n.settingsTitle),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
