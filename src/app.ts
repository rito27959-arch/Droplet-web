import { qrcodegen } from '../third_party/qrcodegen.js';
import { decryptEnvelope, forgetIdentity, loadIdentity, newInvitation, receiveEnvelope, reserveInvitation, saveIdentity, type Identity, type Invitation } from './link.js';

const root = document.querySelector<HTMLElement>('#app');
if (!root) throw new Error('Élément #app manquant.');
const app = root;
const params = new URLSearchParams(location.search);
const preview = params.has('apercu');
let invitation: Invitation | null = null;
let identity: Identity | null = null;
let cancelled = false;
let pollController: AbortController | null = null;
let timer: number | null = null;
let remember = false;
let dark = (() => { try { return localStorage.getItem('droplet-theme') !== 'light'; } catch { return true; } })();
let storageWarning = false;
let linkGeneration = 0;

function el<K extends keyof HTMLElementTagNameMap>(tag: K, cls = '', value = ''): HTMLElementTagNameMap[K] {
  const element = document.createElement(tag);
  if (cls) element.className = cls;
  if (value) element.textContent = value;
  return element;
}
function button(label: string, cls: string, action: () => void): HTMLButtonElement {
  const result = el('button', cls, label);
  result.type = 'button'; result.addEventListener('click', action);
  return result;
}
function clearWork(): void {
  linkGeneration++;
  cancelled = true;
  pollController?.abort();
  pollController = null;
  if (timer !== null) window.clearInterval(timer);
  timer = null;
}
function theme(): void {
  document.documentElement.dataset.theme = dark ? 'dark' : 'light';
  try { localStorage.setItem('droplet-theme', dark ? 'dark' : 'light'); } catch { /* navigation privée */ }
}
function themeButton(): HTMLButtonElement {
  return button(dark ? '☀  Mode clair' : '☾  Mode sombre', 'theme-button', () => { dark = !dark; theme(); render(); });
}

function brand(): HTMLElement {
  const block = el('div', 'brand');
  const logo = el('span', 'brand-mark', '●'); logo.setAttribute('aria-hidden', 'true');
  block.append(logo, el('span', 'brand-name', 'droplet'), el('span', 'brand-label', 'WEB'));
  return block;
}

function drawQR(canvas: HTMLCanvasElement, value: string): void {
  const code = qrcodegen.QrCode.encodeText(value, qrcodegen.QrCode.Ecc.QUARTILE);
  const scale = 5, quiet = 4;
  canvas.width = canvas.height = (code.size + quiet * 2) * scale;
  const context = canvas.getContext('2d');
  if (!context) throw new Error('Canvas non disponible.');
  context.fillStyle = '#fff'; context.fillRect(0, 0, canvas.width, canvas.height);
  context.fillStyle = '#161719';
  for (let y = 0; y < code.size; y++) for (let x = 0; x < code.size; x++) {
    if (code.getModule(x, y)) context.fillRect((x + quiet) * scale, (y + quiet) * scale, scale, scale);
  }
}

