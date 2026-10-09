// ============================================================================
// LE NAVIGATEUR INTÉGRÉ — les liens s'ouvrent DANS Droplet.
// ----------------------------------------------------------------------------
// Comme Telegram, WhatsApp ou Mail : toucher un lien ouvre la page par-dessus
// la discussion, sans quitter l'app, et « Terminé » y ramène.
//
//   • présentée comme une feuille iOS (elle monte depuis le bas) ;
//   • en haut : « Terminé », le titre de la page et son domaine — cadenas
//     si la page est chiffrée, « Non sécurisé » en rouge sinon — et « ⋯ » ;
//   • une fine barre de progression à la couleur de Droplet ;
//   • en bas, la barre d'outils de Safari : précédent, suivant, partager,
//     ouvrir dans le navigateur, actualiser ;
//   • glisser depuis le bord de l'écran revient à la page précédente.
//
// Hors ligne — le cas courant sur un réseau maillé — la page ne peut pas se
// charger : on le dit clairement, avec « Réessayer » et « Copier le lien ».
// Les liens qui ne sont pas du Web (mailto:, tel:, liens d'apps…) partent
// vers les applications du système, comme dans Safari.
//
// Les barres sont OPAQUES, pas en verre dépoli : un flou ne peut pas lire le
// contenu d'une vue native (la page web) sur iOS, il resterait transparent.
// ============================================================================

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/services/media_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/afficher_toast.dart';

/// La clé du navigateur racine (branchée sur le routeur) : elle permet
/// d'ouvrir un lien depuis un widget qui n'a pas de `BuildContext`.
final GlobalKey<NavigatorState> cleNavigateurRacine = GlobalKey<NavigatorState>();

Uri? _normaliser(String adresse) {
  var texte = adresse.trim();
  if (texte.isEmpty) return null;
  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(texte)) texte = 'https://$texte';
  return Uri.tryParse(texte);
}

bool _estWeb(Uri uri) => uri.scheme == 'http' || uri.scheme == 'https';

/// Ouvre un lien : une page Web dans le navigateur intégré, le reste (mail,
/// téléphone, liens d'apps) dans l'application du système.
Future<void> ouvrirLienDansApp(BuildContext? context, String adresse) async {
  final uri = _normaliser(adresse);
  if (uri == null) return;
  if (!_estWeb(uri)) {
    await MediaService.ouvrirLien(uri.toString());
    return;
  }
  final navigateur = context != null && context.mounted
      ? Navigator.of(context, rootNavigator: true)
      : cleNavigateurRacine.currentState;
  if (navigateur == null) {
    await MediaService.ouvrirLien(uri.toString());
    return;
  }
  await navigateur.push(CupertinoPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) => NavigateurIntegre(adresse: uri),
  ));
}

/// L'appui long sur un lien : la feuille d'actions d'iOS.
Future<void> proposerActionsLien(BuildContext context, Uri adresse) async {
  final l10n = AppLocalizations.of(context);
  unawaited(HapticFeedback.mediumImpact());
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (feuille) => CupertinoActionSheet(
      title: Text(adresse.host.replaceFirst(RegExp(r'^www\.'), '')),
      message: Text(adresse.toString(), maxLines: 3, overflow: TextOverflow.ellipsis),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(feuille);
            unawaited(ouvrirLienDansApp(context, adresse.toString()));
          },
          child: Text(l10n.nvOpen),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(feuille);
            unawaited(MediaService.ouvrirLien(adresse.toString()));
          },
          child: Text(l10n.nvOpenInBrowser),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(feuille);
            unawaited(Clipboard.setData(ClipboardData(text: adresse.toString())));
            afficherToast(context, l10n.nvLinkCopied, type: DropletToastType.success);
          },
          child: Text(l10n.nvCopyLink),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(feuille);
            unawaited(Share.share(adresse.toString()));
          },
          child: Text(l10n.nvShare),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(feuille),
        child: Text(l10n.actionCancel),
      ),
    ),
  );
}

