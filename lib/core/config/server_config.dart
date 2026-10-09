// ============================================================================
// Configuration des serveurs Droplet.
//
// URLs des serveurs directory, mailbox et signaling.
// ============================================================================
//
// ⚠️ `kDirectoryUrl`/`kMailboxUrl` POINTAIENT VERS 127.0.0.1 — CE QUI NE
// PEUT JAMAIS FONCTIONNER SUR UN TÉLÉPHONE RÉEL.
//
// `127.0.0.1` désigne l'appareil LUI-MÊME. Sur un poste de
// développement avec les deux serveurs lancés en local, cette adresse
// fonctionne par coïncidence — la machine qui exécute l'app EST la
// machine qui exécute les serveurs. Sur un téléphone, ce n'est plus le
// cas : `127.0.0.1` boucle sur le téléphone, où rien n'écoute sur ces
// ports. Chaque tentative de recherche d'un pair par pseudo, ou de
// dépôt dans la boîte aux lettres hors-ligne, échouait donc en
// silence (connexion refusée) — c'était la cause du signalement
// « Tor ne marche pas réellement ».
//
// Les deux serveurs sont maintenant déployés sur Railway
// (`droplet_directory/`, `droplet_mailbox/`), dans le même projet que
// le serveur de signalisation. Ils tournent SANS démon Tor interne —
// voir le commentaire en tête de `droplet_directory/Dockerfile` pour
// pourquoi un service caché .onion classique n'aurait pas survécu à un
// redéploiement sur cette plateforme (système de fichiers recréé à
// chaque fois, donc nouvelle adresse .onion à chaque fois). Le client,
// lui, continue de router CHAQUE requête vers ces deux serveurs au
// travers de son propre proxy SOCKS5 Tor (`tor_http_client.dart`) :
// l'anonymat de L'UTILISATEUR reste entier, Railway ne voit jamais son
// IP réelle — exactement comme n'importe quel site visité avec Tor
// Browser. Seuls les DEUX SERVEURS cessent d'être eux-mêmes des
// services cachés.
// ============================================================================

// ── À TERME : LES ADRESSES DU DOMAINE, PLUS CELLES DE RAILWAY ─────────
//
// ⏸ EN ATTENTE. Le plan Railway actuel n'autorise aucun domaine
// personnalisé (« limit for custom domains per service »). Le jour où il le
// permet, ces trois adresses deviennent `directory.`, `mailbox.` et
// `calls.dropletmesh.app`, pour la raison qui suit.
//
// `directory.dropletmesh.app` plutôt que `droplet-directory-production
// .up.railway.app` : le jour où un serveur change d'hébergeur, on modifie
// une ligne DNS (chez Vercel, qui gère le domaine) au lieu de publier une
// nouvelle version de l'application — et les téléphones qui ne se mettent
// jamais à jour continuent de fonctionner.
//
// ⚠️ ORDRE À RESPECTER : ces trois sous-domaines devront être déclarés dans
// Railway (Settings › Networking › Custom Domain) ET dans le DNS de Vercel
// AVANT de publier une version de l'app qui les utilise. Vérification :
// `https://calls.dropletmesh.app/health` doit répondre dans un navigateur.
//
// Les anciennes adresses Railway restent actives : les versions déjà
// installées continuent de marcher, et les données (annuaire, sauvegardes
// en ligne, boîte aux lettres) sont les mêmes, puisque c'est le même
// serveur sous deux noms.

/// URL du serveur directory (annuaire — recherche de contacts par pseudo).
const String kDirectoryUrl = 'https://droplet-directory-production.up.railway.app';

/// URL du serveur mailbox (messagerie asynchrone hors-ligne).
const String kMailboxUrl = 'https://droplet-mailbox-production.up.railway.app';

/// URL du serveur signaling (WebSocket pour appels WebRTC).
const String kSignalingUrl = 'https://droplet-server-production.up.railway.app';

/// Le site de Droplet. Il sert la page des liens d'invitation (`/i/`).
const String kSiteUrl = 'https://dropletmesh.app';
