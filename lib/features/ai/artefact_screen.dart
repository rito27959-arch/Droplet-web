// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA SURFACE D'UN ARTÉFACT — l'écran qui montre ce que l'assistant a
// produit, à part du fil.
//
// ── DEUX VUES, ET UNE SEULE QUAND ÇA N'A PAS DE SENS ──────────────────
//
// Une page web a deux vues : le RENDU (ce que ça donne) et la SOURCE (ce
// qui l'écrit). Un script n'en a qu'une — le rendre n'a aucun sens, et
// un sélecteur à un seul onglet est un sélecteur qu'on n'aurait pas dû
// dessiner. La bascule n'apparaît donc que pour ce qui s'affiche.
//
// ── LES VERSIONS ──────────────────────────────────────────────────────
//
// Quand il y en a plusieurs, une barre discrète en bas : ‹ v2/3 ›. C'est
// exactement la forme de Claude, et sa faiblesse connue — des flèches
// minuscules, aucune vue d'ensemble. Ici un appui sur le numéro ouvre la
// liste complète, ce qui coûte quinze lignes et supprime le reproche.
//
// ── ⚠️ CE QUE LE RENDU N'EST PAS ──────────────────────────────────────
//
// Le webview affiche la page SANS accès au réseau ni au téléphone. Une
// page produite par un modèle est du contenu non vérifié : lui laisser
// charger des ressources distantes reviendrait à exécuter chez la
// personne ce qu'un tiers a écrit. Tout ce qui n'est pas dans le fichier
// ne se charge pas, et c'est voulu.
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/services/artefacts_store.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

class ArtefactScreen extends StatefulWidget {
  const ArtefactScreen({
    super.key,
    required this.store,
    required this.artefactId,
    this.onExporter,
  });

  final ArtefactsStore store;
  final String artefactId;

  /// Produit un fichier depuis l'artéfact. Nul = pas de bouton.
  final Future<void> Function(Artefact)? onExporter;

  @override
  State<ArtefactScreen> createState() => _ArtefactScreenState();
}

class _ArtefactScreenState extends State<ArtefactScreen> {
  StreamSubscription<void>? _abonnement;
  Artefact? _artefact;
  int? _version;
  bool _source = false;

  @override
  void initState() {
    super.initState();
    _charger();
    _abonnement = widget.store.changements.listen((_) {
      if (mounted) _charger();
    });
  }

  @override
  void dispose() {
    _abonnement?.cancel();
    super.dispose();
  }

  void _charger() {
    final a = widget.store.lire(widget.artefactId, version: _version);
    setState(() {
      _artefact = a;
      // Le genre décide de la vue par défaut : on montre le RÉSULTAT
      // d'abord quand il y en a un, la source sinon.
      if (a != null && a.genre != GenreArtefact.page) _source = true;
    });
  }

  Future<void> _choisirVersion() async {
    final a = _artefact;
    if (a == null || a.nbVersions < 2) return;
    final l10n = AppLocalizations.of(context);
    OuroHaptics.light();
    final choix = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space3),
          child: OuroListSection(
            header: l10n.arVersions,
            children: [
              for (var i = a.nbVersions; i >= 1; i--)
                OuroListRow(
                  icon: i == a.version
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  iconColor: i == a.version
                      ? OuroColors.accent
                      : OuroColors.tertiaryLabel,
                  title: l10n.arVersion(i),
                  subtitle: i == a.nbVersions ? l10n.arLatest : null,
                  showChevron: false,
                  onTap: () => Navigator.pop(context, i),
                ),
            ],
          ),
        ),
      ),
    );
    if (choix == null || !mounted) return;
    setState(() => _version = choix == a.nbVersions ? null : choix);
    _charger();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final a = _artefact;
    if (a == null) {
      return Scaffold(
        backgroundColor: OuroColors.systemBackground,
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Text(
            l10n.arGone,
            style: OuroTypography.subheadline.copyWith(
              color: OuroColors.secondaryLabel,
            ),
          ),
        ),
      );
    }
    final rendable = a.genre == GenreArtefact.page;

    return Scaffold(
      backgroundColor: OuroColors.systemBackground,
      appBar: AppBar(
        backgroundColor: OuroColors.systemBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          color: OuroColors.label,
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              a.titre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: OuroTypography.headline.copyWith(
                color: OuroColors.label,
              ),
            ),
            Text(
              _sousTitre(a, l10n),
              style: OuroTypography.caption1.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
          ],
        ),
        actions: [
          if (rendable)
            IconButton(
              tooltip: _source ? l10n.arPreview : l10n.arSource,
              icon: Icon(
                _source ? Icons.visibility_outlined : Icons.code_rounded,
              ),
              color: OuroColors.label,
              onPressed: () {
                OuroHaptics.selection();
                setState(() => _source = !_source);
              },
            ),
          IconButton(
            tooltip: l10n.amCopy,
            icon: const Icon(Icons.copy_rounded),
            color: OuroColors.label,
            onPressed: () {
              OuroHaptics.success();
              Clipboard.setData(ClipboardData(text: a.contenu));
            },
          ),
          IconButton(
            tooltip: l10n.amShare,
            icon: const Icon(Icons.ios_share_rounded),
            color: OuroColors.label,
            onPressed: () async {
              OuroHaptics.light();
              if (widget.onExporter != null) {
                await widget.onExporter!(a);
              } else {
                // `Share.share` et non `SharePlus.instance` : c'est
                // l'API de share_plus 10, celle qu'emploie déjà le
                // reste de l'application.
                await Share.share(a.contenu);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: rendable && !_source
                ? _Rendu(html: a.contenu)
                : _Source(contenu: a.contenu, langage: a.langage),
          ),
          if (a.nbVersions > 1)
            _BarreVersions(
              version: a.version,
              total: a.nbVersions,
              onPrecedente: a.version > 1
                  ? () {
                      OuroHaptics.selection();
                      setState(() => _version = a.version - 1);
                      _charger();
                    }
                  : null,
              onSuivante: a.version < a.nbVersions
                  ? () {
                      OuroHaptics.selection();
                      final n = a.version + 1;
                      setState(() => _version = n == a.nbVersions ? null : n);
                      _charger();
                    }
                  : null,
              onListe: _choisirVersion,
            ),
        ],
      ),
    );
  }

  static String _sousTitre(Artefact a, AppLocalizations l10n) {
    final genre = switch (a.genre) {
      GenreArtefact.page => l10n.arKindPage,
      GenreArtefact.code => a.langage.isEmpty ? l10n.arKindCode : a.langage,
      GenreArtefact.schema => l10n.arKindDiagram,
      GenreArtefact.donnees => l10n.arKindData,
      GenreArtefact.document => l10n.arKindDoc,
    };
    return a.nbVersions > 1
        ? '$genre · ${l10n.arVersion(a.version)}'
        : genre;
  }
}

