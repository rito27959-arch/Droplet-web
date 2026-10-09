// ============================================================================
// L'ASSISTANT — les quatre fonctions qui décident de ce qu'on voit.
// ----------------------------------------------------------------------------
// Toutes les quatre sont des analyseurs de texte, et un analyseur de texte
// casse en silence : il ne lève pas d'exception, il rend simplement un
// résultat légèrement faux, que personne ne remarque avant des semaines.
//
// ⚠️ CHAQUE CAS CI-DESSOUS A ÉTÉ UN BUG. Ce ne sont pas des exemples
// choisis pour passer : `***` devenait une astérisque orpheline,
// `snake_case_nom` perdait ses tirets bas, un bloc de code non fermé
// créait un artéfact qui se dédoublait. Les retirer, c'est rouvrir la
// porte à chacun d'eux.
// ============================================================================

import 'package:droplet/core/services/artefacts_store.dart';
import 'package:droplet/core/services/outils_assistant.dart';
import 'package:droplet/features/ai/actions_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Markdown vers texte brut', () {
    void verifie(String entree, String attendu, String pourquoi) {
      test(pourquoi, () => expect(enTextePlat(entree), attendu));
    }

    verifie('## Titre\n\nDu **gras** et de l\'*italique*.',
        'Titre\n\nDu gras et de l\'italique.', 'titres et emphase');
    verifie('- un\n- deux\n  - trois', '• un\n• deux\n  • trois',
        'les puces gardent leur retrait');
    verifie('Voir [la doc](https://ex.com/a).',
        'Voir la doc (https://ex.com/a).', 'un lien garde son adresse');
    verifie('Voir [https://ex.com](https://ex.com).',
        'Voir https://ex.com.', 'un lien dont le libellé EST l\'adresse');
    verifie('```dart\nfinal x = 1;\n```', 'final x = 1;',
        'un bloc de code perd ses clôtures, pas son contenu');
    verifie('> Une citation\n> sur deux lignes',
        'Une citation\nsur deux lignes', 'les citations');
    verifie('---\n\nAprès le filet', 'Après le filet', 'un filet en tirets');

    // ⚠️ CELUI-CI A ÉTÉ UN BUG : la règle d'italique passait avant celle
    // du filet, et `***` devenait une astérisque solitaire.
    verifie('***\n\nAstérisques', 'Astérisques',
        'un filet en astérisques ne laisse rien derrière');
    verifie('___\n\nTirets bas', 'Tirets bas', 'un filet en tirets bas');

    // ⚠️ ET CELUI-LÀ AUSSI : sans borne de mot, `_case_` était lu comme
    // une italique au milieu d'un identifiant.
    verifie('snake_case_nom reste entier', 'snake_case_nom reste entier',
        'un identifiant garde ses tirets bas');
    verifie('a__b__c reste entier', 'a__b__c reste entier',
        'un double tiret bas au milieu d\'un mot');
    verifie('5 * 3 = 15 et 2 * 4 = 8', '5 * 3 = 15 et 2 * 4 = 8',
        'une multiplication n\'est pas une italique');
    verifie('Le `kGroqModele` vaut `openai/gpt-oss-120b`.',
        'Le kGroqModele vaut openai/gpt-oss-120b.', 'le code en ligne');
    verifie('~~barré~~ et normal', 'barré et normal', 'le barré');
    verifie('Rien à faire ici.', 'Rien à faire ici.', 'du texte sans balise');
    verifie('', '', 'une chaîne vide');
  });

  group('Les citations de la recherche web', () {
    test('une citation sort du texte et devient un renvoi', () {
      final r = extraireCitations(
        'Le PIB a crû de 3 %【Banque mondiale†https://wb.org/a】 '
        'cette année.',
      );
      expect(r.texte, 'Le PIB a crû de 3 %[1] cette année.');
      expect(r.citations, hasLength(1));
      expect(r.citations.first.url, 'https://wb.org/a');
    });

    test('la même source citée deux fois garde un seul numéro', () {
      final r = extraireCitations(
        'A【S1†https://a.com】 puis B【S2†https://b.com】 '
        'puis A【S1†https://a.com】.',
      );
      expect(r.texte, 'A[1] puis B[2] puis A[1].');
      expect(r.citations, hasLength(2));
    });

    test('des crochets ASCII ne sont pas touchés', () {
      const brut = 'Une référence [1] écrite à la main.';
      final r = extraireCitations(brut);
      expect(r.texte, brut);
      expect(r.citations, isEmpty);
    });

    test('une citation sans adresse garde son titre', () {
      final r = extraireCitations('Voir【Un titre†L12-L18】.');
      expect(r.citations.single.titre, 'Un titre');
      expect(r.citations.single.url, isEmpty);
    });

    test('un marqueur jamais refermé est laissé tel quel', () {
      const brut = 'Fermeture manquante 【oups sans fin';
      expect(extraireCitations(brut).texte, brut);
    });
  });

  group('Les blocs de code détectés', () {
    test('un bloc fermé est reconnu avec son langage', () {
      final b = detecterBlocs('Voici :\n\n```python\nprint(1)\n```\n');
      expect(b, hasLength(1));
      expect(b.single.langage, 'python');
      expect(b.single.contenu, 'print(1)');
    });

    // ⚠️ PENDANT QUE LA RÉPONSE S'ÉCRIT, le dernier bloc n'a pas encore sa
    // clôture. Le sortir tout de suite créerait un artéfact qui grandit
    // puis se dédouble quand le vrai arrive.
    test('un bloc non fermé est ignoré', () {
      expect(detecterBlocs('```python\nprint(1)\n'), isEmpty);
    });

    test('trois accents en ligne ne sont pas un bloc', () {
      expect(detecterBlocs('du texte ``` en ligne ``` sans saut'), isEmpty);
    });

    test('le langage décide du genre', () {
      expect(detecterBlocs('```html\n<p>a</p>\n```').single.genre,
          GenreArtefact.page);
      expect(detecterBlocs('```mermaid\ngraph TD\n```').single.genre,
          GenreArtefact.schema);
      expect(detecterBlocs('```csv\na,b\n```').single.genre,
          GenreArtefact.donnees);
      expect(detecterBlocs('```rust\nfn a(){}\n```').single.genre,
          GenreArtefact.code);
    });
  });

  group('Le seuil qui sort du fil', () {
    test('trois lignes de code restent dans la conversation', () {
      expect(
        meriteArtefact(contenu: 'print(1)', genre: GenreArtefact.code),
        isFalse,
      );
    });

    test('vingt lignes de code en sortent', () {
      final long = List.generate(20, (i) => 'ligne $i').join('\n');
      expect(
        meriteArtefact(contenu: long, genre: GenreArtefact.code),
        isTrue,
      );
    });

    test('une page web sort même courte : on veut la VOIR', () {
      expect(
        meriteArtefact(contenu: '<p>a</p>', genre: GenreArtefact.page),
        isTrue,
      );
    });

    test('un long paragraphe d\'un seul tenant reste dans le fil', () {
      expect(
        meriteArtefact(contenu: 'x' * 800, genre: GenreArtefact.document),
        isFalse,
      );
    });
  });
}
