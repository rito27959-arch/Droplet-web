// LES DONNÉES DE DROPLET WEB — ce que l'interface affiche et manipule.
//
// Ces modèles ne savent rien du réseau. Le dépôt (`depot.dart`) les garde,
// les enregistre dans le navigateur et les fait circuler par un transport
// (`transport.dart`) : en démonstration un transport simulé, demain celui
// des serveurs Droplet. Les écrans, eux, ne changeront pas.

enum TypeDiscussion { directe, groupe }

enum TypeMessage { texte, image, vocal, fichier, systeme }

/// Le cycle de vie d'un message envoyé, comme les coches de l'app :
/// horloge → une coche → deux coches → deux coches de couleur.
enum StatutMessage { envoi, envoye, recu, lu, echec }

enum ThemeChoisi { systeme, clair, sombre }

/// Moi : l'identifiant réservé à l'utilisateur de ce navigateur.
const String kMoi = 'moi';

class Contact {
  Contact({
    required this.id,
    required this.pseudo,
    this.aPropos = '',
    this.couleur = 0,
    this.enLigne = false,
    this.vuA,
    this.bloque = false,
  });

  final String id;
  String pseudo;
  String aPropos;

  /// Index dans la palette d'avatars (`palettesAvatar`).
  int couleur;
  bool enLigne;
  DateTime? vuA;
  bool bloque;

  Map<String, dynamic> toJson() => {
        'id': id,
        'pseudo': pseudo,
        'aPropos': aPropos,
        'couleur': couleur,
        'vuA': vuA?.toIso8601String(),
        'bloque': bloque,
      };

  factory Contact.fromJson(Map<String, dynamic> j) => Contact(
        id: j['id'] as String,
        pseudo: j['pseudo'] as String? ?? '',
        aPropos: j['aPropos'] as String? ?? '',
        couleur: j['couleur'] as int? ?? 0,
        vuA: j['vuA'] == null ? null : DateTime.tryParse(j['vuA'] as String),
        bloque: j['bloque'] as bool? ?? false,
      );
}

class Discussion {
  Discussion({
    required this.id,
    required this.type,
    required this.titre,
    required this.membres,
    this.couleur = 0,
    this.epinglee = false,
    this.archivee = false,
    this.sourdine = false,
    this.nonLus = 0,
    this.ephemereSecondes = 0,
    this.brouillon = '',
    this.description = '',
    this.admins = const [kMoi],
    this.quitte = false,
    DateTime? creeeLe,
  }) : creeeLe = creeeLe ?? DateTime.now();

  final String id;
  final TypeDiscussion type;
  String titre;

  /// Les identifiants des participants, sans moi.
  List<String> membres;
  int couleur;
  bool epinglee;
  bool archivee;
  bool sourdine;
  int nonLus;

  /// 0 = messages permanents ; sinon, durée de vie des nouveaux messages.
  int ephemereSecondes;
  String brouillon;
  String description;
  List<String> admins;

  /// J'ai quitté ce groupe : on le lit encore, on n'y écrit plus.
  bool quitte;
  final DateTime creeeLe;

  bool get estGroupe => type == TypeDiscussion.groupe;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'titre': titre,
        'membres': membres,
        'couleur': couleur,
        'epinglee': epinglee,
        'archivee': archivee,
        'sourdine': sourdine,
        'nonLus': nonLus,
        'ephemere': ephemereSecondes,
        'brouillon': brouillon,
        'description': description,
        'admins': admins,
        'quitte': quitte,
        'creeeLe': creeeLe.toIso8601String(),
      };

  factory Discussion.fromJson(Map<String, dynamic> j) => Discussion(
        id: j['id'] as String,
        type: TypeDiscussion.values.byName(j['type'] as String? ?? 'directe'),
        titre: j['titre'] as String? ?? '',
        membres: (j['membres'] as List? ?? const []).cast<String>(),
        couleur: j['couleur'] as int? ?? 0,
        epinglee: j['epinglee'] as bool? ?? false,
        archivee: j['archivee'] as bool? ?? false,
        sourdine: j['sourdine'] as bool? ?? false,
        nonLus: j['nonLus'] as int? ?? 0,
        ephemereSecondes: j['ephemere'] as int? ?? 0,
        brouillon: j['brouillon'] as String? ?? '',
        description: j['description'] as String? ?? '',
        admins: (j['admins'] as List? ?? const [kMoi]).cast<String>(),
        quitte: j['quitte'] as bool? ?? false,
        creeeLe: DateTime.tryParse(j['creeeLe'] as String? ?? ''),
      );
}

