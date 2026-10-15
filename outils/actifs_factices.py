"""CI uniquement : crée un fichier vide pour chaque actif déclaré dans
pubspec.yaml et absent du dépôt (les binaires ne sont pas versionnés ici),
pour que `flutter test` puisse construire le paquet d'actifs."""
import os, re
for ligne in open('pubspec.yaml', encoding='utf-8'):
    m = re.match(r'\s*-\s*(?:asset:\s*)?((?:assets|shaders)/\S+)', ligne)
    if not m:
        continue
    chemin = m.group(1)
    if chemin.endswith('/'):
        os.makedirs(chemin, exist_ok=True)
    elif not os.path.exists(chemin):
        os.makedirs(os.path.dirname(chemin), exist_ok=True)
        with open(chemin, 'w') as f:
            if chemin.endswith('.frag'):
                # un shader vide ne compile pas : le plus petit shader valide
                f.write('#version 460 core\nprecision mediump float;\n'
                        'layout(location = 0) out vec4 fragColor;\n'
                        'void main() { fragColor = vec4(0.0); }\n')