function renderLink(status = 'Préparation d’un code sécurisé…', error = false): void {
  app.replaceChildren();
  const page = el('main', 'link-page');
  const top = el('header', 'topbar'); top.append(brand(), themeButton());
  const area = el('div', 'link-area');
  const heading = el('div', 'welcome');
  heading.append(el('div', 'eyebrow', 'VOS DISCUSSIONS, PARTOUT'), el('h1', '', 'Droplet sur votre ordinateur'),
    el('p', '', 'Associez votre téléphone pour retrouver votre identité Droplet sur ce navigateur.'));
  const card = el('section', 'link-card');
  const steps = el('div', 'steps');
  steps.append(el('div', 'section-kicker', 'CONNEXION SÉCURISÉE'), el('h2', '', 'Liez votre appareil'));
  for (const [n, title, detail] of [
    ['01', 'Ouvrez Droplet', 'Sur votre téléphone Android.'],
    ['02', 'Appareils liés', 'Dans les réglages de l’application.'],
    ['03', 'Scannez le code', 'Pointez l’appareil photo vers cet écran.'],
  ]) {
    const row = el('div', 'step'); row.append(el('span', 'step-num', n));
    const words = el('div'); words.append(el('strong', '', title), el('p', '', detail)); row.append(words); steps.append(row);
  }
  const rememberRow = el('label', 'remember');
  const check = el('input') as HTMLInputElement; check.type = 'checkbox'; check.checked = remember;
  check.addEventListener('change', () => { remember = check.checked; });
  rememberRow.append(check, el('span', '', 'Rester connecté sur cet ordinateur'));
  steps.append(rememberRow);
  const qrSide = el('div', 'qr-side');
  const qrFrame = el('div', 'qr-frame');
  if (invitation) {
    const canvas = el('canvas') as HTMLCanvasElement;
    canvas.setAttribute('aria-label', 'Code QR Droplet à scanner avec le téléphone');
    drawQR(canvas, invitation.payload); qrFrame.append(canvas);
  } else qrFrame.append(el('div', 'qr-loading', '◌'));
  const statusLine = el('p', error ? 'status error' : 'status', status);
  statusLine.setAttribute('role', 'status'); statusLine.setAttribute('aria-live', 'polite');
  const renew = button('Actualiser le code', 'text-button', () => { void startLink(); });
  qrSide.append(qrFrame, statusLine, renew);
  card.append(steps, qrSide);
  const small = el('p', 'mobile-note', 'Ouvrez cette page sur un ordinateur pour afficher le code à scanner avec votre téléphone.');
  const foot = el('div', 'footer');
  const site = el('a', '', 'Découvrir Droplet ↗'); site.href = 'https://dropletmesh.app/';
  foot.append(el('span', '', 'Un appareil lié possède sa propre clé privée.'), site);
  area.append(heading, card, small, foot);
  page.append(top, area); app.append(page);
}

async function startLink(): Promise<void> {
  clearWork(); cancelled = false; invitation = null;
  const generation = linkGeneration;
  renderLink();
  if (!window.isSecureContext || !crypto?.subtle) {
    renderLink('Ouvrez Droplet Web en HTTPS avec un navigateur récent.', true); return;
  }
  try {
    const current = await newInvitation();
    if (cancelled || generation !== linkGeneration) return;
    await reserveInvitation(current, AbortSignal.timeout(8000));
    if (cancelled || generation !== linkGeneration) return;
    // Reserve a few seconds for network delay before the server's 60 s TTL.
    current.expiresAt = Date.now() + 55_000;
    invitation = current;
    renderLink('En attente du scan depuis votre téléphone…');
    timer = window.setInterval(() => {
      if (!invitation || cancelled) return;
      const seconds = Math.max(0, Math.ceil((invitation.expiresAt - Date.now()) / 1000));
      if (!seconds) { void startLink(); return; }
      const status = app.querySelector<HTMLElement>('.status');
      if (status && !status.classList.contains('error')) status.textContent = `En attente du scan · nouveau code dans ${seconds} s`;
    }, 1000);
    void poll(current);
  } catch (err) {
    if (cancelled || generation !== linkGeneration) return;
    renderLink(err instanceof Error ? err.message : 'Impossible de créer le code QR.', true);
  }
}

async function poll(current: Invitation): Promise<void> {
  while (!cancelled && invitation === current && Date.now() < current.expiresAt) {
    pollController = new AbortController();
    try {
      const envelope = await receiveEnvelope(current, pollController.signal);
      if (cancelled || invitation !== current) return;
      if (envelope) {
        const found = await decryptEnvelope(current, envelope);
        identity = found;
        if (remember) {
          try { await saveIdentity(found, current.keys); }
          catch { storageWarning = true; }
        }
        clearWork(); render(); return;
      }
    } catch (err) {
      if (cancelled || invitation !== current) return;
      if (err instanceof DOMException && err.name === 'TimeoutError') continue;
      const message = err instanceof Error ? err.message : 'Erreur de connexion.';
      // A failed poll must remain visible. Never show a successful connection on a network error.
      renderLink(message.includes('fetch') || message.includes('Network')
        ? 'Annuaire inaccessible depuis le navigateur (réseau ou CORS). Réessayez plus tard.' : message, true);
      return;
    }
    await new Promise(resolve => window.setTimeout(resolve, 3000));
  }
}

