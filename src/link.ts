/** Browser half of the QR linking protocol used by lib/core/services/appareils_lies.dart. */
export const DIRECTORY = 'https://droplet-directory-production.up.railway.app';
const utf8 = new TextEncoder();
const decoder = new TextDecoder('utf-8', { fatal: true });
const dbName = 'droplet-web-linked-device';

export interface Identity {
  peerId: string;
  pseudo: string;
  appareil: string;
  phonePublic: string;
  linkedAt: string;
}

export interface Invitation {
  channel: string;
  payload: string;
  keys: CryptoKeyPair;
  expiresAt: number;
}

function base64url(bytes: Uint8Array): string {
  let raw = '';
  for (const byte of bytes) raw += String.fromCharCode(byte);
  return btoa(raw).replaceAll('+', '-').replaceAll('/', '_').replace(/=+$/, '');
}

function fromBase64url(value: string, size?: number): Uint8Array<ArrayBuffer> {
  if (!/^[A-Za-z0-9_-]+$/.test(value)) throw new Error('Encodage de la liaison invalide.');
  const raw = atob(value.replaceAll('-', '+').replaceAll('_', '/') + '='.repeat((4 - value.length % 4) % 4));
  const bytes = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) bytes[i] = raw.charCodeAt(i);
  if (size !== undefined && bytes.length !== size) throw new Error('Longueur de clé de liaison invalide.');
  return bytes;
}

function browserName(): string {
  const ua = navigator.userAgent;
  const client = ua.includes('Edg/') ? 'Edge' : ua.includes('Firefox/') ? 'Firefox' : ua.includes('Chrome/') ? 'Chrome' : ua.includes('Safari/') ? 'Safari' : 'Navigateur';
  const os = ua.includes('Windows') ? 'Windows' : ua.includes('Android') ? 'Android' : ua.includes('Mac OS') ? 'macOS' : ua.includes('Linux') ? 'Linux' : '';
  return [client, os].filter(Boolean).join(' · ');
}

export async function newInvitation(): Promise<Invitation> {
  // Private key is deliberately non-extractable. WebCrypto still lets us export the public key.
  const keys = await crypto.subtle.generateKey({ name: 'X25519' }, false, ['deriveBits']) as CryptoKeyPair;
  const publicKey = new Uint8Array(await crypto.subtle.exportKey('raw', keys.publicKey));
  const channel = base64url(crypto.getRandomValues(new Uint8Array(16)));
  return {
    channel,
    keys,
    expiresAt: Date.now() + 60_000,
    payload: JSON.stringify({ type: 'droplet_lien', v: 1, canal: channel, cle: base64url(publicKey), nom: browserName() }),
  };
}

interface Envelope { v: number; cleTel: string; nonce: string; chiffre: string }
function envelopeFrom(response: unknown): Envelope | null {
  if (!response || typeof response !== 'object') return null;
  const body = response as Record<string, unknown>;
  const value = (body.enveloppe && typeof body.enveloppe === 'object' ? body.enveloppe : body) as Record<string, unknown>;
  if (value.v !== 1 || typeof value.cleTel !== 'string' || typeof value.nonce !== 'string' || typeof value.chiffre !== 'string') return null;
  return value as unknown as Envelope;
}

export async function receiveEnvelope(invitation: Invitation, signal: AbortSignal): Promise<Envelope | null> {
  const timeout = AbortSignal.timeout(8_000);
  const combined = AbortSignal.any([signal, timeout]);
  const response = await fetch(`${DIRECTORY}/liaison/${encodeURIComponent(invitation.channel)}`, {
    method: 'GET', mode: 'cors', cache: 'no-store', credentials: 'omit', signal: combined,
  });
  // 404 means nothing has been deposited yet; 204 also denotes an empty poll.
  if (response.status === 404 || response.status === 204) return null;
  if (!response.ok) throw new Error(`L'annuaire refuse la liaison (HTTP ${response.status}).`);
  const parsed: unknown = await response.json();
  const envelope = envelopeFrom(parsed);
  if (!envelope) throw new Error('Réponse de liaison inconnue : vérifiez le contrat GET /liaison/{canal} du serveur.');
  return envelope;
}

export async function decryptEnvelope(invitation: Invitation, envelope: Envelope): Promise<Identity> {
  if (Date.now() >= invitation.expiresAt) throw new Error('Ce code QR a expiré.');
  const phonePublic = fromBase64url(envelope.cleTel, 32);
  const peerKey = await crypto.subtle.importKey('raw', phonePublic, { name: 'X25519' }, false, []);
  const secret = await crypto.subtle.deriveBits({ name: 'X25519', public: peerKey }, invitation.keys.privateKey, 256);
  const material = await crypto.subtle.importKey('raw', secret, 'HKDF', false, ['deriveKey']);
  const aes = await crypto.subtle.deriveKey({
    name: 'HKDF', hash: 'SHA-256', salt: utf8.encode('droplet-mesh'), info: utf8.encode('droplet-lien-v1'),
  }, material, { name: 'AES-GCM', length: 256 }, false, ['decrypt']);
  const nonce = fromBase64url(envelope.nonce, 12);
  const ciphertext = fromBase64url(envelope.chiffre);
  if (ciphertext.length < 17) throw new Error('Enveloppe de liaison tronquée.');
  const plaintext = await crypto.subtle.decrypt({ name: 'AES-GCM', iv: nonce }, aes, ciphertext);
  const body: unknown = JSON.parse(decoder.decode(plaintext));
  if (!body || typeof body !== 'object') throw new Error('Identité invalide.');
  const data = body as Record<string, unknown>;
  if (typeof data.peerId !== 'string' || !data.peerId || typeof data.pseudo !== 'string' ||
      typeof data.appareil !== 'string' || !data.appareil) throw new Error('Identité incomplète.');
  return {
    peerId: data.peerId, pseudo: data.pseudo, appareil: data.appareil,
    phonePublic: envelope.cleTel, linkedAt: new Date().toISOString(),
  };
}

interface StoredIdentity extends Identity { privateKey: CryptoKey; publicKey: CryptoKey }
function openDB(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(dbName, 1);
    request.onupgradeneeded = () => request.result.createObjectStore('identity');
    request.onerror = () => reject(request.error);
    request.onsuccess = () => resolve(request.result);
  });
}

async function dbOperation<T>(mode: IDBTransactionMode, action: (store: IDBObjectStore) => IDBRequest<T>): Promise<T> {
  const db = await openDB();
  try {
    return await new Promise<T>((resolve, reject) => {
      const transaction = db.transaction('identity', mode);
      const request = action(transaction.objectStore('identity'));
      transaction.oncomplete = () => resolve(request.result);
      request.onerror = () => reject(request.error);
      transaction.onerror = () => reject(transaction.error);
      transaction.onabort = () => reject(transaction.error);
    });
  } finally { db.close(); }
}

export async function saveIdentity(identity: Identity, keys: CryptoKeyPair): Promise<void> {
  await dbOperation('readwrite', store => store.put({ ...identity, privateKey: keys.privateKey, publicKey: keys.publicKey } satisfies StoredIdentity, 'current'));
}
export async function loadIdentity(): Promise<StoredIdentity | undefined> {
  return dbOperation('readonly', store => store.get('current'));
}
export async function forgetIdentity(): Promise<void> {
  await dbOperation('readwrite', store => store.delete('current'));
}
