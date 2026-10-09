# Droplet — intégration : mascotte d'envoi, mise en forme, spoilers, traduction, transcription

Tout est dans cette archive : votre `lib/` modifié, les deux fichiers Lottie, le pont iOS, et ce mode d'emploi.

## 1. Les trois choses à faire avant de compiler

**a) `pubspec.yaml` — déclarer les animations** (le paquet `lottie` est déjà une dépendance, `animated_sticker.dart` s'en sert) :

```yaml
dependencies:
  flutter_tts: ^4.2.5   # « Lire à voix haute » sous les réponses de l'assistant

flutter:
  assets:
    - assets/lottie/
```

Pour la lecture à voix haute sur Android 11 et plus, `android/app/src/main/AndroidManifest.xml`, dans `<manifest>` :

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.TTS_SERVICE" />
  </intent>
</queries>
```

**b) iOS — brancher le pont « intelligence »** (c'est ce qui manquait pour la transcription et la traduction sur iPhone) :

1. Glisser `ios/Runner/IntelligenceBridge.swift` dans le projet Xcode, cible **Runner** cochée.
2. `Info.plist` :

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>Droplet transcrit vos messages vocaux directement sur votre téléphone.</string>
```

3. `AppDelegate.swift`, dans `application(_:didFinishLaunchingWithOptions:)`, avant le `return` :

```swift
if let registrar = self.registrar(forPlugin: "IntelligenceBridge") {
  IntelligenceBridge.register(with: registrar)
}
```

Si votre `AppDelegate` utilise le moteur implicite (Flutter récent, scènes UIKit), enregistrez-le plutôt dans `didInitializeImplicitFlutterEngine(_:)` :

```swift
if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "IntelligenceBridge") {
  IntelligenceBridge.register(with: registrar)
}
```

**c) Android — rien de neuf.** La transcription et la traduction continuent de passer par votre `IntelligenceBridge.kt` : le contrat du canal (`com.droplet.droplet/intelligence`, méthodes `transcriptionDisponible`, `transcrire`, `traduire`) n'a pas bougé.

## 2. Les fichiers

**Ajoutés**

| Fichier | Rôle |
|---|---|
| `lib/core/providers/animation_envoi_provider.dart` | Le réglage « Animation d'envoi » (complète / réduite / désactivée), persisté. |
| `lib/features/chat/mascotte_envoi.dart` | Plic : la surcouche Lottie, son ancrage, ses garde-fous. |
| `lib/features/chat/texte_mis_en_forme.dart` | Le texte des bulles, avec les spoilers de Telegram. *(part de `mise_en_forme.dart`)* |
| `lib/features/chat/controleur_mise_en_forme.dart` | La barre de saisie qui montre la mise en forme. *(part de `mise_en_forme.dart`)* |
| `lib/features/chat/feuille_traduction.dart` | La feuille « Traduire » façon Telegram / iOS. |
| `lib/features/settings/section_animation_envoi.dart` | La section d'Apparence, avec l'aperçu qui joue. |
| `assets/lottie/droplet_send.json` · `droplet_send_reduced.json` | L'animation (256 × 256, 60 fps, 1,5 s) et sa variante réduite (0,8 s). |
| `ios/Runner/IntelligenceBridge.swift` | Le pont iOS : `SFSpeechRecognizer` hors ligne + cadre `Translation`. |

**Modifiés**

| Fichier | Ce qui change |
|---|---|
| `lib/features/chat/chat_screen.dart` | 3 imports ; `_inputCtrl` devient `ControleurMiseEnForme` ; préchauffage de la mascotte dans `initState` ; lancement de la mascotte dans `_finTransitionEnvoi` ; `_highlighted` rend `TexteMisEnForme` ; « Traduire » ouvre la feuille (`_ouvrirTraduction`). |
| `lib/features/chat/mise_en_forme.dart` | 3 imports et les deux `part`. Le reste est intact. |
| `lib/features/chat/transition_envoi.dart` | Un getter `EtatEnvoi.rectBulle` : où se trouve la vraie bulle à la fin de la transition. |
| `lib/features/settings/apparence_screen.dart` | Un import et la nouvelle section, juste après le thème. |

## 3. L'animation d'envoi

Votre transition d'envoi (celle de Telegram, 250 ms) fait déjà voler la vraie bulle du champ jusqu'à sa place. La mascotte prend le relais **quand la bulle est posée** : c'est `_finTransitionEnvoi` qui la lance, avec le rectangle mesuré de la bulle.

- **Ancrage** : le point de dépôt du fichier tombe sur le **coin bas-gauche** de la bulle. Plic surgit du champ de saisie, se téléporte, atterrit dans l'espace libre à gauche de la bulle — jamais sur le texte.
- **Le calque `MESSAGE` est masqué** (`ValueDelegate.transformOpacity`) : la vraie bulle a déjà volé, un second message ferait doublon.
- **Garde-fous** : une seule mascotte à la fois, quatre secondes de repos entre deux passages, rien si la transition a échoué (pas de bulle à saluer), rien en mode « Désactivée ». Elle est dans l'`Overlay` racine, `IgnorePointer` et hors sémantique : elle ne bloque aucun geste et ne parle pas aux lecteurs d'écran.
- **Mouvement réduit** : « Réduire les animations » du téléphone force la variante réduite, même en mode « Complète ».

## 4. Le réglage, dans Apparence

Une section « Animation d'envoi » juste sous le thème : un segment iOS à trois positions et, au-dessus, **une mini-conversation qui joue vraiment l'animation** à chaque changement (plus un bouton « Rejouer »). La bulle y arrive avec la même courbe que dans la vraie discussion, et Plic est à la même taille et au même endroit — c'est l'aperçu, pas une illustration.

## 5. La mise en forme visible pendant la frappe

`ControleurMiseEnForme` peint le champ comme la bulle : `**gras**` s'affiche en gras, `||spoiler||` sous un voile, `` `code` `` à chasse fixe, `[texte](lien)` en couleur d'accent. Les marqueurs restent dans le texte — c'est lui qui traverse le mesh — mais tombent à 30 % d'opacité. La composition du clavier (mot en cours, correction automatique, claviers asiatiques) reste soulignée : elle n'est pas cassée.

## 6. Les spoilers

Refaits comme chez Telegram :

- la poussière épouse **les vraies lignes** du texte caché (`RenderParagraph.getBoxesForSelection`), y compris quand le spoiler court sur plusieurs lignes ;
- les points **naissent, dérivent et s'éteignent** chacun à son rythme, peints en trois passes `drawRawPoints` (quelques centaines de points, sans surcoût notable) ;
- l'appui **dissout en cercle** depuis le doigt : le front de l'onde écarte et avive la poussière, le texte apparaît derrière, découpé par ce même cercle ;
- le texte caché est peint **transparent**, jamais remplacé : la bulle ne change pas de taille quand on révèle ;
- un appui long ouvre le menu du message, comme avant : seul un appui court sur la poussière révèle.

## 7. La traduction

« Traduire » ouvre maintenant la feuille : langue détectée, langue cible modifiable (16 langues), original replié, squelette animé pendant le calcul, texte sélectionnable, « Copier » et « Dans la discussion » (qui remet la traduction sous le message comme avant). Un second appui sur « Voir l'original » retire la traduction de la bulle, comme aujourd'hui.

Le moteur ne change pas : `ServiceIntelligence.traduire`, donc le modèle hors ligne de l'appareil. Sur iPhone, c'est le fichier Swift qui répond (cadre `Translation`, iOS 18+) ; si le modèle manque, iOS propose lui-même de l'installer.

## 8. La transcription

Le Dart était déjà complet : ce qui manquait, c'était la réponse d'iOS au canal. `IntelligenceBridge.swift` la fournit, avec `requiresOnDeviceRecognition = true` — rien ne part chez Apple, ce qui est la seule option pour un message chiffré de bout en bout. Le bouton n'apparaît que si l'appareil sait vraiment le faire hors ligne (`supportsOnDeviceRecognition`), ce que votre code teste déjà.

## 9. Ce que je n'ai pas pu vérifier

- **Rien n'a été compilé.** Mon environnement n'a ni SDK Flutter ni Xcode. Ce qui a été fait : analyse syntaxique de tous les fichiers touchés avec un parseur Dart (aucune erreur), et relecture des API utilisées dans votre propre code (`OuroColors`, `OuroTypography`, `OuroListSection`, `StorageService`, `ServiceIntelligence`, `EtatEnvoi`…). Prévoyez quand même un `flutter analyze` avant de lancer.
- **Le Swift n'a jamais été compilé.** La partie traduction demande iOS 18 et Xcode 16 ; sur plus ancien, elle répond « indisponible » et l'app se comporte comme avant.
- **Android**, je ne l'ai pas vu : si la transcription n'y marche toujours pas, envoyez-moi `IntelligenceBridge.kt` et je le reprends.
- **Les libellés ajoutés sont traduits dans les dix langues** : 25 clés ont été ajoutées aux dix `.arb` et aux fichiers générés (`app_localizations*.dart`), écrites à la main puisque `flutter gen-l10n` ne tourne pas ici. Un `flutter gen-l10n` de votre côté les régénérera à l'identique depuis les `.arb`. Les noms de langues de la feuille de traduction, eux, s'affichent dans leur propre langue (Français, English, Español…), comme chez Telegram et iOS : rien à traduire, et c'est juste dans toutes les langues.
- **RTL** : l'ancrage de la mascotte suppose une bulle alignée à droite. En arabe, il faudra le miroir (x = coin.dx − 6 − taille + 198,7 × taille / 256).

## 10. Traduction et transcription en ligne (gratuites)

Un interrupteur dans **Réglages → Traduction et transcription**, désactivé par défaut. Activé, et seulement quand le téléphone est connecté :

- **Traduction : MyMemory**, gratuit et sans clé (5 000 caractères par jour et par appareil ; renseignez `_contactMyMemory` dans `service_intelligence.dart` pour passer à 50 000). Le service est essayé en premier ; s'il ne répond pas ou si le quota est atteint, le moteur hors ligne de l'appareil reprend la main. Même désactivé, la feuille de traduction propose « Traduire en ligne » quand le moteur de l'appareil échoue — un choix au cas par cas. Une traduction venue d'Internet porte la mention « Traduit en ligne par MyMemory ».
- **Transcription : le service vocal du système.** Le Dart transmet `enLigne` au canal natif.
  - **iOS** (`IntelligenceBridge.swift`) : sur l'appareil dès qu'il sait faire ; le serveur d'Apple seulement si l'appareil n'a pas de moteur pour la langue. Gratuit, environ une minute d'audio par requête.
  - **Android** (`IntelligenceBridge.kt`, fourni dans le zip) : le réseau sert seulement à **télécharger le modèle vocal** d'une langue absente (`triggerModelDownload`), une fois ; la transcription reste sur le téléphone. Le reconnaisseur en ligne de Google n'est volontairement pas utilisé : s'il ne sait pas lire un fichier, Android ouvre le micro à sa place. Avant d'écouter, le pont vérifie que la langue est installée (`checkRecognitionSupport`), et les erreurs « langue indisponible » deviennent des messages clairs au lieu d'un échec muet.

⚠️ Pour ces trajets-là, le contenu quitte le téléphone en clair : c'est écrit sous l'interrupteur et sous chaque traduction en ligne. Aucune requête ne part tant que l'interrupteur est coupé, sauf l'appui explicite sur « Traduire en ligne ».


## Passe iOS sur toute l'app (micro-interactions)

- **Boutons-icônes** : les 40 `IconButton` de l'app sont devenus `OuroIconButton` (`lib/design_system/ouro_icon_button.dart`) — pas de cercle gris, estompage à 40 % sans délai et retour en 0,2 s, cible de 44 pt. Mêmes paramètres qu'`IconButton` (`style` lu pour le fond, la forme et la couleur).
- **Roues de chargement** : les roues Android indéterminées sont devenues `OuroSpinner`, au rayon de la boîte qui les entourait. Les barres de progression déterminées (avec `value:`) sont gardées.
- **Tirer pour rafraîchir** : `RefreshIndicator.adaptive` (indicateur d'iOS sur iPhone).
- **Compteurs** : `OuroCompteur` (`lib/design_system/ouro_compteur.dart`) fait rouler les chiffres des non-lus (liste des discussions, bouton « descendre » de la discussion), avec les valeurs de Telegram iOS (0,2 s, décalage de 60 % de la hauteur, échelles 0,3 et 0,1).
- **Glissés des discussions** : ressort de révélation de Telegram (raideur 420, amortissement 40) qui part avec la vitesse du doigt, et icônes qui grandissent de 30 % à 100 % en se découvrant.

Seules les valeurs de Telegram sont reprises, depuis son code source ouvert : aucun code n'est copié (le leur est sous GPL).

### Fin du nettoyage Android

- **Boutons Material (49)** : enveloppés dans `OuroRetourIos` (`lib/design_system/ouro_retour_ios.dart`). Bouton texte : estompage à 35 % comme un bouton système d'iOS. Bouton plein ou bordé : le langage de pression d'`OuroPressable`. Délai de 100 ms dans une liste qui défile, éclair sur un tap bref, rien sur un bouton désactivé. Le voile Material est retiré du thème et des 29 `styleFrom` de l'app.
- **SnackBar (9)** : remplacés par le toast de l'app via `afficherToast(context, message, type:)` (`lib/shared/widgets/afficher_toast.dart`), utilisable sans `ref`.
- **Dialogues Material (5)** : bloquer un contact et supprimer des fichiers → `ouroConfirm` (action destructive en rouge) ; motifs de signalement → feuille d'actions iOS ; modifier un message et ajouter un texte au dessin → alerte iOS avec champ de saisie (multiligne gardé, alerte sombre dans l'éditeur de dessin).
- Gardés volontairement : les 3 indicateurs de progression réelle (avec `value:`) et les 7 `InkWell`, qui n'affichent plus que le surlignage gris façon cellule iOS.


## Bloquer pour de vrai

Le blocage était enregistré mais vérifié nulle part. Il est maintenant appliqué à la source :

- **Réception** (`mesh_repository.dart`, `_handleIncomingMessage`) : rien de ce qu'un contact bloqué nous adresse n'est consommé — messages, fichiers, accusés, réactions, frappe, photo, statuts, demandes de notre photo. Aucune notification. Exceptions, comme WhatsApp : ses messages dans un **groupe**, et le **relais** de ses paquets destinés à d'autres (le maillage continue de fonctionner, sans rien lire).
- **Appels** : un appel d'un contact bloqué ne sonne jamais (`_onIncomingCall`). Appeler un contact bloqué propose d'abord de le débloquer ; toute autre entrée vers `/call/…` est redirigée vers la discussion.
- **Envois** : rien ne part vers un contact bloqué (messages, frappe, accusés de lecture, vues et réactions de statuts, photo, statuts à une audience).
- **Statuts « Tout le monde »** : publics par nature (diffusés en clair à qui passe à portée). Ils portent un jeton par contact bloqué (empreinte SHA-256 de « statut:personne », tronquée) : l'app de la personne bloquée ne les affiche pas. Une app modifiée pourrait l'ignorer — « Mes contacts sauf… » exclut, lui, par le chiffrement.
- **Interface** : bandeau « Vous avez bloqué ce contact » + « Débloquer » à la place de la saisie ; statuts d'un contact bloqué masqués ; **Réglages → Sécurité → Contacts bloqués** (liste, déblocage avec confirmation, explication en pied de liste).

## Lecteur de statuts en pages

`lib/features/status/status_pager_screen.dart` : chaque contact est une page d'un `PageView` (cube, le glissé suit le doigt) ; seule la page au premier plan lit et avance. La route `/status/:authorId` est posée par-dessus les onglets (non opaque) et s'ouvre en zoom depuis la carte touchée ; fermer dépile et revient dans la carte. Pendant le glissé vers le bas, le fond noir s'efface et la liste réapparaît.

## Statuts : lecteur en pages, zoom, éditeur — et blocage réel

- **Lecteur en pages** (`status_pager_screen.dart`) : les contacts défilent sous le doigt en cube. Correction : le cube tournait à l'envers (les bords venaient vers l'œil) ; la face qui tourne s'assombrit.
- **Zoom depuis la carte** : correction d'un défaut — après un changement de contact, la fermeture reconstruisait le lecteur et montrait le premier contact pendant le fondu. Le lecteur se referme désormais sur la carte du contact affiché (les cartes s'enregistrent dans `StatusPagerScreen.rectsCartes`).
- **Éditeur de statut** : l'outil dessin ne publiait rien (calque jeté, jamais figé). Pour une photo, le crayon ouvre l'éditeur des photos de discussion (recadrer, tourner, dessiner, émojis) qui rend une image figée.
- **Blocage** : en entrée, un contact bloqué n'atteint plus rien hors des groupes (messages, appels, statuts, réactions, frappe, accusés, demandes de photo) ; ce qui transite pour d'autres continue d'être relayé sans être lu. En sortie, gardes ajoutées sur tout ce qui visait encore un contact bloqué : accusés de réception, réactions, modifications, votes, contrôles chiffrés, `hello` ciblé, événements Nexus, fichiers, envoi de photo de profil.

## Navigateur intégré et liens

- **Dépendance** : `webview_flutter: ^4.10.0` ajoutée au `pubspec.yaml` → `flutter pub get`, puis sur iPhone `cd ios && pod install`.
- **iPhone, pages en `http://`** : iOS bloque le Web non chiffré par défaut. Pour que ces pages s'ouvrent dans le navigateur intégré, ajouter dans `ios/Runner/Info.plist` :
  `NSAppTransportSecurity` → `NSAllowsArbitraryLoadsInWebContent` = `YES` (clé réservée aux vues Web, acceptée par Apple).
- **Où** : `lib/features/navigateur/navigateur_integre.dart` — `ouvrirLienDansApp(context, adresse)` ouvre le Web dans l'app et le reste (mail, téléphone, liens d'apps) dans le système ; `proposerActionsLien` est la feuille de l'appui long. `cleNavigateurRacine` est branchée sur le routeur pour ouvrir un lien sans contexte.
- **Liens des messages** : ouverts dans l'app par défaut (texte, carte d'aperçu, réponses de l'assistant). La carte suit le style de Telegram (liseré, site, titre, description, image).
- **Aperçus** (`lib/core/services/apercus_liens.dart`) : chargés seulement si « En ligne quand je suis connecté » est activé, car le téléphone contacte alors le site, qui apprend que le message a été ouvert. Sinon, l'aperçu se limite au domaine. La mention de l'interrupteur le dit désormais.
- **Infos du contact** : section « Liens » (les 12 plus récents, sans doublons) ; la photo vole depuis l'en-tête de la discussion (`heroTag` d'`EnTeteProfil`) et un clic haptique marque le passage en plein cadre.

## Discussions, profil, apparence

- **Filtre « À proximité »** (`chats_filter_bar.dart`) : les discussions joignables sans Internet à cet instant, celles dont le contact est relié par le maillage. Comme les autres filtres, il n'apparaît que s'il y a au moins une discussion concernée.
- **Anneau de statut sur les avatars de la liste** : dégradé dans la famille de l'accent tant qu'un statut n'a pas été vu, gris fin ensuite. Toucher l'avatar ouvre le statut en zoomant depuis l'avatar ; le reste de la rangée ouvre la discussion. L'anneau est peint autour de l'avatar sans décaler la rangée.
- **Profil** : la photo tirée vers le bas reste en plein cadre une fois relâchée (comme Telegram) ; remonter la liste la referme.
- **Apparence** : la section « Animation d'envoi » est retirée (fichier `section_animation_envoi.dart` supprimé). La mascotte garde le réglage enregistré, par défaut l'animation complète.

## Audit sur captures — corrections

- **Citation** : l'auteur affiché était inversé (« Vous » au-dessus des messages de l'autre). Corrigé dans `_MessageBubble._citationDeMoi`.
- **Stickers** : un sticker cité ou dernier message d'une discussion s'affichait en code brut (`🎞tgs:noto/checkMark`). Il s'affiche « Sticker » dans la citation, la barre de réponse et la liste.
- **Bouton « descendre »** : rond de verre de la matière de la barre de saisie, pastille d'accent pour les non-lus.
- **Dates** : « 27 août » (ou « 27 août 2025 ») dans la langue de l'app, au lieu de « 27/08/2026 ».
- **Fond de discussion** : motif un tiers plus discret.
- **Discussions** : sous une liste courte, un bloc qui explique le fonctionnement sans Internet, avec un emblème d'ondes animé seulement quand des appareils sont à portée, et un lien vers la page du réseau.

## Avatars et Assistant

