// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE COMPTE OFFICIEL DROPLET — l'identité qui annonce les nouveautés de
// l'application, et la clé publique qui prouve que c'est bien elle.
//
// ── ⚠️ POURQUOI UNE SIGNATURE, ET PAS SIMPLEMENT UN SERVEUR ───────────
//
// Chez WhatsApp, ce qui garantit que le compte officiel est officiel,
// c'est le serveur : on fait confiance à Meta. Droplet n'a pas de serveur
// de confiance — les annonces voyagent par le maillage, de téléphone en
// téléphone, en passant par des appareils que personne ne contrôle.
//
// La garantie doit donc être PORTÉE PAR L'ANNONCE ELLE-MÊME. Chaque
// annonce est signée en Ed25519 ; la clé publique ci-dessous est gravée
// dans le binaire. N'importe qui peut RELAYER une annonce — c'est même
// souhaité, c'est ce qui la fait arriver hors ligne. Personne ne peut en
// FABRIQUER une.
//
// Une conséquence qui mérite d'être dite : un relais hostile ne peut pas
// non plus MODIFIER une annonce au passage. Un caractère changé et la
// signature ne colle plus ; le téléphone jette l'annonce sans la montrer.
//
// ── ⚠️ CE QUE CETTE CLÉ NE PROTÈGE PAS ────────────────────────────────
//
// Elle prouve l'ORIGINE, pas la FRAÎCHEUR. Un relais peut taire une
// annonce (on ne la verra pas) ou rejouer une vieille annonce valide. Le
// premier cas est inévitable dans un maillage et sans conséquence — une
// annonce manquée n'est pas une annonce fausse. Le second est neutralisé
// par l'identifiant : une annonce déjà vue n'est jamais réaffichée.
//
// ── ⚠️ LA CLÉ CI-DESSOUS EST UNE CLÉ DE DÉMONSTRATION ─────────────────
//
// Elle est publique, elle est dans ce dépôt, et sa clé privée a servi à
// un essai. Elle DOIT être remplacée avant toute publication :
//
//     python3 outils/annonce_droplet.py cles
//
// L'outil imprime la ligne à coller ici. Remplacer cette clé APRÈS une
// publication rendrait muettes toutes les applications déjà installées :
// elles ne reconnaîtraient plus vos annonces. C'est donc une chose à
// faire une fois, au début, et jamais ensuite.
// ============================================================================

/// Le compte officiel : son identité, sa clé, son adresse.
class CompteDroplet {
  const CompteDroplet._();

  /// L'identifiant d'expéditeur des annonces.
  ///
  /// ⚠️ IL NE CORRESPOND À AUCUN PAIR DU MAILLAGE, et c'est voulu. La
  /// liste des discussions se dérive des messages, pas d'une table de
  /// conversations : un message portant cet expéditeur suffit à faire
  /// exister la conversation, sans que personne ait à être connecté.
  static const String id = 'droplet.officiel';

  /// Le nom affiché. Volontairement pas traduit : c'est un nom propre.
  static const String pseudo = 'Droplet';

  /// Le `type` porté par les messages d'annonce, pour les distinguer d'un
  /// message ordinaire partout où ça compte (composeur verrouillé, coche,
  /// relais). La colonne `type` est un texte libre : aucune migration.
  static const String typeMessage = 'annonce';

  /// La clé publique Ed25519, en base64 (32 octets).
  ///
  /// ⚠️ CLÉ DE DÉMONSTRATION — voir l'en-tête du fichier.
  static const String clePubliqueBase64 =
      'fEFkzuKRiEffd7+wDAopuLLPu78bVkUC7bAzh4SBK58=';

  /// Où l'application va chercher le lot d'annonces quand elle a Internet.
  ///
  /// Le serveur sert UN fichier contenant TOUTES les annonces récentes :
  /// un téléphone qui n'a rien vu depuis six mois rattrape tout d'un coup,
  /// au lieu d'avoir à deviner les identifiants qu'il a manqués.
  static const String cheminAnnonces = '/annonces.json';

  /// Combien de temps au plus entre deux vérifications par Internet.
  ///
  /// ⚠️ PAS À CHAQUE OUVERTURE. Les annonces sortent quelques fois par an ;
  /// interroger le serveur à chaque lancement coûterait de la batterie et
  /// dessinerait, requête après requête, une carte des heures auxquelles
  /// chaque utilisateur ouvre l'application.
  static const Duration intervalleVerification = Duration(hours: 12);

  /// Combien d'annonces le téléphone garde en mémoire pour les relayer.
  ///
  /// Au-delà, les plus anciennes cessent d'être proposées aux voisins :
  /// quelqu'un qui installe l'application aujourd'hui n'a pas besoin de
  /// recevoir les nouveautés d'il y a trois ans par Bluetooth.
  static const int relaisMax = 12;

  /// Version du format signé. Doit rester synchronisée avec
  /// `VERSION_FORMAT` dans `outils/annonce_droplet.py`.
  static const int versionFormat = 1;
}
