"""Ressources listées dans pubspec.yaml mais absentes du dépôt : on pose des
bouche-trous, SEULEMENT pour que la compilation sur GitHub puisse aller au
bout. Chaque bouche-trou est signalé dans le journal."""
import base64, glob, os, shutil
import yaml

PNG = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=")
p = yaml.safe_load(open("pubspec.yaml"))
fl = p.get("flutter", {}) or {}
entrees = [a if isinstance(a, str) else a.get("path") for a in fl.get("assets", []) or []]
for f in fl.get("fonts", []) or []:
    entrees += [x["asset"] for x in f.get("fonts", [])]
SHADER = """#include <flutter/runtime_effect.glsl>
uniform vec2 uTaille;
out vec4 fragColor;
void main() { fragColor = vec4(0.0); }
"""
for e in fl.get("shaders", []) or []:
    if not os.path.exists(e):
        os.makedirs(os.path.dirname(e) or ".", exist_ok=True)
        open(e, "w").write(SHADER)
        print(f"⚠️ absent du dépôt (bouche-trou de shader) : {e}")
police = (glob.glob("assets/fonts/*.ttf") or [None])[0]
for e in entrees:
    # « packages/<paquet>/… » désigne les ressources d'une dépendance : elles
    # viennent du paquet lui-même, pas du dépôt.
    if not e or e.startswith("packages/") or os.path.exists(e):
        continue
    if e.endswith("/"):
        os.makedirs(e, exist_ok=True)
        open(os.path.join(e, ".bouche-trou"), "w").close()
    else:
        os.makedirs(os.path.dirname(e) or ".", exist_ok=True)
        if e.lower().endswith((".ttf", ".otf")) and police:
            shutil.copy(police, e)
        elif e.lower().endswith(".png"):
            open(e, "wb").write(PNG)
        else:
            open(e, "wb").close()
    print(f"⚠️ absent du dépôt (bouche-trou) : {e}")
