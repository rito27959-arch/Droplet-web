# 50 améliorations esthétiques pour Droplet

Chaque point vient d'un **audit du code**, pas d'une impression générale.
Les chiffres entre parenthèses sont des mesures faites sur `lib/` ; les
références `fichier:ligne` sont vérifiables.

L'ordre compte : **les quinze premiers se voient dès la première minute
d'utilisation**. Les suivants se voient à l'usage, et les derniers ne se
voient jamais consciemment — ce sont ceux qui font dire « c'est propre »
sans qu'on sache pourquoi.

---

## A. Ce qui se voit tout de suite

### 1. Les brouillons ne sont pas gardés par conversation
**Vérifié : aucun mécanisme de brouillon dans tout le projet.** Quitter une
conversation en pleine phrase perd la phrase. C'est la frustration la plus
banale d'une messagerie, et celle qu'on ressent le plus souvent : on va
vérifier une information dans un autre fil, on revient, et le texte a
disparu. Une entrée par conversation dans le magasin de réglages, restaurée
à l'ouverture, suffit.

### 2. Les images apparaissent d'un coup
23 `Image.file` / `Image.memory` / `Image.network` dans `lib/features`, et
**4 seulement** ont un `frameBuilder`. Les autres surgissent à la
milliseconde où le décodage finit. Un fondu de 150 ms suffit à transformer
un à-coup en apparition.

### 3. Un blanc en dur sur un accent réglable
363 `Colors.white` dans `lib/features` et `lib/shared`. Trois ont déjà été
corrigés dans cette session (bouton « 1 », bouton de lecture vocal, icône
du cercle) — et chaque fois le symptôme était le même : **avec un accent
clair, menthe ou jaune, le contenu disparaît**. `OuroColors.texteSurAccent`
existe pour ça. À passer en revue systématiquement.

### 4. 197 couleurs écrites en hexadécimal brut
`Color(0xFF…)` dans les écrans, hors du système. Chacune est une couleur
qui ne suivra ni le thème sombre, ni le changement d'accent, ni un futur
réglage de contraste. Toutes ne sont pas des erreurs — un dégradé
décoratif a le droit d'être fixe — mais 197 mérite un tri.

### 5. Dix rayons d'arrondi différents
`BorderRadius.circular()` avec 20, 16, 14, 12, 10, 9, 8, 6, 3, 30… Aucune
échelle. L'œil ne compte pas les rayons, mais il sent qu'il y en a trop :
l'ensemble paraît assemblé plutôt que dessiné. Trois valeurs suffisent
(petit, moyen, grand) plus le plein arrondi.

### 6. Le cercle d'enregistrement ne se transforme pas en onde
Chez Telegram, une fois verrouillé, le gros cercle se métamorphose en forme
d'onde dans la barre de saisie (`RECORD_STATE_PREPARING`, 580 ms en trois
sous-étapes). Chez nous il reste un gros disque bleu. **C'est l'écart le
plus net avec Telegram aujourd'hui**, maintenant que le reste du geste est
fidèle.

### 7. Aucun retour visuel d'appui sur la moitié des cibles
402 `onTap` pour 261 appels à `OuroHaptics`. Un bouton qui ne fait rien
sous le doigt donne l'impression d'un appui raté, et on réappuie.

### 8. 59 cibles tactiles plus petites que 44 points
Sous 44 points, on vise. Au-dessus, on touche. C'est la seule règle
d'ergonomie tactile qui ne souffre aucune exception, et une zone tactile
peut être plus grande que son dessin.

### 9. Les listes ne rebondissent pas toutes pareil
3 déclarations de `ScrollPhysics` pour 21 listes. Certaines rebondissent,
d'autres s'arrêtent net, selon la plateforme. Dans une même application,
c'est une incohérence qu'on ressent sans la nommer.

### 10. 200 tailles de police écrites à la main
`fontSize: 13`, `fontSize: 15`, `fontSize: 17`… à côté de 461 usages
corrects d'`OuroTypography`. Les 200 restants sont autant de textes qui ne
suivront pas un futur réglage de taille.

### 11. Les avatars de profil manquent à 13 endroits
`PeerAvatar` sans `imagePath` : le widget affiche alors les initiales, en
silence. Liste complète produite par `avatars.py`. **Déjà signalé, toujours
ouvert.**

### 12. Pas d'accusé visuel quand une photo finit de se téléverser
Un média en cours d'envoi et un média envoyé se ressemblent. Un voile qui
se lève, ou un cercle de progression sur la vignette, suffit.

