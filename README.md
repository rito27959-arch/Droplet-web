# Droplet Web — client TypeScript

Le client servi par Vercel est maintenant écrit en **TypeScript**. Le code Flutter/Dart historique reste sous `lib/` pour permettre la comparaison de l'interface et une migration progressive. Le choix de TypeScript suit le langage de Telegram Web K ; ce dépôt n'importe aucun code GPL de Telegram.

## Ce qui fonctionne

- Code QR au format exact que lit `lib/core/services/appareils_lies.dart` du téléphone : `droplet_lien`, version 1, canal de 16 octets et clé publique X25519 de 32 octets.
- Clé privée non exportable générée par WebCrypto, rotation du QR chaque 60 secondes, interrogation de l'annuaire par `GET /liaison/{canal}`.
- Réception de l'enveloppe publiée par le téléphone, X25519 + HKDF-SHA256 (`droplet-mesh`, `droplet-lien-v1`) + AES-256-GCM pour la déchiffrer.
- Sauvegarde de l'identité et des clés CryptoKey en IndexedDB seulement si « Rester connecté » est coché. L'autre option ne garde l'identité qu'en mémoire jusqu'à la fermeture de l'onglet.
- Vue d'aperçu explicite par `?apercu`, séparée de la liaison réelle. Aucun faux accusé de réception ni réponse simulée n'est affiché comme un message réel.

## Limites bloquantes pour les discussions réelles

Le client mobile publie la liaison sur `POST /liaison/{canal}`, mais le code du serveur d'annuaire et son contrat de lecture ne figurent dans aucun des dépôts accessibles. La requête `GET /liaison/{canal}` doit répondre avec l'enveloppe JSON `{v, cleTel, nonce, chiffre}` (ou `{enveloppe: {...}}`), `404`/`204` tant que rien n'a été publié, et des en-têtes CORS limités à `https://web.dropletmesh.app`. Si ce contrat n'existe pas, la page affiche une erreur réelle au lieu de faire semblant d'être liée. Vérifier que la lecture est atomique et limitée à un seul consommateur, que le canal expire, et que la publication ne peut être remplacée.

L'application Flutter mobile conserve ses conversations sur le téléphone. Aucun point d'accès authentifié ne synchronise les conversations, contacts, clés de session, reçus et messages vers un appareil lié. Le dépôt `droplet-server` public ne contient que la signalisation des appels. Lier une identité ne permet donc pas encore d'envoyer ou de recevoir une discussion. L'interface liée l'indique et désactive l'envoi. **Ne pas utiliser les routes mailbox existantes à partir d'un simple `peerId` : elles n'authentifient pas un appareil lié.**

Pour terminer le produit, il faut publier le code ou le contrat du serveur directory/mailbox, ajouter une authentification par appareil lié, transférer une sauvegarde chiffrée au navigateur, puis implémenter l'envoi, la réception, les accusés et la révocation côté téléphone et serveur. Tester avec deux appareils et un compte réel avant de présenter la messagerie comme fonctionnelle.

## Développement

```sh
npm install
npm run check
npm run build
```

Vercel exécute `npm run build` et sert `dist/`. Ouvrir le site en HTTPS : WebCrypto X25519 et IndexedDB exigent un contexte sécurisé. Le fichier `third_party/qrcodegen.ts` provient de Project Nayuki sous licence MIT, conservée en tête du fichier. `lib/`, `pubspec.yaml` et `vercel-build.sh` appartiennent à l'ancienne version Flutter et ne participent plus au déploiement.
