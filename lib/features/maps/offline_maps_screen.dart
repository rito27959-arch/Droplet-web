// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'écran CARTES HORS CONNEXION : ce que Droplet a gardé de la carte, ce
// que ça pèse, et comment en ajouter.
//
// ── Deux façons d'avoir une carte hors connexion ──────────────────────
//
// 1. EN LA REGARDANT. Tout ce qu'on parcourt avec du réseau est
//    conservé et reste consultable ensuite. C'est automatique, il n'y a
//    rien à faire — et ça couvre le cas le plus fréquent : son quartier,
//    son trajet, l'endroit où l'on va.
//
// 2. EN IMPORTANT UN FICHIER `.mbtiles`. Une région entière, préparée à
//    l'avance sur un ordinateur, puis copiée sur le téléphone. C'est la
//    seule façon d'avoir une ville complète sans l'avoir parcourue.
//
// ── Pourquoi pas un bouton « Télécharger Yaoundé » ? ──────────────────
//
// Parce qu'il n'existe aucun serveur de tuiles gratuit qui autorise ce
// téléchargement. Une ville aux zooms utiles, c'est plusieurs dizaines
// de milliers de requêtes ; les conditions d'utilisation d'OpenStreetMap
// l'interdisent explicitement, et les services commerciaux qui le
// permettent réclament un compte et un abonnement.
//
// Un bouton qui promettrait ce téléchargement serait donc soit
// inopérant, soit un moyen de faire bannir l'application. L'import de
// fichier, lui, fonctionne vraiment — c'est un format standard que
// n'importe quel outil cartographique sait produire.
// ============================================================================

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/mesh_provider.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_alert.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../shared/widgets/empty_state.dart';
import 'offline_tile_store.dart';
import '../../shared/widgets/scene_animee.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_icon_button.dart';

class OfflineMapsScreen extends ConsumerStatefulWidget {
  const OfflineMapsScreen({super.key});

  @override
  ConsumerState<OfflineMapsScreen> createState() => _OfflineMapsScreenState();
}

class _OfflineMapsScreenState extends ConsumerState<OfflineMapsScreen> {
  List<OfflineRegion> _regions = const [];
  bool _loading = true;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    await OfflineTileStore.instance.init();
    final regions = await OfflineTileStore.instance.regions();
    if (!mounted) return;
    setState(() {
      _regions = regions;
      _loading = false;
    });
  }

  Future<void> _import() async {
    OuroHaptics.selection();
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles();
      final path = result?.files.single.path;
      if (path == null) return;

      final error = await OfflineTileStore.instance.import(File(path));
      if (!mounted) return;
      if (error != null) {
        _toast(error, DropletToastType.error);
      } else {
        OuroHaptics.success();
        _toast(AppLocalizations.of(context).omMapInstalled, DropletToastType.success);
        await _reload();
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _remove(OfflineRegion region) async {
    final l10n = AppLocalizations.of(context);
    final isCache = region.isCache;
    final confirmed = await ouroConfirm(
      context,
      title: isCache ? l10n.omClearCacheTitle : l10n.omRemoveZoneTitle,
      message: isCache
          ? l10n.omClearCacheMessage
          : l10n.omRemoveZoneMessage(region.name),
      confirmLabel: isCache ? l10n.omClear : l10n.actionDelete,
      destructive: true,
    );
    if (confirmed != true) return;

    await OfflineTileStore.instance.remove(region);
    if (!mounted) return;
    OuroHaptics.medium();
    await _reload();
  }

  void _toast(String message, DropletToastType type) {
    ref.read(toastProvider.notifier).show(message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = _regions.fold<int>(0, (sum, r) => sum + r.sizeBytes);

    return OuroLargeTitleScaffold(
      title: l10n.omTitle,
      subtitle: _loading
          ? l10n.omReading
          : total == 0
              ? l10n.omNoMapsSaved
              : l10n.omSizeOnDevice(_sizeLabel(l10n, total)),
      backgroundColor: OuroColors.systemGroupedBackground,
      leading: const OuroBackButton(fallback: '/map'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.screenMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_loading && _regions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 24),
                    child: EmptyState(
                      emoji: Scenes.aucuneCarte,
                      icon: Icons.map_outlined,
                      title: l10n.omNoMapsSaved,
                      subtitle: l10n.omBrowseMapHint,
                    ),
                  )
                else if (!_loading)
                  OuroListSection(
                    header: l10n.omOnThisDevice,
                    footer: l10n.omZonesFillThemselves,
                    separatorInset: 60,
                    children: [
                      for (final region in _regions)
                        OuroListRow(
                          icon: region.isCache
                              ? Icons.history_rounded
                              : Icons.map_rounded,
                          iconColor: region.isCache
                              ? OuroColors.systemGray
                              : OuroColors.systemGreen,
                          title: region.name,
                          subtitle: '${region.sizeLabel} · '
                              '${_tileLabel(l10n, region.tileCount)} · '
                              'zoom ${region.minZoom}–${region.maxZoom}',
                          showChevron: false,
                          trailing: OuroIconButton(
                            tooltip: region.isCache ? l10n.omClear : l10n.actionDelete,
                            icon: Icon(Icons.delete_outline_rounded,
                                color: OuroColors.systemRed, size: 20),
                            onPressed: () => _remove(region),
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: DesignTokens.space5),

                OuroListSection(
                  header: l10n.giAdd,
                  footer: l10n.omMbtilesExplainer,
                  children: [
                    OuroListRow(
                      icon: Icons.file_open_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.omImportMap,
                      subtitle: _importing
                          ? l10n.omReadingFile
                          : l10n.omMbtilesFromPhone,
                      onTap: _importing ? null : _import,
                    ),
                  ],
                ),

                const SizedBox(height: DesignTokens.space5),
                _explainer(l10n),
                const SizedBox(height: DesignTokens.space6),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Le bloc qui explique d'où viennent les cartes — et qui porte
  /// l'attribution qu'impose la licence des données.
  Widget _explainer(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space4),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public_rounded, size: 18, color: OuroColors.accent),
              const SizedBox(width: 8),
              Text('OpenStreetMap · CARTO',
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.label,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.omAttributionText,
            style: OuroTypography.footnote.copyWith(
              color: OuroColors.secondaryLabel,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  static String _tileLabel(AppLocalizations l10n, int count) {
    if (count < 1000) return l10n.omTilesCount(count);
    return l10n.omTilesCountK((count / 1000).toStringAsFixed(1).replaceAll('.', ','));
  }

  static String _sizeLabel(AppLocalizations l10n, int bytes) {
    if (bytes < 1024 * 1024) return l10n.omSizeKb((bytes / 1024).round());
    final mo = bytes / (1024 * 1024);
    if (mo < 1024) return l10n.omSizeMb(mo.toStringAsFixed(mo < 10 ? 1 : 0));
    return l10n.omSizeGb((mo / 1024).toStringAsFixed(1));
  }
}
