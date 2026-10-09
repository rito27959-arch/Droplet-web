// ============================================================================
// CE QUE DROPLET PRO APPORTE — le catalogue, en un seul endroit.
// ----------------------------------------------------------------------------
// La liste de l'écran Pro et l'écran d'explications lisent la MÊME source :
// un avantage ajouté ici apparaît aux deux endroits, avec le même mot, la
// même couleur et le même aperçu. Rien n'est plus pénible qu'une fonction
// qui s'appelle autrement selon l'écran où on la lit.
//
// ⚠️ ET POURTANT C'EST EXACTEMENT CE QUI ÉTAIT ARRIVÉ.
// L'écran Pro affichait DEUX listes l'une sous l'autre, tirées de deux
// catalogues différents : « Ce que Pro apporte » (ce fichier) et « Ce que
// le pack ouvre » (`fonctions_premium.dart`). Les mêmes six fonctions, deux
// fois, sous deux noms — « Vocaux en texte » ici, « Transcription » là —
// avec deux styles d'illustration et deux boutons qui ne faisaient pas la
// même chose. Les deux catalogues sont désormais fondus en un seul, et
// chaque avantage porte SON APERÇU : le vrai téléphone de Telegram, avec
// un vrai morceau de Droplet joué dedans.
//
// L'ORDRE COMPTE : les plus parlants d'abord. Personne ne fait défiler une
// liste de fonctions pour trouver la bonne.
//
// LA COULEUR N'EST PAS CHOISIE, ELLE EST CALCULÉE. Chaque ligne prend sa
// teinte sur le dégradé premium, selon sa place dans la liste (voir
// `couleurFonction`) : l'ensemble se lit comme un seul long dégradé
// découpé. C'est l'astuce de Telegram, et elle ne coûte rien à dessiner.
// ============================================================================

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'apercu_telephone.dart';
import 'fonctions_premium.dart';

class AvantagePro {
  const AvantagePro({
    required this.cle,
    required this.icone,
    required this.titre,
    required this.court,
    required this.long,
    required this.apercu,
  });

  /// Un nom stable, qui ne dépend d'aucune traduction — pour les clés de
  /// widget et le suivi d'usage.
  final String cle;

  final IconData icone;

  /// Le nom de l'avantage, dans la liste comme en tête de l'explication.
  final String Function(AppLocalizations) titre;

  /// Une ligne, sous le nom, dans la liste.
  final String Function(AppLocalizations) court;

  /// Le texte de l'écran d'explications : ce que ça change vraiment.
  final String Function(AppLocalizations) long;

  /// Ce qu'on voit quand on ouvre l'avantage : un vrai morceau de l'app,
  /// joué dans le téléphone dessiné. Pas une vidéo — donc rien à
  /// télécharger, et rien qui puisse mentir sur ce qu'on recevra.
  final Widget Function(double glissement, bool actif) apercu;
}

/// La couleur d'un avantage : sa place sur le dégradé premium.
Color couleurAvantage(int index) =>
    couleurFonction(index, avantagesPro().length);

/// ⚠️ CONSTRUITE UNE SEULE FOIS. L'écran d'explications lit la couleur de
/// l'avantage à chaque image pendant un glissement : reconstruire sept
/// objets soixante fois par seconde pour ça n'a aucun sens. Les entrées ne
/// retiennent que des fonctions de `AppLocalizations` — aucune langue,
/// aucun contexte n'est capturé — donc le cache reste valable quand la
/// langue change.
List<AvantagePro>? _cache;

List<AvantagePro> avantagesPro() => _cache ??= [
      AvantagePro(
        cle: 'vocaux',
        icone: Icons.graphic_eq_rounded,
        titre: (l) => l.avVoiceTitle,
        court: (l) => l.avVoiceShort,
        long: (l) => l.avVoiceLong,
        apercu: (g, actif) => ApercuTelephone(
          glissement: g,
          actif: actif,
          ecran: const ScenarioTranscription(),
        ),
      ),
      AvantagePro(
        cle: 'miseEnForme',
        icone: Icons.text_fields_rounded,
        titre: (l) => l.avFormatTitle,
        court: (l) => l.avFormatShort,
        long: (l) => l.avFormatLong,
        apercu: (g, actif) => ApercuTelephone(
          decale: 0.15,
          glissement: g,
          actif: actif,
          ecran: const ScenarioMiseEnForme(),
        ),
      ),
      AvantagePro(
        cle: 'fonds',
        icone: Icons.wallpaper_rounded,
        titre: (l) => l.avWallpaperTitle,
        court: (l) => l.avWallpaperShort,
        long: (l) => l.avWallpaperLong,
        apercu: (g, actif) => ApercuTelephone(
          decale: 0.3,
          glissement: g,
          actif: actif,
          ecran: const ScenarioFonds(),
        ),
      ),
      AvantagePro(
        cle: 'traduction',
        icone: Icons.translate_rounded,
        titre: (l) => l.avTranslateTitle,
        court: (l) => l.avTranslateShort,
        long: (l) => l.avTranslateLong,
        apercu: (g, actif) => ApercuTelephone(
          decale: 0.45,
          glissement: g,
          actif: actif,
          ecran: const ScenarioTraduction(),
        ),
      ),
      AvantagePro(
        cle: 'autocollants',
        icone: Icons.auto_awesome_rounded,
        titre: (l) => l.avStickersTitle,
        court: (l) => l.avStickersShort,
        long: (l) => l.avStickersLong,
        apercu: (g, actif) => ApercuTelephone(
          decale: 0.6,
          glissement: g,
          actif: actif,
          ecran: const ScenarioAutocollants(),
        ),
      ),
      AvantagePro(
        cle: 'icones',
        icone: Icons.apps_rounded,
        titre: (l) => l.avIconTitle,
        court: (l) => l.avIconShort,
        long: (l) => l.avIconLong,
        apercu: (g, actif) => ApercuTelephone(
          decale: 0.75,
          glissement: g,
          actif: actif,
          ecran: const ScenarioIcones(),
        ),
      ),
      AvantagePro(
        cle: 'badge',
        icone: Icons.workspace_premium_rounded,
        titre: (l) => l.avBadgeTitle,
        court: (l) => l.avBadgeShort,
        long: (l) => l.avBadgeLong,
        apercu: (g, actif) => ApercuTelephone(
          decale: 0.9,
          glissement: g,
          actif: actif,
          ecran: const ScenarioBadge(),
        ),
      ),
    ];
