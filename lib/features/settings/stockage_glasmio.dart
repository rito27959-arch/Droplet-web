// ============================================================================
// LE STOCKAGE EN GLASMIO (Android 13+). Même analyse et même suppression que
// `StockageScreen` (l'écran de repli) : l'espace utilisé, sa répartition par
// genre, le classement des discussions ; puis, dans une discussion, la grille
// des fichiers à cocher et la suppression (avec confirmation).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notification_service.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../design_system/ouro_colors.dart';
import '../../shared/taille_lisible.dart';
import 'stockage_screen.dart';

const _clesIcones = {
  GenreStockage.photo: 'image',
  GenreStockage.video: 'videocam',
  GenreStockage.audio: 'graphic_eq',
  GenreStockage.document: 'description',
  GenreStockage.autre: 'folder',
};

class PasserelleStockage extends ConsumerStatefulWidget {
  const PasserelleStockage({super.key});

  @override
  ConsumerState<PasserelleStockage> createState() => _PasserelleStockageState();
}

class _PasserelleStockageState extends EtatPasserelleGlasmio<PasserelleStockage> {
  List<DiscussionStockage>? _discussions;

  /// La discussion ouverte (second niveau), ou `null` pour le résumé.
  DiscussionStockage? _ouverte;
  final Set<FichierStockage> _choisis = {};

  @override
  String get ecran => 'stockage';

  @override
  Widget construireRepli(BuildContext context) => const StockageScreen();

  @override
  void surOuvert() {
    // L'analyse lit le disque : elle se fait une fois l'écran ouvert, puis
    // l'écran se redessine avec le résultat.
    if (_discussions == null) {
      analyserStockage(ref, textes).then((l) {
        _discussions = l;
        rafraichir();
      });
    }
  }

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final t = textes;
    final d = _ouverte;
    switch (id) {
      case 'remonter':
        _ouverte = null;
        _choisis.clear();
      case 'tout':
        if (d != null) {
          _choisis.length == d.fichiers.length ? _choisis.clear() : _choisis.addAll(d.fichiers);
        }
      case 'supprimer':
        if (_choisis.isEmpty) break;
        return ReponseGlasmio.alerte({
          'titre': t.stoDeleteConfirm,
          'confirmer': t.actionDelete,
          'annuler': t.actionCancel,
          'destructif': true,
          'id': 'supprimer_confirme',
        });
      case 'supprimer_confirme':
        if (d != null) {
          await supprimerFichiersStockage(ref, d, _choisis);
          _choisis.clear();
          _discussions = await analyserStockage(ref, t);
          // La discussion vidée disparaît du classement.
          if (d.fichiers.isEmpty) _ouverte = null;
        }
      default:
        final liste = _discussions ?? const [];
        if (id.startsWith('discussion:')) {
          final i = int.tryParse(id.substring(11)) ?? -1;
          if (i >= 0 && i < liste.length) _ouverte = liste[i];
        } else if (id.startsWith('fichier:') && d != null) {
          final i = int.tryParse(id.substring(8)) ?? -1;
          if (i >= 0 && i < d.fichiers.length) {
            final f = d.fichiers[i];
            if (!_choisis.remove(f)) _choisis.add(f);
          }
        }
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  static int _c(Color c) => c.toARGB32();

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final base = {
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': _c(OuroColors.accent),
    };
    final d = _ouverte;

    // ── Second niveau : les fichiers d'une discussion ──────────────────
    if (d != null) {
      final taille = d.fichiers.where(_choisis.contains).fold(0, (s, f) => s + f.taille);
      final tous = d.fichiers.isNotEmpty && _choisis.length == d.fichiers.length;
      return {
        ...base,
        'titre': d.nom,
        'retourId': 'remonter',
        'sections': [
          {
            'lignes': [
              {'id': 'tout', 'type': 'bouton', 'titre': tous ? MaterialLocalizations.of(context).cancelButtonLabel : MaterialLocalizations.of(context).selectAllButtonLabel},
            ],
          },
          {
            'grille': [
              for (var i = 0; i < d.fichiers.length; i++)
                {
                  'id': 'fichier:$i',
                  if (d.fichiers[i].genre == GenreStockage.photo) 'chemin': d.fichiers[i].fichier.path,
                  'icone': _clesIcones[d.fichiers[i].genre],
                  'teinte': _c(couleurGenre(d.fichiers[i].genre)),
                  'legende': tailleLisible(d.fichiers[i].taille),
                  'coche': _choisis.contains(d.fichiers[i]),
                },
            ],
          },
        ],
        if (_choisis.isNotEmpty)
          'bas': {'id': 'supprimer', 'titre': '${t.stoDelete(_choisis.length)} · ${tailleLisible(taille)}', 'destructif': true},
      };
    }

    // ── Premier niveau : le résumé et le classement ────────────────────
    final liste = _discussions;
    if (liste == null || liste.isEmpty) {
      return {
        ...base,
        'titre': t.stoTitle,
        'sections': [
          {'pied': liste == null ? '…' : t.stoEmpty, 'lignes': <Object>[]},
        ],
      };
    }
    final parGenre = <GenreStockage, int>{};
    for (final x in liste) {
      for (final f in x.fichiers) {
        parGenre[f.genre] = (parGenre[f.genre] ?? 0) + f.taille;
      }
    }
    final total = parGenre.values.fold(0, (s, v) => s + v);
    final genres = GenreStockage.values.where((g) => (parGenre[g] ?? 0) > 0).toList();
    return {
      ...base,
      'titre': t.stoTitle,
      'vitrine': {
        'icone': 'pie_chart',
        'teinte': _c(OuroColors.systemIndigo),
        'titre': t.stoUsed(tailleLisible(total)),
        'segments': [
          for (final g in genres) {'teinte': _c(couleurGenre(g)), 'part': total == 0 ? 0 : parGenre[g]! / total},
        ],
      },
      'sections': [
        {
          'lignes': [
            for (final g in genres)
              {
                'id': 'genre:${g.name}',
                'type': 'info',
                'icone': _clesIcones[g],
                'teinte': _c(couleurGenre(g)),
                'titre': libelleGenre(t, g),
                'valeur': tailleLisible(parGenre[g]!),
              },
          ],
        },
        {
          'entete': t.stoByChat,
          'lignes': [
            for (var i = 0; i < liste.length; i++)
              {
                'id': 'discussion:$i',
                'type': 'nav',
                'icone': liste[i].cle == '_autres' ? 'folder' : 'lettre:${liste[i].nom.characters.isEmpty ? '?' : liste[i].nom.characters.first.toUpperCase()}',
                'teinte': liste[i].cle == '_autres'
                    ? _c(OuroColors.systemGray)
                    : NotificationService.couleurAvatar(liste[i].nom),
                'titre': liste[i].nom,
                'sous': '${liste[i].fichiers.length} · ${tailleLisible(liste[i].taille)}',
              },
          ],
        },
      ],
    };
  }
}