function renderLinked(): void {
  if (!identity) return;
  app.replaceChildren();
  const page = el('main', 'linked-page');
  const rail = el('aside', 'rail'); rail.append(brand());
  rail.append(el('div', 'rail-divider'), el('span', 'rail-icon active', '◉'), el('span', 'rail-icon', '◷'));
  const list = el('section', 'list-pane');
  list.append(el('div', 'list-heading', 'Discussions'), el('p', 'list-empty', 'Vos discussions apparaîtront ici après l’activation de la synchronisation des appareils liés.'));
  const main = el('section', 'conversation-pane');
  const card = el('div', 'linked-card');
  const avatar = el('div', 'linked-avatar', identity.pseudo.slice(0, 1).toUpperCase() || 'D');
  card.append(avatar, el('div', 'eyebrow', 'APPAREIL LIÉ'), el('h1', '', `Bonjour ${identity.pseudo || 'sur Droplet'}`),
    el('p', '', 'Votre téléphone a confirmé ce navigateur. La synchronisation des discussions et l’envoi réel nécessitent encore le service multiappareil côté serveur et côté téléphone.'));
  const badge = el('div', 'sync-badge', storageWarning
    ? 'Liaison confirmée · stockage local indisponible, reconnexion au prochain chargement'
    : 'Identité enregistrée · discussions indisponibles');
  const actions = el('div', 'linked-actions');
  actions.append(themeButton(), button('Oublier ce navigateur', 'outline-button', () => {
    void (async () => { try { await forgetIdentity(); } catch { /* stockage indisponible */ } identity = null; void startLink(); })();
  }));
  card.append(badge, actions); main.append(card);
  page.append(rail, list, main); app.append(page);
}

function renderPreview(): void {
  app.replaceChildren();
  const page = el('main', 'linked-page');
  const rail = el('aside', 'rail'); rail.append(brand(), el('div', 'rail-divider'), el('span', 'rail-icon active', '◉'), el('span', 'rail-icon', '◷'));
  const list = el('section', 'list-pane'); list.append(el('div', 'list-heading', 'Discussions'));
  const people = [
    ['Amina', 'Je suis à côté du stand bleu', 'A', '10:42'],
    ['Famille', 'On se retrouve à 18 h', 'F', '09:18'],
    ['Papa', 'Bien reçu, merci 🙏', 'P', 'Hier'],
    ['Lina', 'Je t’envoie l’adresse ce soir', 'L', 'Hier'],
  ];
  let selected = 0;
  const main = el('section', 'conversation-pane');
  function show(): void {
    main.replaceChildren();
    const [name, last, letter] = people[selected];
    const header = el('div', 'chat-head'); header.append(el('span', 'chat-avatar', letter), el('strong', '', name));
    const msgs = el('div', 'chat-messages');
    msgs.append(el('div', 'preview-label', 'APERÇU LOCAL · AUCUN MESSAGE N’EST ENVOYÉ'),
      el('div', 'bubble inbound', selected ? 'Salut ! Comment ça va ?' : 'On se retrouve au festival ?'),
      el('div', 'bubble outbound', selected ? 'Oui, à bientôt 👋' : 'Oui, j’arrive bientôt !'),
      el('div', 'bubble inbound', last));
    const composer = el('div', 'disabled-composer', 'Envoi désactivé dans l’aperçu · liez votre téléphone pour continuer');
    main.append(header, msgs, composer);
    list.querySelectorAll<HTMLButtonElement>('.chat-row').forEach((row, index) => row.classList.toggle('selected', index === selected));
  }
  people.forEach(([name, last, letter, time], index) => {
    const row = button('', 'chat-row', () => { selected = index; show(); });
    const avatar = el('span', `chat-avatar avatar-${index}`, letter);
    const detail = el('span', 'chat-detail'); detail.append(el('strong', '', name), el('small', '', last));
    row.append(avatar, detail, el('time', '', time)); list.append(row);
  });
  const banner = el('div', 'preview-banner', 'Mode aperçu : conversations fictives');
  banner.append(button('Quitter l’aperçu', 'text-button', () => { history.replaceState(null, '', location.pathname); void startLink(); }));
  page.append(rail, list, main, banner); app.append(page); show();
}

function render(): void {
  theme();
  if (!identity && new URLSearchParams(location.search).has('apercu')) renderPreview();
  else if (identity) renderLinked();
  else renderLink();
}

theme();
if (preview) renderPreview();
else void loadIdentity().then(saved => {
  if (saved) { identity = saved; renderLinked(); }
  else void startLink();
}).catch(() => { void startLink(); });
