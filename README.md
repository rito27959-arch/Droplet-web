# Droplet Web — client TypeScript

Le client Web à déployer sur Vercel est écrit en **TypeScript**. Le code Flutter/Dart historique reste sous `lib/` pour permettre la comparaison de l'interface et une migration progressive. Le choix de TypeScript suit le langage de Telegram Web K ; ce dépôt n'importe aucun code GPL de Telegram.

## Ce qui fonctionne

- Code QR au format exact que lit `lib/core/services/appareils_lies.dart` du téléphone : `droplet_lien`, version 1, canal de 16 octets et clé publique X25519 de 32 octets.
- Clé privée non exportable générée par WebCrypto, réservation du canal par `PUT /liaison/{canal}`, rotation du QR avant son expiration de 60 secondes, interrogation de l'annuaire par `GET /liaison/{canal}`.
- Réception de l'enveloppe publiée par le téléphone, X25519 + HKDF-SHA256 (`droplet-mesh`, `droplet-lien-v1`) + AES-256-GCM pour la déchiffrer.
- Sauvegarde de l'identité et des clés CryptoKey en IndexedDB seulement si « Rester connecté » est coché. L'autre option ne garde l'identité qu'en mémoire jusqu'à la fermeture de l'onglet.
- Vue d'aperçu explicite par `?apercu`, séparée de la liaison réelle. Aucun faux accusé de réception ni réponse simulée n'est affiché comme un message réel.

## Limites bloquantes pour les discussions réelles

Le correctif serveur de `droplet_directory/` se trouve dans une branche du dépôt `rito27959-arch/droplet`, établie à partir de l'archive serveur fournie par le propriétaire. Le navigateur réserve le canal par `PUT` (`201`), attend `GET` (`204`), le téléphone publie par `POST` (`200`) et le navigateur lit l'enveloppe JSON `{v, cleTel, nonce, chiffre}` (`200`). La publication ne peut être remplacée, et le canal expire après une minute. La lecture répétée du texte chiffré évite qu'un tiers efface le dépôt avant le navigateur. Tant que la version serveur n'est pas déployée sur Railway, l'annuaire public répond `404 Route not found` à `GET /liaison/{canal}`.

La version serveur apportée dans l'archive préserve la configuration Firebase, les sauvegardes et les clés Signal qui manquaient dans la branche publique. Le stockage des canaux reste en mémoire : un seul processus doit traiter les requêtes, ou il faut un magasin partagé avec expiration atomique. Vérifier la configuration du service Railway avant le déploiement.

L'application Flutter mobile conserve ses conversations sur le téléphone. Aucun point d'accès authentifié ne synchronise les conversations, contacts, clés de session, reçus et messages vers un appareil lié. Le dépôt `droplet-server` public ne contient que la signalisation des appels. Lier une identité ne permet donc pas encore d'envoyer ou de recevoir une discussion. L'interface liée l'indique et désactive l'envoi. **Ne pas utiliser les routes mailbox existantes à partir d'un simple `peerId` : elles n'authentifient pas un appareil lié.**

Pour terminer le produit, il faut intégrer et déployer la liaison sur le serveur effectivement utilisé, ajouter une authentification par appareil lié, transférer une sauvegarde chiffrée au navigateur, puis implémenter l'envoi, la réception, les accusés et la révocation côté téléphone et serveur. Le mobile appelle `DELETE /appareils/{peerId}/{appareilId}`, route absente du serveur public ; l'ajouter sans authentification permettrait à un tiers de déconnecter un appareil. Tester avec deux appareils et un compte réel avant de présenter la messagerie comme fonctionnelle.

## Développement

```sh
npm install
npm run check
npm run build
```

Vercel exécute `npm run build` et sert `dist/`. Ouvrir le site en HTTPS : WebCrypto X25519 et IndexedDB exigent un contexte sécurisé. Le fichier `third_party/qrcodegen.ts` provient de Project Nayuki sous licence MIT, conservée en tête du fichier. `lib/`, `pubspec.yaml` et `vercel-build.sh` appartiennent à l'ancienne version Flutter et ne participent plus au déploiement.
