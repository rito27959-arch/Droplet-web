#!/usr/bin/env python3
"""Variante 13 de l'icône de Droplet : « Peluche » (boule de fourrure bleue).

L'image source est une boule posée sur un fond blanc. On la DÉCOUPE :
  - le centre de la boule est opaque d'office (le logo y est blanc, il ne
    faut surtout pas le prendre pour du fond) ;
  - sur la frange de poils, l'opacité se déduit de la couleur : un poil
    bleu à moitié sur le blanc donne un pixel à mi-chemin des deux.
Puis on décline les couches Android comme les autres variantes.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SRC, SORTIE = sys.argv[1], sys.argv[2]
N = 13
DENSITES = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}

img = np.asarray(Image.open(SRC).convert('RGB')).astype(np.float32)
h, w, _ = img.shape
R, G, B = img[..., 0], img[..., 1], img[..., 2]

# 1. Où est la boule ? Les pixels nettement bleus.
bleu = (B - R) > 90
ys, xs = np.nonzero(bleu)
cx, cy = xs.mean(), ys.mean()
dist = np.hypot(np.arange(w)[None, :] - cx, np.arange(h)[:, None] - cy)
rayon = np.percentile(dist[bleu], 99.5)

# Couleur moyenne de la fourrure (pour « décontaminer » la frange).
anneau = bleu & (dist > rayon * 0.80) & (dist < rayon * 0.92)
fourrure = img[anneau].mean(axis=0)

# 2. Opacité de la frange : distance au blanc, rapportée à celle de la
#    fourrure. Au cœur (85 % du rayon), opaque quoi qu'il arrive.
blanc = np.array([254, 254, 254], np.float32)
a = np.clip(np.linalg.norm(blanc - img, axis=2) / np.linalg.norm(blanc - fourrure), 0, 1)
coeur = np.clip((rayon * 0.88 - dist) / (rayon * 0.03), 0, 1)
alpha = np.maximum(a, coeur)
alpha[dist > rayon * 1.04] = 0

# Couleur sans le blanc mélangé : C = a·F + (1-a)·blanc  →  F = (C - (1-a)·blanc) / a
frange = (coeur < 1) & (alpha > 0.02)
couleur = img.copy()
aa = np.maximum(alpha[..., None], 1e-3)
couleur[frange] = np.clip((img - (1 - aa) * blanc) / aa, 0, 255)[frange]

rgba = np.dstack([couleur, alpha * 255]).astype(np.uint8)
boule = Image.fromarray(rgba, 'RGBA')

# Recadrage carré serré sur la boule.
c = int(rayon * 1.04)
boule = boule.crop((int(cx) - c, int(cy) - c, int(cx) + c, int(cy) + c)).resize((1024, 1024), Image.LANCZOS)

# 3. Le logo (bulle + goutte) seul, pour l'icône monochrome d'Android 13+.
b = np.asarray(boule).astype(np.float32)
blancheur = np.clip((b[..., 0] - 120) / 90, 0, 1)        # le logo est blanc, la fourrure non
dd = np.hypot(np.arange(1024)[None, :] - 512, np.arange(1024)[:, None] - 512)
blancheur[dd > 1024 * 0.42] = 0                          # rien hors du logo
logo = Image.fromarray((blancheur * 255).astype(np.uint8), 'L').filter(ImageFilter.MedianFilter(5))

fond_rgb = tuple(int(v * 0.92) for v in fourrure)        # un rien plus sombre que les poils


def adaptative_fond(s):
    return Image.new('RGBA', (s, s), fond_rgb + (255,))


REMPLI = 0.78   # 84 dp sur 108 : la pointe de la bulle tombe à 32 dp du centre (zone sûre : 33 dp)


def adaptative_dessin(s):
    # La boule couvre la quasi-totalité de ce qui est visible ; sa frange
    # de poils se fond dans le fond uni, d'un bleu à peine plus sombre,
    # qui remplit les coins des masques carrés.
    i = int(s * REMPLI)
    toile = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    toile.alpha_composite(boule.resize((i, i), Image.LANCZOS), ((s - i) // 2, (s - i) // 2))
    return toile


def adaptative_mono(s):
    i = int(s * REMPLI)
    m = Image.new('L', (s, s), 0)
    m.paste(logo.resize((i, i), Image.LANCZOS), ((s - i) // 2, (s - i) // 2))
    noir = Image.new('RGBA', (s, s), (0, 0, 0, 255))
    noir.putalpha(m)
    return noir


def vignette(s):
    """Ce que montrera le lanceur avec un masque carré arrondi (aperçu dans la grille)."""
    t = s * 108 // 72
    toile = adaptative_fond(t)
    toile.alpha_composite(adaptative_dessin(t))
    o = (t - s) // 2
    v = toile.crop((o, o, o + s, o + s))
    ss = 4
    masque = Image.new('L', (s * ss, s * ss), 0)
    ImageDraw.Draw(masque).rounded_rectangle([0, 0, s * ss - 1, s * ss - 1], radius=int(s * ss * 0.2237), fill=255)
    v.putalpha(masque.resize((s, s), Image.LANCZOS))
    return v


XML = """<?xml version="1.0" encoding="utf-8"?>
<!--
  Variante {n} de l'icône de Droplet : « Peluche ».

  Icône adaptative : la boule de fourrure couvre toute la toile, si bien
  que le masque du fabricant (cercle, carré arrondi…) ne montre que de la
  fourrure ; le logo tient dans les 66 dp centraux, toujours visibles.
-->
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_v{n}_background" />
    <foreground android:drawable="@mipmap/ic_launcher_v{n}_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_v{n}_monochrome" />
</adaptive-icon>
"""

res = f'{SORTIE}/android/app/src/main/res'
for nom, f in DENSITES.items():
    d = f'{res}/mipmap-{nom}'
    os.makedirs(d, exist_ok=True)
    leg, ada = int(48 * f), int(108 * f)
    vignette(leg).save(f'{d}/ic_launcher_v{N}.png')
    boule.resize((leg, leg), Image.LANCZOS).save(f'{d}/ic_launcher_v{N}_round.png')
    adaptative_fond(ada).save(f'{d}/ic_launcher_v{N}_background.png')
    adaptative_dessin(ada).save(f'{d}/ic_launcher_v{N}_foreground.png')
    adaptative_mono(ada).save(f'{d}/ic_launcher_v{N}_monochrome.png')
os.makedirs(f'{res}/mipmap-anydpi-v26', exist_ok=True)
for suffixe in ('', '_round'):
    open(f'{res}/mipmap-anydpi-v26/ic_launcher_v{N}{suffixe}.xml', 'w').write(XML.format(n=N))

os.makedirs(f'{SORTIE}/assets/icon/variants', exist_ok=True)
vignette(384).save(f'{SORTIE}/assets/icon/variants/droplet_{N}.png')
boule.save(f'{SORTIE}/peluche_decoupee.png')
print('rayon', rayon, 'fourrure', fourrure, 'fond', fond_rgb)
