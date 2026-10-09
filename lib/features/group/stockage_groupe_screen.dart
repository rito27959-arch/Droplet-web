// ============================================================================
// LE STOCKAGE D'UN GROUPE — ce qui a été envoyé, par qui, et ce que ça pèse.
// ----------------------------------------------------------------------------
// Dans un groupe actif, les fichiers s'accumulent sans que personne ne sache
// ce qu'ils occupent. WhatsApp ne montre le poids qu'en réglages, tout
// mélangé. Ici, le groupe rend des comptes : le total en tête, chaque
// fichier avec son auteur et sa taille, et le plus lourd en premier quand
// on le demande.
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../chat/messages_importants.dart' show MessagesImportants;
import '../chat/vue_unique.dart';
import '../lecteur/lecteur_pdf.dart';

/// Un fichier du groupe, une fois son poids connu.
class _Piece {
  const _Piece({
    required this.message,
    required this.chemin,
    required this.octets,
  });

  final MeshMessage message;
  final String? chemin;
  final int octets;

  bool get present => chemin != null;
}

enum _Tri { recents, lourds }

class StockageGroupeScreen extends ConsumerStatefulWidget {
  const StockageGroupeScreen({
    super.key,
    required this.groupId,
    required this.nom,
  });

  final String groupId;
  final String nom;

  @override
  ConsumerState<StockageGroupeScreen> createState() =>
      _StockageGroupeScreenState();
}