// ══ LE RENDU ════════════════════════════════════════════════════════════

class _Rendu extends StatefulWidget {
  const _Rendu({required this.html});
  final String html;

  @override
  State<_Rendu> createState() => _RenduState();
}

class _RenduState extends State<_Rendu> {
  late final WebViewController _controleur;

  @override
  void initState() {
    super.initState();
    _controleur = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(OuroColors.systemBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          // ⚠️ AUCUNE NAVIGATION SORTANTE. La page vient d'un modèle :
          // un lien, une redirection ou une ressource distante ferait
          // charger chez la personne du contenu que personne n'a
          // vérifié. On ne bloque pas « par prudence », on bloque parce
          // que rien ne justifie de l'autoriser.
          onNavigationRequest: (demande) => demande.url.startsWith('data:')
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
        ),
      );
    _afficher();
  }

  @override
  void didUpdateWidget(covariant _Rendu ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.html != widget.html) _afficher();
  }

  void _afficher() {
    // `loadHtmlString` donnerait une origine `about:blank` où certaines
    // API se comportent autrement ; une URL `data:` est plus proche
    // d'une vraie page et supprime ces surprises.
    _controleur.loadRequest(
      Uri.parse(
        'data:text/html;charset=utf-8;base64,'
        '${base64Encode(utf8.encode(_complet(widget.html)))}',
      ),
    );
  }

  /// Un fragment (`<p>bonjour</p>`) n'est pas une page : sans en-tête ni
  /// viewport, il s'affiche en taille bureau sur un téléphone, et c'est
  /// le reproche qu'on fait le plus souvent aux aperçus.
  static String _complet(String html) {
    final bas = html.toLowerCase();
    if (bas.contains('<html')) return html;
    return '<!doctype html><html><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        '<style>body{margin:16px;font:16px/1.5 -apple-system,system-ui,'
        'sans-serif}</style></head><body>$html</body></html>';
  }

  @override
  Widget build(BuildContext context) =>
      WebViewWidget(controller: _controleur);
}

// ══ LA SOURCE ═══════════════════════════════════════════════════════════

class _Source extends StatelessWidget {
  const _Source({required this.contenu, required this.langage});

  final String contenu;
  final String langage;

  @override
  Widget build(BuildContext context) {
    final lignes = contenu.split('\n');
    // Assez de place pour le plus grand numéro, pas plus : une gouttière
    // fixe gâcherait la largeur sur un fichier de dix lignes.
    final largeur = 10.0 + '${lignes.length}'.length * 8.0;

    return Scrollbar(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        itemCount: lignes.length,
        itemBuilder: (context, i) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: largeur,
              child: Text(
                '${i + 1}',
                textAlign: TextAlign.right,
                style: OuroTypography.caption1.copyWith(
                  color: OuroColors.quaternaryLabel,
                  fontFamily: 'monospace',
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SelectableText(
                lignes[i].isEmpty ? ' ' : lignes[i],
                style: OuroTypography.footnote.copyWith(
                  color: OuroColors.label,
                  fontFamily: 'monospace',
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(width: DesignTokens.space3),
          ],
        ),
      ),
    );
  }
}

// ══ LA BARRE DE VERSIONS ════════════════════════════════════════════════

class _BarreVersions extends StatelessWidget {
  const _BarreVersions({
    required this.version,
    required this.total,
    required this.onPrecedente,
    required this.onSuivante,
    required this.onListe,
  });

  final int version;
  final int total;
  final VoidCallback? onPrecedente;
  final VoidCallback? onSuivante;
  final VoidCallback onListe;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: OuroColors.systemBackground,
          border: Border(
            top: BorderSide(color: OuroColors.separator, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Fleche(
              icone: Icons.chevron_left_rounded,
              onTap: onPrecedente,
            ),
            // ⚠️ LE NUMÉRO EST UN BOUTON, PAS UNE ÉTIQUETTE. C'est le
            // reproche fait à Claude : deux flèches minuscules et aucune
            // vue d'ensemble. Ici on touche « v2/3 » et la liste s'ouvre.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onListe,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space4,
                  vertical: DesignTokens.space2,
                ),
                child: Text(
                  'v$version/$total',
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.label,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            _Fleche(
              icone: Icons.chevron_right_rounded,
              onTap: onSuivante,
            ),
          ],
        ),
      ),
    );
  }
}

class _Fleche extends StatelessWidget {
  const _Fleche({required this.icone, required this.onTap});
  final IconData icone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icone,
            size: DesignTokens.iconLg,
            color: onTap == null
                ? OuroColors.quaternaryLabel
                : OuroColors.label,
          ),
        ),
      );
}
