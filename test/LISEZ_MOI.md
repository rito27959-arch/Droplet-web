# Les tests de Droplet

## Ce qu'il y a ici

| Fichier | Ce qu'il verrouille |
| --- | --- |
| `contraste_test.dart` | Les dix accents à 4,5:1 dans les deux modes, les quatre paliers de texte, et la formule WCAG elle-même |
| `assistant_test.dart` | Markdown → texte brut, citations web, blocs de code, seuil d'artéfact |

Chaque cas de `assistant_test.dart` **a été un vrai bug**. Ce ne sont pas des
exemples choisis pour passer : `***` devenait une astérisque orpheline,
`snake_case_nom` perdait ses tirets bas, un bloc de code non fermé créait un
artéfact qui se dédoublait ensuite. Les retirer rouvre la porte à chacun.

## ⚠️ Trois fichiers à supprimer

Ils testent du code renommé ou supprimé depuis, et ils font échouer
`flutter analyze` à eux seuls :

```
rm test/discussions_finition_test.dart   # features/chat/document_bubble.dart n'existe plus
rm test/fonctions_premium_test.dart      # FonctionPremium → AvantagePro
rm -r test/_tmp                          # ListeFonctionsPremium, disparu avec la refonte Pro
```

Les réécrire serait possible pour le second (`avantagesPro()` remplace
`fonctionsPremium()`), pas pour le premier : la bulle de document a disparu
sans remplaçant identifiable.

## ⚠️ Et un fichier à la racine du dépôt

`mise_en_forme.dart`, à la racine, importe `/home/effi/Musique/c/droplet/…`
— des chemins absolus d'une autre machine, vers des fichiers absents. Rien
dans `lib/` ne peut l'importer (ses chemins relatifs pointent hors du dépôt).
`flutter analyze` le ramasse uniquement parce qu'il traîne là.

```
rm mise_en_forme.dart
```

## Lancer

```
flutter test
```

Ce qui n'est PAS couvert, et qui devrait l'être un jour : les tests de
capture d'écran sur les quinze écrans principaux, en français, en allemand
et en anglais à la plus grande taille de texte. C'est la deuxième ligne du
plan de l'audit, et elle reste ouverte.