### 13. Le séparateur de jour ne reste pas collé en haut
⚠️ **Correction d'une erreur de ma part** : j'avais d'abord écrit qu'il
n'existait pas. Il existe — `_DaySeparator` (`chat_screen.dart:4738`),
inséré ligne 4479 et rendu ligne 3872, avec « Aujourd'hui », « Hier » et
les jours de la semaine. Ce qui manque est plus fin : il **défile avec le
contenu** au lieu de rester épinglé en haut. Dans un fil long, on perd donc
la date dès qu'on a dépassé le séparateur — c'est-à-dire pendant presque
tout le temps où l'on remonte. Un `SliverPersistentHeader` épinglé règle
ça.

### 14. Aucun aperçu de lien pour les domaines connus
`_LinkPreviewCard` existe et affiche le domaine et une icône, sans titre ni
image. Pour un réseau hors ligne, aller chercher la métadonnée est exclu —
mais **une table locale des cinquante domaines les plus courants** (nom
propre, couleur, icône) donnerait 90 % du résultat sans une requête.

### 15. Le fil ne dit pas où l'on en était
Il y a un `_BarreNonLus`, mais pas de repère persistant « nouveaux
messages » qui reste en place pendant qu'on lit.

---

## B. La cohérence du système

### 16. Trois durées d'animation pour le même geste
220, 240, 250, 180, 200, 420 ms selon l'écran. Un mouvement de même nature
doit avoir la même durée partout : c'est ce qui fait qu'une application
« a un rythme ».

### 17. Les courbes aussi sont dispersées
Il existe `DesignTokens.curveEnter` ; l'adopter partout plutôt que des
`Curves.easeOut` disséminés.

### 18. Un seul fichier d'états vides
`Center(child: Text(...))` pour tout dire. Chaque état vide mérite un
dessin, une phrase et, quand c'est possible, **une action**. Un écran vide
qui ne propose rien est un cul-de-sac.

### 19. Les séparateurs ne font pas tous 0,5 point
Un filet d'un point est visible comme un trait ; un filet d'un demi-point
est visible comme une limite. C'est toute la différence entre « bordure »
et « séparation ».

### 20. Les ombres ne viennent pas d'une échelle commune
Plusieurs `BoxShadow` ad hoc. Trois niveaux suffisent — posé, flottant,
modal — et l'ombre doit s'assombrir ET s'élargir ensemble, jamais l'un
sans l'autre.

### 21. Les espacements internes ne suivent pas la grille
`DesignTokens.spaceN` existe, mais beaucoup de `EdgeInsets` sont écrits en
nombres bruts. Une grille de 4 points respectée partout est invisible et
irremplaçable.

### 22. Les icônes mélangent les familles
`Icons.x_rounded` et `Icons.x_outlined` coexistent. Une seule famille, sur
toute l'application.

### 23. Les tailles d'icônes sont libres
`DesignTokens.iconSm/Md/Lg` existent ; les `size: 18`, `size: 22`, `size:
23` écrits à la main les contournent.

### 24. Deux styles de feuille modale
`FrostedSheet` (verre) et des `showModalBottomSheet` opaques. Choisir.

### 25. Le poids des polices varie sans règle
`w500`, `w600`, `w700` apparaissent dans des contextes équivalents. Deux
graisses suffisent : normale et accentuée.

---

## C. Le mouvement

### 26. Rien ne s'anime à l'entrée d'une liste
Les éléments apparaissent déjà en place. Un décalage de 20 points avec un
fondu, échelonné de 20 ms par ligne sur les six premières, donne
l'impression que la liste « se pose ».

### 27. Les changements de compteur sautent
Un badge qui passe de 2 à 3 devrait faire glisser son chiffre, comme le
chrono d'enregistrement le fait déjà. Le composant existe (`_Chiffre`), il
suffit de le généraliser.

### 28. Aucune transition partagée entre une vignette et son plein écran
7 `Hero` dans toute l'application. Une photo qui s'agrandit depuis sa
vignette est le détail qui sépare une galerie d'un visualiseur.

### 29. Les écrans entrent tous de la même façon
Une navigation latérale pour aller « plus loin », une feuille montante pour
une tâche ponctuelle : la direction du mouvement devrait dire ce qui se
passe.

### 30. Les suppressions disparaissent sans se replier
Un élément retiré doit laisser sa place se refermer. Le code existe pour la
transition d'envoi (`SizeTransition` inversé) ; à réutiliser.

### 31. Le clavier et le contenu ne bougent pas ensemble
À vérifier au doigt : si le contenu rattrape le clavier avec un décalage,
c'est un `AnimatedPadding` mal synchronisé — la correction tient en une
courbe et une durée.

### 32. Pas de « squelette » pendant les chargements
Une roue qui tourne dit « attends ». Un squelette aux formes du contenu
attendu dit « voilà ce qui arrive », et le temps paraît deux fois plus
court.

### 33. Les 33 usages de `bouclerSiAmbiant` sont une bonne pratique à étendre
L'application sait déjà couper ses boucles quand le système demande moins
d'animations. À appliquer aux nouvelles : gouttes du cercle, respiration du
cadenas.

