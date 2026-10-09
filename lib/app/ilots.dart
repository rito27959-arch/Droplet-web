// LES ÎLOTS — les listes groupées d'iOS (Réglages, Infos) : un titre gris
// en petites capitales, un bloc arrondi, des lignes séparées par des traits
// décalés après l'icône. À la souris, la ligne s'éclaire au survol.
import 'package:flutter/material.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import 'composants.dart';

class TitreIlot extends StatelessWidget {
  const TitreIlot(this.texte, {super.key});

  final String texte;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
        child: Text(texte.toUpperCase(), style: OuroTypography.sectionHeader.copyWith(color: OuroColors.secondaryLabel)),
      );
}

/// Un îlot de lignes, séparées par des traits décalés comme dans iOS.
class Ilot extends StatelessWidget {
  const Ilot({super.key, required this.enfants, this.fond});

  final List<Widget> enfants;

  /// Le fond de l'îlot (par défaut, le gris clair des listes groupées).
  final Color? fond;

  @override
  Widget build(BuildContext context) {
    final lignes = enfants.whereType<Widget>().toList();
    if (lignes.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: fond ?? OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < lignes.length; i++) ...[
            if (i > 0) Padding(padding: const EdgeInsets.only(left: 56), child: Divider(height: 0.5, thickness: 0.5, color: OuroColors.separator)),
            lignes[i],
          ],
        ],
      ),
    );
  }
}

class LigneIlot extends StatelessWidget {
  const LigneIlot({
    super.key,
    required this.titre,
    this.sousTitre,
    this.icone,
    this.couleurIcone,
    this.couleurTitre,
    this.valeur,
    this.fin,
    this.debut,
    this.onTap,
    this.lignesTitre = 1,
  });

  final String titre;
  final String? sousTitre;
  final IconData? icone;
  final Color? couleurIcone;
  final Color? couleurTitre;
  final String? valeur;
  final Widget? fin;
  final Widget? debut;
  final VoidCallback? onTap;
  final int lignesTitre;

  @override
  Widget build(BuildContext context) {
    return Survol(
      onTap: onTap,
      builder: (context, survol) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        color: survol && onTap != null ? OuroColors.label.withValues(alpha: 0.04) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            if (debut != null) ...[debut!, const SizedBox(width: 12)] else if (icone != null) ...[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: couleurIcone ?? OuroColors.systemGray, borderRadius: BorderRadius.circular(8)),
                child: Icon(icone, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    maxLines: lignesTitre,
                    overflow: TextOverflow.ellipsis,
                    style: OuroTypography.body.copyWith(color: couleurTitre ?? OuroColors.label),
                  ),
                  if (sousTitre != null)
                    Text(
                      sousTitre!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
                    ),
                ],
              ),
            ),
            if (valeur != null) ...[
              const SizedBox(width: 8),
              Text(valeur!, style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel)),
            ],
            if (fin != null) fin! else if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: OuroColors.tertiaryLabel, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

