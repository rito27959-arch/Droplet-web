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
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../l10n/generated/app_localizations.dart';

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
