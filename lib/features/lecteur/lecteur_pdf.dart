// ============================================================================
// LE LECTEUR DE PDF — lire un document sans quitter Droplet.
// ----------------------------------------------------------------------------
// Ouvrir un PDF dans une autre app, c'est sortir de la conversation, perdre
// sa place, et confier le fichier à un lecteur qui ne sait rien de notre
// promesse. Ici on le lit sur place.
//
// Parti pris iOS : le document occupe tout l'écran, la barre flotte
// par-dessus en verre dépoli et s'efface dès qu'on lit. Un toucher la
// rappelle. Le numéro de page reste une pastille discrète, en bas.
// ============================================================================

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Ouvre un PDF en plein écran.
Future<void> ouvrirPdf(BuildContext context, String chemin, {String? titre}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => LecteurPdf(chemin: chemin, titre: titre),
    ),
  );
}

class LecteurPdf extends StatefulWidget {
  const LecteurPdf({super.key, required this.chemin, this.titre});

  final String chemin;
  final String? titre;

  @override
  State<LecteurPdf> createState() => _LecteurPdfState();
}

class _LecteurPdfState extends State<LecteurPdf> {
  PdfController? _controleur;
  String? _erreur;
  bool _barres = true;
  int _page = 1;
  int _pages = 0;

  @override
  void initState() {
    super.initState();
    _ouvrir();
  }

  Future<void> _ouvrir() async {
    try {
      if (!File(widget.chemin).existsSync()) {
        if (mounted) setState(() => _erreur = 'introuvable');
        return;
      }
      final controleur = PdfController(
        document: PdfDocument.openFile(widget.chemin),
      );
      if (!mounted) {
        controleur.dispose();
        return;
      }
      setState(() => _controleur = controleur);
    } catch (_) {
      if (mounted) setState(() => _erreur = 'illisible');
    }
  }

  @override
  void dispose() {
    _controleur?.dispose();
    super.dispose();
  }

  String get _nom => widget.titre ?? widget.chemin.split('/').last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controleur = _controleur;
    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _barres = !_barres),
              child: _erreur != null
                  ? _Erreur(
                      message: _erreur == 'introuvable'
                          ? l10n.pdfMissing
                          : l10n.pdfUnreadable,
                    )
                  : controleur == null
                      ? const Center(child: OuroSpinner(radius: 14))
                      : PdfView(
                          controller: controleur,
                          scrollDirection: Axis.vertical,
                          backgroundDecoration: BoxDecoration(
                            color: OuroColors.systemGroupedBackground,
                          ),
                          onDocumentLoaded: (doc) {
                            if (mounted) setState(() => _pages = doc.pagesCount);
                          },
                          onPageChanged: (page) {
                            if (mounted) setState(() => _page = page);
                          },
                        ),
            ),
          ),

          // La barre du haut : verre dépoli, nom du document, fermer et
          // partager. Elle s'efface dès qu'on lit.
          AnimatedPositioned(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            top: _barres ? 0 : -140,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: Container(
                  color: OuroColors.systemBackground.withValues(alpha: 0.72),
                  padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
                  child: SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        OuroIconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: l10n.actionCancel,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            _nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: OuroTypography.subheadline.copyWith(
                              color: OuroColors.label,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        OuroIconButton(
                          icon: const Icon(Icons.ios_share_rounded),
                          tooltip: l10n.nvShare,
                          onPressed: () => Share.shareXFiles([XFile(widget.chemin)]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // La pastille des pages : elle dit où on en est, sans gêner.
          if (_pages > 0)
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 18,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _barres ? 1 : 0,
                  duration: const Duration(milliseconds: 240),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          color: OuroColors.systemBackground.withValues(alpha: 0.74),
                          child: Text(
                            '$_page / $_pages',
                            style: OuroTypography.footnote.copyWith(
                              color: OuroColors.secondaryLabel,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Erreur extends StatelessWidget {
  const _Erreur({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_outlined, size: 44, color: OuroColors.tertiaryLabel),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
