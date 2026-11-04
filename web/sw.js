// ============================================================================
// LE SERVICE WORKER DE DROPLET WEB.
// ----------------------------------------------------------------------------
// Deux rôles :
//   • OUVRIR SANS RÉSEAU. Chaque fichier de l'app passe par le réseau
//     d'abord (on a toujours la dernière version), et sa copie est gardée :
//     sans réseau, la copie sert. L'interface s'ouvre donc hors ligne, avec
//     les discussions enregistrées dans le navigateur.
//   • LES POLICES ET IMAGES (`assets/`, `canvaskit/`) : servies depuis la
//     copie dès qu'elle existe, ce qui accélère chaque réouverture.
//
// ⚠️ JAMAIS UNE ANCIENNE VERSION À LA PLACE DE LA NOUVELLE. C'était la
// raison pour laquelle les service workers étaient retirés. Ici, `VERSION`
// est remplacée à chaque construction (`vercel-build.sh`) : une nouvelle
// version installe un nouveau cache et efface l'ancien, et le code de
// l'app (`main.dart.js`, `index.html`) vient toujours du réseau d'abord.
// ============================================================================

const VERSION = '__VERSION__';
const CACHE = 'droplet-web-' + VERSION;
const FIGES = ['/assets/', '/canvaskit/', '/icons/'];

// La coquille de l'app, gardée dès l'installation : sans elle, la toute
// première visite (faite avant que ce service worker ne soit actif) ne
// laissait rien à servir hors ligne.
const COQUILLE = ['./', 'index.html', 'flutter_bootstrap.js', 'flutter.js', 'main.dart.js', 'manifest.json', 'favicon.svg'];

self.addEventListener('install', (e) => {
  e.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    await Promise.all(COQUILLE.map((u) => cache.add(new Request(u, { cache: 'reload' })).catch(() => {})));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (e) => {
  e.waitUntil((async () => {
    for (const nom of await caches.keys()) {
      if (nom !== CACHE) await caches.delete(nom);
    }
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // Seulement nos propres fichiers : jamais l'annuaire, la boîte aux
  // lettres ni les appels (des requêtes vers d'autres domaines).
  if (url.origin !== self.location.origin) return;

  if (FIGES.some((p) => url.pathname.startsWith(p))) {
    e.respondWith((async () => {
      const cache = await caches.open(CACHE);
      const copie = await cache.match(req);
      if (copie) return copie;
      const rep = await fetch(req);
      if (rep.ok) cache.put(req, rep.clone());
      return rep;
    })());
    return;
  }

  e.respondWith((async () => {
    const cache = await caches.open(CACHE);
    try {
      const rep = await fetch(req);
      if (rep.ok) cache.put(req, rep.clone());
      return rep;
    } catch (err) {
      const copie = await cache.match(req, { ignoreSearch: true });
      if (copie) return copie;
      // Une page (`/`, `/?apercu`…) : la coquille gardée.
      if (req.mode === 'navigate') {
        const coquille = (await cache.match('index.html')) || (await cache.match('./'));
        if (coquille) return coquille;
      }
      throw err;
    }
  })());
});

// ── LES NOTIFICATIONS ONGLET FERMÉ ─────────────────────────────────────
// La boîte aux lettres ne nous envoie RIEN d'autre qu'un réveil (voir
// `droplet_mailbox/lib/push_web.dart`) : ni expéditeur, ni texte. On
// écrit donc « Nouveau message », dans la langue du navigateur. Si Droplet
// Web est déjà ouvert et visible, la page s'en charge elle-même : pas de
// doublon.
const NOUVEAU = {
  fr: 'Nouveau message', en: 'New message', de: 'Neue Nachricht', es: 'Nuevo mensaje',
  it: 'Nuovo messaggio', pt: 'Nova mensagem', ru: 'Новое сообщение', zh: '新消息',
  ar: 'رسالة جديدة', hi: 'नया संदेश',
};

self.addEventListener('push', (e) => {
  e.waitUntil((async () => {
    const fenetres = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    if (fenetres.some((f) => f.visibilityState === 'visible' && f.focused)) return;
    const langue = (self.navigator.language || 'en').slice(0, 2);
    await self.registration.showNotification('Droplet', {
      body: NOUVEAU[langue] || NOUVEAU.en,
      icon: 'icons/icone-192.png',
      badge: 'icons/badge-96.png',
      tag: 'droplet-nouveau',
      renotify: true,
    });
  })());
});

// Un clic sur une notification affichée par la page ramène à Droplet Web.
self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  e.waitUntil((async () => {
    const fenetres = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    if (fenetres.length) return fenetres[0].focus();
    return self.clients.openWindow('/');
  })());
});