class _StockageGroupeScreenState extends ConsumerState<StockageGroupeScreen> {
  _Tri _tri = _Tri.recents;
  List<_Piece>? _pieces;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final messages = ref.read(groupMessagesProvider(widget.groupId));
    final pieces = <_Piece>[];
    for (final m in messages) {
      // Une vue unique n'a rien à faire ici : elle n'existe que le temps
      // d'être vue.
      if (m.type != 'file' || VueUnique.marquee(m.content)) continue;
      final chemin = await StorageService.getSharedFilePath(
        m.fileId ?? '',
        m.fileName ?? '',
      );
      var octets = 0;
      if (chemin != null) {
        try {
          octets = File(chemin).lengthSync();
        } catch (_) {}
      }
      pieces.add(_Piece(message: m, chemin: chemin, octets: octets));
    }
    if (mounted) setState(() => _pieces = pieces);
  }

  List<_Piece> get _triees {
    final l = [...?_pieces];
    if (_tri == _Tri.lourds) {
      l.sort((a, b) => b.octets.compareTo(a.octets));
    } else {
      l.sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
    }
    return l;
  }

  static String poids(int octets) {
    if (octets <= 0) return '—';
    const unites = ['o', 'ko', 'Mo', 'Go'];
    var v = octets.toDouble();
    var i = 0;
    while (v >= 1024 && i < unites.length - 1) {
      v /= 1024;
      i++;
    }
    return '${v.toStringAsFixed(v >= 10 || i == 0 ? 0 : 1)} ${unites[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pieces = _triees;
    final total = pieces.fold<int>(0, (t, p) => t + p.octets);
    final parAuteur = <String, int>{};
    for (final p in pieces) {
      final nom = p.message.authorPseudo.trim();
      parAuteur[nom.isEmpty ? l10n.imUnknown : nom] =
          (parAuteur[p.message.authorPseudo] ?? 0) + p.octets;
    }

    return OuroLargeTitleScaffold(
      title: l10n.sgTitle,
      backgroundColor: OuroColors.systemGroupedBackground,
      leading: const OuroBackButton(),
      slivers: [
        if (_pieces == null)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator.adaptive()),
          )
        else if (pieces.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        size: 42, color: OuroColors.tertiaryLabel),
                    const SizedBox(height: 14),
                    Text(
                      l10n.sgEmpty,
                      textAlign: TextAlign.center,
                      style: OuroTypography.subheadline
                          .copyWith(color: OuroColors.secondaryLabel),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          // Le total, en tête : c'est la première question qu'on se pose.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenMargin,
                8,
                DesignTokens.screenMargin,
                DesignTokens.space4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poids(total),
                    style: OuroTypography.largeTitle.copyWith(
                      color: OuroColors.label,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.sgTotal(pieces.length),
                    style: OuroTypography.subheadline
                        .copyWith(color: OuroColors.secondaryLabel),
                  ),
                ],
              ),
            ),
          ),

          // Qui pèse le plus lourd : une barre par personne, la part de
          // chacun. Aucune app ne le montre, et c'est pourtant la seule
          // chose qui règle une discussion sur « qui remplit le téléphone ».
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.screenMargin,
              ),
              child: OuroListSection(
                header: l10n.sgByAuthor,
                children: [
                  for (final e in (parAuteur.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                      .take(5))
                    _LigneAuteur(
                      nom: e.key,
                      octets: e.value,
                      part: total == 0 ? 0 : e.value / total,
                    ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenMargin,
                DesignTokens.space5,
                DesignTokens.screenMargin,
                DesignTokens.space2,
              ),
              child: Row(
                children: [
                  Text(
                    l10n.sgFiles.toUpperCase(),
                    style: OuroTypography.caption1.copyWith(
                      color: OuroColors.secondaryLabel,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  _Bascule(
                    tri: _tri,
                    onChange: (t) {
                      OuroHaptics.selection();
                      setState(() => _tri = t);
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.screenMargin,
                0,
                DesignTokens.screenMargin,
                DesignTokens.space16,
              ),
              child: OuroListSection(
                separatorInset: 54,
                children: [
                  for (final p in pieces) _LignePiece(piece: p),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Bascule extends StatelessWidget {
  const _Bascule({required this.tri, required this.onChange});

  final _Tri tri;
  final ValueChanged<_Tri> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => onChange(tri == _Tri.recents ? _Tri.lourds : _Tri.recents),
      child: Text(
        tri == _Tri.recents ? l10n.sgSortRecent : l10n.sgSortHeavy,
        style: OuroTypography.footnote.copyWith(
          color: OuroColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LigneAuteur extends StatelessWidget {
  const _LigneAuteur({
    required this.nom,
    required this.octets,
    required this.part,
  });

  final String nom;
  final int octets;
  final double part;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.subheadline
                      .copyWith(color: OuroColors.label),
                ),
              ),
              Text(
                _StockageGroupeScreenState.poids(octets),
                style: OuroTypography.footnote
                    .copyWith(color: OuroColors.secondaryLabel),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: part.clamp(0, 1),
              minHeight: 4,
              backgroundColor: OuroColors.systemFill,
              valueColor: AlwaysStoppedAnimation<Color>(OuroColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _LignePiece extends StatelessWidget {
  const _LignePiece({required this.piece});

  final _Piece piece;

  IconData get _icone {
    final n = (piece.message.fileName ?? '').toLowerCase();
    if (n.endsWith('.pdf')) return Icons.picture_as_pdf_rounded;
    if (RegExp(r'\.(jpg|jpeg|png|gif|webp|heic)$').hasMatch(n)) {
      return Icons.photo_rounded;
    }
    if (RegExp(r'\.(mp4|mov|m4v|webm)$').hasMatch(n)) {
      return Icons.videocam_rounded;
    }
    if (RegExp(r'\.(m4a|mp3|aac|ogg|wav)$').hasMatch(n)) {
      return Icons.mic_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final m = piece.message;
    final langue = Localizations.localeOf(context).toLanguageTag();
    final nom = m.fileName ?? '—';
    final auteur = m.authorPseudo.trim().isEmpty ? l10n.imUnknown : m.authorPseudo;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final chemin = piece.chemin;
        if (chemin == null || !nom.toLowerCase().endsWith('.pdf')) return;
        OuroHaptics.light();
        ouvrirPdf(context, chemin, titre: nom);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OuroColors.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icone, size: 17, color: OuroColors.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.subheadline.copyWith(
                      color: piece.present
                          ? OuroColors.label
                          : OuroColors.tertiaryLabel,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '$auteur · ${DateFormat.MMMd(langue).format(m.timestamp)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.caption1
                        .copyWith(color: OuroColors.tertiaryLabel),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              piece.present
                  ? _StockageGroupeScreenState.poids(piece.octets)
                  : l10n.sgNotOnDevice,
              style: OuroTypography.caption1.copyWith(
                color: piece.present
                    ? OuroColors.secondaryLabel
                    : OuroColors.tertiaryLabel,
              ),
            ),
            if (MessagesImportants.estImportant(m.id)) ...[
              const SizedBox(width: 6),
              Icon(Icons.star_rounded, size: 13, color: OuroColors.accent),
            ],
          ],
        ),
      ),
    );
  }
}
