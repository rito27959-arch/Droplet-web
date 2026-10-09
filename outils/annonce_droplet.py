#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
SIGNER UNE ANNONCE DROPLET
==============================================================================

C'EST QUOI CET OUTIL ?
------------------------------------------------------------------------------
Le compte officiel « Droplet » n'est pas garanti par un serveur : il est
garanti par une SIGNATURE. La clé publique est gravée dans l'application ;
la clé privée reste sur VOTRE ordinateur et ne doit jamais en sortir.

Cet outil fait trois choses :

    python3 annonce_droplet.py cles            → crée votre paire de clés
    python3 annonce_droplet.py signer ...      → signe une annonce
    python3 annonce_droplet.py verifier f.json → relit une annonce signée

⚠️ CE QUI SE PASSE SI LA CLÉ PRIVÉE FUIT
------------------------------------------------------------------------------
N'importe qui peut alors parler au nom de Droplet, à tous vos utilisateurs,
sans qu'aucun téléphone puisse s'en apercevoir — c'est exactement la
propriété qu'on cherchait, retournée contre vous. Il n'y a pas de
révocation possible sans publier une mise à jour de l'application.

Donc : la clé privée ne monte sur AUCUN serveur, n'entre dans AUCUN dépôt
git, et ne va sur AUCUN téléphone. Le fichier est créé en 0600.

⚠️ POURQUOI LA SIGNATURE PORTE SUR UN TEXTE CANONIQUE, PAS SUR LE JSON
------------------------------------------------------------------------------
Deux bibliothèques JSON n'écrivent pas les mêmes octets pour le même
contenu : ordre des clés, espaces, échappement d'Unicode. Si l'on signait
« le fichier », la vérification échouerait sur un simple reformatage.
On signe donc une chaîne reconstruite champ par champ, dans un ordre fixe,
que Dart et Python savent rebâtir à l'identique. Le format exact est décrit
ci-dessous et DOIT rester synchronisé avec `annonces_droplet.dart`.

    id \n version \n date-ISO \n versionMini \n lien \n
    puis, par langue triée : langue \n titre \n corps \n