### 34. Rien ne se passe quand on tire une liste au-delà de sa fin
L'étirement élastique est gratuit et donne la matière.

### 35. Les bascules d'onglet ne glissent pas
Un onglet qui change de contenu sans mouvement latéral perd l'information
« je vais à droite ».

---

## D. La lecture du fil

### 36. Les bulles d'une même minute devraient se grouper plus serré
Le groupage existe (`message_grouping.dart`) ; vérifier que l'espacement
intra-groupe est bien inférieur à l'inter-groupe, c'est ce qui crée le
rythme vertical.

### 37. L'heure devrait disparaître sur les messages groupés
Sauf le dernier de la série. Répéter 14:32 six fois n'informe pas.

### 38. Les messages très courts méritent une largeur minimale
Une bulle de deux caractères avec l'heure dedans est plus large que haute
et paraît cassée.

### 39. Les citations de réponse devraient porter la couleur de leur auteur
En groupe, c'est ce qui permet de suivre un fil de réponses sans lire les
noms.

### 40. Les liens dans une bulle envoyée doivent rester lisibles
Un bleu de lien sur un fond accent bleu est un piège classique.

### 41. Le texte sélectionné n'a pas de couleur propre
Par défaut, Flutter prend l'accent — qui est aussi la couleur de la bulle
envoyée. La sélection y devient invisible.

### 42. Les émojis seuls devraient être plus grands
La taille existe (`stickerFontSize`) ; vérifier le seuil — un à trois
émojis sans texte, pas plus.

---

## E. L'accessibilité, qui est aussi de l'esthétique

### 43. Seuls 29 fichiers sur 127 déclarent des `Semantics`
Un lecteur d'écran y annonce « bouton » sans dire lequel. Ce n'est pas une
case à cocher réglementaire : une application qui se laisse lire à voix
haute est une application dont la structure est propre.

### 44. 4 usages de `textScaler` seulement
Quand quelqu'un agrandit le texte du système, la plupart des écrans ne
suivent pas, ou débordent. À tester à 200 %.

### 45. Les contrastes ne sont pas vérifiés automatiquement
`verifie_contraste.py` existe dans les outils ; l'étendre à toutes les
paires texte/fond du système et l'exécuter à chaque changement de palette.

### 46. L'ordre de focus clavier n'est défini nulle part
Sur un téléphone avec clavier physique, ou sur une tablette, l'ordre de
tabulation est celui de l'arbre — rarement celui qu'on lit.

---

## F. Les finitions invisibles

### 47. Deux fichiers orphelins traînent
`recent_media_strip.dart` (plus aucun appelant depuis la nouvelle feuille
de pièces jointes) et le doublon `lib/mise_en_forme.dart`. **À vérifier
avant suppression** — j'ai déjà eu tort une fois sur ce point.

### 48. Les coins du contenu ne sont pas tous rognés
`clipBehavior` manquant sur certains conteneurs arrondis : le contenu
dépasse d'un pixel dans l'angle, ce qui se voit surtout sur les images.

### 49. Les dégradés n'ont pas d'interpolation corrigée
Un dégradé de deux couleurs vives passe par un gris sale au milieu en
espace sRVB. Interpoler en OKLab coûte quelques lignes et supprime la zone
morte.

### 50. L'icône d'application et l'écran de lancement doivent se raccorder
L'écran de démarrage doit porter exactement la même marque, à la même
place, pour que l'ouverture paraisse continue plutôt que successive. C'est
le tout premier dixième de seconde de l'application, et c'est celui qu'on
oublie de dessiner.

---

## Par quoi commencer

Si vous ne deviez en faire que cinq, dans cet ordre :

1. **les brouillons par conversation** (n° 1) — le seul point de cette
   liste qui fait perdre quelque chose à l'utilisateur ;
2. **le fondu des images** (n° 2) — une ligne par image, effet immédiat ;
3. **l'échelle des rayons** (n° 5) — rend l'ensemble dessiné plutôt
   qu'assemblé ;
4. **la transformation du cercle en onde** (n° 6) — le dernier écart avec
   Telegram ;
5. **les 44 points de cible tactile** (n° 8) — le seul point qu'on ressent
   sans jamais le voir.

---

## Une note sur la méthode

Cette liste a été écrite à partir du code, et une erreur s'y est glissée en
chemin : j'avais annoncé en tête de liste que les séparateurs de jour
n'existaient pas. Ils existent. Le point a été corrigé et rétrogradé au
n° 13, où il reste vrai mais mineur.

Je le laisse écrit plutôt que de l'effacer, parce que c'est la limite de
l'exercice : un audit par recherche textuelle trouve ce qu'il cherche sous
le nom qu'il attend. `chToday` ne ressemble pas à `separateurJour`. **Les
items marqués d'un chiffre mesuré sont fiables ; ceux qui décrivent une
absence méritent une vérification avant d'ouvrir un chantier.**
