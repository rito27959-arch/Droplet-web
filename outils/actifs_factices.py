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
        open(chemin, 'wb').close()
