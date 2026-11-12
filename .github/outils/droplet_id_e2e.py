#!/usr/bin/env python3
# Droplet ID de bout en bout, côté « site » : une vraie connexion sur le
# service de test (id-test.dropletmesh.app) avec le client du bac à sable,
# comme le ferait un navigateur. L'émulateur, lui, joue le téléphone.
#
#   droplet_id_e2e.py commencer DOSSIER  → écrit DOSSIER/demande.json
#   droplet_id_e2e.py etat DOSSIER       → affiche l'état de la demande
#   droplet_id_e2e.py terminer DOSSIER   → finit la connexion, échange le
#                                          code contre les jetons, vérifie
import base64, hashlib, http.cookiejar, json, os, re, secrets, sys, urllib.parse, urllib.request

EMETTEUR = os.environ.get('EMETTEUR', 'https://id-test.dropletmesh.app')
CLIENT = 'bac-a-sable'
RETOUR = os.environ.get('RETOUR', 'https://developpeurs-id.dropletmesh.app/bac-a-sable')

class SansSuivre(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a, **k):
        return None

def navigateur(dossier):
    jar = http.cookiejar.LWPCookieJar(os.path.join(dossier, 'cookies.txt'))
    if os.path.exists(jar.filename):
        jar.load(ignore_discard=True)
    o = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar), SansSuivre)
    o.addheaders = [('user-agent', 'Mozilla/5.0 (Linux; Android 14) DropletCI'), ('accept-language', 'fr')]
    return o, jar

def aller(o, url, data=None, accept='text/html'):
    req = urllib.request.Request(url, data=data, headers={'accept': accept})
    try:
        r = o.open(req, timeout=20)
        return r.status, {k.lower(): v for k, v in r.headers.items()}, r.read().decode('utf-8', 'replace')
    except urllib.error.HTTPError as e:
        return e.code, {k.lower(): v for k, v in e.headers.items()}, e.read().decode('utf-8', 'replace')

def commencer(dossier):
    os.makedirs(dossier, exist_ok=True)
    o, jar = navigateur(dossier)
    verifier = secrets.token_urlsafe(48)
    defi = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).rstrip(b'=').decode()
    etat = secrets.token_urlsafe(16)
    q = urllib.parse.urlencode({'client_id': CLIENT, 'redirect_uri': RETOUR, 'response_type': 'code', 'scope': 'openid profile',
                                'code_challenge': defi, 'code_challenge_method': 'S256', 'state': etat, 'nonce': secrets.token_urlsafe(16)})
    s, h, _ = aller(o, f'{EMETTEUR}/oauth2/auth?{q}')
    assert s in (302, 303), f'autorisation : HTTP {s}'
    interaction = urllib.parse.urljoin(EMETTEUR, h['location'])
    s, h, page = aller(o, interaction)
    assert s == 200, f'page de connexion : HTTP {s}'
    demande = re.search(r'/a/([A-Za-z0-9_-]{16,})', page).group(1)
    code = re.search(r'class="chiffres" aria-label="(\d\d)"', page).group(1)
    android = re.search(r'data-android="([^"]+)"', page).group(1).replace('&amp;', '&')
    jar.save(ignore_discard=True)
    d = {'interaction': interaction, 'demande': demande, 'code': code, 'android': android, 'verifier': verifier, 'etat': etat}
    json.dump(d, open(os.path.join(dossier, 'demande.json'), 'w'))
    print(json.dumps({'demande': demande, 'code': code, 'android': android}))

def lire(dossier):
    return json.load(open(os.path.join(dossier, 'demande.json')))

def etat(dossier):
    o, _ = navigateur(dossier)
    d = lire(dossier)
    s, _, corps = aller(o, d['interaction'] + '/etat', accept='application/json')
    print(json.loads(corps).get('etat') if s == 200 else f'HTTP {s}')

def terminer(dossier):
    o, jar = navigateur(dossier)
    d = lire(dossier)
    s, _, corps = aller(o, d['interaction'] + '/terminer', data=b'', accept='application/json')
    assert s == 200, f'terminer : HTTP {s} {corps[:200]}'
    url = urllib.parse.urljoin(EMETTEUR, json.loads(corps)['redirection'])
    for _ in range(6):
        s, h, _ = aller(o, url)
        url = urllib.parse.urljoin(url, h.get('location', ''))
        if url.startswith(RETOUR):
            break
    p = urllib.parse.parse_qs(urllib.parse.urlparse(url).query)
    assert 'code' in p, f'pas de code : {url}'
    assert p['state'][0] == d['etat'], 'state'
    corps = urllib.parse.urlencode({'grant_type': 'authorization_code', 'code': p['code'][0], 'redirect_uri': RETOUR,
                                    'client_id': CLIENT, 'code_verifier': d['verifier']}).encode()
    req = urllib.request.Request(f'{EMETTEUR}/oauth2/token', data=corps, headers={'content-type': 'application/x-www-form-urlencoded', 'origin': '{0.scheme}://{0.netloc}'.format(urllib.parse.urlparse(RETOUR))})
    j = json.loads(urllib.request.urlopen(req, timeout=20).read())
    claims = json.loads(base64.urlsafe_b64decode(j['id_token'].split('.')[1] + '=='))
    req = urllib.request.Request(f'{EMETTEUR}/userinfo', headers={'authorization': 'Bearer ' + j['access_token']})
    info = json.loads(urllib.request.urlopen(req, timeout=20).read())
    jar.save(ignore_discard=True)
    print(f"CONNECTÉ : sub={claims['sub'][:10]}… pseudo={info.get('preferred_username')!r} iss={claims['iss']}")

if __name__ == '__main__':
    {'commencer': commencer, 'etat': etat, 'terminer': terminer}[sys.argv[1]](sys.argv[2])
