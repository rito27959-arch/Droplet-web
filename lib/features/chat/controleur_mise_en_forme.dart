// ============================================================================
// LA BARRE DE SAISIE QUI MONTRE CE QU'ON ÉCRIT.
// ----------------------------------------------------------------------------
// Jusqu'ici, écrire `**demain**` affichait `**demain**` : on ne voyait le gras
// qu'une fois le message parti. Ce contrôleur peint le champ comme la bulle :
// le gras est gras, le spoiler est voilé, le code est à chasse fixe — et les
// marqueurs, eux, s'effacent presque (ils restent dans le texte, puisque c'est
// ce texte-là qui traverse le mesh, mais ils ne sautent plus aux yeux).
//
// ⚠️ LA COMPOSITION DU CLAVIER EST PRÉSERVÉE. Sur Android, le mot en cours de
// frappe est « en composition » et doit rester souligné : sans ça, la
// correction automatique et les claviers asiatiques deviennent illisibles.
// ============================================================================

part of 'mise_en_forme.dart';

class ControleurMiseEnForme extends TextEditingController {
  ControleurMiseEnForme({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = style ?? const TextStyle();
    final brut = text;
    if (brut.isEmpty || !MiseEnForme._regex.hasMatch(brut)) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    // Un style par caractère : le plus simple moyen de gérer les marqueurs,
    // le contenu et la composition du clavier sans se marcher dessus.
    final styles = List<TextStyle>.filled(brut.length, base);
    final marqueur = base.copyWith(
      color: (base.color ?? OuroColors.label).withValues(alpha: 0.30),
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      decoration: TextDecoration.none,
    );

    void poser(int debut, int fin, TextStyle applique) {
      for (var i = math.max(0, debut); i < fin && i < styles.length; i++) {
        styles[i] = applique;
      }
    }

    for (final m in MiseEnForme._regex.allMatches(brut)) {
      final Formatage format;
      int ouvre;
      int ferme;
      if (m.group(1) != null) {
        format = Formatage.bloc;
        ouvre = 3;
        ferme = 3;
      } else if (m.group(2) != null) {
        format = Formatage.code;
        ouvre = 1;
        ferme = 1;
      } else if (m.group(3) != null) {
        format = Formatage.gras;
        ouvre = 2;
        ferme = 2;
      } else if (m.group(4) != null) {
        format = Formatage.italique;
        ouvre = 2;
        ferme = 2;
      } else if (m.group(5) != null) {
        format = Formatage.souligne;
        ouvre = 2;
        ferme = 2;
      } else if (m.group(6) != null) {
        format = Formatage.barre;
        ouvre = 2;
        ferme = 2;
      } else if (m.group(7) != null) {
        format = Formatage.spoiler;
        ouvre = 2;
        ferme = 2;
      } else if (m.group(8) != null) {
        // `[texte](adresse)` : seul le texte se voit, l'adresse s'efface.
        format = Formatage.lien;
        ouvre = 1;
        ferme = m.end - (m.start + 1 + m.group(8)!.length);
      } else {
        continue;
      }
      final debutContenu = m.start + ouvre;
      final finContenu = m.end - ferme;
      poser(m.start, debutContenu, marqueur);
      poser(finContenu, m.end, marqueur);
      poser(debutContenu, finContenu, _styleSaisie(format, base));
    }

    if (withComposing &&
        value.isComposingRangeValid &&
        !value.composing.isCollapsed) {
      final souligne = <TextStyle, TextStyle>{};
      final fin = math.min(value.composing.end, styles.length);
      for (var i = math.max(0, value.composing.start); i < fin; i++) {
        styles[i] = souligne.putIfAbsent(
          styles[i],
          () => styles[i].merge(
            const TextStyle(decoration: TextDecoration.underline),
          ),
        );
      }
    }

    // On recolle les caractères qui partagent le même style.
    final enfants = <TextSpan>[];
    var debut = 0;
    for (var i = 1; i <= brut.length; i++) {
      if (i == brut.length || !identical(styles[i], styles[debut])) {
        enfants.add(TextSpan(
          text: brut.substring(debut, i),
          style: styles[debut],
        ));
        debut = i;
      }
    }
    return TextSpan(style: base, children: enfants);
  }

  /// Le style du champ : celui de la bulle, plus un fond discret là où la
  /// bulle dessine autre chose (le voile d'un spoiler, le bloc de code).
  static TextStyle _styleSaisie(Formatage format, TextStyle base) {
    final applique = MiseEnForme._style(format, base);
    final encre = base.color ?? OuroColors.label;
    return switch (format) {
      Formatage.spoiler => applique.copyWith(
          backgroundColor: encre.withValues(alpha: 0.18),
        ),
      Formatage.code || Formatage.bloc => applique.copyWith(
          backgroundColor: encre.withValues(alpha: 0.10),
        ),
      Formatage.lien => applique.copyWith(color: OuroColors.accent),
      _ => applique,
    };
  }
}