/// Une pièce jointe : photo, vocal ou fichier. Le contenu est une adresse
/// `data:` (ou `blob:`) utilisable telle quelle par le navigateur.
class PieceJointe {
  PieceJointe({
    required this.nom,
    required this.mime,
    required this.taille,
    required this.url,
    this.largeur,
    this.hauteur,
    this.dureeMs,
    this.onde = const [],
  });

  final String nom;
  final String mime;
  final int taille;
  final String url;
  final int? largeur;
  final int? hauteur;

  /// Pour un vocal.
  final int? dureeMs;
  final List<double> onde;

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'mime': mime,
        'taille': taille,
        // Les gros contenus ne sont pas gardés d'une session à l'autre :
        // le stockage du navigateur est limité. Le jour où les serveurs sont
        // branchés, la boîte aux lettres garde la copie chiffrée.
        'url': url.length < 400000 ? url : '',
        'largeur': largeur,
        'hauteur': hauteur,
        'dureeMs': dureeMs,
        'onde': onde,
      };

  factory PieceJointe.fromJson(Map<String, dynamic> j) => PieceJointe(
        nom: j['nom'] as String? ?? '',
        mime: j['mime'] as String? ?? '',
        taille: j['taille'] as int? ?? 0,
        url: j['url'] as String? ?? '',
        largeur: j['largeur'] as int?,
        hauteur: j['hauteur'] as int?,
        dureeMs: j['dureeMs'] as int?,
        onde: (j['onde'] as List? ?? const []).map((e) => (e as num).toDouble()).toList(),
      );
}

class Message {
  Message({
    required this.id,
    required this.discussionId,
    required this.auteurId,
    required this.type,
    required this.date,
    this.texte = '',
    this.piece,
    this.reponseA,
    Map<String, List<String>>? reactions,
    this.statut = StatutMessage.envoye,
    this.modifie = false,
    this.supprime = false,
    this.epingle = false,
    this.important = false,
    this.transfere = false,
    this.expireLe,
  }) : reactions = reactions ?? {};

  final String id;
  final String discussionId;
  final String auteurId;
  final TypeMessage type;
  final DateTime date;
  String texte;
  PieceJointe? piece;

  /// L'identifiant du message auquel celui-ci répond.
  String? reponseA;

  /// emoji → auteurs.
  Map<String, List<String>> reactions;
  StatutMessage statut;
  bool modifie;
  bool supprime;
  bool epingle;
  bool important;
  bool transfere;
  DateTime? expireLe;

  bool get deMoi => auteurId == kMoi;

  Map<String, dynamic> toJson() => {
        'id': id,
        'disc': discussionId,
        'auteur': auteurId,
        'type': type.name,
        'date': date.toIso8601String(),
        'texte': texte,
        'piece': piece?.toJson(),
        'reponseA': reponseA,
        'reactions': reactions,
        'statut': statut.name,
        'modifie': modifie,
        'supprime': supprime,
        'epingle': epingle,
        'important': important,
        'transfere': transfere,
        'expireLe': expireLe?.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id'] as String,
        discussionId: j['disc'] as String,
        auteurId: j['auteur'] as String,
        type: TypeMessage.values.byName(j['type'] as String? ?? 'texte'),
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        texte: j['texte'] as String? ?? '',
        piece: j['piece'] == null ? null : PieceJointe.fromJson((j['piece'] as Map).cast<String, dynamic>()),
        reponseA: j['reponseA'] as String?,
        reactions: ((j['reactions'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k as String, (v as List).cast<String>())),
        statut: StatutMessage.values.byName(j['statut'] as String? ?? 'envoye'),
        modifie: j['modifie'] as bool? ?? false,
        supprime: j['supprime'] as bool? ?? false,
        epingle: j['epingle'] as bool? ?? false,
        important: j['important'] as bool? ?? false,
        transfere: j['transfere'] as bool? ?? false,
        expireLe: j['expireLe'] == null ? null : DateTime.tryParse(j['expireLe'] as String),
      );
}

/// Un statut (onglet Actus) : un texte sur un fond de couleur, 24 heures.
class Statut {
  Statut({
    required this.id,
    required this.auteurId,
    required this.texte,
    required this.fond,
    required this.date,
    this.image,
    List<String>? vuPar,
    List<String>? aimePar,
  })  : vuPar = vuPar ?? [],
        aimePar = aimePar ?? [];