Chaque champ est d'abord débarrassé de ses sauts de ligne (remplacés par
« \\n » littéral) pour qu'un corps multiligne ne puisse pas se faire passer
pour un champ supplémentaire — c'est l'attaque classique contre ce genre de
format, et elle est gratuite à empêcher.
"""

import argparse
import base64
import datetime
import json
import os
import pathlib
import sys

try:
    from cryptography.hazmat.primitives.asymmetric.ed25519 import (
        Ed25519PrivateKey,
        Ed25519PublicKey,
    )
except ImportError:
    sys.exit("Il manque la bibliothèque : pip install cryptography")

LANGUES = ["ar", "de", "en", "es", "fr", "hi", "it", "pt", "ru", "zh"]
VERSION_FORMAT = 1
CLE_DEFAUT = pathlib.Path.home() / ".droplet" / "annonces.cle"


# ── LE TEXTE CANONIQUE ──────────────────────────────────────────────────

def _plat(v):
    """Aplatit un champ : plus aucun saut de ligne réel ne subsiste.

    Sans ça, un corps d'annonce contenant un retour à la ligne décalerait
    tous les champs suivants, et deux annonces différentes pourraient
    produire le même texte à signer.
    """
    return str(v).replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "")


def canonique(a):
    """Le texte exact qui est signé. Doit être identique côté Dart."""
    lignes = [
        _plat(a["id"]),
        str(VERSION_FORMAT),
        _plat(a["date"]),
        _plat(a.get("versionMini", "")),
        _plat(a.get("lien", "")),
    ]
    for lg in sorted(a["textes"]):
        lignes.append(_plat(lg))
        lignes.append(_plat(a["textes"][lg]["titre"]))
        lignes.append(_plat(a["textes"][lg]["corps"]))
    return "\n".join(lignes)


# ── LES COMMANDES ───────────────────────────────────────────────────────

def cmd_cles(args):
    chemin = pathlib.Path(args.sortie or CLE_DEFAUT)
    if chemin.exists() and not args.ecraser:
        sys.exit(
            f"{chemin} existe déjà.\n"
            "⚠️ L'écraser rendrait MUETTES toutes les applications déjà\n"
            "   publiées : elles ne reconnaîtraient plus vos annonces.\n"
            "   Utilisez --ecraser seulement si vous savez pourquoi."
        )
    chemin.parent.mkdir(parents=True, exist_ok=True)
    privee = Ed25519PrivateKey.generate()
    brut = privee.private_bytes_raw()
    chemin.write_bytes(base64.b64encode(brut))
    os.chmod(chemin, 0o600)

    pub = privee.public_key().public_bytes_raw()
    print(f"Clé privée écrite dans {chemin} (lisible par vous seul).")
    print()
    print("Collez ceci dans lib/core/config/compte_droplet.dart :")
    print()
    print("  static const String clePubliqueBase64 =")
    print(f"      '{base64.b64encode(pub).decode()}';")
    print()
    print("⚠️ Sauvegardez la clé privée hors ligne. Perdue, elle ne se")
    print("   retrouve pas : il faudrait publier une mise à jour de l'app")
    print("   pour annoncer quoi que ce soit à nouveau.")


def _charger_privee(args):
    chemin = pathlib.Path(args.cle or CLE_DEFAUT)
    if not chemin.exists():
        sys.exit(f"Pas de clé dans {chemin}. Lancez d'abord : annonce_droplet.py cles")
    return Ed25519PrivateKey.from_private_bytes(base64.b64decode(chemin.read_bytes()))


def cmd_signer(args):
    privee = _charger_privee(args)
    source = json.loads(pathlib.Path(args.fichier).read_text(encoding="utf-8"))

    manquantes = [lg for lg in LANGUES if lg not in source.get("textes", {})]
    if manquantes and not args.partiel:
        sys.exit(
            "Langues manquantes : " + ", ".join(manquantes) + "\n"
            "⚠️ Une annonce sans traduction s'affiche en anglais chez ces\n"
            "   utilisateurs — ou pire, dans une langue qu'ils ne lisent pas.\n"
            "   Passez --partiel si c'est assumé."
        )

    annonce = {
        "id": source["id"],
        "version": VERSION_FORMAT,
        "date": source.get("date") or datetime.datetime.now(
            datetime.timezone.utc
        ).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "versionMini": source.get("versionMini", ""),
        "lien": source.get("lien", ""),
        "textes": source["textes"],
    }
    texte = canonique(annonce)
    annonce["signature"] = base64.b64encode(
        privee.sign(texte.encode("utf-8"))
    ).decode()

    sortie = pathlib.Path(args.sortie or "annonces.json")
    # Le serveur sert UN fichier qui contient TOUTES les annonces : un
    # téléphone qui n'a rien vu depuis six mois rattrape tout d'un coup,
    # au lieu de deviner les identifiants qu'il a manqués.
    if sortie.exists() and not args.seule:
        lot = json.loads(sortie.read_text(encoding="utf-8"))
        lot = [a for a in lot if a["id"] != annonce["id"]]
    else:
        lot = []
    lot.append(annonce)
    lot.sort(key=lambda a: a["date"], reverse=True)
    if args.garder:
        lot = lot[: args.garder]
    sortie.write_text(
        json.dumps(lot, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Annonce « {annonce['id']} » signée. {sortie} contient {len(lot)} annonce(s).")
    print(f"Déposez {sortie} sur le serveur, à l'adresse configurée dans")
    print("lib/core/config/compte_droplet.dart (cheminAnnonces).")


def cmd_verifier(args):
    lot = json.loads(pathlib.Path(args.fichier).read_text(encoding="utf-8"))
    if isinstance(lot, dict):
        lot = [lot]
    pub_b64 = args.cle_publique
    if not pub_b64:
        chemin = pathlib.Path(args.cle or CLE_DEFAUT)
        if not chemin.exists():
            sys.exit("Donnez --cle-publique, ou gardez la clé privée à portée.")
        privee = Ed25519PrivateKey.from_private_bytes(
            base64.b64decode(chemin.read_bytes())
        )
        pub_b64 = base64.b64encode(privee.public_key().public_bytes_raw()).decode()
    pub = Ed25519PublicKey.from_public_bytes(base64.b64decode(pub_b64))

    mauvaises = 0
    for a in lot:
        try:
            pub.verify(
                base64.b64decode(a["signature"]), canonique(a).encode("utf-8")
            )
            etat = "OK     "
        except Exception:
            etat = "REFUSÉE"
            mauvaises += 1
        titre = a["textes"].get("fr", next(iter(a["textes"].values())))["titre"]
        print(f"{etat}  {a['date']}  {a['id']}  {titre}")
    print()
    print(
        f"{len(lot)} annonce(s), {mauvaises} refusée(s)."
        if mauvaises
        else f"{len(lot)} annonce(s), toutes valides."
    )
    return 1 if mauvaises else 0


def main():
    p = argparse.ArgumentParser(
        description="Signe les annonces du compte officiel Droplet.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    sous = p.add_subparsers(dest="cmd", required=True)

    c = sous.add_parser("cles", help="crée la paire de clés")
    c.add_argument("--sortie")
    c.add_argument("--ecraser", action="store_true")
    c.set_defaults(fn=cmd_cles)

    s = sous.add_parser("signer", help="signe une annonce et l'ajoute au lot")
    s.add_argument("fichier", help="le brouillon JSON (voir annonce_exemple.json)")
    s.add_argument("--sortie", help="le lot à produire (défaut: annonces.json)")
    s.add_argument("--cle")
    s.add_argument("--seule", action="store_true", help="repart d'un lot vide")
    s.add_argument("--partiel", action="store_true", help="accepte les traductions manquantes")
    s.add_argument("--garder", type=int, default=50, help="nombre d'annonces conservées")
    s.set_defaults(fn=cmd_signer)

    v = sous.add_parser("verifier", help="relit un lot signé")
    v.add_argument("fichier")
    v.add_argument("--cle")
    v.add_argument("--cle-publique")
    v.set_defaults(fn=cmd_verifier)

    args = p.parse_args()
    sys.exit(args.fn(args) or 0)


if __name__ == "__main__":
    main()