- **`lib/design_system/ouro_avatar.dart`** : huit dégradés de la famille de Droplet, un reflet discret, deux initiales quand le nom a deux mots, et une couleur stable par personne (hachage FNV du nom, au lieu de `String.hashCode`). Les couleurs de chacun changent donc une fois, avec cette version, puis ne bougent plus.
- **`PeerAvatar`** utilise ce système partout ; un appelant peut toujours imposer une couleur (`color`) ou un dégradé (`gradient`).
- **En-tête du profil** : même dégradé et mêmes initiales que dans la liste (il prenait la couleur d'accent pour tout le monde).
- **Assistant** : `AvatarAssistant` remplace l'étincelle — la goutte de Droplet sur son rond dans l'eau, dégradé bleu-violet. `actif: true` fait s'élargir les ronds pendant une réponse (respecte « Réduire les animations »).

## Assistant qui écrit, en-tête vivant

- **`lib/features/ai/etat_assistant.dart`** : `assistantEcrit`, vrai tant que l'Assistant écrit une réponse, y compris après avoir quitté son écran. Dans la liste des Discussions, sa goutte fait des ronds dans l'eau pendant ce temps.
- **Écran de l'Assistant inchangé** : l'étoile façon Gemini en haut, la lueur et l'indicateur de réflexion restent tels quels, couleurs comprises.
- **En-tête des Discussions** : deux ronds très pâles, de la couleur de l'icône, s'échappent de l'icône des ondes tant qu'un appareil est à portée ; immobile sinon, et si « Réduire les animations » est activé.

## Écran d'accueil (Discussions)

- **État du réseau** : un point devant « Personne à proximité · Internet » — couleur de Droplet quand le maillage relie quelqu'un, vert pour Internet seul, rond vide sinon. Immobile (l'icône des ondes porte déjà l'animation). `OuroLargeTitleScaffold` accepte pour cela un `subtitleLeading`.
- **Aperçus** : les émojis de tête (🎤, 📷, 🎥, 📎, 📍…) deviennent des pictogrammes sobres de la couleur du texte. Un émoji écrit par quelqu'un reste tel quel.

## Éditeur photo et vidéo (avant envoi et pour les statuts)

- **`lib/features/editeur/`** : `filtres_photo.dart` (filtres et réglages en matrices de couleur) et `outils_retouche.dart` (rail d'outils, bande de filtres, règle graduée, calques de texte, export).
- **Où** : `ApercuEnvoiScreen` — la même page sert aux photos d'une discussion et à celles d'un statut (le crayon du composeur l'ouvre).
- **Outils** : recadrer, pivoter, filtres (12, avec intensité), réglages (luminosité, contraste, saturation, chaleur, vignette), texte (déplaçable, agrandissable, pivotable), dessin, et pour une vidéo : découper (ouvre l'éditeur de découpe existant).
- **Performance** : filtres et réglages sont appliqués par le processeur graphique (`ColorFilter.matrix`), donc l'aperçu suit le doigt ; l'image n'est recomposée qu'une fois, à l'export, à sa propre résolution (jusqu'à 3 072 px).
- **Retour en arrière** : chaque retouche est mémorisée (20 pas) et le bouton en haut à droite annule la dernière.

## Réglages

- **Recherche** : un champ sous le grand titre, à la façon d'iOS. Il cherche sans tenir compte des accents ni des majuscules, affiche le réglage avec sa section, et mène soit à la page concernée, soit à la section de cette même page, en l'amenant sous les yeux (`Scrollable.ensureVisible`).
- **Section Notifications** : l'ancienne section « Son » devient « Notifications » et gagne **Aperçu du contenu**. Coupé, l'écran verrouillé n'annonce plus que l'arrivée d'un message, sans son texte (`NotificationService.apercuActif`, clé `notif:apercu`).
- **Profil** : il était déjà en haut de la page (photo, pseudo, identifiant) — je m'étais trompé dans ma comparaison précédente.

- **Ordre des sections** : profil · sécurité · en ligne quand je suis connecté · notifications · apparence · icône · langue · assistant · réseau · Tor · soutien · aide. Du plus personnel au plus technique, comme WhatsApp, Telegram et les Réglages d'iOS.

## Motifs du fond de discussion

- **26 dessins redessinés** (22 grands, 4 petits) : goutte, ondes, maillage, avion et bateau en papier, bulle, antenne relais, boussole, vagues, clé, cadenas, montagne de nuit, talkie-walkie, feuille, tente, enveloppe, nuage barré, phare, satellite, constellation, oignon de Tor, Bluetooth.
- **Deux graisses de trait** : 1,75 pour les grands dessins, 1,35 pour les petits remplissages — c'est ce qui donne de la profondeur au lieu d'une grille d'icônes.
- **Disposition** : une case sur huit reste vide, tailles de 22 à 32 (10 à 15 pour les petits), rotation jusqu'à ±26°. Aucun dessin ne déborde de sa case, donc la répétition de la tuile reste invisible.
- Les tracés viennent d'un jeu de courbes vérifié au rendu avant d'être transcrit en Dart (voir l'aperçu livré avec cette version).

## Bulles : la signature de Droplet

- **La goutte** (`_FormeBulle.goutte`) : sur la dernière bulle d'une série, le coin du côté de l'auteur est tiré comme une goutte au bord d'une surface — deux courbes tangentes aux bords qui se rejoignent en une pointe arrondie, 3 pt hors du rectangle. Elle remplace la pointe triangulaire qui avait été désactivée parce qu'elle se lisait comme un emprunt à WhatsApp.
- **La lumière sur l'eau** : un cheveu clair sur l'arête haute, qui s'éteint aux deux coins (dégradé). Franc sur une bulle claire (75 %), discret sur une bulle foncée ou colorée (16 %).
- **La matière** : mes bulles prennent un dégradé de la MÊME couleur, 5 % plus claire en haut. Aucune couleur n'est changée, seulement éclairée.
- Les bulles sans fond (autocollants, réponses de l'Assistant) n'ont ni reflet ni goutte.

## Mentions dans les groupes

- **Écriture** : taper `@` dans un groupe ouvre la liste des personnes au-dessus de la barre de saisie (quatre lignes au plus), avec `@tous` en tête. Le choix insère le pseudo entier et remet le curseur derrière.
- **Lecture** : les mentions sont surlignées à la couleur d'accent, en demi-gras, dans les bulles comme dans le champ pendant la frappe. `Mentions.pseudos` permet de surligner un pseudo entier, espaces compris (« @mr Edz »).
- **Ailleurs** : `Mentions.concerne(texte, monPseudo)` dit si un message me vise — prêt à brancher sur les notifications pour qu'une mention passe outre le silence.

## Vue unique

- **Envoi** : un bouton « 1 » à côté de la légende, dans l'éditeur des photos et vidéos d'une discussion (pas dans les statuts). La marque `vu1:` voyage en tête de la légende : rien de nouveau ne circule sur le réseau.
- **Réception** : la bulle montre une pastille « 1 », « Vue unique » et le type du média. Un toucher ouvre l'écran noir ; en sortant, le fichier est supprimé du téléphone et la bulle passe à « Ouverte ». Celui qui a envoyé ne peut pas rouvrir non plus.
- **Ailleurs** : ces médias n'entrent pas dans la galerie du contact.
- **Limite honnête** : aucune app ne peut empêcher une capture d'écran sur iPhone. La vue unique protège de l'oubli, pas de la mauvaise foi.
- Fichiers : `lib/features/chat/vue_unique.dart`, `apercu_envoi_screen.dart`, `chat_screen.dart`, `chat_info_screen.dart`.

## Sondages : une date de fin

- **Création** : une rangée de durées (∞, 1 h, 6 h, 24 h, 3 j) sous la question. Sans choix, le sondage reste ouvert comme avant.
- **Encodage** : une clé facultative `f` s'ajoute au message du sondage. Un client qui ne la connaît pas voit un sondage sans fin, jamais un message cassé.
- **Bulle** : l'heure de fin s'affiche sous les options, puis « Sondage terminé » ; on ne peut plus voter après l'heure dite.

## Vue unique : les messages vocaux

- **Armer** : un bouton « 1 » à gauche du micro, visible tant que le champ est vide. Allumé, le prochain vocal part en vue unique ; il s'éteint tout seul après l'envoi.
- **Écouter** : la bulle montre la pastille « 1 » et un micro. Un toucher ouvre l'écran noir, la lecture démarre seule, l'onde se remplit, le temps défile.
- **Après** : à la fin de la lecture (ou en fermant), le fichier est supprimé et la bulle passe à « Ouverte ».

## Packs de motifs

- **Quatre papiers peints** : Droplet (26 dessins), Jeux (13), Maison (13), Jardin (12) — 38 nouveaux dessins, tracés avec le même soin : trois à cinq traits, masse équilibrée dans une boîte de 24, deux graisses au tracé.
- **Moteur** : `MotifsDroplet` prend désormais un `PackMotifs` (tracés, graine de disposition et cache d'image par pack). `CalqueMotifsDroplet(pack: …)` recharge la tuile quand le pack change.
- **Choix** : section « Motifs du fond » dans Apparence, avec une vignette par pack montrant le vrai fond et deux bulles pour juger en situation. Le choix est enregistré avec les autres réglages (`packMotifs`).

## Messages importants

- **Le geste** : appui long sur un message → « Marquer comme important », en tête du menu. Rien n'est envoyé, personne n'est prévenu.
- **La bulle** : une petite étoile s'ajoute devant l'heure.
- **L'écran** : `/starred`, ouvert depuis le bouton « + » de l'accueil, première entrée de la feuille. Chaque ligne donne l'auteur, l'extrait et la date, et ramène à la discussion d'un toucher ; un appui long retire l'étoile.
- **Vide, il enseigne le geste** : une étoile cerclée et la phrase qui explique l'appui long — on ne devine pas cette fonction tout seul.
- **Copie au moment de l'étoile** : la liste reste lisible même si la discussion a été vidée depuis.
- Fichiers : `lib/features/chat/messages_importants.dart`, `messages_importants_screen.dart`, `chat_screen.dart`, `settings_screen.dart`, `main.dart`.

## Choix des motifs, façon Telegram

- Vignettes de 96 × 124 : le vrai fond, une bulle reçue, une bulle envoyée en dégradé d'accent.
- **Emblème** : le premier dessin du pack, peint en bas à gauche — chaque pack se reconnaît sans lire.
- **Sélection** : anneau d'accent, halo coloré, coche qui arrive en ressort, vignette qui grandit d'un cheveu.
- **Appui** : la carte s'enfonce à 95,5 %, comme une touche iOS, avec un clic haptique.

## Correctif : le choix de motif s'applique vraiment

`PersonnalisationNotifier.modifier()` enregistrait le nouveau réglage sans appeler `appliquer()` : le choix restait dans l'état Riverpod et n'arrivait jamais à `ReglagesApparence`, que lisent les écrans. Deux changements :

- `modifier()` appelle désormais `valeur.appliquer()`.
- La discussion lit le pack sur `personnalisationProvider` plutôt que sur la valeur statique, donc le fond se redessine dès le choix, sans quitter l'écran.

## Accueil : langue, non-lus, frappe

- **Dates traduites** : `formatMessageTime` n'écrit plus « Hier » ni les jours en français en dur. Aujourd'hui → l'heure au format du pays, hier → le mot de l'app, cette semaine → le jour localisé, avant → la date courte locale.
- **Aperçus traduits** : la liste est construite loin de tout `BuildContext`, donc le fournisseur pose une marque (`ApercuSysteme`) et c'est la ligne qui écrit dans la bonne langue — discussion verrouillée, appel manqué, appel vidéo manqué, message vocal.
- **Les non-lus visent vraiment les non-lus** : les messages d'un contact bloqué et ceux déjà lus ne comptent plus ; surtout, la discussion se remarque comme lue à chaque message reçu pendant qu'on la lit, et en la quittant. Avant, un message arrivé sous les yeux laissait une pastille en revenant à l'accueil.
- **« En train d'écrire… »** : quand quelqu'un écrit, sa ligne remplace l'aperçu par le texte en couleur d'accent, suivi des points qui respirent.

## Accueil : suppression et groupes vides

- **Supprimer une discussion** : appui long sur la ligne → « Supprimer la discussion », en rouge, avec une confirmation qui dit franchement ce qui se passe : les messages disparaissent de ce téléphone, et sans serveur personne ne peut les retirer de celui des autres. `supprimerConversation(peerId:, groupId:)` efface l'état et le stockage ; le groupe n'est pas quitté.
- **Un groupe existe dès sa création** : la liste ajoute désormais les groupes dont on est membre actif même sans aucun message, avec « Groupe créé · aucun message » et l'heure de création. Avant, il fallait attendre le premier message pour voir apparaître un groupe qu'on venait de créer.
- **« Diffusion mesh »** était un nom français figé dans les données : il passe par la même marque que les autres aperçus et s'affiche dans la langue de l'app.

## Messages éphémères

- **L'écran** : le modèle de WhatsApp — une goutte qui s'évapore (dessinée, animée), la phrase qui dit exactement ce qui va se passer, puis 24 heures, 7 jours, 90 jours, Non, en liste iOS avec la coche qui arrive en ressort. Accessible depuis les infos de la discussion, sous le verrouillage.
- **Comment ça marche sans serveur** : personne ne peut aller effacer un message sur le téléphone d'en face après coup. Chaque message envoyé pendant que le minuteur est actif part donc avec sa date de péremption, portée par une marque invisible en tête du contenu (`\u0002ep<secondes>\u0002`). Les deux téléphones la lisent et effacent au même moment, sans rien changer au protocole.
- **À l'affichage** : la marque est retirée partout — 21 points dans la bulle, plus l'aperçu de l'accueil.
- **Le balayage** : les messages arrivés à terme sont effacés à l'ouverture de la discussion et à chaque nouveau message.
- **Comme WhatsApp** : changer le réglage ne touche pas aux messages déjà envoyés, chacun garde la durée qu'il portait au départ. C'est écrit noir sur blanc dans le pied de l'écran.

## Deux corrections d'affichage

- **« Annuler » en toutes langues** : `ouroConfirm`, `ouroChoice` et `ouroPrompt` avaient « Annuler », « Continuer » et « Enregistrer » en français dans leurs valeurs par défaut. Ces libellés viennent maintenant de la langue de l'app.
- **Plus de noms de fichiers sur l'accueil** : une pièce jointe s'annonce par ce qu'elle est — 📷 Photo, 🎥 Vidéo, 📎 Document — au lieu de « IMG_2043.PNG ». Les vocaux gardent leur durée.

## Présence Internet, séparée du maillage

- **Le problème** : « vu à 14 h 03 » voulait dire « croisé par le maillage à 14 h 03 ». Utile en festival, inutile pour savoir si quelqu'un, à l'autre bout du pays, peut recevoir un message tout de suite.
- **La source** : `PresenceInternet` note l'heure du dernier signe reçu PAR INTERNET — un paquet relevé dans la boîte aux lettres (`recevoirPaquetEnLigne`). C'est la seule preuve honnête sans serveur de présence : ça ne dit pas « il regarde son écran », ça dit « son téléphone a parlé par Internet à telle heure ».
- **L'en-tête** : « En ligne · Internet » si moins de cinq minutes, sinon « Par Internet il y a 12 min / 3 h / 2 j ». Le maillage garde ses propres phrases : les deux sources ne se mélangent jamais.
- **Suite possible** : un battement de présence déposé périodiquement dans la boîte aux lettres rendrait l'indication bien plus vive. À décider ensemble, parce que ça consomme de la batterie et de la donnée.

## Lecteur de PDF

- **Nouvelle dépendance** : `pdfx: ^2.9.1` dans `pubspec.yaml` → `flutter pub get && cd ios && pod install`.
- Plein écran, fond groupé iOS, défilement vertical. La barre du haut flotte en verre dépoli avec le nom, fermer et partager, et s'efface dès qu'on lit ; un toucher la rappelle. La pastille « 3 / 12 » suit en bas.
- Toucher l'icône d'un PDF reçu dans une discussion l'ouvre dans l'app.

## Battement de présence

Décision prise : **au premier plan seulement**, et **visible de tous ceux qui peuvent écrire**.

- **Client** : `BattementPresence` publie un battement toutes les deux minutes tant que l'app est ouverte, et lit au passage la présence des gens avec qui on a une conversation (40 au plus). Deux verrous : le mode en ligne accepté, et une identité connue. À la mise en arrière-plan, plus rien n'est publié — la dernière heure connue vieillit d'elle-même.
- **Annuaire** : `DirectoryClient.battement(peerId)` et `DirectoryClient.presences(ids)`. Si le serveur ne connaît pas encore `/presence`, les appels échouent en silence et l'app se comporte comme avant.
- **Serveur** : `serveur_presence.js` — deux routes Express à coller dans droplet-directory, une table en mémoire, oubli au bout d'un jour.
- **Ce que ça coûte, dit franchement** : l'annuaire apprend quand un identifiant est en ligne et quels identifiants on interroge. Aucun contenu, aucun message. C'est de la métadonnée que Droplet ne donnait pas avant, d'où les deux verrous.

## Groupes : description, droit d'écriture, recherche

- **Les réglages voyagent avec le manifeste** : `ReglagesGroupes` ajoute une clé `reglages` au `group_sync` existant (description, droit d'écriture, heure de modification). Un ancien client l'ignore sans rien casser, et le plus récent gagne en cas de désaccord. Aucune migration de base : les réglages sont rangés à côté, en JSON.
- **Description** : carte sous le nom du groupe. Les administrateurs l'écrivent (200 caractères), tout le monde la lit. L'enregistrement rediffuse aussitôt le manifeste (`diffuserReglagesGroupe`).
- **Seuls les administrateurs écrivent** : un interrupteur pour les admins, une mention pour les autres. Dans la discussion, la barre de saisie disparaît et laisse place à une ligne qui explique pourquoi — plutôt que de laisser quelqu'un taper pour rien.
- **Recherche des membres** : un champ apparaît au-delà de huit membres. En dessous, chercher n'a pas de sens.
- **Reste à faire** : les avis d'ajout et de retrait dans la discussion, et l'ajout par QR.

## Groupes : les avis, et les salons en lecture seule

- **Avis d'ajout et de retrait** : rien de nouveau ne circule. Chaque fiche de membre garde déjà qui l'a ajouté et quand ; la conversation lit ces fiches et pose les lignes au bon endroit dans le fil — création du groupe, arrivées, départs — mêlées aux messages par ordre d'heure, avec les séparateurs de jour recalculés en conséquence.
- **On ne dit pas qui a retiré** : la fiche ne le sait pas. « X ne fait plus partie du groupe » est sobre et vrai ; inventer un auteur serait pire.
- **Salon en lecture seule** : quand seuls les administrateurs écrivent, la barre de saisie laisse place à une note en verre dépoli — pastille ronde, porte-voix, phrase courte, et le retrait du bas respecté. Rien ne clignote, rien ne s'excuse.

## Rejoindre un groupe par QR

**Le principe** : le code ne contient AUCUNE CLÉ. Il porte l'identifiant du groupe, son nom, qui invite, un jeton tiré au hasard et une date de péremption. Photographier l'écran de quelqu'un ne donne donc que le droit de DEMANDER : c'est l'appareil de l'administrateur qui vérifie le jeton et ajoute le membre.

- **Trois verrous** : le jeton expire au bout de 24 h, ne sert que 20 fois, et un nouveau code tue l'ancien à la seconde même.
- **Côté administrateur** : bouton « Code QR » dans l'écran du groupe → feuille iOS avec le code sur carte blanche, la validité qui s'écoule, partager et renouveler. Un nouveau contrôle `group_join_request` vérifie que le demandeur n'est ni membre, ni bloqué, que je suis bien administrateur, et que le jeton passe. En cas de refus, aucune réponse n'est envoyée : un jeton refusé n'apprend rien à qui l'essaie.
- **Côté invité** : le scan depuis « Nouveau message » reconnaît une invitation de groupe, envoie la demande et le dit. Si la clé de l'hôte est inconnue, l'app le dit franchement plutôt que de laisser croire que la demande est partie.
- Fichiers : `invitation_groupe.dart`, `invitation_groupe_screen.dart`, `traitement_invitation.dart`, `mesh_repository.dart`, `group_info_screen.dart`, `new_message_screen.dart`.

## Accueil : cinq réglages tirés de la comparaison avec WhatsApp

1. **Compteurs sur les chips** : « Non lues 4 », comme chez eux. La largeur des pastilles est mesurée avec le compte, donc rien ne rogne au Dynamic Type.
2. **Marqueur @** : une pastille d'accent devant le compte quand une mention non lue attend. Le calcul se fait sur les messages non lus du groupe, avec `Mentions.concerne`.
3. **Aperçu sur une ligne**, avec l'auteur dans les groupes (« ~ Cyrille : … ») et les liens réduits à leur domaine (« 🔗 droplet-directory…railway.app ») au lieu d'une URL brute sur deux lignes.
4. **Ordre du haut** : recherche, filtres, Archivées, Verrouillées, puis l'Assistant comme une ligne de la liste, épinglé comme les autres.
5. **Densité et retrait bas** : lignes resserrées (76/64 au lieu de 84/68) et 40 points de plus sous la liste pour que la barre flottante ne coupe plus la dernière conversation.

## La joignabilité, sur chaque ligne

- **Chaque discussion dit par où elle passerait** : point de couleur et deux mots — À portée, 2 sauts, Internet, En attente, Hors de portée. Le calcul reprend `cheminVersPair`, déjà utilisé par l'en-tête de discussion, nourri par les pairs du maillage, l'état Internet et la présence en ligne.
- **Le champ de saisie ne ment plus** : hors de portée, il annonce « Partira dès qu'il sera à portée » au lieu de laisser écrire pour rien. Le message part tout seul quand la personne revient.
- **Badge sur l'onglet Discussions** : le total des non-lus, en pastille d'accent qui déborde de l'icône sans la décaler.

C'est l'information qu'aucune app à serveur ne peut afficher : chez elles, il n'y a qu'un chemin, donc rien à dire.

## Deux finitions de la liste

- **Nom en gras quand la discussion est non lue** : on reconnaît la ligne sans la lire, comme chez WhatsApp. L'heure passait déjà en accent.
- **Rafales d'émojis rabotées** (`titreLisible`) : « Écosystème 🏔🌊🌋🌪🌳🏕🖼 » s'affiche « Écosystème 🏔 ». On garde le premier émoji de chaque rafale de trois ou plus, le vrai nom reste entier, et l'heure n'est plus poussée au bord. Les noms sobres ne sont jamais touchés.

## Le fondu du bas

Sous la barre flottante, le contenu se coupait net sur son bord : on voyait un demi-mot, une demi-ligne. Un fondu occupe désormais la hauteur réservée de la barre plus trente points :

- **dégradé vers le fond de l'écran** (0 → 90 %), donc correct en thème clair comme en sombre ;
- **flou de 10 points masqué par ce même dégradé** — pas de bande floue à bord franc, ce qui trahirait le procédé, comme la barre de lecture d'Apple Music ;
- **il s'efface avec la barre** quand elle se replie au défilement (opacité 35 %), sinon il resterait un voile sans raison.

## Appels et Actus

**Appels** — les appels consécutifs du même contact, le même jour, avec la même issue, tiennent maintenant sur UNE ligne avec « (3) » à côté du nom, dans sa couleur (rouge si manqué). C'est ce que fait Téléphone sur iOS ; ni WhatsApp ni Telegram ne le font, et trois manqués d'affilée n'écrasent plus l'historique.

**Actus** — une borne sépare les statuts neufs de ceux déjà vus : un mot en capitales et un filet à la hauteur des cartes, assez discret pour ne pas couper le geste de défilement. WhatsApp sépare avec un titre de section qui coûte une ligne entière ; ici la séparation vit dans le carrousel lui-même.

## L'anneau segmenté des statuts

`AnneauStatuts` (lib/features/status/anneau_statuts.dart) remplace l'anneau plein, dans les Actus comme dans la liste des discussions :

- **un arc par statut**, allumé tant qu'il n'est pas vu, éteint ensuite — on lit la progression avant d'ouvrir ;
- **un seul statut donne un cercle entier**, sans coupure : une coupure unique ressemblerait à un défaut de tracé ;
- **au-delà de seize statuts**, les arcs deviendraient de la poussière : on les regroupe, et un paquet ne compte comme vu que s'il l'est entièrement ;
- **l'écart entre arcs est donné en points de contour** puis converti en angle, donc il reste constant à l'œil quelle que soit la taille de l'anneau.

## Actus et Appels, deuxième passe

**Actus**
- **Liste verticale sous le carrousel** (`_ListeStatuts`) : une ligne par personne — anneau segmenté, nom en gras s'il reste du nouveau, dernier statut, heure, et surtout PAR OÙ on la joint maintenant (à portée, N sauts, Internet, hors de portée), plus une pastille du nombre de statuts non vus. Cette dernière colonne n'existe dans aucune app à serveur.
- **Lisibilité** : le texte d'un statut suit la luminance du fond (blanc, ou presque noir quand le fond est clair) au lieu d'être blanc par habitude.
- **Cartes agrandies** : 106 × 186 au lieu de 92 × 164, et la pastille « + » descend en bas à droite de l'avatar, comme le badge d'appareil photo d'iOS, au lieu de chevaucher l'anneau.

**Appels**
- **Colonne d'heure de largeur fixe**, calée à droite : « 16:45 », « hier » et « 22/09 » ne dansent plus d'une ligne à l'autre.
- **Sous-titre d'un sortant sans réponse** : « Sortant · Sans réponse », pour que la flèche ne soit plus le seul indice.

## Appels : ⓘ et glissement · Éphémères : une seule mécanique

- **Bouton ⓘ** avant le bouton vert : la ligne rappelle, le « i » ouvre la discussion — la répartition de l'app Téléphone d'iOS.
- **Glissement pour supprimer** : `GlissementActions` sur chaque ligne, `StorageService.supprimerAppel(id)` retire l'entrée du journal (local, comme tout le journal), et l'écran se redessine par rappel.
- **Éphémères, doublon corrigé** : Droplet avait DÉJÀ un minuteur éphémère, meilleur que celui que j'avais ajouté — il voyage dans le message lui-même (`expiresInSeconds`). L'entrée que j'avais ajoutée dans les infos de discussion est retirée, la marque posée sur le texte à l'envoi aussi, et l'écran façon WhatsApp pilote désormais le vrai minuteur (`getEphemeralTimer` / `setEphemeralTimer`).

## Messages éphémères : l'écran remplace le sélecteur

- La ligne des infos de discussion ouvre désormais `MessagesEphemeresScreen` — illustration animée, choix en liste iOS, phrase du bas — et pilote le minuteur historique (`expiresInSeconds`), celui qui voyage avec le message.
- L'ancien sélecteur en feuille a été retiré.
- **Durées réunies** : 30 secondes, 5 minutes et 1 heure (déjà dans Droplet) plus 24 heures, 7 jours et 90 jours (celles de WhatsApp). On n'enlève à personne ce dont il se servait.

## Discussions et Actus, troisième passe

**Discussions**
- **La joignabilité passe à droite, sous l'heure**, dans sa propre colonne — et se tait quand c'est « Internet ». Cinq lignes qui répètent le cas ordinaire n'apprennent rien et coûtaient trois conversations par écran.
- **Aperçu allégé** d'un cran de taille et de couleur : l'œil tombe sur QUI, puis sur QUOI.
- **Archivées et Verrouillées** sont calées sur la colonne des avatars (48 points), donc tous les textes démarrent au même endroit.

**Actus**
- **Titre « Statut » retiré** : il faisait un troisième titre après « Actus » et son sous-titre.
- **Pastille « + »** ramenée contre l'avatar, juste hors de l'anneau.
- **Mon propre statut** porte un anneau neutre : il n'a rien à me faire voir.
- **Teinte des cartes** décalée d'un cheveu selon l'auteur (±10° de teinte). Assez pour séparer deux cartes composées avec la même couleur, trop peu pour trahir la couleur choisie.

## Droplet Pro : les explications, écran à part

Le modèle est celui de Telegram Premium.

- **`avantages_pro.dart`** : le catalogue des avantages (icône, couleur, nom, une ligne, texte long). La liste de l'écran Pro et l'écran d'explications lisent la MÊME source, donc une fonction ne s'appelle jamais autrement selon l'écran.
- **Dans l'écran Pro** : une section « Ce que Pro apporte », une ligne par avantage avec son icône colorée et son chevron. On touche, l'explication s'ouvre.
- **`avantages_screen.dart`** : un avantage par page, qu'on fait défiler du pouce. Trois soins pour la tenue iOS — la page qui arrive glisse et grandit pendant que celle qui part s'efface ; le halo du fond prend la couleur de l'avantage et se fond vers la suivante EN MÊME TEMPS que le doigt ; les points du bas s'étirent au lieu de sauter. Le bouton d'achat reste en bas : on décide sans revenir en arrière.
- **Aucune vidéo, aucune image à charger** : l'illustration est peinte (icône en dégradé, anneaux qui respirent), donc rien à télécharger et rien qui vieillit.
- **Six avantages décrits honnêtement**, dont le badge Pro : « il ne donne aucun pouvoir sur les autres, il dit seulement que vous avez payé pour que Droplet reste sans publicité ».

## Groupes : photo et stockage

- **Photo du groupe** : les administrateurs touchent l'avatar (badge d'appareil photo en bas à droite), choisissent une image, elle est réduite à 512 px et enregistrée comme les avatars personnels, puis le manifeste repart aux membres. Limite honnête : l'image elle-même ne circule pas encore, donc les autres membres gardent l'avatar à initiales tant qu'on n'aura pas branché le transfert d'image des avatars personnels.
- **Stockage du groupe** (`stockage_groupe_screen.dart`) : le poids total en gros titre, **qui envoie le plus** avec une barre par personne — ce qu'aucune app ne montre et qui règle seul la discussion sur « qui remplit le téléphone » — puis la liste des fichiers avec auteur, date et poids, triable par date ou par taille. Un PDF s'ouvre d'un toucher dans le lecteur intégré. Les vues uniques n'y figurent pas.

## Salon vocal de groupe

Le modèle est celui de WhatsApp, Telegram et Discord : **ça ne sonne chez personne**. Le salon s'ouvre, un bandeau apparaît en bas de la discussion, chacun entre quand il est disponible et continue d'écrire pendant ce temps.

- **Ce qui circule sur le maillage** : trois annonces minuscules — ouvert, j'entre, je sors — plus les réactions, via un nouveau contrôle `group_voice_room`. Aucun son n'y passe.
- **La voix passe par le serveur**, donc par Internet. Choix assumé et dit à l'écran : le maillage sait porter un message qui attend, pas vingt voix en même temps. Sans Internet, le bouton l'explique au lieu d'échouer en silence.
- **Le bandeau** : verre dépoli, les visages qui se chevauchent comme une tablée, le nombre de personnes, et « Entrer ». Il ne clignote pas et ne sonne pas — un salon attend, il ne réclame pas.
- **Réactions** : `SalonsVocaux.reagir` et six emoji prêts, pour approuver sans couper la parole.
- **Fichiers** : `lib/features/call/salon_vocal.dart`, `mesh_repository.dart`, `chat_screen.dart`.

## Salon vocal : les réactions et l'anneau de parole

- **L'anneau qui pulse** : deux ondes s'échappent de l'avatar de celui qui parle, décalées d'un demi-temps pour que le mouvement paraisse continu au lieu de battre. Elles ne tournent que pour lui — quatre avatars qui pulsent ensemble ne distinguent plus rien.
- **Les réactions** : six emoji sous les contrôles, avec l'enfoncement iOS au toucher. Ce qu'on envoie s'envole tout de suite chez soi et part aux autres membres du salon par le même contrôle `group_voice_room`.
- **L'envol** : chaque réaction monte, dérive selon une valeur propre à son auteur — deux pouces levés ne se superposent jamais — et s'efface en trois secondes et demie.

## L'écran d'appel de groupe, repris en main

L'écran fonctionnait mais il ne ressemblait pas au reste de l'app : fond noir plat, cartes grises bordées d'un trait de couleur de 2,5 px, trois boutons ronds nus posés en bas. À côté de l'appel 1:1 — son fond bleu nuit, sa barre en verre, ses boutons légendés — on avait l'impression de changer d'application en passant d'un appel à l'autre. Tout a été repris pour que ce soit le même écran, avec plus de monde dessus.

- **Le même fond que l'appel 1:1** : un halo bleu nuit, plus une teinte de la couleur de celui qui parle, qui respire très lentement. À la limite du visible, et c'est voulu : sur un écran d'appel, tout ce qui bouge franchement finit par agacer au bout d'une heure. Les appareils modestes n'ont que le halo.
- **On se voit soi-même.** Le fournisseur ne liste que les autres ; une tuile « Vous » est ajoutée à l'écran, avec le badge orange du micro coupé posé dessus. Toutes les grandes apps le font, et pour une bonne raison : sans ça, on ne sait jamais si on est coupé.
- **La voix guide l'œil.** Celui qui parle s'éclaire d'un dégradé de sa couleur, son trait se resserre, ses ondes s'échappent de son avatar et il grandit d'un demi-point ; les autres reculent d'autant et s'estompent à 88 %. Ce n'est presque rien, et c'est ce qui fait qu'on regarde la bonne tuile sans y penser. Plus de trait de 2,5 px : une lueur.
- **Grille adaptative, jamais de trou.** Deux personnes : deux tuiles larges, on respire. Trois : une paire et une tuile centrée. La taille des tuiles ET celle des avatars sont calculées à partir de la place réellement disponible, en retirant d'abord la hauteur du nom et de l'étiquette — le bloc entre dans la tuile par construction, sur un 360×640 comme sur un grand écran.
- **Barre de contrôle en verre et boutons légendés** — « Haut-parleur », « Micro », « Raccrocher » — exactement celle de l'appel 1:1, pour qu'on ne cherche jamais le micro selon le type d'appel. Enfoncement iOS, jamais d'onde Material. Flou d'arrière-plan seulement là où l'appareil peut se le permettre.
- **Les états redondants disparaissent.** Quand tout le monde est connecté, afficher « En ligne » quatre fois ne dit plus rien : l'étiquette n'apparaît que pendant la connexion — avec le rouet iOS et la pastille orange de l'avatar — ou après un échec.
- **Réduire sans raccrocher.** Le chevron en haut à gauche ramène aux discussions, l'appel continue. Et pour que ce ne soit pas un piège, une **pastille verte flotte sous la barre de navigation de l'accueil** (`bandeau_appel_groupe.dart`) : le nom du groupe, le nombre de personnes, un point qui respire, et « Revenir à l'appel ». Elle ne défile pas, elle ne pousse rien, et elle disparaît d'elle-même au raccrochage.
- **Les réactions s'envolent mieux** : chacune naît juste au-dessus du pouce — jamais derrière les contrôles, la hauteur est calculée sur la zone sûre du téléphone —, apparaît un peu trop grosse puis se pose, monte vite puis ralentit, tourne légèrement et emporte le nom de qui l'a envoyée, qui s'efface avant elle. Chaque auteur a son couloir : deux pouces levés ne se superposent jamais. Le rouet d'animation **s'arrête quand l'écran est vide** — un appel d'une heure ne doit pas redessiner pour rien.
- **Six nouvelles clés dans les dix langues** : `gcMinimize`, `gcVoiceOnly`, `gcReactWith`, `gcSpeakingNow`, `gcMicOff`, `gcReturnToCall`.
- **Fichiers** : `lib/features/call/group_call_screen.dart` (réécrit), `lib/features/call/bandeau_appel_groupe.dart` (nouveau), `lib/features/chats/chats_screen.dart` (la pastille dans l'emplacement flottant), les dix `.arb` et leurs fichiers générés.

## Le salon vocal porte enfin la voix

Jusqu'ici, « Ouvrir un salon » annonçait le salon sur le maillage et ouvrait un écran d'appel **vide** : personne ne rejoignait la salle du serveur, donc aucun son ne passait. Le maillage audio par le serveur existait déjà (`appel_groupe_internet.dart`), mais rien ne le branchait au salon. C'est fait.

- **Une seule salle par groupe, `salon_<groupId>`.** L'appel de groupe et le salon vocal partagent désormais la même pièce. Avant, l'appel entrait dans `appelgroupe_<id>` et le salon n'entrait nulle part : ouvrir un salon pendant qu'un appel tournait dans le même groupe aurait créé deux conversations parallèles que personne ne pouvait réunir. C'est aussi ce préfixe qui dit au serveur de ne réveiller personne par notification — seules les boîtes `inbox_` le font.
- **La chorégraphie, vérifiée plutôt que supposée.** La règle est que **l'arrivant appelle les présents** : une seule offre par paire, sans aucun message de coordination. J'ai simulé le protocole de 1 à 10 personnes, avec des départs au hasard : à huit, 28 liens, aucune offre croisée, aucune paire oubliée, et le neuvième est refusé proprement. C'est pour ça que `peer-joined` **n'ouvre pas** de connexion — il ne sert qu'à tenir la liste des présents à jour. S'en servir pour appeler aurait fait s'appeler les deux côtés en même temps.
- **Un hors-par-un sur le plafond** : le code comparait « mes connexions + 1 » au maximum et s'arrêtait donc une personne trop tôt — un salon annoncé à huit n'en tenait que sept.
- **Un salon n'a pas de liste d'invités.** Dans un appel, on sait d'avance qui on essaie de joindre ; dans un salon, on découvre les gens quand ils entrent. Le fournisseur se contentait de METTRE À JOUR les participants déjà listés : une personne inconnue se connectait, sa voix arrivait… et sa tuile n'apparaissait jamais. Elle est maintenant ajoutée à la volée, avec son pseudo.
- **Rester seul ne raccroche plus.** Dans un appel, se retrouver seul veut dire que l'autre a raccroché. Dans un salon, c'est l'état normal de celui qui vient d'ouvrir la porte : l'écran dit « En attente des autres… », montre votre propre tuile, et une ligne explique une fois que les membres verront le salon dans la discussion. Elle disparaît dès que quelqu'un entre.
- **Ce qui se dit au groupe, et quand.** L'annonce (`ouvrir` / `entrer`) ne part plus au moment du toucher mais **une fois vraiment dans la salle** : prévenir avant de savoir si le serveur nous accepte faisait apparaître chez tout le monde le bandeau d'un salon où personne n'était jamais entré. Et sortir se dit aussi, sinon le bandeau des autres continuait de nous compter.
- **Le refus « salon complet » atterrit là où on regarde.** Le serveur ne répond « complet » qu'une fois la connexion ouverte, donc bien après le bouton : attendre sa réponse aurait retardé TOUS les appels pour le seul cas rare où la porte est fermée. Le message s'affiche donc sur l'écran d'appel lui-même, à la place d'un « Appel terminé » qui n'expliquait rien.
- **Sans Internet, on le dit avant d'ouvrir un écran muet** ; si le serveur ne répond pas du tout, un bandeau le dit.
- **Rien à redéployer** : le serveur en production gère déjà `salon_`, le plafond de huit, `peer-joined`, `room-full` et le routage adressé (`to`) — c'est ce qui avait été déployé au tour précédent.
- **Limite assumée** : à huit, chaque téléphone tient sept connexions et envoie sa voix sept fois (~200 kbit/s montants). C'est la rançon du maillage complet ; au-delà il faudrait un mélangeur côté serveur, et ce sera une autre histoire.
- **Quatre nouvelles clés dans les dix langues** : `vrUnreachable`, `vrFull`, `vrWaiting`, `vrWaitingBody`.
- **Fichiers** : `signaling_client.dart` (deux événements de salon), `call_service.dart` (le `switch` scellé complété), `appel_groupe_internet.dart`, `mesh_provider.dart` (`entrerDansSalon`, accueil des arrivants), `chat_screen.dart` (le bandeau branche le son), `group_call_screen.dart` (l'attente et le refus).

## Droplet Pro, repris d'après la vidéo Telegram

La vidéo de référence a été relue image par image. Sa page Premium tient en trois plans : un fond qui ne change pas d'une page à l'autre, une étoile qui reste et s'incline, une feuille arrondie qui passe par-dessus et porte le contenu. C'est ce feuilletage qui fait qu'on feuillette **un** écran au lieu d'en enchaîner sept. Droplet n'en avait aucun des trois.

**Le défaut principal n'était pas cosmétique : l'écran Pro listait deux fois les mêmes fonctions.** « Ce que Pro apporte » et « Ce que le pack ouvre », l'une sous l'autre, tirées de deux catalogues séparés — « Vocaux en texte » ici, « Transcription » là — avec deux styles d'illustration et deux boutons qui ne faisaient pas la même chose. Les deux sont fondus en un seul catalogue (`avantages_pro.dart`), et c'est lui seul que la liste et les explications lisent.

- **L'application avait déjà le bon aperçu, il n'arrivait simplement pas jusqu'à la page.** `apercu_telephone.dart` contient le téléphone dessiné de Telegram (rayon à 6,7 % de la largeur, comme dans leur source), les étoiles avec leur rectangle d'exclusion, le dégradé qui glisse, et six démonstrations jouées avec les **vrais composants de Droplet**. La page d'explications, elle, montrait une icône dans un rond posée sur des anneaux. On ne lit plus ce que fait la fonction : on la voit.
- **Le septième aperçu manquait** : les autocollants n'avaient pas de scénario. `ScenarioAutocollants` a été écrit — la goutte de l'app arrive de côté, dépasse sa place et revient (`elasticOut`), comme un autocollant qu'on lâche. Ce n'est pas une image chargée, c'est le logo dessiné.
- **L'emblème** : une grande goutte translucide en haut, qui bascule de −14° à +14° sur l'ensemble du catalogue et dérive à contre-sens du doigt, trois fois moins vite que la feuille. Deux mouvements minuscules ; ce sont eux qui ancrent le regard.
- **Un conflit visuel trouvé au rendu** : le bandeau et l'aperçu portent chacun le dégradé premium, en diagonales différentes. À pleine force, ils se heurtaient au bord de la feuille et l'œil voyait deux fonds se disputer. L'aperçu est éclairci d'un sixième — il redevient ce qu'il est chez Telegram, un panneau posé sur le fond — et une ombre portée de deux points détache la feuille.
- **Les proportions sont calculées, pas devinées.** Le bandeau prend 22 % de la hauteur, pas 26 : au-delà, le téléphone dessiné tombait à 153 points de large, une vignette. À 22 % il en fait 167, et il reste lisible sur un 360×640. Le bloc de texte est borné à quatre lignes, parce qu'il est mesuré **avant** que l'aperçu reçoive ce qui reste — une traduction plus longue que le français aurait rogné le téléphone sans qu'on s'en aperçoive.
- **Le bouton d'achat ne faisait rien** : il était appelé avec un rappel vide. Il ne peut pas encaisser tout seul (le paiement demande un numéro), alors il fait la seule chose honnête — il referme l'explication, ramène à l'endroit où l'on paie, et un halo s'allume une seconde et demie pour qu'on sache où on a atterri.
- **Les couleurs de la liste ne sont plus choisies à la main** : c'étaient six teintes système sans rapport entre elles. Chaque ligne prend la sienne sur le dégradé premium selon sa place, si bien que la liste se lit comme une seule pièce. C'est l'astuce de Telegram, et elle ne coûte rien.
- **Les aperçus parlaient français dans toutes les langues.** « en ligne », « Message », « Traduit automatiquement » et les huit répliques des démonstrations étaient écrites en dur : un utilisateur russe ou chinois voyait des bulles en français sur l'écran où on lui demande de payer. Dix-sept clés ont été ajoutées dans les dix langues, **marqueurs de mise en forme compris** — chaque langue met en gras, en italique, en code et en spoiler ses propres mots. Et dans l'aperçu de traduction, la source n'est jamais dans la langue de l'utilisateur : elle est en anglais partout, sauf en anglais où elle passe au français — sinon l'original et sa traduction seraient le même texte et l'aperçu ne montrerait rien.
- **Fichiers** : `avantages_pro.dart` (catalogue unique), `avantages_screen.dart` (réécrit), `apercu_telephone.dart` (traductions + septième scénario), `fonctions_premium.dart` (réduit au dégradé et au bouton), `premium_screen.dart` (liste en double retirée, bouton branché), les dix `.arb` et leurs fichiers générés.

## Confidentialité, données, aide et contact

Droplet n'avait rien de tout cela : une petite feuille « À propos » avec trois puces et les mentions de licence. Ni politique de confidentialité, ni écran de données, ni aide, ni moyen de nous joindre — le seul contact existant était un bouton WhatsApp enfoui dans le tunnel d'achat Pro. Quatre écrans ont été écrits, et une section « Aide et confidentialité » les rassemble dans les réglages, à la place que leur donnent WhatsApp, Telegram et Signal : vers le bas, juste avant « À propos ».

**⚠️ Tout marche hors ligne, et c'est le point qui change tout.** Chez les trois autres, ces rangées ouvrent un navigateur — centre d'aide, FAQ, formulaire. Pour une application faite pour servir quand il n'y a pas de réseau, une aide qui exige Internet serait muette exactement au moment où quelqu'un se demande pourquoi son message ne part pas. Les réponses, les textes légaux et les coordonnées sont embarqués.

### Ce qui a été construit

- **La politique de confidentialité** couvre les douze points de l'article 13 du RGPD — identité du responsable, finalités, base légale, destinataires, transferts hors UE, durée de conservation, droits, retrait, réclamation, caractère obligatoire, décision automatisée. Chaque section porte en commentaire le point qu'elle couvre. Le modèle de ton est celui de Signal, remarquablement court et sans jargon.
- **Et elle est vraie.** Les quatre serveurs sont nommés un par un — annuaire, boîte aux lettres, mise en relation, relais — avec ce que chacun voit et ce qu'il ne peut pas voir. Le fait que l'annuaire et la boîte aux lettres passent par Tor y figure, comme le fait que Railway et Cloudflare sont américains. Une politique qui dit « nous ne collectons rien » et s'arrête là est une politique qui ment.
- **L'écran « Vos données »** reprend l'idée des étiquettes de confidentialité d'Apple, mais range selon la seule question qui compte pour une messagerie : *est-ce que cette ligne sort de mon téléphone ?* Trois sections — ce qui reste, ce qui passe par un serveur (avec le nom du serveur), et **ce qui n'existe pas, énuméré ligne par ligne**. C'est ce que les étiquettes d'Apple ne savent pas montrer : « aucune donnée collectée » y est une case vide, alors qu'une absence qu'on énumère se vérifie. En tête, le résumé en trois chiffres : 0 donnée de suivi, 0 compte, 4 serveurs — et on les nomme.
- **L'aide** : huit questions qui se déplient sur place, avec une recherche qui ignore les accents. Pas de navigation vers une page par question — sept allers-retours pour lire sept réponses, c'est ce qui rend les centres d'aide pénibles.
- **Le contact** garde de WhatsApp le canal unique, de Telegram le fait d'écrire à quelqu'un plutôt qu'à un ticket, et de Signal la possibilité de joindre le journal. **Et il fait ce que personne ne fait : il montre ce qui part avant que ça parte.** « Joindre les informations de diagnostic » est ailleurs une case qu'on coche sans savoir ce qu'elle contient ; ici le texte exact s'affiche, en clair, et c'est ensuite qu'on choisit de l'envoyer. Sur une application dont tout l'argument est « rien ne part sans vous », une case aveugle aurait contredit l'écran d'à côté.
- **Le pied de page dit qu'il n'y a pas d'équipe d'assistance, mais une personne**, et qu'une réponse peut prendre un jour ou deux. Mieux vaut le dire que laisser attendre.

### Deux décisions à connaître

- **La politique n'existe qu'en français et en anglais, délibérément.** Tout le reste — les 90 clés d'interface, les huit questions, les lignes de l'écran des données — est dans les dix langues. Pas le texte juridique : une tournure approximative en arabe ou en chinois créerait une obligation que personne n'a voulue, et c'est précisément le document où une traduction approximative devient une responsabilité plutôt qu'un défaut de finition. L'écran le dit en une ligne, avec un bouton pour passer d'une langue à l'autre, au lieu de le cacher.
- **`kEditeur` vaut « Droplet », sans personne nommée.** Le RGPD attend une identité précise ; c'est assumé et signalé dans le code. Un magasin d'applications européen pourra demander davantage le jour d'une publication officielle — le nom se met alors dans `contact_config.dart`, en une ligne, et se répercute partout, y compris dans la politique.

**Fichiers** : `core/config/contact_config.dart` (toutes les coordonnées, un seul endroit à changer), `features/aide/politique_texte.dart`, `politique_screen.dart`, `donnees_screen.dart`, `aide_screen.dart`, `contact_screen.dart`, `settings_screen.dart` (la section), `main.dart` (les quatre routes), les dix `.arb` et leurs fichiers générés.

## Les incohérences, traquées par classes plutôt qu'à l'œil

### Le vert qui mentait

« Par Internet il y a 3 j » s'affichait **en vert**. La cause n'était pas une couleur mal choisie : **le texte et la couleur étaient calculés par deux fonctions différentes**, l'une sur l'ancienneté du dernier signe de vie, l'autre sur le type de route. Deux calculs séparés finissent toujours par se contredire — celui-ci le faisait à l'écran.

Et le même contact était peint de **deux couleurs selon l'écran** : bleu « à portée » sur l'accueil, vert dans l'en-tête de conversation. Deux vocabulaires de couleur pour la même chose, dans la même application.

Une seule règle désormais, dans `etat_connexion.dart`, que les deux écrans appellent : **vert = joignable maintenant et c'est prouvé** (le maillage répond, ou un signe de vie Internet de moins de cinq minutes) ; **orange = ça bouge** ; **gris = tout ce qui est au passé**, y compris « joignable par Internet » sans preuve de présence. La route est déjà dite par les mots et par l'icône ; elle n'avait pas besoin d'un second canal. Le point de réseau global de l'accueil garde sa propre langue — il parle de ma connexion, pas de la présence de quelqu'un — et le code le dit, pour qu'on ne l'« harmonise » pas par mégarde.

### La double palette d'emoji

Sur un statut, ouvrir la réponse affichait **deux rangées d'emoji empilées** : celle de `_ReactionsRapides` et celle de `_ReplyBar`, avec les mêmes huit émojis **dans un ordre différent** (😍😂😮… contre 😂😮😍…). Une seule reste — celle du verre dépoli, qui a la forme et l'animation d'iOS — et la liste est devenue une constante unique.

### Le français en dur dans une app traduite en dix langues

Un audit automatique des seize écrans principaux a trouvé **quinze textes** qui échappaient aux traductions : les étiquettes d'accessibilité du cœur d'un statut et de la photo de profil, et dix messages d'erreur du composeur de statut (surchauffe, fichier trop lourd, format non pris en charge, vidéo illisible…). Tous passés en clés, dans les dix langues.

Le plus grave était invisible : **le contexte envoyé à l'assistant était écrit en français ET demandait explicitement une réponse en français**. Quelqu'un utilisant Droplet en chinois recevait une suggestion en français. L'instruction est maintenant rédigée dans la langue de la personne et nomme cette langue — un petit modèle suit bien mieux une consigne écrite dans la langue qu'on attend de lui.

### La markdown de l'assistant : six défauts trouvés en la testant

Le rendu était déjà complet (titres, listes imbriquées, code, tableaux, citations). Plutôt que d'y ajouter des fonctions, j'ai rejoué le parseur sur des sorties de modèle réalistes. Six défauts sont sortis, tous corrigés et tous vérifiés :

1. **Une fuite, amplifiée par le streaming.** Chaque lien fabriquait un `TapGestureRecognizer` dans `build` sans jamais le libérer — et la réponse arrive jeton par jeton, donc `build` est rappelé des centaines de fois par message. Ils sont maintenant mis en cache par adresse et libérés à la fermeture.
2. **Les échappements étaient ignorés** : `2 \* 3` affichait la barre, et `\_mot\_` passait carrément **en italique** — l'exact contraire de ce que demande l'échappement.
3. **Le texte d'un lien n'était pas mis en forme** : `[**la doc**](…)` montrait les astérisques. Et comme un reconnaisseur posé sur un span parent ne descend pas à ses enfants dans Flutter, il fallait l'attacher feuille par feuille, sinon un lien en gras n'était plus touchable du tout.
4. **Les URL à parenthèses étaient coupées** : un lien Wikipédia comme `…/Dart_(langage)` perdait sa fin, qui s'affichait en texte brut.
5. **L'imbrication supposait un pas de deux espaces.** La plupart des modèles indentent de quatre : leur premier niveau était compté comme le deuxième. Le pas n'est plus deviné — on relève les retraits réellement présents et leur rang donne le niveau.
6. **Les citations ne portaient que du texte** : une liste ou un titre cités s'affichaient avec leurs tirets et leurs dièses en clair. Leur contenu est réanalysé comme un document à part entière.

Et une septième, introduite puis rattrapée en la testant : `\$` dans une chaîne brute Dart reste un dollar échappé, donc `$` ne voulait plus dire « fin de texte » — une adresse en fin de phrase n'était plus reconnue du tout. Les treize cas (six corrections, sept non-régressions) sont rejoués et passent.

---

## Contraste : les remplissages pleins (29 septembre 2026)

**26 fichiers.** Corrige le premier des trois défauts relevés par l'audit en 20 critères : du texte blanc posé sur des teintes d'accent brutes, à 2,12:1 dans le pire cas — illisible dehors, c'est-à-dire là où Droplet sert.

### Ce qui a été ajouté dans `OuroColors`

| Nom | Rôle |
| --- | --- |
| `contraste(a, b)` | le rapport WCAG 2.1 entre deux couleurs opaques |
| `surRemplissage(teinte, {encre})` | la teinte poussée jusqu'à 4,5:1 avec son encre |
| `texteSurRemplissage(teinte)` | blanc, ou noir si la teinte est claire au point que le noir y lit à 12:1 |
| `accentRempli` / `texteSurAccent` | le couple prêt à l'emploi pour l'accent choisi |
| `bubbleOutgoingText` | l'encre des bulles envoyées, qui va avec `bubbleOutgoing` |

`accent` n'a pas bougé : c'est toujours ce qu'on **écrit sur** un fond. `accentRempli` est ce qu'on **peint derrière**. Les deux ne sont pas interchangeables, et c'est toute la correction.

### Résultat mesuré, les dix accents, les deux modes

Pire cas **4,50:1** (violet sombre), contre 2,02:1 avant. Vert 2,22 → 4,60. Menthe 2,12 → 4,52. Orange 2,20 → 4,51. Bleu 4,02 → 4,56.

L'encre est décidée sur la **variante claire** de l'accent et appliquée aux deux modes : sans cela, la menthe passait à une encre noire la nuit seulement, ce qui se lit comme un bug. Seul le jaune système, qu'aucun accent ne propose, garde son encre noire — l'assombrir jusqu'au blanc lisible en ferait un olive.

### Paliers de texte relevés

| Palier | Avant (clair) | Après | Cible |
| --- | --- | --- | --- |
| `secondaryLabel` | 3,44:1 | 7,01:1 | 7:1 |
| `tertiaryLabel` | 1,74:1 | 4,54:1 | 4,5:1 |
| `quaternaryLabel` | 1,37:1 | 3,03:1 | 3:1, **décoratif uniquement** |

⚠️ `quaternaryLabel` est le seul palier sous 4,5:1 et y reste pour que la hiérarchie garde quatre marches. Ses 15 emplois ont été vérifiés un par un : chevrons, points d'état, lettres d'avatar en 52 pt — aucun texte porteur de sens. Toute nouvelle utilisation sur du texte doit prendre `tertiaryLabel`.

### Un piège rattrapé au passage

`chat_screen.dart` décidait la couleur d'un bouton en comparant `style.color == Colors.white`. Dès que l'encre des bulles a cessé d'être blanc pur, le test échouait en silence et le bouton repassait en bleu au milieu d'une bulle colorée. Il mesure maintenant la luminance, ce qui reste vrai quelle que soit la teinte choisie.

**Vérification** : les 265 fichiers Dart de `lib/` sont réanalysés syntaxiquement ; les contrastes sont recalculés en rejouant la formule Dart à l'identique, pas estimés à l'œil.

---

## L'assistant : conversations, outils, artéfacts (29 septembre 2026)

**12 fichiers neufs, 69 chaînes dans dix langues.** L'assistant passe d'un fil unique et local à ce que font les grandes applications d'IA — sans rien perdre du hors-ligne, qui reste le défaut.

### Les fichiers

| Fichier | Ce qu'il fait |
| --- | --- |
| `core/services/groq_service.dart` | L'assistant en ligne : `openai/gpt-oss-120b`, flux, outils, annulation |
| `core/services/conversations_ia_store.dart` | Plusieurs conversations : renommer, épingler, chercher dans l'historique |
| `core/services/outils_assistant.dart` | Les outils déclarés, leur exécution, l'extraction des citations |
| `core/services/production_fichiers.dart` | txt, md, csv, json, html, code, pdf, docx, pptx, zip |
| `core/services/artefacts_store.dart` | Les artéfacts et leurs versions, et le seuil qui décide |
| `features/ai/assistant_tiroir.dart` | Le tiroir : destinations, épinglées, récentes, nouvelle session |
| `features/ai/conversations_screen.dart` | La liste plein écran et la recherche |
| `features/ai/composeur_assistant.dart` | Le composeur à deux étages |
| `features/ai/selecteur_moteur.dart` | Local / En ligne, et la proposition de refaire en ligne |
| `features/ai/journal_activite.dart` | Ce que l'assistant fait, montré puis relisible |
| `features/ai/actions_message.dart` | Le menu d'un message et l'index des chapitres |
| `features/ai/artefact_screen.dart` | La surface d'un artéfact : aperçu, source, versions |

### Trois décisions qui ne se devinent pas

**L'origine est enregistrée PAR MESSAGE**, pas par conversation. Une même conversation mélange les deux (on commence hors ligne, on refait une réponse en ligne) ; sans cette colonne, impossible de dire en relisant ce qui a quitté le téléphone.

**Les conversations et les artéfacts vivent dans leur PROPRE base** (`assistant_ia.db`), pas dans `app_database.dart`. Aucun lien avec le schéma du mesh : les y faire entrer imposerait une migration à toute l'application pour des tables qui ne parlent qu'à l'assistant.

**`browser_search` et `code_interpreter` sont exécutés par Groq**, pas par nous. Pas de deuxième clé API, pas de HTML à analyser, citations comprises. Conséquence assumée : ces deux outils n'existent qu'en ligne.

### Ce qui reste à brancher

Le câblage dans `ai_chat_screen.dart` : le tiroir sur le `Scaffold`, la boucle d'appel d'outils, et la détection d'artéfacts en fin de réponse. Tout le reste est autonome et testé.

### Ce qui a été vérifié, et comment

| Quoi | Méthode | Résultat |
| --- | --- | --- |
| Décodage du flux SSE | 6 scénarios × 40 découpages aléatoires | stable partout, JSON d'outil réassemblé |
| Schéma et requêtes SQL | rejouées contre un vrai SQLite | cascade et « modifier » corrects |
| Markdown → texte brut | 20 cas | 2 bugs trouvés et corrigés |
| Extraction des citations | 9 cas | dédoublonnage correct, crochets ASCII intacts |
| Détection des blocs de code | 8 cas | blocs non fermés ignorés |
| Seuil d'artéfact | 6 cas | `print()` reste, page web sort |
| docx et pptx | ouverts par `python-docx` et `python-pptx` | acceptés |
| Les 10 parties XML fixes | analysées une par une | toutes bien formées |
| Localisation | outil avec auto-vérification | 69 clés × 11 fichiers, aucun `\$` échappé |
| Syntaxe | tree-sitter Dart | 277 fichiers |

⚠️ **Aucune de ces vérifications n'est une compilation.** Le SDK Flutter n'est pas dans le conteneur où ce code a été écrit : les erreurs de type, les imports manquants et les signatures fausses ne sont PAS couverts. Le premier `flutter analyze` reste à faire.

### Les captures

Le dossier `captures/` contient onze rendus, un par écran. ⚠️ Ce ne sont pas des captures d'appareil : ce sont des images produites à partir des cotes, rayons et couleurs exacts du code, pour attraper les proportions fausses avant de compiler. Elles ont d'ailleurs servi : les rangées du tiroir étaient à 49 points au lieu des ~57 de la référence.

---

## Le câblage (29 septembre 2026)

`ai_chat_screen.dart` relie tout : le tiroir, le composeur, la boucle d'outils, les citations, les artéfacts et l'enregistrement.

### Ce qui change dans l'écran

- **Le `Scaffold` porte un `drawer`** — mais seulement quand la base des conversations est ouverte. Un tiroir vide qui glisse sur rien est pire que pas de tiroir.
- **Le chemin local n'a pas bougé d'une ligne.** `_envoyer` se contente de bifurquer sur `_moteur`. C'était le point le plus risqué du câblage : réécrire les deux chemins ensemble aurait rendu impossible de savoir lequel a cassé.
- **`_repondreEnLigne` est une boucle**, bornée à cinq tours. Le modèle peut demander un outil, recevoir son résultat, puis en demander un autre ; sans boucle on s'arrêterait au premier et la réponse serait amputée en silence. La borne existe parce qu'un modèle qui se trompe d'outil peut le redemander indéfiniment, et chaque tour est facturé.
- **L'ordre en fin de réponse est fixé** : citations extraites, PUIS artéfacts détectés, PUIS enregistrement. Dans un autre ordre, la base garderait un texte plein de marqueurs `【…†…】` que personne ne sait plus relire.

### Quatre défauts trouvés pendant le câblage

1. **`case MorceauOutils(:final appels appelsRecus)`** n'est pas un motif Dart valide — la forme correcte pour renommer un champ est `appels: final recus`. L'analyse syntaxique l'acceptait ; le compilateur ne l'aurait pas accepté.
2. **`Navigator.pushNamed('/aide')`** aurait compilé et échoué à l'exécution : l'application navigue avec go_router, pas avec des routes nommées.
3. **`AiMemoire.ajouter` / `.entrees` n'existent pas** — l'API réelle est `retenir` et `bloc`. Deux noms inventés de mémoire.
4. **`_nouvelleConversation` sortait sur `_messages.isEmpty`** : depuis le tiroir, « Nouvelle session » n'aurait rien fait sur un écran déjà vide, et on aurait cru le bouton cassé.

### Deux décisions prises seul

**`_arreter` arrête les DEUX moteurs**, sans tester lequel tourne. Tester `_moteur` serait juste la plupart du temps et faux dans le cas qui compte : si la personne bascule pendant la génération, on arrêterait celui qui ne travaille pas.

**Trois pièces jointes au plus.** Chacune est lue puis envoyée au modèle ; au-delà on dépasse la fenêtre de contexte et la requête entière échoue sans message utile.

### Vérifié

| Quoi | Résultat |
| --- | --- |
| 27 symboles importés existent dans leur fichier source | concordent |
| 25 paramètres nommés passés aux widgets | concordent |
| 7 méthodes de magasin appelées | existent |
| Méthodes appelées et non définies | aucune |
| Champs de `_AssistantMessage` inconnus | aucun |
| `switch` sur le flux scellé | les 4 morceaux traités |
| Syntaxe Dart, arbre entier | 277 fichiers |

⚠️ **Toujours pas une compilation.** Les types, la nullabilité et les signatures des paquets tiers (`Share.shareXFiles`, `FilePicker.platform.pickFiles`) ne sont pas couverts. `flutter analyze` reste le premier vrai juge.

---

## L'écran qui manquait, et trois bugs (29 septembre 2026)

### « Est-ce que l'IA en ligne marche vraiment ? » — non, et voici pourquoi

`definirCle()` existait dans le service, et **rien ne l'appelait**. Aucun écran pour saisir la clé, donc `_enLigneDisponible` restait faux pour toujours : la pastille était visible et le mode en ligne inaccessible. Un bouton mort — exactement ce qu'on s'interdit.

`reglages_assistant_screen.dart` comble ce trou, avec un **bouton « Tester la clé »** qui fait un appel réel de huit jetons et distingue les causes :

| Verdict | Ce que ça veut dire |
| --- | --- |
| La clé fonctionne | le mode en ligne est utilisable |
| Clé refusée | caractère perdu au collage, ou clé révoquée |
| Serveur injoignable | la requête n'est jamais partie — la clé n'est pas en cause |
| Modèle indisponible | clé acceptée, mais plus rien derrière ce nom de modèle |
| Trop de requêtes | la clé marche, le compte a atteint sa limite |

Sans ce test, le seul symptôme d'une clé mal copiée serait une réponse qui n'arrive jamais, au milieu d'une question, sans savoir si c'est la clé, le réseau ou l'application.

### L'API vérifiée contre la documentation

`max_completion_tokens` ✓ (et `max_tokens` est déprécié), `reasoning_effort` ✓ avec `medium` parmi les valeurs admises, `stream` / `tools` / `tool_choice` / `temperature` ✓. Le champ du raisonnement s'appelle bien `reasoning`, et il est inclus par défaut pour `gpt-oss-120b`.

⚠️ **Aucun appel réel n'a pu être fait** : `api.groq.com` est bloqué par la liste blanche du conteneur où ce code a été écrit. Le bouton « Tester » existe précisément parce que cette vérification-là ne peut se faire que depuis le téléphone.

### Trois bugs trouvés en répondant à la question

1. **Le flux était armé avec les outils intégrés de Groq**, alors que le fichier documentait le contraire. `repondre` accepte maintenant `flux:`, et l'écran passe `!contraintSansFlux(outils)`. Le chemin sans flux rend les mêmes morceaux que le flux, pour que l'appelant n'ait qu'une boucle à écrire.
2. **Deux `\$` échappés** dans le code que je venais d'écrire : `detail: '\$e'` affichait littéralement `$e` au lieu de l'erreur. Troisième fois que ce piège mord — il a maintenant son vérificateur, qui passe sur tout `lib/`.
3. **Et ce vérificateur a trouvé un bug qui n'était pas de moi.** `motifs_droplet.dart` mettait ses tuiles en cache sous la clé `'\$densite:\${pack.index}'` — littéralement la même chaîne pour **toutes** les densités et **tous** les packs. Le premier motif rendu était ensuite servi à tout le monde : flou sur un écran plus dense, et jamais changé quand on changeait de pack. Le cache marchait ; il cachait la mauvaise chose.

---

## Le premier `flutter analyze` (29 septembre 2026)

### Ce qui était de moi — corrigé

**Un `const` invalide**, `group_create_screen.dart:192`. En corrigeant les contrastes, j'avais retiré le `const` de l'`Icon` mais pas du `SizedBox` qui la suivait : `OuroColors.texteSurAccent` est un accesseur calculé à l'exécution (il dépend de l'accent choisi), donc il ne peut pas entrer dans une constante.

⚠️ **C'est une erreur que l'analyse syntaxique ne peut PAS voir** : le code est parfaitement bien formé. Elle a donc désormais son vérificateur — un script qui cherche toute expression `const` contenant un accesseur dynamique de `OuroColors`. Passé sur les 278 fichiers : celui-ci était le seul.

### Ce qui n'était pas une erreur de code

**Les 27 getters `ra*` manquants** ne manquent pas : ils sont bien dans les onze fichiers de localisation de la livraison, 26 clés déclarées dans la classe abstraite et complètes dans les dix langues. L'archive appliquée ne contenait que l'écran, pas les fichiers de localisation qui vont avec.

### Ce qui n'est pas de moi, et qui casse quand même

**`mise_en_forme.dart` à la racine du dépôt.** Il importe des chemins absolus d'une autre machine (`/home/effi/Musique/c/droplet/…`) et des fichiers qui n'existent pas. Ce n'est pas un fichier du projet : il traîne à la racine et `flutter analyze` le ramasse. À supprimer ou à déplacer hors du dépôt.

**Trois fichiers de test qui ne compilent plus** :

| Fichier | Ce qu'il cherche | État |
| --- | --- | --- |
| `test/discussions_finition_test.dart` | `features/chat/document_bubble.dart`, `estDocumentPdf` | le fichier n'existe plus |
| `test/fonctions_premium_test.dart` | `FonctionPremium`, `fonctionsPremium()` | remplacés par `AvantagePro` / `avantagesPro()` |
| `test/_tmp/apercu_vitrine_test.dart` | `ListeFonctionsPremium` | disparu avec la refonte de l'écran Pro |

Ces trois-là testent du code qui a été renommé ou supprimé. Deux options : les réécrire contre les noms actuels, ou les supprimer. `test/_tmp/` porte son statut dans son nom.

### ⚠️ Une erreur dans l'audit en 20 critères

Le critère 20 annonçait « **0 test, 0 test de capture d'écran** ». **C'était faux.** La mesure portait sur `lib/` seul, et le dossier `test/` n'était pas dans la copie analysée : j'ai rapporté une absence que je n'avais pas vérifiée. Il y a au moins trois fichiers de test — cassés, ce qui est un autre problème, mais pas le même.

Le reste de l'audit reposait sur des comptages faits sur des fichiers réellement lus. Celui-ci ne l'était pas.

---

## Plus de téléchargement à l'ouverture (30 septembre 2026)

Ouvrir l'assistant lançait le téléchargement des **529 Mo** du modèle local sans rien demander. Sur un forfait compté c'est une facture ; sur une connexion lente c'est un écran bloqué plusieurs minutes pour quelqu'un qui voulait poser une question. **Ouvrir un écran n'est pas consentir à un demi-gigaoctet.**

### Le nouveau parcours

1. L'écran s'affiche **immédiatement**, en mode **en ligne**.
2. Choisir « Local » ouvre un dialogue qui annonce la taille, ce qu'on y gagne, et qu'on peut continuer en ligne pendant le téléchargement.
3. Un refus laisse le moteur inchangé. Le téléchargement ne démarre qu'après un « Télécharger » explicite.
4. Pendant, un **bandeau** au-dessus du composeur montre la progression — l'assistant reste utilisable en ligne.

### Le piège évité

Sans `ensureDownloaded()` à l'ouverture, plus rien n'apprenait à l'application que le modèle était **déjà là** : quelqu'un qui l'avait installé se serait vu redemander 529 Mo — pire que le problème corrigé.

`estInstalle()` a donc été ajouté au service : il sonde le disque et **ne télécharge rien**. S'il rend `true`, l'écran charge le modèle en RAM et repasse en local tout seul ; s'il rend `false`, on reste en ligne sans toucher au réseau. C'est le seul appel automatique qui subsiste, et il est conditionné.

⚠️ `estInstalle()` rend `false` en cas d'erreur : mieux vaut proposer un téléchargement inutile qu'affirmer qu'un modèle absent est présent, puis échouer au premier message.

### Le revirement sur le défaut

`_moteur` était `local` par défaut, avec un commentaire disant « local par défaut, TOUJOURS ». Ce n'est plus vrai, et le fichier le dit : **le principe tient** (ce choix dit où part le message, et il appartient à la personne), mais un défaut qui exige d'abord 529 Mo, c'est choisir à sa place de dépenser son forfait. Le local reprend la main dès qu'il est installé.

### Au passage

Les trois vues plein écran (`_ChargementVue`, `_TelechargementVue`, `_ErreurVue`) n'ont plus d'appelant : **101 lignes de code mort supprimées**.

### Vérifié

Un audit automatique du flux : chaque appel à `ensureDownloaded()` est gardé, `estInstalle()` ne contient ni `download` ni `install()`, la taille annoncée vient de la constante `kAiModelTailleMo`, plus aucune vue ne bloque l'écran, et le moteur ne change jamais avant la confirmation.

---

## Le composeur en verre, et les photos (30 septembre 2026)

### Les messages passent SOUS le composeur

C'était une colonne : la conversation s'arrêtait net au-dessus du composeur, le dernier message se cognait à un bord opaque, et rien ne passait jamais derrière. C'est ce qui distingue une application soignée d'une autre — dans iOS, le contenu **glisse sous le verre et s'y estompe**.

C'est maintenant une **pile** :

- la liste occupe toute la hauteur, avec un rembourrage bas **égal à la hauteur mesurée du composeur** ;
- le composeur flotte par-dessus, dans un `OuroBlurSurface` dont l'`intensite` suit `extentAfter` — zéro en bas de conversation (rien derrière, donc aucun voile), plein dès qu'on remonte le fil.

⚠️ **La hauteur est MESURÉE, pas devinée.** Elle change avec le nombre de lignes tapées, les vignettes, le bandeau de téléchargement et la taille de police du système. Une valeur en dur laisserait le dernier message caché derrière le composeur chez quiconque grossit son texte.

Le filet de séparation suit le même voile : sur une conversation courte, il n'y a rien à séparer, donc pas de filet.

### Les photos et l'appareil photo

`_joindre` ouvrait un `FilePicker` — y compris pour « Appareil photo », qui ouvrait donc… un sélecteur de fichiers. Il appelle maintenant **`pickAttachment`**, la feuille des discussions, qui porte déjà la bande des photos récentes (`photo_manager`), l'appareil photo et le verre calibré du reste de l'application.

⚠️ **On n'écrit pas un deuxième sélecteur de médias.** Deux finiraient par diverger, et c'est exactement le défaut qu'on passe son temps à corriger ailleurs. Les trois choix qui n'ont pas de sens pour un assistant — sticker, position, sondage — sont ignorés silencieusement plutôt que masqués, ce qui ferait une deuxième feuille à maintenir.

### La bulle envoyée

Trois choses :

1. **Un défaut de contraste qui m'avait échappé** lors du passage sur les remplissages : elle utilisait encore `OuroColors.accent` avec du `Colors.white` en dur — le blanc à 2,22:1 sur un accent vert. Corrigé en `accentRempli` / `texteSurAccent`.
2. **Les images jointes s'affichent dans la bulle** : une seule occupe toute sa largeur, plusieurs se rangent en grille. Une photo réduite à la taille d'un ongle ne se regarde pas, elle se devine.
3. **Pas de rembourrage quand il n'y a qu'une image.** Une photo cernée de 14 points de bleu ressemble à un cadre photo de brocante.

### ⚠️ Ce qu'aucune capture ne peut montrer

L'effet de verre dépend du défilement : au repos, en bas de conversation, le composeur est **transparent**, parce qu'il n'y a rien derrière lui. Une image fixe d'une conversation au repos montre donc… un composeur sans verre, ce qui est correct et parfaitement inutile à regarder. Trois rendus ont été tentés puis jetés plutôt que d'en livrer un qui donnerait une fausse idée. Le mécanisme est vérifié dans le code, pas en image.

---

## La ligne qui ne menait nulle part (30 septembre 2026)

Sans clé, la feuille « Où part votre message » disait : *« Indisponible : aucune clé n'est configurée. Ajoutez-en une dans Réglages › Assistant. »*

**Deux choses fausses à la fois.** Ce chemin n'existe pas — l'écran est dans le **tiroir de l'assistant**, pas dans les Réglages de l'application. Et la ligne « En ligne » était **grisée et morte** : on lisait une consigne de navigation sous un bouton qui ne répondait pas.

### Ce qui change

La ligne reste **touchable** même sans clé, et elle emmène droit à l'écran où l'on met la clé. Le texte ne décrit plus une navigation mais le geste : *« Il faut une clé pour parler à un modèle distant. Touchez pour en ajouter une — c'est gratuit et ça prend une minute. »*

⚠️ **Un texte qui décrit une navigation est fragile** : la navigation change, le geste non. C'est précisément ce qui s'était produit ici — l'écran a déménagé dans le tiroir et la phrase est restée.

L'état `desactivee` a disparu de la feuille : griser une ligne, c'est dire « inutile d'essayer », et c'était faux.

### Le piège créé en corrigeant

Depuis que « en ligne » est le mode par défaut, quelqu'un **sans clé y est déjà**. Or la feuille ne prévenait l'appelant que si le choix DIFFÉRAIT du moteur courant, et `_changerMoteur` sortait aussi sur `voulu == _moteur` : la ligne serait redevenue muette, autrement.

Deux corrections : la feuille prévient **toujours** (c'est à l'appelant de décider s'il y a quelque chose à faire), et le test de la clé passe **avant** la sortie anticipée dans `_changerMoteur`.

---

## L'assistant passé à ses propres critères (30 septembre 2026)

On ne peut pas reprocher à l'application 232 durées en dur pour 6 jetons, puis livrer un assistant qui fait pareil. Les douze fichiers de `lib/features/ai/` ont donc été mesurés contre les critères de l'audit, et corrigés.

| | avant | après |
| --- | --- | --- |
| Durées littérales | 12 (toutes uniques) | **2** |
| Rayons littéraux | 6 | **2** |
| Courbes brutes de Flutter | 3 | **0** |
| Emplois de jetons | — | **164** |
| Garde-fous « réduire les animations » | 2 | 3 |

### Ce qui reste, et pourquoi

**`Duration(milliseconds: 530)`** — le rythme d'un curseur texte, hérité des premiers systèmes à fenêtres. Ce n'est pas une durée d'interface, c'est une constante du monde extérieur, comme 24 images par seconde. Elle est maintenant nommée `_rythmeCurseur` et documentée.

**`Duration(seconds: 2)`** — combien de temps « Copié » reste affiché. Le temps de LIRE un mot, pas d'animer quelque chose. Nommée `_tempsDeLire`.

**Rayons 1 et 2** — un filet de séparation et une barre de progression. Un jeton pour un cheveu serait du zèle.

**Les neuf durées de `lueur_gemini.dart`** sont exemptées, et l'exemption est **écrite en tête du fichier** plutôt que laissée muette — sinon le prochain audit les recomptera. Elles ne règlent pas une transition : elles composent une animation ambiante. La rotation de 7 s, la respiration de 3,2 s et le retour de 1,1 s ne coïncident jamais, et c'est ce décalage qui empêche la lueur de se répéter à l'œil. Les ramener à deux jetons donnerait trois cycles synchrones, donc un clignotement.

### Trois défauts visibles corrigés

**Les bulles étaient à 18, celles des discussions à 19.** Un point d'écart : invisible sur un écran, évident quand on passe de l'un à l'autre. Elles prennent maintenant `DesignTokens.radiusBubble`.

**L'écran d'accueil affirmait quelque chose de faux** : « Cet assistant tourne entièrement sur votre appareil — rien n'est jamais envoyé sur Internet ». C'était vrai quand le local était le défaut ; depuis qu'on ne télécharge plus 529 Mo sans le demander, le défaut est en ligne. **La phrase mentait, sur le premier écran.** Elle est partie sans remplaçante : la pastille du composeur dit déjà où part le message, en permanence et sans se tromper.

**Et il ne proposait rien.** Trois textes empilés, dont deux de la même couleur — on ne savait pas lequel lire en premier. Il en reste deux, qui ne se ressemblent pas, avec un salut par le prénom. Les pastilles de départ (« Explique-moi… », « Écris un message », « Résume ce texte », « Traduis en… ») vivent dans le composeur, au plus près du champ, et disparaissent dès la première réponse : des suggestions qui reviennent entre deux échanges ne sont plus une aide mais une distraction.

### Et les animations d'entrée respectent le réglage

`_AccueilVide` animait son apparition sans regarder « réduire les animations ». Ce réglage existe pour des gens que le mouvement met mal à l'aise : leur épargner les transitions puis leur faire glisser le premier écran du haut en bas, c'est rater le point exactement.

---

## Dix agents, un chef, et la production de projets (30 septembre 2026)

### ⚠️ D'abord une mauvaise nouvelle, vérifiée

**Groq n'a plus aucun modèle de vision.** Llama 4 Scout et Maverick — les seuls qui lisaient une image — ont été retirés le 17 juillet et le 9 mars 2026. `groq/compound`, le système agentique maison, l'a été le 21 septembre. `moonshotai/kimi-k2-instruct` en octobre 2025.

Conséquence : **l'assistant en ligne ne peut pas regarder une photo.** Il peut en produire (schéma, graphique) et lire un document texte, pas décrire une photographie. Aucun agent « vision » n'est déclaré : un rôle sans modèle échouerait à chaque appel.

### Le choix des agents, sur des limites vérifiables

Pas « celui-ci est meilleur », mais « celui-ci est le seul à… » :

| Agent | Modèle | La raison, en termes mesurables |
| --- | --- | --- |
| **chef** | `openai/gpt-oss-120b` | seul à porter `browser_search` et `code_interpreter` |
| recherche | `openai/gpt-oss-120b` | seul avec la recherche web · température 0,2 |
| calcul | `openai/gpt-oss-120b` | seul avec l'exécution de code · température 0,1 |
| **rédaction** | `minimaxai/minimax-m2.7` | **131 000 jetons de sortie** contre 65 000 au chef |
| **lecture** | `minimaxai/minimax-m2.7` | **196 000 jetons de contexte**, la plus grande fenêtre |
| rapide | `llama-3.1-8b-instant` | le plus rapide du catalogue |
| code | `qwen/qwen3.8-27b` | famille entraînée davantage sur du code |
| traduction | `llama-3.3-70b-versatile` | meilleur compromis taille / multilinguisme |
| relecture | `openai/gpt-oss-20b` | assez fin pour juger, assez petit pour ne pas coûter plus que l'écriture |
| garde | `llama-prompt-guard-2-86m` | entraîné pour ça seul, réponse en millisecondes |

⚠️ **`agents_groq.dart` est la seule table où un identifiant de modèle est écrit.** Vérifié par script : aucun autre fichier n'en nomme un. Groq en a retiré quatre en 2026 — il ne doit y avoir qu'un endroit à changer.

### La relève

Le chef a un outil de plus : `deleguer(collegue, consigne)`. Trois règles dans le code :

1. **Le collègue ne voit pas la conversation** — il travaille sur la consigne que le chef lui écrit, ce qui oblige ce dernier à être explicite.
2. **Le collègue ne reçoit aucun outil.** Deux modèles qui se délèguent l'un à l'autre consomment un quota entier sans rien rendre.
3. **Le chef ne délègue pas ce qu'il sait faire**, et sa consigne le dit en toutes lettres — un modèle à qui l'on donne un outil a tendance à s'en servir.

Le journal nomme le **rôle**, pas le modèle : « Confié à : écrit les documents longs » se comprend, `minimaxai/minimax-m2.7` non.

### Les projets complexes

`creer_projet` est séparé de `produire_fichier`, et c'est voulu : un projet n'est pas un gros fichier, c'est une arborescence. Laisser le modèle écrire du JSON d'archive à la main dans un champ de texte produit une archive où il manque un fichier sur trois.

⚠️ **Aucun chemin ne sort de l'archive** : `..` et les chemins absolus sont retirés. Le contenu vient d'un modèle, et une archive qui écrit ailleurs qu'en elle-même est une faille connue. Un `LISEZ_MOI.txt` est ajouté quand le modèle n'a pas prévu de point d'entrée.

### Les PDF se voient, enfin

Une pastille « rapport.pdf · 124 Ko » n'apprend rien : on ne sait pas si la mise en page tient, si le tableau est passé, si le document est vide. **La première page est maintenant rendue dans la conversation** (via `pdfx`), en proportion A4, et les images produites s'affichent directement. On juge sans ouvrir.

---

## Mode vocal — parler à l'assistant, l'entendre répondre

**Fichiers**

| Fichier | État |
|---|---|
| `lib/features/ai/mode_vocal.dart` | **nouveau** |
| `lib/features/ai/composeur_assistant.dart` | remplacer (paramètre `onVocal` + bouton onde) |
| `lib/features/ai/ai_chat_screen.dart` | remplacer (`_ouvrirVocal`, `_repondreVocalement`) |
| `lib/core/services/groq_service.dart` | remplacer (méthode `transcrire`) |
| `lib/l10n/app_*.arb` (×10) | remplacer — 13 clés `mv*` |
| `lib/l10n/generated/app_localizations*.dart` (×11) | remplacer |

**Aucun paquet ajouté.** `record`, `path_provider`, `path` et `flutter_tts`
étaient déjà dans `pubspec.yaml` ; la transcription passe par
`whisper-large-v3-turbo`, déjà au catalogue Groq.

**Deux boutons, et c'est voulu.** Le micro dicte dans le champ (on relit,
on corrige, on envoie). L'onde ouvre le mode vocal (on parle, ça répond à
voix haute). Claude et ChatGPT les séparent aussi ; les fondre donnerait
un bouton qui fait tantôt l'un tantôt l'autre.

**Le tour vocal passe par `_envoyer`** : ce qu'on dit à voix haute s'écrit
dans LE MÊME FIL, avec les mêmes outils, la même mémoire et le même
enregistrement. Pas de second historique à part.

**Sans clé, le bouton n'ouvre pas l'écran** — il mène à l'écran de
configuration. La transcription passe par le réseau : un écran vocal qui
s'ouvre puis échoue au premier mot ferait croire que le micro est cassé.

### Ce qui a été vérifié

- **Emballement de la boucle mains libres** — la machine à états a été
  rejouée hors Flutter sur quatre scénarios (micro muet, bruit seul,
  deux vides puis une phrase, maintien). Elle se borne à 3 tours vides
  dans tous les cas, et la phrase du scénario 3 atteint bien le chef.
  Sans ce compteur, un téléphone posé sur une table enchaînait les
  transcriptions — facturées — indéfiniment.
- **Débordement de l'onde** — la formule des hauteurs a été calculée sur
  toute la période : respiration 18→64, écoute 65,5→106, boîte 120.
  Rien ne sort, et les deux régimes restent distinguables à l'amplitude.
- **Double déclenchement en maintien** — `onTap` et `onTapDown` étaient
  branchés ensemble : le micro repartait tout seul au relâchement. Un
  seul des deux est actif selon la façon d'écouter.
- Les trois vérificateurs (syntaxe des 281 fichiers, dollars échappés,
  `const` contenant un accesseur dynamique) passent.

### Ce qui reste hors de portée

L'**écran en direct** demande un modèle de vision. Groq n'en sert plus
aucun depuis le retrait de Llama 4 Scout et Maverick. Ce n'est pas un
manque de temps, c'est une absence de modèle.

---

## Mode vocal, version 2 — sur le modèle de Gemini Live (avril 2026)

**Ce qui change, en une phrase :** le mode vocal n'est plus un écran noir
plein cadre, c'est une **couche posée à la place du composeur**. La
conversation reste visible derrière et défile pendant qu'on parle.

C'est le chemin que Google a fait en avril 2026 : Gemini Live a QUITTÉ le
plein écran, pour une raison qui vaut ici mot pour mot — « faire en sorte
que la conversation continue ressemble moins à un mode séparé qui prend
tout le téléphone ». Le plein écran cachait le fil au moment précis où le
tour vocal s'y écrivait.

### La forme, reprise de Gemini Live

| Gemini Live | Droplet |
|---|---|
| Barre du haut « Live with Gemini » | « En direct », avec l'étincelle animée |
| Bouton sous-titres en haut à droite | idem |
| Pastille en bas, **onde au centre** | idem |
| ✕ pour sortir | idem, à gauche |
| Micro coupé à droite | idem |
| Appareil photo + partage d'écran à gauche | **absents** — ils demandent un modèle de vision, et Groq n'en sert plus aucun |
| « Tap to interrupt » écrit à l'écran | « Toucher pour interrompre » |
| Onde **bleue** (la marque Google) | onde à **l'accent choisi dans Droplet** |

**La couleur n'a pas été reprise, et c'est délibéré.** Reprendre la forme
d'une interface est une chose ; reprendre la couleur d'une marque en est
une autre, et c'est celle qui se plaide.

### Les deux écarts assumés

**1. Les sous-titres ne s'affichent pas toujours.** Gemini n'écrit RIEN
dans le fil pendant qu'il parle — son transcript complet n'arrive qu'à la
fin — donc sa boîte est le seul endroit où lire la réponse. Ici, le tour
vocal s'écrit dans le fil en direct : quand la liste est collée en bas, la
boîte répéterait mot pour mot la bulle posée 40 points plus haut. La boîte
n'apparaît donc que lorsqu'elle sert vraiment — quand on a fait défiler
vers le haut pour relire et que la réponse est sortie du champ.

**2. Le maintien du doigt pour parler a disparu.** Gemini ne l'a pas : sa
réponse au bruit est le micro coupé, pas le doigt sur un bouton. Suivre
Gemini, c'était accepter ça aussi. Si le besoin revient, sa place est dans
les réglages de l'assistant, pas dans la pastille.

### Un doublon supprimé au passage

`mode_vocal.dart` nettoyait le markdown avant de le prononcer avec ses
propres expressions régulières, alors que `texteBrutDepuisMarkdown` existe
et passe par le MÊME analyseur que le rendu à l'écran. Les deux auraient
divergé au premier balisage tordu, et on aurait entendu autre chose que ce
qu'on lit. Il ne reste qu'une fonction, `texteAPrononcer`, qui appelle
l'analyseur commun et n'ajoute qu'une règle propre à la voix : **on ne
prononce pas les blocs de code**. « Lire à voix haute » dans le fil
l'utilise aussi désormais.

### Ce qui a été vérifié

- Les trois vérificateurs passent sur les 281 fichiers.
- **Débordement de l'onde**, recalculé pour la nouvelle boîte de 44 :
  respiration 8→28, écoute 6→42. Le calcul donnait exactement 44 à
  saturation — pile la hauteur de la boîte, donc aucune marge : le
  coefficient est passé de 38 à 36.
- **Largeur** : l'onde fait 49 px pour 294 px disponibles entre les deux
  ronds de 48.
- La borne à 3 tours vides de la version précédente est conservée.

### Fichiers

`lib/features/ai/mode_vocal.dart` (réécrit), `ai_chat_screen.dart`,
`composeur_assistant.dart`, les 10 `.arb` et les 11 fichiers générés
(20 clés `mv*`).

⚠️ Cinq clés de la version 1 ne servent plus (`mvHoldToTalk`,
`mvHandsFree`, `mvHold`, `mvInterrupt`, `mvTalk`). Elles ne gênent pas
`flutter analyze` ; elles sont laissées en place au cas où le maintien
reviendrait par les réglages.

---

## Vidéos de statut : n'importe quelle taille en entrée, 2 Mo en sortie

**Aucun code natif n'a été nécessaire.** `MediaBridge.kt` expose déjà
`compresserVideo` avec `coteCourt` et `debit` en paramètres ; tout tient
donc côté Dart. (Pour mémoire : ffmpeg n'était de toute façon pas une
option — FFmpegKit a été retiré le 6 janvier 2025 et ses binaires supprimés
des dépôts.)

### Ce qui change

| Avant | Maintenant |
|---|---|
| Une vidéo de plus de 12 Mo était refusée | Aucune limite de taille à l'import |
| Réencodage fixe 720p / 2 Mbit/s | Débit **calculé depuis la durée** pour tenir sous 2 Mo |
| Roue qui tourne | Pourcentage d'avancement |

La limite de 12 Mo reste pour les **photos**, où elle a un sens : une image
de 50 Mo est un fichier anormal, pas une photo.

### Comment on vise une taille

⚠️ **Aucun encodeur ne sait viser une taille.** On lui donne un débit, il
rend ce qu'il rend — et le VBR matériel d'Android dépasse couramment sa
consigne de 20 à 35 %. D'où deux temps : calculer, puis **vérifier et
recommencer**.

    débit total = (2 Mo × 8 × 0,90) ÷ durée      (la marge paie l'en-tête MP4)
    débit vidéo = débit total − 32 kbit/s de son

⚠️ **La définition se déduit du débit**, et c'est le point important.
Encoder du 720p à 150 kbit/s ne donne pas du 720p, ça donne une bouillie
de blocs en 720p. On vise 0,08 bit par pixel et par image, et on renverse
la formule pour en tirer la hauteur, arrondie à un multiple de 16 :

| Durée | Débit vidéo | Définition |
|---|---|---|
| 5 s | 2,99 Mbit/s | 720p |
| 15 s | 975 kbit/s | ~528p |
| 30 s | 471 kbit/s | ~368p |
| 60 s | 220 kbit/s | ~256p |
| 90 s | 136 kbit/s | 240p |

C'est l'arithmétique d'une taille imposée, pas un réglage à améliorer.
**Le budget vaut PAR SEGMENT** : le montage découpe déjà en tranches de
90 s, donc une longue vidéo devient plusieurs statuts, chacun sous la barre.

### Ce qui a été vérifié

La boucle a été rejouée ligne à ligne hors de l'application, avec un
encodeur simulé dépassant sa consigne de 1× à 2,5×, sur huit durées :

- **3 encodages au maximum**, jamais plus.
- **Aucun fichier intermédiaire oublié** dans le cache, dans aucun chemin.
- Une vidéo déjà sous 2 Mo et un natif en panne rendent l'original **sans
  aucun encodage**.
- Deux cas restent au-dessus de la cible : 75 s et 90 s avec un encodeur
  qui dépasse de **2,5×**, c'est-à-dire qui ignore la consigne. Un message
  le dit alors franchement plutôt que de publier en silence un statut qui
  mettra une éternité à traverser le maillage.

Deux défauts ont été trouvés par cette simulation, et par elle seule :
1. le plancher de débit était à 90 kbit/s, ce qui rendait la cible
   inatteignable dès qu'un encodeur dépassait de 2× — descendu à 60 kbit/s,
   avec la contrepartie assumée en commentaire ;
2. la boucle sortait dès que le calcul **tombait** sur le plancher, sans
   jamais l'essayer — elle l'essaie maintenant une fois, et une seule.

### Fichiers

`lib/core/services/media_service.dart`, `lib/features/status/status_composer.dart`,
les 10 `.arb` et les 11 fichiers générés (`scCompressing`, `scStillHeavy`).

---

## Wi-Fi Direct : la connexion qui n'arrivait plus

**Un seul fichier : `lib/core/services/native_p2p_transport.dart`.**

### Ce qui s'est passé

La régression vient du correctif de la **poignée de main** — celui qui a
apporté le vrai identifiant Droplet et réparé le chiffrement. Il était
juste ; il lui manquait deux garde-fous.

Un pair est inscrit dans `_connectedPeers` dès que `connectById()`
réussit, **avant** toute poignée de main. À partir de là, la boucle de
découverte le saute comme « déjà connecté ». Mais il n'est annoncé au
reste de l'application que quand sa carte de visite arrive — et celle-ci
était envoyée **une seule fois**, à l'instant précis où NOTRE canal
s'ouvrait, alors que le canal d'en face ne l'est pas encore.
`nearby_service` jette alors le message sans rien dire.

Résultat : deux téléphones techniquement connectés, invisibles l'un pour
l'autre, et aucune sortie de cet état tant que l'un des deux ne quitte pas
la portée. Avant ce correctif, le pair était annoncé dès la connexion —
d'où « ça se connectait dès l'ouverture ».

Deux défauts aggravants :

- **Une carte de visite reçue d'un appareil inconnu était jetée.** C'est le
  cas une fois sur deux : quand c'est L'AUTRE qui a gagné la course à la
  connexion, on n'a pas d'entrée pour lui, et on mettait sa présentation à
  la poubelle.
- **Le plafond de recul était à deux minutes.** Deux téléphones côte à côte
  atteignent sept échecs en une quinzaine de secondes ; ensuite chaque
  tentative est repoussée de deux minutes. Et comme les deux appareils
  reculaient du même délai exact, ils repartaient au même instant et
  échouaient de nouveau pour la même raison.

### Les corrections

| | |
|---|---|
| Carte de visite | réémise toutes les 1,2 s tant que la réponse n'arrive pas, 6 fois |
| Après 6 envois muets | la liaison est **défaite** pour pouvoir être refaite |
| Carte reçue d'un inconnu | on crée l'entrée et **on répond** (une seule fois : A→B, B→A, A→B, silence) |
| Plafond de recul | 2 minutes → **20 secondes** |
| Délai de recul | ±25 % de hasard, pour casser le synchronisme |
| Exposant du doublement | borné à 16 (au-delà, `1 << n` déborde l'entier) |
| `Timer.periodic` | annulés à l'arrêt du transport et à la perte du pair |

### Ce qui a été mesuré

Deux téléphones qui ouvrent l'application en même temps, rejoués 400 fois
hors de l'application, avec la logique du fichier : réémission à 1 Hz de
`getPeersStream`, une tentative à la fois, `BUSY` en cas de collision,
perte de la carte de visite quand le canal d'en face n'est pas ouvert.

| Perte de la carte | Avant : se voient | Avant : jamais en 5 min | Après : se voient | Après : médiane |
|---|---|---|---|---|
| 10 % | 314/400 | 86 | 400/400 | 2 s |
| 30 % | 190/400 | 210 | 400/400 | 2 s |
| 50 % | 94/400 | 306 | 400/400 | 2 s |
| 90 % | 6/400 | 394 | 400/400 | 8 s |

⚠️ **Le taux de perte est une hypothèse, pas une mesure** — d'où le
balayage. Ce qui ne dépend pas de l'hypothèse : avant, l'issue est
**binaire** (immédiat, médiane 0 s, ou jamais) ; après, elle est toujours
bornée. C'est exactement la signature décrite : « ça marchait dès
l'ouverture, maintenant c'est une éternité ».

⚠️ **La première version de cette simulation donnait 0/400 à l'ancien
code** — un chiffre flatteur et faux : une condition d'arrêt empêchait le
second téléphone d'envoyer sa propre carte. Corrigée avant d'être lue.

---

## La garde : le correctif n° 1 du rapport

**Fichiers :** `lib/core/services/garde_messages.dart` (nouveau),
`lib/core/repositories/mesh_repository.dart`, `test/garde_messages_test.dart`
(nouveau). **Aucun paquet ajouté** — `sqlite3`, `path` et `path_provider`
sont déjà dans `pubspec.yaml`.

### Le chiffre qui justifie tout le reste

`PremiumMessageQueue` est la couche « livraison garantie » actuelle. Son
recul est `2^n × 100 ms` plafonné à 30 s, avec `maxRetries: 6`. Le calcul
a été rejoué sur 500 tirages :

> **L'abandon définitif tombe entre 6,4 et 7,7 secondes (médiane 7,1 s).**

Un destinataire absent plus de sept secondes ne reçoit jamais le message,
et plus rien ne le repropose ensuite. La file vit en outre **en mémoire** :
application fermée, tout ce qui n'était pas parti n'existe plus.

Et la synchronisation différentielle ne comble pas ce trou :
`_envoyerOffreDeSynchro()` ne propose que les **statuts**
(`getActiveStatuses`). Les messages n'ont jamais eu de rattrapage.

### Ce que fait la garde

Une ligne par couple **(message, destinataire)**, sur disque. Reprise de la
table du Bramble Sync Protocol de Briar — **la spécification, sous
CC BY-SA 4.0, pas le code, qui est en GPLv3**. Cette distinction est ce qui
rend l'emprunt possible sans publier Droplet ni affronter le problème de
l'App Store.

La règle qui compte : **on n'abandonne pas avant sept jours.** Le recul
exponentiel espace les tentatives, il ne les arrête pas.

⚠️ **On réémet les octets d'origine**, on ne reconstruit rien. Refaire le
chiffrement des jours plus tard, avec un état cryptographique qui a pu
changer, donnerait un paquet que le destinataire ne saurait pas ouvrir — et
l'échec serait silencieux. Réémettre un chiffré identique est une
retransmission, pas un nouveau chiffrement : aucun nonce n'est réutilisé.

Branchements : `confier` à l'enfilement, `acquitter` sur l'ACK **pour ce
pair précis**, et `_remettreDues()` toutes les 20 secondes. Ce battement
n'est pas qu'un rattrapage de reconnexion : un message créé *pendant* une
session vivante mais instable n'avait rien qui le repropose, et c'est
exactement la classe de bogue « on était tous les deux là, et il n'est pas
arrivé ».

### Ce qui a été vérifié

Le SQL a été **rejoué contre un vrai SQLite** avant l'écriture du Dart :

| Vérification | Résultat |
|---|---|
| `ON CONFLICT DO NOTHING` ne remet pas le compteur à zéro | ✓ |
| `EXPLAIN QUERY PLAN` utilise bien `idx_garde_du` | ✓ (pas de parcours complet) |
| Délai sur 2000 essais | 2,3 s à 374,8 s, jamais négatif, jamais au-dessus du plafond |
| Paquet binaire relu à l'octet près, y compris avec des octets nuls en tête | ✓ |
| Acquitter un destinataire ne libère pas l'autre | ✓ |
| Purge : périmés et acquittés anciens effacés, le reste conservé | ✓ |

Simulation d'un destinataire absent, file actuelle contre garde :

| Absence | File en mémoire | Avec la garde |
|---|---|---|
| 5 s | perdu | livré |
| 1 min | perdu | livré |
| 1 h | perdu | livré |
| 1 jour | perdu | livré |
| 3 jours | perdu | livré |
| 8 jours | perdu | perdu (au-delà du TTL) |

Coût disque mesuré : **~380 octets par message en attente et par
destinataire**. Mille messages non livrés vers trois pairs : 1,1 Mo.

### Deux limites, dites franchement

1. **Les messages de groupe ne sont pas encore gardés utilement.** La cible
   enfilée est l'identifiant du GROUPE, pas celui d'un pair : la ligne ne
   sera jamais due ni acquittée, et vivra jusqu'à la purge des sept jours
   (~380 o chacune). Les messages 1:1, qui sont le cas qui posait problème,
   fonctionnent. Le correctif propre consiste à passer la liste des membres
   au site d'appel de l'envoi de groupe — un changement à faire et à
   compiler séparément.
2. **`GardeMessages.enMemoire` (pour les tests) ouvre SQLite en mémoire.**
   Sous `flutter test`, cela dépend de la bibliothèque SQLite du système.
   Si le test échoue au chargement, c'est cela et non la logique.

---

## Le bandeau d'appel en cours

**Fichiers :** `lib/features/call/bandeau_appel.dart` (nouveau),
`lib/main.dart`, `lib/core/models/mesh_message.dart`,
`lib/core/providers/mesh_provider.dart`, `test/bandeau_appel_test.dart`
(nouveau), les 10 `.arb` et les 11 fichiers générés (5 clés `ba*`).

### Ce qui est repris de WhatsApp

Sa barre historique ne montrait **que la durée**. Sa refonte (bêta
2.24.10.18, repérée par Android Police) y a ajouté un bouton micro et un
bouton raccrocher, pour la raison exacte qu'on rencontre ici : sans eux,
se couper le micro obligeait à rouvrir tout l'écran d'appel. C'est donc la
version refondue qui est reprise, pas l'ancienne.

### ⚠️ Une date, pas un compteur

La durée se calcule en soustrayant `debutConnexion`, figée au décrochage.
Un compteur incrémenté par un `Timer` dérive : Android gèle les minuteurs
d'une application en arrière-plan, et on revient d'un appel de dix minutes
en lisant « 4:12 ». Le minuteur qui bat dans le bandeau ne sert qu'à
**redessiner** ; s'il saute un battement, l'affichage saute une seconde
puis se rattrape.

`copyWith` ne sait pas remettre un champ à `null` : sans le drapeau
`effacerDebut`, le bandeau du prochain appel afficherait la durée du
précédent. Les **neuf** fins d'appel du notifier le passent.

### Détails qui ne se voient qu'une fois en main

- **Chiffres de largeur fixe** (`FontFeature.tabularFigures`). Sans eux la
  durée tressaute à chaque seconde, le « 1 » étant plus étroit que le « 8 ».
- **Le vert est corrigé avant d'être posé.** `presenceMaintenant`
  (48, 209, 88) avec du blanc ne fait que 2,2:1. `OuroColors.surRemplissage`
  l'assombrit jusqu'à (30, 135, 56), soit **4,59:1** — au-dessus du seuil
  WCAG. C'est la machinerie déjà en place depuis l'audit.
- **Le bandeau ne s'affiche pas sur l'écran d'appel** : le chemin courant
  est lu sur le routeur, pas sur le contexte — cette surcouche vit
  au-dessus du routeur, où `GoRouter.of(context)` lève une exception.
  C'est le même piège que celui déjà documenté sur l'appel entrant.
- **Il est placé SOUS les fenêtres d'appel entrant.** Une sonnerie doit
  rester la chose la plus visible de l'écran.
- **Cible tactile de 44** pour des boutons dessinés à 28, dans un bandeau
  de 40 : la zone touchable compte plus que le dessin.

### Vérifié

`formaterDureeAppel` rejouée sur 13 cas, dont deux qui arrivent vraiment :
une **horloge qui recule** pendant l'appel (resynchronisation réseau —
sans la garde on lirait « -1:-3 ») et un appel de **plus de 24 heures**.
13/13. Les quatre vérificateurs passent sur `lib/` et `test/`.

### Ce qui n'est PAS fait : les appels joignables

C'est l'autre moitié de la demande, et c'est un changement de **protocole**,
pas d'interface. Chez WhatsApp, l'état « un appel est en cours » est tenu
par le serveur ; quelqu'un qui revient en ligne l'apprend en se
reconnectant, et voit « Appuyer pour rejoindre » dans l'onglet Appels.

Droplet n'a pas de serveur qui tienne cet état pour le maillage. Le
mécanisme équivalent serait une **réannonce périodique** : tant qu'un appel
de groupe dure, un participant rediffuse « appel en cours dans G depuis T,
participants P » toutes les N secondes. Qui revient à portée reçoit la
prochaine annonce et voit le bouton rejoindre ; personne n'a besoin d'avoir
été là au début. `AppelGroupeInternet.rejoindre(moi:, groupId:)` existe
déjà — c'est la brique d'arrivée. Manquent : un type de paquet, la boucle
d'émission, un registre local avec péremption, et la ligne dans la liste.

Ce n'est pas long, mais cela touche le format de fil, et je ne peux ni
compiler ni tester sur deux téléphones d'ici. À faire dans un tour dédié.

---

## La notification « appel en cours », hors de l'application

**Fichiers :** `lib/core/services/notification_service.dart`,
`lib/core/providers/mesh_provider.dart`, les 10 `.arb` et les 11 fichiers
générés (3 clés `ntf*`). **Aucun paquet ajouté.**

Marche pour les **deux chemins** : elle ne lit que l'état d'appel, qui est
commun au maillage et à Internet. Le sous-titre dit lequel.

### ⚠️ Le minuteur est dessiné par Android, pas par Droplet

`usesChronometer: true` plus `when` = l'instant du décrochage : **le
système compte tout seul**. Une durée écrite par l'application se figerait
au moment exact où elle devient utile — quand Android gèle le processus
parce qu'on a quitté l'app. C'est le même principe que le bandeau, mais ici
c'est le système qui tient l'horloge.

### Pas de `CallStyle`, et pourquoi

`Notification.CallStyle` est le gabarit d'Android 12+ fait exactement pour
ça, avec son bouton « Raccrocher » dessiné par le système et un rang
privilégié en haut de la liste. **`flutter_local_notifications` ne l'expose
pas** — sa documentation d'`AndroidNotificationDetails` n'en parle nulle
part. L'atteindre demanderait du code natif.

Une notification permanente de catégorie `call`, avec chronomètre et un
bouton « Raccrocher », rend le même service. Elle ne gagne pas le rang
privilégié, et sur Android récent elle peut rester balayable si aucun
service de premier plan de type `phoneCall` ne la porte — ce point-là est
une modification du manifeste Android, donc de votre côté.

### Un seul point de branchement, pas douze

L'état d'appel est modifié à **trois** endroits pour le décrochage et
**neuf** pour la fin. Poser un appel de notification à chacun garantissait
qu'un futur chemin en oublierait un — et l'oubli se voit de la pire façon :
une notification d'appel permanente, pour un appel raccroché depuis
longtemps, qu'on ne peut pas balayer. Tout passe donc par un
`addListener` unique sur l'état.

⚠️ `addListener`, **pas** un override du setter `state` : ce setter est
`@protected` dans `state_notifier`, le redéfinir est du bricolage sur
l'API interne d'un paquet.

### Deux défauts trouvés par la simulation, pas par la relecture

La machine à états a été rejouée sur six chemins d'appel :

1. **Bascule directe d'un correspondant à l'autre** (un appel en attente
   pris à la volée) : chaque pair a sa propre notification, avec sa propre
   clé. L'ancienne n'était jamais fermée — elle serait restée à l'écran
   pour toujours, non balayable.
2. **Coupure passagère** (Wi-Fi ↔ 4G) : la condition regardait
   `connectionState`, qui retombe en `connecting` deux secondes. La
   notification disparaissait et réapparaissait à chaque hoquet du réseau.
   Elle ne regarde plus que « l'appel existe-t-il encore ».

⚠️ **La première version de la simulation ne gardait qu'une notification
en mémoire** et masquait donc exactement le défaut n° 1 qu'elle devait
trouver. Corrigée avant d'être lue.

Après correction, les six chemins — appel normal, 300 mises à jour du
niveau sonore pendant l'appel, échec avant décrochage, raccrocher puis
rappeler, bascule directe, coupure/reconnexion — ne laissent **aucune
notification orpheline**, et l'appel normal n'en affiche qu'une seule.

---

## L'écran de partage depuis une autre application

**Fichiers :** `lib/features/share/share_target_screen.dart` (réécrit),
`lib/shared/taille_lisible.dart` (nouveau),
`lib/features/settings/stockage_screen.dart` (doublon retiré), les 10 `.arb`
et les 11 fichiers générés (5 clés `sh*`).

### ⚠️ Le défaut corrigé d'abord n'est pas esthétique

**L'écran faisait confirmer à l'aveugle.** Pour un fichier, l'aperçu
affichait un trombone et « 3 éléments à partager » : ni nom, ni taille, ni
image. Et un **seul appui sur un nom envoyait**, immédiatement, sans
confirmation.

Les deux défauts ensemble donnaient le pire enchaînement possible : un
appui de travers expédiait un fichier qu'on n'avait pas identifié à
quelqu'un qu'on n'avait pas choisi — et un message envoyé ne se rattrape
pas.

Désormais : on **voit** (vignette réelle pour une image, nom et taille pour
un fichier, extrait pour du texte), on **choisit** un ou plusieurs
destinataires, on appuie sur **Envoyer**.

### Ce qui fait la finesse

- **Grand titre repliable** (`OuroLargeTitleScaffold`). Cet écran était le
  seul de l'application à avoir une barre plate, et ça se voyait.
- **Rangée de récents** avant la liste — le geste de la feuille de partage
  d'iOS. Neuf partages sur dix visent quelqu'un qu'on vient de croiser.
- **Sélection multiple** avec coches, et une **barre d'envoi en verre**
  posée sur la liste qui glisse dessous, jamais une colonne qui coupe le
  défilement net.
- Composants de la maison (`OuroListRow`, `DesignTokens`, `OuroHaptics`) au
  lieu des `ListTile` bruts et des marges écrites à la main (16, 8, 14, 12).
- Vignettes colorées par genre : violet vidéo, orange audio, rouge PDF,
  gris archive, vert document.

### Détails qui évitent un défaut réel

- **La coche prend son encre de l'accent**, pas du blanc : avec un accent
  menthe ou jaune, un coche blanc disparaît. Même règle que depuis l'audit.
- **Une taille nulle s'écrit « — », pas « 0 o »** : zéro veut dire
  « fichier introuvable », et « 0 o » ferait croire à un fichier abîmé.
- **`Image.file` a un `errorBuilder`** : une image partagée peut être un
  fichier temporaire déjà effacé par l'application d'origine. Sans repli,
  tout l'écran se remplit d'une exception de rendu.
- **La barre d'envoi est enveloppée d'un `Material`.** Elle vit dans une
  `Stack` à côté du scaffold, donc hors de son `Material` : Flutter y
  dessinerait le double soulignement jaune déjà documenté dans `main.dart`.
- **Plusieurs destinataires → retour à la liste**, pas à une conversation :
  en ouvrir une seule laisserait croire que les autres n'ont rien reçu.

### Un doublon évité

`tailleLisible` vivait dans `stockage_screen.dart`. Un deuxième écran qui
en a besoin avait deux choix, tous deux mauvais : importer un écran depuis
un autre écran, ou recopier la fonction. La fonction est donc passée dans
`lib/shared/`, et `stockage_screen.dart` l'importe — une copie en moins,
pas une de plus.

---

## La pastille d'appel dans la barre d'état (CallStyle natif)

**⚠️ CETTE PARTIE DEMANDE DU KOTLIN, ET UNE LIGNE DANS `MainActivity.kt`.**
C'est exactement ce que j'avais signalé comme hors de portée en Dart pur.

### Pourquoi la version Dart ne suffisait pas

`flutter_local_notifications` n'expose pas `CallStyle` — sa documentation
d'`AndroidNotificationDetails` ne le mentionne nulle part. Or c'est
`CallStyle`, **porté par un service de premier plan de type `phoneCall`**,
et lui seul, qui donne :

- la **pastille dans la barre d'état**, combiné + minuteur, visible depuis
  l'écran d'accueil ;
- le bouton **« Raccrocher » dessiné et traduit par Android** (on ne peut
  volontairement pas le renommer) ;
- le rang privilégié en haut du volet.

La notification Dart avec `usesChronometer` donne la durée dans le volet
déroulé, jamais la pastille.

### Les deux conditions d'Android, non négociables

Vérifiées par le système au démarrage du service :

1. `FOREGROUND_SERVICE_PHONE_CALL` déclarée ;
2. **ET** `MANAGE_OWN_CALLS` déclarée **ou** être l'application téléphone
   par défaut.

Droplet prend `MANAGE_OWN_CALLS` : permission de manifeste, sans fenêtre de
demande, et c'est exactement ce pour quoi elle existe — une application qui
gère ses *propres* appels. **Sans elle, le service est refusé et la
pastille n'apparaît jamais.** Les deux sont ajoutées au manifeste.

Et `startForeground()` doit être appelé **dans les cinq secondes** sur
Android 14+ : c'est pourquoi il est la première ligne d'`onStartCommand`,
avant tout accès disque ou réseau.

### Les fichiers

| Fichier | État |
|---|---|
| `android/.../AppelEnCoursService.kt` | **nouveau** — le service et la notification |
| `android/.../AppelActionReceiver.kt` | **nouveau** — le bouton « Raccrocher » |
| `android/.../AppelNotifPont.kt` | **nouveau** — la télécommande côté Dart |
| `android/app/src/main/AndroidManifest.xml` | 2 permissions, 1 service, 1 receiver |
| `lib/core/services/appel_systeme.dart` | **nouveau** |
| `lib/core/providers/mesh_provider.dart` | choisit natif ou Dart |

### ⚠️ LA SEULE CHOSE À FAIRE À LA MAIN

Une ligne dans votre `MainActivity.kt` (que je n'ai pas dans mon
exemplaire du dépôt) :

```kotlin
override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    AppelNotifPont.brancher(this, flutterEngine)   // ← celle-ci
    // …vos autres ponts…
}
```

Envoyez-moi `MainActivity.kt` et je vous le rends fusionné.

### Le repli, et pourquoi il compte

`AppelSysteme.demarrer` rend `false` si le pont natif est absent
(`MissingPluginException`) ou si Android refuse le service
(`PlatformException`) — et l'appelant retombe alors sur la notification
Dart, qui marche déjà. **Une fonctionnalité native absente ne doit jamais
faire disparaître celle qu'elle remplace.** Donc : si vous compilez le Dart
sans ajouter la ligne ci-dessus, rien ne casse ; vous gardez simplement la
notification sans pastille.

Et jamais les deux à la fois : deux notifications d'appel empilées, dont
aucune ne se balaie, serait pire que l'une ou l'autre.

### Trois pièges traités dans le code

- **`Number`, pas `Long`, pour lire la date.** Un entier venu de Dart
  arrive en `Integer` sous 32 bits et en `Long` au-delà ; un
  `argument<Long>` rendrait `null` sans prévenir et le chronomètre
  repartirait de zéro — un appel de dix minutes afficherait « 0:00 ».
- **Le bouton arrête le service AVANT de prévenir Dart.** Si le moteur est
  mort, prévenir Dart échoue ; sans cet ordre, on garderait une
  notification d'appel permanente, non balayable, pour un appel raccroché.
- **`START_NOT_STICKY`.** Un service d'appel ressuscité par le système
  afficherait une notification d'appel pour un appel qui n'existe plus.

### Ce que je n'ai pas pu vérifier

Je n'ai pas de compilateur Android ici. L'équilibre des accolades et des
parenthèses est contrôlé, la logique est relue, mais **le Kotlin n'a pas
été compilé**. Deux points à surveiller au premier build :
`androidx.core` doit être assez récent pour `NotificationCompat.CallStyle`,
et l'appui sur la notification rouvre l'application sans forcément revenir
à l'écran d'appel — le bandeau en haut s'en charge une fois dedans.

### Mise à jour : `MainActivity.kt` fusionné, et un défaut qu'il a révélé

`MainActivity.kt` reçu et fusionné. Deux lignes ajoutées :
`AppelNotifPont.brancher(...)` dans `configureFlutterEngine`, et
`AppelNotifPont.debrancher()` dans `onDestroy` — sans cette seconde, on
garderait une référence sur un moteur mort et le bouton « Raccrocher »
écrirait dans un canal détruit.

**Le fichier a corrigé une erreur de ma part.** J'avais inventé la clé
d'extra `droplet_route` ; la vraie est **`payload`**, lue par
`siAppelEntrant()` et rangée dans `routeLancement`, que Dart vient
chercher par `routeDeLancement`. Avec ma clé, l'appui sur la notification
aurait rouvert l'application sur l'écran quitté, pas sur l'appel. Même
chose pour l'action : `ACTION_VIEW`, comme `publierRaccourci`, et non
`ACTION_MAIN`.

**Et il a révélé une limite qui préexistait.** `main.dart` ne lit
`routeDeLancement()` **qu'une seule fois, au démarrage**. Application
simplement en arrière-plan, l'intent arrive par `onNewIntent`, l'activité
repasse devant… et plus personne ne lit la route. `siAppelEntrant` pousse
donc désormais la route sur le canal quand le moteur est vivant
(`AppelSysteme.onRoute`, branché dans `main.dart`). Les deux chemins
coexistent sans se gêner : au démarrage le canal n'existe pas encore et
`routeLancement` prend le relais.

Cela vaut pour **toute** notification portant un `payload` vers
`MainActivity`, pas seulement la nouvelle — l'appel entrant plein écran en
bénéficie aussi.

**Il ne reste rien à faire à la main.** Les cinq fichiers Kotlin sont
cohérents (références croisées vérifiées, accolades équilibrées), le
manifeste est valide. Le Kotlin n'est toujours pas compilé de mon côté.

---

## Les photos de profil qui ne s'affichaient pas

**Vous en aviez repéré deux. Il y en avait vingt-six.**

### La cause, en une phrase

`PeerAvatar` **ne va pas chercher la photo tout seul** : il affiche ce
qu'on lui passe dans `imagePath`, et retombe sur l'initiale quand on ne lui
passe rien. L'oubli ne produit **aucune erreur, aucun avertissement** —
juste une lettre à la place d'un visage.

C'est exactement ce que montrait votre capture de l'onglet Actus : la ligne
« Reçus » affichait le visage de Kollol parce qu'elle passait
`imagePath: AvatarService.cheminPair(dernier.authorId)` ; la vignette
juste au-dessus, pour la même personne sur le même écran, affichait un
« K ».

### Un vérificateur pour cette famille de défaut

`avatars.py` parcourt tout `lib/`, apparie les parenthèses de chaque
`PeerAvatar(...)` et liste ceux qui n'ont pas d'`imagePath`. Il ne dit pas
qu'un appel est faux — certains sont légitimes — il dit lesquels regarder.
Il en a trouvé **26**.

### Les 13 corrigés

| Écran | Source de la photo |
|---|---|
| Actus — vignette d'un contact | `cheminPair(dernier.authorId)` |
| Actus — ma vignette | `chemin(currentUser?.avatarUrl)` |
| Lecteur de statut — en-tête | `cheminPair(status.authorId)` |
| Lecteur de statut — note vocale | `cheminPair(status.authorId)` |
| Lecteur de statut — « vu par » | `cheminPair(v.viewerId)` |
| Discussions — deux listes + une carte | `cheminPair(c.peerId)` |
| Appel en cours — plein écran | `cheminPair(widget.peerId)` |
| Appel entrant 1:1 | `cheminPair(peerId)` |
| Appel entrant de groupe | `cheminPair(fromPeerId)` |
| Membres d'un groupe | `cheminPair(m.peerId)` |
| Création de groupe | `cheminPair(candidate.peerId)` |
| Réseau maillé — ligne et détail | `cheminPair(peer.peerId)` |
| Contacts bloqués | `cheminPair(id)` |
| Pair scanné par QR | `cheminPair(peer.peerId)` |
| Composeur de statut — moi | `chemin(currentUser?.avatarUrl)` |

⚠️ **Un piège évité de justesse.** Les deux fenêtres d'appel entrant de
`main.dart` ont le même appel à la lettre près, mais pas le même champ :
`peerId` pour l'appel 1:1, **`fromPeerId`** pour celui de groupe. Un
remplacement global des deux aurait cassé la compilation. C'est en
vérifiant la classe englobante de chaque occurrence que je l'ai vu.

⚠️ **Et un faux positif utile.** L'en-tête de conversation a deux branches :
celle du 1:1 passait déjà la photo, celle du groupe ne le peut pas — un
groupe n'a pas de pair unique. Le vérificateur la signale ; elle est
correcte telle quelle.

### Les 13 restants

Ils demandent d'ouvrir chaque fichier pour trouver l'identifiant du pair
dans la portée, et je ne peux pas compiler : je préfère ne pas les toucher
à l'aveugle après la quasi-erreur ci-dessus. Lancez `avatars.py` pour les
lister — ou dites-le-moi et je les fais un par un, en vérifiant chacun.

---

## L'appui long sur une conversation : un vrai coup d'œil dans la discussion

**Fichiers :** `lib/features/chats/apercu_conversation.dart` (nouveau),
`lib/features/chat/message_context_menu.dart`,
`lib/features/chats/chats_screen.dart`, les 10 `.arb` et les 11 fichiers
générés (6 clés `apc*`).

### Ce que faisait l'aperçu, et pourquoi ça ne suffisait pas

Il montrait **la ligne elle-même**, reconstruite à l'identique et posée sur
une carte. C'est-à-dire : exactement ce qu'on avait sous les yeux une
demi-seconde plus tôt, au même endroit. Le geste coûtait une attente pour
n'apprendre rien.

Chez Apple, l'aperçu d'un menu contextuel est un **coup d'œil dans la
destination** : `previewProvider` rend un contrôleur de vue dimensionné par
`preferredContentSize`, et toucher l'aperçu valide la navigation
(`willPerformPreviewActionForMenuWith`). C'est ce que fait WhatsApp sur
iOS, et sur cette liste précisément — son menu contextuel de liste de
discussions est d'ailleurs le premier de l'app à être passé en Liquid
Glass en 2026, avant celui des messages.

### ⚠️ Ce qui l'interdisait dans le code

Tout le placement du menu était calculé sur `origin.height` — la hauteur de
la **ligne touchée**. Un aperçu plus haut se faisait recouvrir par le menu,
un aperçu plus large était tronqué. L'aperçu ne pouvait donc rien être
d'autre qu'une copie de la ligne.

`showMessageContextMenu` prend maintenant `previewHeight`, `previewMargin`
et `onPreviewTap`. Sans `previewHeight`, **le comportement d'avant est
inchangé** — les bulles de message ne bougent pas d'un pixel.

### Trois décisions qui se voient

- **L'aperçu grandit, il ne se contente pas de glisser.** Position ET
  taille sont interpolées de la ligne vers la carte : c'est le geste d'iOS,
  où l'élément touché devient la destination.
- **Le contenu apparaît en fondu pendant l'agrandissement.** Peint dès le
  premier pixel, un fil de discussion entier se tasserait dans la hauteur
  d'une ligne pendant toute la montée — on verrait des bulles écrasées
  puis se détendre.
- **Un fondu en haut de la carte.** Sans lui, le message du haut est
  tranché net au milieu d'une ligne de texte, ce qui se lit comme un
  défaut d'affichage.

### Un défaut préexistant corrigé au passage

La place de la barre d'émojis (66 points) était réservée **même quand elle
n'est pas affichée**. Invisible tant que l'aperçu était minuscule ; mais
c'est autant de hauteur volée à un coup d'œil. Elle n'est plus comptée que
si elle existe.

### Et un null-assert retiré

`c.groupId!` était sûr en pratique, mais `isGroup` se déduit du TYPE de la
conversation, pas de la présence de l'identifiant. Une exception dans un
geste aussi courant qu'un appui long est le pire endroit pour en avoir une.

### Ce qui a été vérifié

Le placement a été rejoué hors de l'application sur **trois tailles
d'écran** (iPhone 15, SE, Pro Max) × **trois positions de ligne** (haut,
milieu, bas), plus le cas extrême « petit écran, 9 actions, aperçu de 400
demandé ». Dans tous les cas : rien ne sort de l'écran, le menu ne recouvre
jamais l'aperçu, et l'aperçu ne devient jamais plus petit que la ligne
touchée (il paraîtrait rétrécir au lieu de grandir). Sur le petit écran
chargé, c'est bien **l'aperçu qui cède** — ramené à 207 points — et pas le
menu : sans les actions, l'appui long ne sert à rien.

Le comportement des bulles de message a été rejoué séparément : identique
à avant, au point près.

### Volontairement pauvre

L'aperçu ne charge pas les images, ne lit pas les vocaux, n'affiche ni
réactions ni réponses citées. Il est construit **pendant** une animation de
320 ms : tout ce qui coûte cher à peindre se paie en saccade, au moment
précis où le geste doit paraître fluide. Un média est annoncé par un mot.

---

## Le panneau de stickers à la place du clavier

**Fichiers :** `lib/features/chat/sticker_picker.dart`,
`lib/features/chat/chat_screen.dart`, les 10 `.arb` et les 11 fichiers
générés (1 clé `chKeyboardTooltip`). **Aucun paquet ajouté.**

### D'abord : les stickers existent déjà

`sticker_picker.dart`, `animated_sticker.dart`, `AnimatedStickerCatalog`,
le format **`.tgs` de Telegram** (du Lottie gzippé, joué par `lottie` sans
embarquer `rlottie` en natif), les lots, les récents, l'aperçu dans la
liste des discussions — tout est là et fonctionne. Il n'y avait rien à
construire de ce côté.

### Ce qui manquait : le geste

L'icône était **à gauche**, visible en permanence, et ouvrait une **feuille
modale**. Trois conséquences :

1. Une cible de plus à éviter du pouce pendant qu'on tape, pour une action
   qu'on ne fait jamais au milieu d'une phrase.
2. La feuille se pose PAR-DESSUS : le clavier se referme sous elle et la
   barre de saisie disparaît — on ne peut plus écrire en cherchant un
   sticker.
3. Aucun chemin de retour évident vers le clavier.

Le geste d'iOS — iMessage, WhatsApp, Telegram — est différent : le bouton
**remplace** le clavier par la grille, au même endroit et à la même
hauteur, et son icône **devient un clavier** pour faire le chemin inverse.

### Ce qui a été fait

- L'icône passe **à droite**, et n'apparaît que sur un **champ vide**.
- Elle devient **un clavier** quand le panneau est ouvert.
- Le panneau est **en ligne, sous le composeur**, dans la même colonne : il
  pousse la conversation vers le haut exactement comme le clavier qu'il
  remplace, et la barre de saisie reste utilisable.
- La grille a été sortie de sa feuille (`PanneauStickers`), qui subsiste
  pour les autres appelants.
- Le panneau **reste ouvert** après un envoi : on enchaîne deux ou trois
  stickers sans le rouvrir.
- Le **bouton Retour d'Android** referme le panneau au lieu de quitter la
  conversation.

### ⚠️ Le détail qui fait tout : la hauteur

Le panneau doit faire **exactement** la hauteur du clavier. Une valeur
fixe donnerait un bond de quelques dizaines de points au moment précis de
la bascule — et c'est ce bond qui fait qu'une application « ne fait pas
iOS ». La vraie hauteur est donc retenue dès qu'elle se montre
(`MediaQuery.viewInsetsOf`), avec un seuil de 80 pour écarter la barre de
suggestions, qui pousse les encarts sans que le clavier soit ouvert.

Et **on retire le focus AVANT d'ouvrir** : sans cela le clavier reste
affiché SOUS le panneau, les deux s'empilent, l'écran se décale du double
et la conversation disparaît.

### Vérifié

La bascule a été rejouée hors de l'application sur cinq enchaînements :
écrire → stickers → clavier, stickers d'emblée, stickers → Retour Android,
quatre aller-retours rapides, et toucher le champ pendant que le panneau
est ouvert. **Dans aucun cas le clavier et le panneau ne coexistent**, et
la hauteur reste à 336 d'un bout à l'autre — aucun saut. Ouvert sans que
le clavier se soit jamais montré, le panneau prend la valeur de repli de
300 ; c'est le seul cas où un ajustement se verra, à la première ouverture
du clavier.

## La feuille de pièces jointes, façon Telegram

`lib/features/chat/attach_sheet.dart` est réécrit. Ce n'est plus une liste
d'actions avec une bande de six photos : c'est une **grille de galerie en
pleine largeur, à sélection multiple**, et les autres sources descendent
dans une barre d'onglets en bas.

### Ce qui manquait, précisément

L'ancienne version avait deux limites, liées l'une à l'autre :

* **on ne voyait que six photos.** Au-delà, il fallait appuyer sur
  « Galerie », quitter l'application, traverser le sélecteur système et
  revenir — pour la septième photo de la pellicule ;
* **on ne pouvait en envoyer qu'une.** Trois photos d'affilée, c'était
  trois fois tout le parcours.

### Ce qui a été construit

* une grille à **3 colonnes**, 2 points d'espacement, qui défile ;
* la **sélection multiple**, et le rond porte le **numéro de rang** — pas
  une simple coche : c'est l'ordre d'envoi, et c'est ce qui permet de le
  choisir au lieu de le subir ;
* le **chargement par pages de 60**, avec deux écrans d'avance ; une
  photothèque de dix mille éléments ne s'énumère pas pour un panneau qu'on
  referme au bout de trois secondes ;
* un **cache de vignettes tenu par la feuille**, pas par la case : une
  case de grille est détruite dès qu'elle sort de l'écran, et sans ce
  cache, remonter de deux écrans redemande au système chaque vignette
  qu'on vient de voir ;
* la **barre d'onglets** (Galerie, Fichier, Position, Sticker, Sondage)
  qui **devient la barre d'envoi** dès qu'une photo est cochée — elle ne
  s'y ajoute pas : garder les onglets offrirait cinq façons de perdre la
  sélection qu'on vient de faire ;
* l'envoi des photos **une par une, dans l'ordre choisi**, chacune passant
  par l'aperçu d'envoi : les expédier d'un bloc sauterait la légende, et
  quelqu'un qui en coche cinq n'aurait plus moyen d'en légender une seule.

Les vignettes passent par `thumbnailDataWithSize(300)` puis
`Image.memory(cacheWidth: 300, cacheHeight: 300)` — le chemin déjà éprouvé
dans `recent_media_strip.dart`. Sans ces deux bornes, Flutter décode la
vignette à la résolution de l'écran et la garde ainsi : on annulerait tout
le bénéfice d'avoir demandé une petite image.

### Trois défauts trouvés avant livraison

1. **Une poignée en double.** `FrostedSheet` en dessine déjà une, aux
   dimensions exactes d'iOS. La mienne s'empilait deux points plus bas —
   le genre de détail qu'on ne nomme pas en le voyant, mais qui fait dire
   « c'est mal fini ». Supprimée.
2. **La roue qui tourne sans fin.** Sur un téléphone sans aucune photo,
   l'accès est accordé et la grille reste vide : le panneau paraissait
   cassé. Il dit maintenant « Aucune photo ni vidéo sur ce téléphone »
   (nouvelle chaîne `asEmptyGallery`, dans les dix langues).
3. **Un filet manquant.** La grille se termine toujours sur une rangée
   **coupée** — c'est elle qui dit qu'il y a autre chose en dessous. Sans
   trait de séparation, cette rangée tronquée et la barre du bas se
   touchaient, et l'ensemble se lisait comme une bouillie de rectangles.

### Vérifié

La mise en page a été rejouée hors de l'application sur trois écrans, dans
les deux états (onglets / envoi) :

| Écran | Feuille | Grille | Côté d'une case | Rangées visibles |
|---|---|---|---|---|
| iPhone SE (375×667) | 413 | 307 | 122 | 2,5 |
| iPhone 15 (393×852) | 528 | 408 | 128 | 3,1 |
| Pixel 8 Pro (412×892) | 553 | 443 | 135 | 3,2 |

Dans tous les cas la dernière rangée est **partiellement coupée**, ce qui
est voulu : une grille qui se termine pile sur une rangée entière paraît
finie, et on ne pense pas à la faire défiler.

### ⚠️ Une erreur de compilation attrapée au passage

`chat_screen.dart` appelait `_sendSticker()`, **une méthode qui n'existe
pas**. L'appel est remplacé par `_basculerStickers()`, le panneau de
stickers en ligne : rouvrir ici une feuille modale donnerait deux
sélecteurs de stickers d'aspect différent dans la même application, selon
le chemin emprunté pour y arriver.

Ce défaut était invisible pour les vérificateurs existants — appeler une
méthode inexistante est **grammaticalement parfait**. D'où un sixième
vérificateur permanent, `membres.py`, qui lit l'arbre syntaxique et
signale tout `_methode(...)` sans déclaration correspondante. Il raisonne
par **bibliothèque** et non par fichier, pour ne pas crier à tort sur les
fichiers `part` (`texte_mis_en_forme.dart` appelle `_BlocCode`, déclaré
dans `mise_en_forme.dart`). Projet entier : **aucun autre cas**.

### Un fichier devenu orphelin — à vérifier avant de supprimer

`lib/features/chat/recent_media_strip.dart` n'a plus aucun appelant :
c'était la bande de photos récentes de l'ancienne feuille, et la grille
l'a remplacée. **Je ne l'ai pas supprimé.** Vérifiez vous-même :

```sh
grep -rn "RecentMediaStrip\|recent_media_strip" lib/ test/
```

Si cela ne renvoie que le fichier lui-même, il peut partir.

## La barre de saisie façon Telegram — première étape

Le code source de Telegram pour Android a été récupéré et **mesuré** :
`ChatActivityEnterView.java` (15 745 lignes), `BlobDrawable.java`,
`CubicBezierInterpolator.java`. Chaque constante reprise porte en
commentaire sa ligne d'origine.

### ⚠️ Pourquoi les fichiers ne sont pas « pris »

Deux raisons, l'une technique et l'autre juridique.

**Technique** : c'est du Java Android qui dessine au pixel sur un
`Canvas`. `RecordCircle` est une classe interne de `ChatActivityEnterView`
qui hérite de `View`. Il n'y a pas une ligne transposable dans Flutter.

**Juridique** : Telegram Android est sous **GPL v2**. Recopier du code
verbatim obligerait Droplet à passer en GPL et à publier l'intégralité de
ses sources. Ce qui est repris ici, ce sont les **seuils** et l'**ordre
des transitions** — le comportement, pas l'expression.

### Ce qui est fait

**`lib/features/chat/geste_enregistrement.dart`** — la machine à états,
sans Flutter, sans horloge, donc **rejouable hors application** :

| Mesure | Valeur | Origine |
|---|---|---|
| Attente avant enregistrement | 150 ms, **et seulement si la caméra existe** | CAEV.java:3059-3064 |
| Course de glissement | `min(largeur × 0,35 ; 140 pt)` | CAEV.java:3183-3186 |
| Annulation en glissant | progression **0** (il faut aller au bout) | CAEV.java:3204 |
| Annulation en relâchant | progression **< 0,45** | CAEV.java:3097 |
| Annulation sur interruption | progression **< 0,70**, sinon **verrouillage** | CAEV.java:3069-3084 |
| Verrouillage | **57 pt** vers le haut | CAEV.java:2148 |
| Rayon du cercle | **41 pt** au silence → **71 pt** à pleine voix | CAEV.java:2002-2003 |
| Suivi du niveau | écart parcouru en **375 ms** | CAEV.java:2073 |

Les **trois seuils d'annulation différents** ne sont pas une incohérence :
glisser à moitié puis relâcher est une hésitation, donc on annule ; se
faire interrompre par un appel entrant n'est pas une décision, donc on
garde — en verrouillant.

**`lib/features/chat/cercle_enregistrement.dart`** — le cercle, les deux
gouttes organiques (11 et 12 points, nombres premiers entre eux pour
qu'elles ne retombent jamais en phase) et le cadenas qui se ferme puis
devient bouton pause.

### Ce que l'ancien code faisait de faux

L'ancien `_RecordDrag` décidait avec deux seuils en dur (96 et 56) et une
règle maison (`-dy > -dx * 0.8`). Rejoué, il se trompait sur deux points :

1. glisser à moitié puis relâcher **n'annulait pas** ;
2. une interruption système **jetait** l'enregistrement.

Un appel `_sendSticker()` vers une méthode inexistante dormait par
ailleurs dans `chat_screen.dart` — corrigé, et un sixième vérificateur
(`membres.py`) empêche désormais ce cas.

### Vérifié

* **Machine à états** : 15 enchaînements rejoués, dont la diagonale du
  pouce (glisser à gauche puis monter ne doit **pas** verrouiller),
  l'interruption système, le retour en arrière après glissement. Le seuil
  de relâchement mesuré au point près : envoie jusqu'à 75 pt, annule à
  partir de 76 — exactement `(1 − 0,45) × course`.
* **Gouttes** : contour fermé à 10⁻⁶ pt près, et à rayons égaux l'écart au
  cercle parfait est de 0,065 pt (l'erreur connue de l'approximation de
  Bézier à 12 segments).
* **Niveau du micro** : la courbe a été comparée à celle de Telegram sur
  un signal de parole simulé. **Écart maximal : 0,00 point de rayon.**

### Trois défauts trouvés à la mesure

1. **La goutte était tranchée net.** À pleine voix elle atteint 130 pt de
   rayon ; le cadre de 194 pt la coupait des quatre côtés — un bord droit
   au milieu d'une forme organique. Porté à 280.
2. **Le rayon montait par marches.** Le lissage était fait au rythme des
   relevés du micro (80 ms) : jusqu'à **10 pt d'écart** avec Telegram. Le
   calcul a été déplacé dans l'horloge du cercle, à 60 images/seconde.
3. **La pente était recalculée au mauvais moment.** Telegram la recalcule
   à **chaque** relevé, même quand le niveau n'a pas bougé — ce qui rend
   l'approche asymptotique. Ne la recalculer que sur changement donnait
   encore 5 pt d'écart. D'où le champ `releve` : deux relevés de même
   valeur sont deux évènements distincts.

### Ce qui n'est PAS encore fait

* **La vidéo ronde par le bouton micro.** `videoPossible` est à `false` :
  sans caméra, l'attente de 150 ms et la bascule micro↔caméra
  n'existent pas — c'est exactement ce que fait Telegram quand la caméra
  n'est pas disponible. La branche `basculerMode` est écrite ; il n'y
  aura qu'un drapeau à retourner.
* **Le texte « glisser pour annuler »** à la lettre : le chevron qui
  oscille de ±6 pt toutes les 250 ms, et le bouton CANCEL en gras.
* **Le chrono** qui remplace ses chiffres un par un (glissement de 15 pt,
  116 ms).
* **La pastille « vue unique »** au-dessus du cadenas, qui n'apparaît
  qu'après le verrouillage.

## La barre de saisie façon Telegram — finitions et vidéo ronde

### Les trois finitions d'affichage

**`lib/features/chat/barre_enregistrement.dart`** :

* **Le chrono au centième**, dont chaque chiffre est *remplacé* et non
  réécrit (glissement de 15 pt, 116 ms — CAEV.java:14295, :14439). Les
  centièmes n'ont aucune valeur de lecture — personne ne les lit — mais
  ils ont une valeur de **preuve** : un compteur qui n'avance qu'une fois
  par seconde laisse, neuf dixièmes du temps, une interface strictement
  immobile, et on doute que ça enregistre.
* **L'invite « ‹ glisser pour annuler »**, dont le chevron oscille de
  ±6 pt — **et seulement tant que le doigt n'a pas démarré**
  (CAEV.java:14186-14196). Dès qu'on agit vraiment, l'agitation devient du
  bruit. Une fois verrouillé, l'invite devient un vrai bouton ANNULER.
* **La pastille « vue unique »** au-dessus du cadenas, qui n'apparaît
  **qu'après le verrouillage** (CAEV.java:1691-1693) : tant que le doigt
  est posé, une cible qu'on ne peut pas atteindre n'est pas une option,
  c'est une frustration. Elle comble au passage un vrai trou : le bouton
  « 1 » de la barre disparaissait avec la barre, donc on ne pouvait pas
  régler la vue unique pendant un enregistrement.

Vérifié : le chrono se calcule par **différence de dates** et ne dérive
pas (contrôlé sur 125 s avec 2 % d'images sautées) ; 85 % des
rafraîchissements ne changent **qu'un seul caractère**.

### La vidéo ronde

**`lib/features/chat/video_ronde.dart`** — 384 pt, 1000 kb/s image,
64 kb/s son, coupure à 59,5 s (MessagesController.java:1635-1637,
CAEV.java:14350).

Un **appui court** sur le bouton bascule micro ↔ caméra ; un **maintien**
enregistre. L'aiguillage vocal/vidéo se fait en **un seul endroit** : le
bouton, le geste et la barre ignorent complètement qu'il existe deux
sortes de prise, ce qui garantit que le glissement pour annuler et le
verrouillage se comportent exactement pareil dans les deux cas.

La caméra s'allume **dès la bascule**, pas à la pose du doigt :
l'initialiser prend 300 à 600 ms, et la première seconde d'un message
vidéo, c'est le bonjour.

#### ⚠️ Le fichier n'est pas carré, l'affichage l'est

Telegram encode un vrai 384×384 : il a son propre encodeur OpenGL qui
recadre pendant la capture. Droplet n'en a pas. Ce que ça coûte
réellement : les pixels hors du cercle sont encodés pour rien, environ
27 % du débit sur une source 4:3 — d'où la capture en `medium` et le
passage par la compression avant envoi. Ce que ça ne coûte pas : **l'image
affichée est identique au pixel près**.

### ⚠️ Trois erreurs de compilation attrapées, et deux vérificateurs de plus

Les six vérificateurs existants ne pouvaient voir aucune des trois : elles
sont **grammaticalement parfaites**.

1. **Collision de noms.** `PastilleVueUnique` existait déjà dans
   `vue_unique.dart` quand j'en ai écrit un autre dans
   `barre_enregistrement.dart` — et `chat_screen.dart` importe les deux.
   En Dart, l'erreur ne tombe pas à l'import mais à l'utilisation, et
   parle d'ambiguïté, pas de doublon. Renommé en `BoutonVueUnique`, et
   **`collisions.py`** signale désormais tout nom public apporté deux fois
   dans un même fichier.
2. **Champ lu depuis une autre classe.** `_debutEnregistrement` est
   déclaré dans `_InputBarState` ; je l'ai employé depuis
   `_ChatScreenState`, 6 000 lignes plus haut *dans le même fichier*. Le
   nom existe, donc rien ne le signalait. D'où **`champs.py`**.
3. **Le même défaut, en plus grave.** `_recDrag` était dans la barre de
   saisie alors que la **surcouche flottante** (cercle, cadenas) le lit
   aussi — et elle n'est pas dans la barre. L'objet est remonté dans
   l'écran et passé à la barre. Au passage : la barre le **libérait** dans
   son `dispose`, ce qui l'aurait rendu inutilisable dès la première
   reconstruction — c'est-à-dire à chaque caractère tapé.

`champs.py` a d'abord sorti trois faux positifs (des accesseurs et des
méthodes pris pour des champs d'une autre classe) ; la règle a été
resserrée avant d'être retenue. **Projet entier : aucun autre cas.**

### Un défaut de contraste corrigé en passant

Le bouton « 1 » de la barre écrivait son chiffre en `Colors.white` en dur
sur fond accent. L'accent étant réglable, un accent clair — menthe, jaune —
le rendait illisible. Remplacé par `OuroColors.texteSurAccent`, qui choisit
l'encre d'après la luminosité réelle.

## L'animation d'envoi de message

### ⚠️ Le code n'est pas repris verbatim, et ne peut pas l'être

Deux raisons, les mêmes que pour la barre de saisie. **Technique** : c'est du
Java qui peint sur un `Canvas` Android — `TextMessageEnterTransition` étend
`View`, rien n'est transposable en Flutter. **Juridique** : Telegram Android
est sous **GPL v2** ; recopier obligerait Droplet à publier l'intégralité de
ses sources. Ce qui est repris, ce sont les **valeurs** et la
**chorégraphie**.

### La transition TEXTE existait déjà — elle a été vérifiée, pas réécrite

`lib/features/chat/transition_envoi.dart` avait été écrit plus tôt. Plutôt
que de le refaire, il a été **confronté point par point** au relevé fait
dans le source. Les sept valeurs attendues y sont :

| Valeur | Origine |
|---|---|
| durée **250 ms**, horloge linéaire | ChatListItemAnimator.java:46 |
| verticale `cubic-bezier(0.1992, 0.0106, 0.2792, 0.9103)` | ChatListItemAnimator.java:47 |
| horizontale `easeOut ∘ easeOutQuint` | TextMessageEnterTransition.java:474-475 |
| opacités : rampe **linéaire** saturée à t = 0,4 | TMET:472 |
| débordement du bord droit de 4 pt, résorbé | TMET:495 |
| cible **remesurée à chaque image** | TMET:453-468 |
| échelle de départ = taille du champ ÷ taille de la bulle | TMET:211 |

**Le piège principal** : `progressX` n'est pas une courbe, c'en est **deux
composées**. Une seule cubique ne la reproduit pas. Rejoué, le décalage
mesuré est net :

* l'horizontale atteint 90 % à **58 ms**, la verticale à **174 ms** ;
* avance maximale de l'horizontale sur la verticale : **+0,587** à t = 0,20 ;
* le crossfade est terminé à **100 ms**, la géométrie continue jusqu'à 250.

C'est ce décalage — et rien d'autre, aucun arc dessiné — qui donne au texte
sa trajectoire courbe.

### La transition VOCALE manquait — elle est faite

`lib/features/chat/transition_vocale.dart`. Ce n'est pas la même animation,
et elles ne sont pas interchangeables :

| | Texte | Vocal |
|---|---|---|
| Durée | 250 ms | **220 ms** |
| Verticale / rayon / couleur | bézier de la liste | `cubic-bezier(0.25, 0.1, 0.25, 1)` |
| Horizontale | `easeOut ∘ easeOutQuint` (**deux** courbes) | `easeOutQuint` (**une** seule) |
| Ce qui voyage | deux textes + deux fonds | **un disque** |

Pour un texte, Telegram fait voyager deux rendus du texte et deux fonds.
Pour un vocal il n'y a rien à métamorphoser : le cercle d'enregistrement
**est** déjà un disque, et la bulle vocale en contient un — le bouton de
lecture. L'animation se réduit à un trajet.

Les **ondes s'éteignent sur les 60 % premiers** (VMET:101-103), pas sur
toute la durée : mesuré, elles ont disparu à 132 ms alors que le disque
n'arrive à 95 % qu'à 160 ms. Une bulle vocale qui se pose avec des ondes
encore accrochées ressemble à un enregistrement qui continue.

**Vérifié** : les quatre valeurs sont dans le Dart ; l'avance maximale de
l'horizontale est de +0,387 (trajectoire courbe) ; et l'écart entre
l'horizontale du vocal et celle du texte atteint **0,187** — assez pour que
les garder séparées soit justifié, et non une complication gratuite.

### Un détail repris de Telegram, à contre-courant de l'autre variante

Quand la cellule cible disparaît en cours de route, la transition texte de
Telegram **abandonne le dessin** tandis que la vocale **réutilise la
dernière cible connue**. C'est la seconde politique qui a été retenue ici :
un disque qui s'arrête net au milieu de l'écran se remarque beaucoup plus
qu'un disque qui finit son trajet vers un endroit devenu approximatif.

### ⚠️ Ce qui reste à brancher

La transition vocale est **écrite et vérifiée, pas encore câblée**. Il
manque deux raccords, tous deux triviaux mais qui touchent du code que je
préfère ne pas modifier à l'aveugle :

1. passer à `TransitionVocale.lancer` le centre et le rayon du cercle
   d'enregistrement au moment où le doigt se lève ;
2. envelopper le bouton de lecture de la bulle vocale dans `CibleVocale`,
   exactement comme `EntreeEnvoi` enveloppe déjà la bulle de texte.

### La transition vocale est maintenant câblée

Les deux raccords manquants sont faits.

**1. Le départ.** `TransitionVocale.lancer` est appelé dans
`_stopRecording`, **avant l'envoi et non après** : le cercle est encore à
l'écran, c'est le seul instant où l'on peut le mesurer. Lancer après
`sendFile` ferait partir le disque d'un endroit que plus rien n'occupe,
après un blanc de plusieurs centaines de millisecondes.

Le centre est **mesuré** (`GlobalKey` sur la surcouche), pas calculé depuis
la position du bouton : la barre flotte au-dessus d'une zone sûre dont la
hauteur change d'un téléphone à l'autre, et une estimation ferait partir le
disque à côté de l'endroit d'où il est censé venir. Le rayon de départ est
celui qu'avait le cercle au relâchement, pas un rayon de repos — sinon le
disque sauterait à la première image.

**2. L'arrivée.** Le bouton de lecture de `VoiceNoteBubble` est enveloppé
dans `CibleVocale`, qui se remesure à chaque image (la liste vient de
gagner une ligne) et masque le vrai bouton pendant la première moitié du
trajet — les voir tous les deux donnerait deux boutons de lecture à
l'arrivée.

La transition n'est donnée qu'à **la dernière bulle, et seulement si elle
est de moi** : la cible est unique, et la donner à plusieurs bulles ferait
que la dernière construite gagne, au hasard de l'ordre de rendu.

#### Deux détails corrigés au câblage

* **La couleur d'arrivée n'est pas l'accent.** Sur une bulle envoyée, le
  bouton de lecture est un blanc à 22 % posé sur le fond de bulle. Faire
  arriver le disque en accent créerait un saut de couleur à l'instant
  précis où il se pose — c'est-à-dire là où l'œil regarde. Les deux sont
  composés au départ plutôt que transportés : un blanc à 22 % qui voyage
  au-dessus de la conversation serait presque invisible en vol.
* **Un `mine ? Colors.white : Colors.white`** dans `voice_note.dart` — une
  alternative sans alternative, et un blanc en dur sur fond accent.
  Remplacé par `OuroColors.texteSurAccent`. C'est le troisième défaut de
  ce type trouvé dans ce fichier-ci et les précédents ; le système de
  contraste existe justement pour ça.

#### Un nouvel envoi pendant qu'un disque est encore en vol

`terminerMaintenant()` coupe court au précédent. Deux disques en vol se
croiseraient à l'écran, et le premier se poserait sur une bulle qui n'est
plus la dernière.

## Les notifications de conversation d'Android

Ce que montrent vos captures : une section **« Conversations »** dans les
réglages du téléphone, une ligne **par discussion** avec son avatar et ses
propres réglages, les **bulles** flottantes, la **pastille** sur l'icône, et
les notifications **plein écran**.

### Pourquoi c'est en Kotlin et pas en Dart

`flutter_local_notifications` sait poser une notification. Il ne sait pas
poser une notification **de conversation** : il n'expose ni `shortcutId`,
ni `LocusId`, ni `BubbleMetadata`, ni les canaux à identifiant de
conversation. Android exige **les quatre ensemble** — trois sur quatre et
la notification retombe dans « Autres ».

### Les fichiers

| Fichier | Rôle |
|---|---|
| `NotifConversations.kt` | canaux par discussion, groupe « Conversations », notification `MessagingStyle`, bulle, réponse directe, raccourcis vers les réglages |
| `BulleActivity.kt` | la fenêtre affichée dans la bulle |
| `ReponseDirecteReceiver.kt` | la réponse tapée depuis le volet |
| `lib/core/services/notifs_conversation.dart` | le pont Dart |
| `AndroidManifest.xml` | l'activité de bulle et le receveur |
| `MainActivity.kt` | deux lignes : `brancher` / `debrancher` |

Les **raccourcis de conversation existaient déjà**
(`MainActivity.publierRaccourci`, avec `setLongLived(true)` et la catégorie
`android.shortcut.conversation`). C'est la pièce n° 1 des quatre ; il
manquait les trois autres.

### Les permissions

**Aucune nouvelle n'est nécessaire.** `POST_NOTIFICATIONS` et
`USE_FULL_SCREEN_INTENT` sont déjà dans le manifeste. Les bulles ne
demandent pas de permission — elles demandent trois **attributs
d'activité**, et c'est là que ça se joue :

* `allowEmbedded="true"` — Android affiche la bulle dans **sa** fenêtre, pas
  dans la nôtre. Sans cet attribut, la bulle s'ouvre vide ;
* `resizeableActivity="true"` — une activité non redimensionnable est
  refusée comme bulle ;
* `documentLaunchMode="always"` — sans lui, Android réutilise l'activité et
  la bulle **reste collée à la conversation précédente** quelle que soit
  celle qu'on touche.

### Trois décisions qui méritent d'être dites

**L'importance d'un canal est figée à sa création.** Les canaux de
conversation sont donc créés en importance **haute** : c'est la condition
pour qu'une conversation puisse « buller ». Un canal créé en importance
basse ne remonterait jamais, et **l'utilisateur ne pourrait pas le
corriger** — il faudrait changer l'identifiant du canal, c'est-à-dire
effacer les réglages qu'il avait faits.

**Les canaux sont créés à la première notification, pas à l'avance.** Créer
trois cents canaux au démarrage remplirait les réglages du téléphone d'une
liste illisible. Vos captures le confirment : la liste de WhatsApp ne
contient que les discussions actives.

**La réponse directe couvre le cas où l'application est morte.** Un
`BroadcastReceiver` est réveillé par Android même sans processus vivant : il
n'y a alors aucun moteur Flutter, et le code naïf perd le texte en silence.
Ici, moteur mort = l'application démarre avec le texte en extra, et c'est
elle qui l'envoie. L'écran s'allume, ce qui n'est pas idéal — perdre le
message serait pire.

### ⚠️ Deux choses que je n'ai PAS pu vérifier

**Le dossier `android/` de ma copie ne contient aucun fichier Gradle** — il
n'a que les Kotlin et le manifeste. Je n'ai donc pas pu contrôler :

1. **la version d'`androidx.core`.** `setLocusId`, `setBubbleMetadata` et
   `NotificationChannelCompat` demandent **1.3.0 ou plus**. À vérifier dans
   `android/app/build.gradle` :
   ```
   implementation 'androidx.core:core-ktx:1.12.0'
   ```
2. **le `compileSdk`.** `setConversationId` demande **30 ou plus**. Le code
   le garde derrière un test de version, donc il compile en dessous — mais
   la section « Conversations » n'apparaîtra pas.

**Et `kotlinc` n'est pas dans ce conteneur** : aucune compilation n'a été
faite. Le script `kotlin_check.py` ne contrôle que ce qui est contrôlable
sans compilateur — équilibre des accolades hors chaînes et commentaires,
présence des symboles annoncés, paquet correct, et cohérence du manifeste.
**Les trois fichiers passent, ce qui ne garantit pas qu'ils compilent.**

### Ce qu'il reste à brancher côté Dart

1. appeler `NotifsConversation.brancher(...)` au démarrage — **tôt**, car une
   réponse tapée alors que l'application était morte arrive quelques
   millisecondes après le lancement ;
2. remplacer l'appel à `NotificationService` par `NotifsConversation.notifier`
   **pour les messages de discussion seulement** — les deux pour le même
   message afficheraient une notification en double ;
3. `effacer(id)` à l'ouverture d'une conversation ;
4. servir une vue réduite sur la route `/bulle/<id>` : la bulle ne doit pas
   être une copie de l'application, sinon on peut ouvrir les réglages dans
   une fenêtre de 600 points posée sur une autre application.

### Les quatre raccords Dart sont faits

**1. L'écoute démarre dans `main()`, le traitement plus tard.**

C'est le point qui demandait une vraie décision. `brancher` ne pouvait pas
être appelé dans `main()` : l'arbre de widgets n'existe pas encore, donc il
n'y a aucun dépôt à qui demander d'envoyer. Et le brancher plus tard
perdait exactement la réponse qu'on venait d'écrire — Android relance
l'application et transmet le texte quelques millisecondes après le
démarrage.

D'où deux étapes : `ecouter()` dans `main()` ouvre l'oreille et **met de
côté** ce qui arrive ; `brancher(handler)` au montage de l'écran racine
reprend la file et la vide. La file est copiée puis vidée **avant** l'envoi :
un envoi qui échoue peut y remettre quelque chose, et itérer sur une liste
qu'on modifie lui ferait sauter des entrées.

**2. Les messages de discussion passent par la voie native**, à l'intérieur
de `showNewMessage` et non au point d'appel : il n'y a donc qu'un seul
chemin, et tout ce qui existait — suppression de l'aperçu, mémoire du fil,
nom du groupe — continue de s'appliquer. La fonction **sort** si la voie
native a réussi : laisser l'ancienne s'exécuter derrière afficherait deux
notifications pour le même message.

⚠️ **Le fil entier est transmis, pas le dernier message.** La notification
est republiée sous le même identifiant : elle remplace la précédente.
N'envoyer que le dernier effacerait les autres à chaque arrivée, et le style
« conversation » d'Android n'afficherait jamais qu'une ligne.

**3. Ouvrir une conversation retire sa notification** — la notification
seulement, jamais le canal : supprimer le canal jetterait les réglages que
la personne y avait faits.

**4. La bulle sert une vue réduite** sur `/bulle/<id>`. Pas de bouton
retour, pas d'accès à la fiche du contact : une bulle est une fenêtre de
600 points posée sur une **autre** application, et rien n'y ramène en
arrière. Tout chemin qui mène ailleurs y est un cul-de-sac — un bouton qui
ne fait rien est pire qu'un bouton absent.

### ⚠️ Deux pièges rencontrés en écrivant ce raccord

**Un dollar littéral dans le Kotlin.** La version générée contenait
`"${'$'}{m["texte"]}"`, qui en Kotlin produit un dollar **littéral** suivi
de texte brut : chaque notification aurait affiché la formule au lieu du
message — et jamais vide, donc le test de chaîne vide qui suit ne l'aurait
pas attrapé. Remplacé par un `as? String` ordinaire.

**Les accesseurs d'une classe tierce.** Le fil natif avait d'abord été
reconstruit depuis les `Message` de `flutter_local_notifications`
(`m.text`, `m.timestamp`, `m.person`). Le paquet n'étant pas dans ce
conteneur, **je ne pouvais pas vérifier ces trois noms** — et une rupture
ne se serait vue qu'à la compilation d'une version future. Les trois
valeurs étant déjà entre nos mains au moment où le `Message` est construit,
un second fil typé chez nous coûte trois champs et supprime la dépendance.

## Le compte officiel branché, son visage, et quinze explications

### 1. Les annonces circulent vraiment

**Par Internet** — `AnnoncesDroplet.synchroniser` est appelé au démarrage,
sans bloquer : le serveur peut mettre vingt secondes à répondre, et la
liste des conversations n'a pas à l'attendre pour une nouveauté qui sort
quelques fois par an. Le frein de douze heures est dans la méthode, pas
chez l'appelant — un téléphone dont le réseau clignote interrogerait sinon
le serveur vingt fois par heure, et dessinerait une carte des heures
auxquelles son porteur ouvre l'application.

**Par le maillage** — trois temps : je PROPOSE mes identifiants, le voisin
RÉCLAME ce qui lui manque, je lui ENVOIE cela seul. Les trois paquets ont
**un seul saut** : une négociation est une conversation entre deux
appareils voisins, la relayer ferait réclamer des gens qui ne m'ont rien
proposé.

#### Vérifié par simulation

| Propriété | Résultat |
|---|---|
| 40 téléphones, un seul a vu le serveur | **40/40 synchronisés en 12 tours**, 68 Ko en tout |
| 500 rencontres entre téléphones déjà à jour | **0 annonce transmise** |
| annonce falsifiée relayée par un ami | **refusée** |
| téléphone au plafond de relais (12 gardées sur 30) | la **plus récente passe quand même** |

⚠️ Le quatrième test a d'abord échoué — mais c'était **mon test** : je
changeais la date *après* avoir signé, donc la signature ne collait plus.
L'échec prouvait en réalité que la vérification fonctionne.

### 2. Le visage du compte

`lib/shared/widgets/avatar_officiel.dart` — la goutte de Droplet dans un
disque, plus la coche.

⚠️ **Ce n'est pas « un avatar avec une coche dessus ».** N'importe qui peut
mettre une coche dans sa photo de profil. Ce qui fait la différence : ce
badge n'est **jamais dessiné à partir de données reçues**. Il est posé par
le code, pour un identifiant gravé dans le binaire, dont les messages
portent une signature vérifiée. Le widget ne prend aucun paramètre
d'identité — il n'y a rien à lui passer qui puisse le tromper.

**Trois défauts corrigés après rendu aux tailles réelles :**

1. le badge faisait 0,72 du rayon et **mordait sur la goutte** — à 20
   points, la coche était presque aussi large que la marque qu'elle
   certifie. Ramené à **0,42** ;
2. le reflet, à 0,28 d'opacité et centré, se lisait comme **un trou gris**
   au milieu de la goutte. Descendu à 0,10, réduit, remonté en haut à
   gauche ;
3. `liseré` **ne compile pas** : Dart n'accepte que des lettres ASCII dans
   un identifiant, et l'erreur parle d'un jeton inattendu, pas d'un accent.

### 3. Quinze explications, jamais quinze d'affilée

`bulle_guide.dart` pose dans son propre en-tête une règle : **quatre étapes
au maximum par visite**, parce qu'au-delà plus personne ne lit. Une demande
de quinze bulles n'annule pas cette règle — elle demande de les
**répartir**.

D'où **cinq visites de trois étapes**, chacune attachée à l'écran qu'elle
explique. Personne ne voit jamais plus de trois bulles d'un coup, et chacune
parle de ce qu'on a sous les yeux.

| Visite | Ce qu'elle explique |
|---|---|
| accueil | « zéro pair » n'est pas une panne · l'aperçu à l'appui long · le compte officiel |
| composeur | maintenir pour parler · appui court = caméra · la grille de galerie |
| conversation | l'icône de relais · la vue unique · stickers ↔ clavier |
| confidentialité | messages éphémères · conversation verrouillée · code de sécurité |
| réseau | par où ça passe · rien ne se perd · les statuts de 24 h |

Les 15 titres et 15 textes sont dans les **dix langues**.

**Ce qu'on n'explique pas** : ni le bouton « envoyer », ni la liste des
conversations, ni la recherche. Expliquer l'évident apprend aux gens à
appuyer sur « passer » sans lire.

### ⚠️ Ce qui reste à attacher, et pourquoi je ne l'ai pas fait

Les visites désignent leurs cibles par `GlobalKey`. J'ai attaché celles du
composeur — micro, vue unique, trombone, stickers — et lancé la visite
`composeur`. **Les onze autres clés ne sont pas encore posées.**

Ce n'est pas un oubli : `chats_screen` a **déjà** sa propre visite avec ses
propres clés privées, et deux `GlobalKey` sur le même widget à l'écran est
une **erreur Flutter**, pas un avertissement. Poser les miennes à l'aveugle
par-dessus les siennes ferait planter l'accueil — et je ne peux pas
l'exécuter ici pour le vérifier.

La bonne manœuvre, écran par écran : remplacer la clé privée existante par
celle de `ClesExplications`, jamais en ajouter une seconde. Une étape dont
la cible n'est pas montée est **sautée**, pas affichée dans le vide : rien
ne casse en attendant.

Au passage, `_IconePilule` a reçu un `super.key` — sans lui, passer une
`GlobalKey` ne compile pas, et l'erreur parle d'un paramètre nommé inconnu.
