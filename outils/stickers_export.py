#!/usr/bin/env python3
# ============================================================================
# FABRIQUE LES FICHIERS DE STICKERS POUR LES AUTRES APPLICATIONS.
# ----------------------------------------------------------------------------
# Entrée : les images rendues par `test/stickers_export_test.dart`
#          (build/export_stickers/<lot>-<id>/NNN.png + stickers.json).
# Sortie : assets/stickers_export/
#            <lot>/<id>.webp  WebP animé 512 × 512, ≤ 500 Ko — WhatsApp
#                             (et tout partage vers une autre app) ;
#            <lot>/<id>.webm  VP9 avec transparence, ≤ 3 s, ≤ 256 Ko,
#                             30 i/s — l'import officiel de Telegram ;
#            <lot>/tray.png   l'icône du pack pour WhatsApp, 96 × 96,
#                             ≤ 50 Ko ;
#            stickers.json    le catalogue lu par `FournisseurPartage.kt`.
#
# Les limites sont celles que publient WhatsApp (dépôt WhatsApp/stickers)
# et Telegram (core.telegram.org/import-stickers). Chaque fichier est
# ré-encodé plus fort tant qu'il les dépasse.
#
# Usage : python3 outils/stickers_export.py build/export_stickers
# ============================================================================

import json
import os
import shutil
import subprocess
import sys
import tempfile

from PIL import Image

SOURCE = sys.argv[1] if len(sys.argv) > 1 else 'build/export_stickers'
SORTIE = 'assets/stickers_export'

WEBP_MAX = 500 * 1024
WEBM_MAX = 256 * 1024
TRAY_MAX = 50 * 1024


def ffmpeg(*args):
    subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', *args], check=True)


def webp(dossier, cible):
    # Pillow (l'encodeur d'animations de libwebp) plutôt que ffmpeg : il
    # sait compresser la transparence avec pertes (`alpha_quality`), ce
    # qui divise presque par deux le poids — le liseré et l'ombre douce
    # coûtaient plus que le dessin. 15 i/s d'abord, 10 en dernier recours.
    noms = sorted(f for f in os.listdir(dossier) if f.endswith('.png'))
    images = [Image.open(os.path.join(dossier, n)).convert('RGBA') for n in noms]
    for q, aq, pas in [(60, 50, 2), (50, 40, 2), (40, 35, 2), (55, 45, 3), (40, 30, 3), (30, 25, 3)]:
        sel = images[::pas]
        sel[0].save(cible, save_all=True, append_images=sel[1:], duration=round(1000 / 30 * pas),
                    loop=0, quality=q, alpha_quality=aq, method=4)
        if os.path.getsize(cible) <= WEBP_MAX:
            return 30 // pas, q
    raise SystemExit(f'{cible} : impossible de descendre sous 500 Ko')


def webm(dossier, cible, periode):
    # Telegram : 3 s au plus. Une boucle plus longue est jouée un peu plus
    # vite plutôt que coupée, pour que la boucle reste sans à-coup.
    facteur = min(1.0, 2.9 / periode)
    for crf in [30, 36, 42, 48, 54, 60]:
        ffmpeg('-framerate', '30', '-i', os.path.join(dossier, '%03d.png'),
               '-vf', f'setpts=PTS*{facteur:.5f}', '-r', '30',
               '-c:v', 'libvpx-vp9', '-pix_fmt', 'yuva420p', '-b:v', '0', '-crf', str(crf),
               '-deadline', 'good', '-row-mt', '1', '-an', cible)
        if os.path.getsize(cible) <= WEBM_MAX:
            return crf
    raise SystemExit(f'{cible} : impossible de descendre sous 256 Ko')


def tray(png, cible):
    img = Image.open(png).convert('RGBA').resize((96, 96), Image.LANCZOS)
    img.save(cible, optimize=True)
    if os.path.getsize(cible) > TRAY_MAX:
        img.quantize(colors=128).save(cible, optimize=True)


def main():
    meta = json.load(open(os.path.join(SOURCE, 'stickers.json')))
    if os.path.exists(SORTIE):
        shutil.rmtree(SORTIE)
    for s in meta:
        lot, ident = s['lot'], s['id']
        dossier = os.path.join(SOURCE, f'{lot}-{ident}')
        os.makedirs(os.path.join(SORTIE, lot), exist_ok=True)
        ips, q = webp(dossier, os.path.join(SORTIE, lot, f'{ident}.webp'))
        crf = webm(dossier, os.path.join(SORTIE, lot, f'{ident}.webm'), s['periode'])
        print(f'{lot}/{ident}: webp {os.path.getsize(os.path.join(SORTIE, lot, ident + ".webp")) // 1024} Ko ({ips} i/s, q {q}), '
              f'webm {os.path.getsize(os.path.join(SORTIE, lot, ident + ".webm")) // 1024} Ko (crf {crf})')
    # L'icône de chaque pack : son premier sticker, à mi-boucle.
    for lot, premier in [('goutte', 'salut'), ('eclat', 'feu')]:
        images = sorted(os.listdir(os.path.join(SOURCE, f'{lot}-{premier}')))
        tray(os.path.join(SOURCE, f'{lot}-{premier}', images[len(images) // 3]), os.path.join(SORTIE, lot, 'tray.png'))
    json.dump([{k: s[k] for k in ('lot', 'id', 'nom', 'emojis', 'premium')} for s in meta],
              open(os.path.join(SORTIE, 'stickers.json'), 'w'), ensure_ascii=False, indent=1)
    total = sum(os.path.getsize(os.path.join(r, f)) for r, _, fs in os.walk(SORTIE) for f in fs)
    print(f'total : {total // 1024} Ko')


if __name__ == '__main__':
    main()