  final String id;
  final String auteurId;
  final String texte;

  /// Une photo (adresse `data:`), ou rien pour un statut texte.
  final String? image;

  /// Index dans `fondsStatut`.
  final int fond;
  final DateTime date;
  List<String> vuPar;
  List<String> aimePar;

  bool get expire => DateTime.now().difference(date) > const Duration(hours: 24);

  Map<String, dynamic> toJson() => {
        'id': id,
        'auteur': auteurId,
        'texte': texte,
        'fond': fond,
        'date': date.toIso8601String(),
        'image': image != null && image!.length < 400000 ? image : null,
        'vuPar': vuPar,
        'aimePar': aimePar,
      };

  factory Statut.fromJson(Map<String, dynamic> j) => Statut(
        id: j['id'] as String,
        auteurId: j['auteur'] as String,
        texte: j['texte'] as String? ?? '',
        fond: j['fond'] as int? ?? 0,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        image: j['image'] as String?,
        vuPar: (j['vuPar'] as List? ?? const []).cast<String>(),
        aimePar: (j['aimePar'] as List? ?? const []).cast<String>(),
      );
}

class Appel {
  Appel({
    required this.id,
    required this.discussionId,
    required this.video,
    required this.entrant,
    required this.date,
    this.manque = false,
    this.dureeSecondes = 0,
  });

  final String id;
  final String discussionId;
  final bool video;
  final bool entrant;
  final DateTime date;
  final bool manque;
  final int dureeSecondes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'disc': discussionId,
        'video': video,
        'entrant': entrant,
        'date': date.toIso8601String(),
        'manque': manque,
        'duree': dureeSecondes,
      };

  factory Appel.fromJson(Map<String, dynamic> j) => Appel(
        id: j['id'] as String,
        discussionId: j['disc'] as String,
        video: j['video'] as bool? ?? false,
        entrant: j['entrant'] as bool? ?? false,
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        manque: j['manque'] as bool? ?? false,
        dureeSecondes: j['duree'] as int? ?? 0,
      );
}

class Profil {
  Profil({this.pseudo = '', this.aPropos = '', this.couleur = 0, this.photo});

  String pseudo;
  String aPropos;
  int couleur;

  /// Une adresse `data:` d'image, ou rien.
  String? photo;

  Map<String, dynamic> toJson() => {'pseudo': pseudo, 'aPropos': aPropos, 'couleur': couleur, 'photo': photo};

  factory Profil.fromJson(Map<String, dynamic> j) => Profil(
        pseudo: j['pseudo'] as String? ?? '',
        aPropos: j['aPropos'] as String? ?? '',
        couleur: j['couleur'] as int? ?? 0,
        photo: j['photo'] as String?,
      );
}

class ReglagesWeb {
  ReglagesWeb({
    this.theme = ThemeChoisi.systeme,
    this.accent = 'rose',
    this.tailleTexte = 15,
    this.fond = 0,
    this.notifications = true,
    this.sons = true,
    this.entreeEnvoie = true,
    this.apercuLiens = false,
    this.confirmationsLecture = true,
  });

  ThemeChoisi theme;
  String accent;
  double tailleTexte;

  /// Index dans `fondsDiscussion`.
  int fond;
  bool notifications;
  bool sons;
  bool entreeEnvoie;
  bool apercuLiens;
  bool confirmationsLecture;

  Map<String, dynamic> toJson() => {
        'theme': theme.name,
        'accent': accent,
        'tailleTexte': tailleTexte,
        'fond': fond,
        'notifications': notifications,
        'sons': sons,
        'entreeEnvoie': entreeEnvoie,
        'apercuLiens': apercuLiens,
        'lecture': confirmationsLecture,
      };

  factory ReglagesWeb.fromJson(Map<String, dynamic> j) => ReglagesWeb(
        theme: ThemeChoisi.values.byName(j['theme'] as String? ?? 'systeme'),
        accent: j['accent'] as String? ?? 'rose',
        tailleTexte: (j['tailleTexte'] as num?)?.toDouble() ?? 15,
        fond: j['fond'] as int? ?? 0,
        notifications: j['notifications'] as bool? ?? true,
        sons: j['sons'] as bool? ?? true,
        entreeEnvoie: j['entreeEnvoie'] as bool? ?? true,
        apercuLiens: j['apercuLiens'] as bool? ?? false,
        confirmationsLecture: j['lecture'] as bool? ?? true,
      );
}
