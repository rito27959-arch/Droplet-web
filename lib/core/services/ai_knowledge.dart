// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA FICHE DE CONNAISSANCE DE DROPLET — le texte, en français, que
// l'assistant reçoit en tout début de conversation pour savoir de quoi
// il parle. C'est ce qui fait de lui « un connaisseur de Droplet » plutôt
// qu'un modèle générique qui devine.
//
// ── POURQUOI UNE FICHE ÉCRITE À LA MAIN, ET PAS UN VRAI RAG ────────────
//
// Un modèle de 1 milliard de paramètres n'a AUCUNE connaissance fiable
// d'une app qui n'existait pas dans ses données d'entraînement. Sans
// cadrage, il invente : il décrit des menus qui n'existent pas, prête à
// Droplet des fonctions d'autres messageries, se trompe sur ce qui marche
// hors ligne. La seule façon de corriger ça sans embarquer un index
// vectoriel (exclu de l'APK pour l'alléger — voir `ai_chat_screen.dart`)
// est de lui DONNER les faits, une fois, au début.
//
// ── ⚠️ LE BUDGET DE JETONS EST UNE CONTRAINTE DURE, PAS UN CONFORT ─────
//
// Cette fiche est réinjectée à chaque ouverture et compte dans la fenêtre
// de contexte de 2048 jetons (voir `_charger`). Le fichier `.task` du
// modèle est converti pour un contexte court ; une amorce trop longue a
// un coût BIEN concret :
//   - sur CPU, le préchargement (prefill) de l'amorce avant le premier
//     jeton de réponse peut dépasser le délai d'inactivité → « Désolé,
//     une erreur s'est produite » à chaque message ;
//   - la session native déborde et se recrée sans arrêt, ce qui vide
//     justement cette amorce en premier.
// Une première version de cette fiche faisait ~600 jetons et cassait
// l'assistant sur l'appareil de test. CIBLE STRICTE : ~250 jetons, ~1200
// caractères. Si tu ajoutes une ligne, retires-en une autre. Le test
// `test/ai_memoire_test.dart` échoue si la fiche dépasse 1600 caractères.
//
// ⚠️ RÈGLE : n'écris ici que ce qui est VRAI dans l'app livrée. Une fiche
// qui décrit une fonction prévue mais pas encore branchée est pire que
// pas de fiche du tout — l'assistant guiderait vers un bouton absent.
// ============================================================================

/// Fiche de connaissance injectée en amorce de chaque conversation avec
/// l'assistant. Voir l'en-tête du fichier pour les règles d'édition —
/// notamment la cible stricte de longueur.
const String kDropletKnowledge = '''
Droplet est une messagerie chiffrée de bout en bout qui marche SANS réseau : les téléphones proches se relaient les messages de proche en proche (« mesh »). Pas de compte ni de numéro ; l'identité est une clé créée sur l'appareil.

Un message cherche un chemin dans cet ordre : mesh direct (Bluetooth / Wi-Fi Direct), puis relais multi-sauts par les autres appareils Droplet, puis boîte aux lettres (il attend chiffré sur un relais), puis Tor (via Internet, sans serveur qui voie qui parle à qui — à activer dans Réglages, le premier démarrage prend ~1 min). Un message non remis reste « en attente » et repart seul.

Trouver quelqu'un : les appareils proches apparaissent seuls dans Discussions et Pairs ; l'onglet Pairs cherche aussi un pseudo dans l'annuaire (facultatif, demande Tor ou Internet).

Appels audio/vidéo : par le mesh en proximité, par un serveur de mise en relation à distance (le flux reste chiffré). Actus : statuts qui disparaissent après 24 h. Sécurité : « Je vais bien », demande d'aide avec position, signaler/bloquer un contact depuis sa fiche (signalement anonyme, aucun message transmis). Groupes et diffusion mesh existent.

Réglages : thème, langue, fond de discussion, sons, relais en arrière-plan, Tor, cet assistant. Vie privée : aucun serveur central, les relais ne voient que du chiffré, les photos partent en vignette. Droplet ne fait pas : sauvegarde cloud, multi-appareils, messages vers des gens sans Droplet.
''';