class NavigateurIntegre extends StatefulWidget {
  const NavigateurIntegre({super.key, required this.adresse});

  final Uri adresse;

  @override
  State<NavigateurIntegre> createState() => _NavigateurIntegreState();
}

class _NavigateurIntegreState extends State<NavigateurIntegre> {
  late final WebViewController _controleur;
  late Uri _adresse = widget.adresse;
  String? _titre;
  double _progres = 0;
  bool _chargement = true;
  bool _peutReculer = false;
  bool _peutAvancer = false;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _controleur = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) {
          if (mounted) setState(() => _progres = p / 100);
        },
        onPageStarted: (url) {
          if (!mounted) return;
          setState(() {
            _chargement = true;
            _erreur = null;
            _adresse = Uri.tryParse(url) ?? _adresse;
          });
        },
        onPageFinished: (_) => _majEtat(fini: true),
        onUrlChange: (changement) {
          final url = changement.url;
          if (url != null && mounted) {
            setState(() => _adresse = Uri.tryParse(url) ?? _adresse);
          }
          _majEtat();
        },
        onWebResourceError: (erreur) {
          if ((erreur.isForMainFrame ?? true) && mounted) {
            setState(() {
              _erreur = erreur.description;
              _chargement = false;
            });
          }
        },
        onNavigationRequest: (demande) {
          final uri = Uri.tryParse(demande.url);
          if (uri == null) return NavigationDecision.prevent;
          if (_estWeb(uri) || const {'about', 'data', 'blob'}.contains(uri.scheme)) {
            return NavigationDecision.navigate;
          }
          unawaited(MediaService.ouvrirLien(demande.url));
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(widget.adresse);
  }

  Future<void> _majEtat({bool fini = false}) async {
    final recule = await _controleur.canGoBack();
    final avance = await _controleur.canGoForward();
    final titre = await _controleur.getTitle();
    if (!mounted) return;
    setState(() {
      _peutReculer = recule;
      _peutAvancer = avance;
      if (titre != null && titre.trim().isNotEmpty) _titre = titre.trim();
      if (fini) {
        _chargement = false;
        _progres = 1;
      }
    });
  }

  Future<void> _reculer() async {
    if (await _controleur.canGoBack()) await _controleur.goBack();
  }

  Future<void> _avancer() async {
    if (await _controleur.canGoForward()) await _controleur.goForward();
  }

  void _recharger() {
    setState(() {
      _erreur = null;
      _chargement = true;
      _progres = 0;
    });
    unawaited(_controleur.loadRequest(_adresse));
  }

  void _copier() {
    unawaited(Clipboard.setData(ClipboardData(text: _adresse.toString())));
    afficherToast(context, AppLocalizations.of(context).nvLinkCopied, type: DropletToastType.success);
  }

  Future<void> _menu() async {
    final l10n = AppLocalizations.of(context);
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (feuille) => CupertinoActionSheet(
        title: Text(_titre ?? _adresse.host),
        message: Text(_adresse.toString(), maxLines: 3, overflow: TextOverflow.ellipsis),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(feuille);
              _copier();
            },
            child: Text(l10n.nvCopyLink),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(feuille);
              unawaited(MediaService.ouvrirLien(_adresse.toString()));
            },
            child: Text(l10n.nvOpenInBrowser),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(feuille);
              _recharger();
            },
            child: Text(l10n.nvReload),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(feuille),
          child: Text(l10n.actionCancel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final securise = _adresse.scheme == 'https';
    final hote = _adresse.host.replaceFirst(RegExp(r'^www\.'), '');
    final chrome = OuroColors.secondarySystemGroupedBackground;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: chrome,
        body: Column(
          children: [
            _barreHaut(l10n, hote, securise, chrome),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controleur),
                  // Glisser depuis le bord : la page précédente, comme Safari.
                  PositionedDirectional(
                    start: 0,
                    top: 0,
                    bottom: 0,
                    width: 18,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragEnd: (d) {
                        final vitesse = (d.primaryVelocity ?? 0) * (rtl ? -1 : 1);
                        if (vitesse > 250) unawaited(_reculer());
                      },
                    ),
                  ),
                  if (_erreur != null) Positioned.fill(child: _pageErreur(l10n)),
                ],
              ),
            ),
            _barreBas(l10n, chrome),
          ],
        ),
      ),
    );
  }

  Widget _barreHaut(AppLocalizations l10n, String hote, bool securise, Color chrome) {
    final couleurDomaine = securise ? OuroColors.secondaryLabel : OuroColors.systemRed;
    return ColoredBox(
      color: chrome,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(
                      l10n.nvDone,
                      style: OuroTypography.body.copyWith(
                        color: OuroColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: _copier,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _titre ?? hote,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: OuroTypography.subheadline.copyWith(
                              color: OuroColors.label,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                securise ? Icons.lock_rounded : Icons.lock_open_rounded,
                                size: 11,
                                color: couleurDomaine,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  securise ? hote : '${l10n.nvNotSecure} — $hote',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: OuroTypography.footnote.copyWith(color: couleurDomaine),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  OuroIconButton(
                    icon: Icon(Icons.more_horiz_rounded, color: OuroColors.accent),
                    onPressed: _menu,
                    tooltip: l10n.nvMore,
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
            SizedBox(
              height: 2,
              child: AnimatedOpacity(
                opacity: _chargement ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AnimatedFractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    widthFactor: _progres.clamp(0.06, 1.0).toDouble(),
                    heightFactor: 1,
                    child: ColoredBox(color: OuroColors.accent),
                  ),
                ),
              ),
            ),
            Container(height: 0.5, color: OuroColors.separator),
          ],
        ),
      ),
    );
  }

  Widget _barreBas(AppLocalizations l10n, Color chrome) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: chrome,
        border: Border(top: BorderSide(color: OuroColors.separator, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: IconTheme(
            data: IconThemeData(color: OuroColors.accent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OuroIconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
                  onPressed: _peutReculer ? _reculer : null,
                  tooltip: l10n.nvBack,
                ),
                OuroIconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 21),
                  onPressed: _peutAvancer ? _avancer : null,
                  tooltip: l10n.nvForward,
                ),
                OuroIconButton(
                  icon: const Icon(Icons.ios_share_rounded, size: 22),
                  onPressed: () => unawaited(Share.share(_adresse.toString())),
                  tooltip: l10n.nvShare,
                ),
                OuroIconButton(
                  icon: const Icon(Icons.explore_outlined, size: 23),
                  onPressed: () => unawaited(MediaService.ouvrirLien(_adresse.toString())),
                  tooltip: l10n.nvOpenInBrowser,
                ),
                OuroIconButton(
                  icon: const Icon(Icons.refresh_rounded, size: 23),
                  onPressed: _recharger,
                  tooltip: l10n.nvReload,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageErreur(AppLocalizations l10n) {
    return ColoredBox(
      color: OuroColors.systemGroupedBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 46, color: OuroColors.tertiaryLabel),
              const SizedBox(height: 16),
              Text(
                l10n.nvErrorTitle,
                textAlign: TextAlign.center,
                style: OuroTypography.headline.copyWith(
                  color: OuroColors.label,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.nvErrorBody,
                textAlign: TextAlign.center,
                style: OuroTypography.subheadline.copyWith(
                  color: OuroColors.secondaryLabel,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              CupertinoButton(
                color: OuroColors.accentRempli,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                onPressed: _recharger,
                child: Text(
                  l10n.nvRetry,
                  style: TextStyle(color: OuroColors.texteSurAccent, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              CupertinoButton(
                onPressed: _copier,
                child: Text(l10n.nvCopyLink, style: TextStyle(color: OuroColors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
