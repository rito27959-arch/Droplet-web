// ============================================================================
// LES COORDONNÉES DE DROPLET — un seul endroit à changer.
// ----------------------------------------------------------------------------
// L'écran de contact, la politique de confidentialité et l'écran des données
// lisent tous ce fichier. Changer d'adresse ou de numéro se fait ICI, en une
// ligne, et se répercute partout — y compris dans les dix langues, puisque
// les traductions ne contiennent aucune coordonnée en dur.
//
// ⚠️ CE FICHIER EST PUBLIC. Il part dans l'application, donc tout ce qui s'y
// trouve est lisible par n'importe qui l'installe. N'y mettre que ce qu'on
// accepte de rendre public.
// ============================================================================

/// Qui publie Droplet — le « responsable du traitement » au sens du RGPD
/// (article 13, alinéa 1a : l'identité du responsable doit être indiquée).
///
/// ⚠️ ASSUMÉ ET INCOMPLET. Le RGPD attend une identité précise — une
/// personne ou une société, avec une adresse. « Droplet » seul suffit pour
/// une application distribuée entre voisins, mais un magasin d'applications
/// européen peut demander davantage le jour d'une publication officielle.
/// Le jour où ce nom existe, il se met ici et nulle part ailleurs.
const String kEditeur = 'Droplet';

/// L'adresse à laquelle on écrit pour l'assistance ET pour tout ce qui
/// touche aux données personnelles (accès, effacement, opposition).
///
/// La même que sur le site (dropletmesh.app) : une adresse du domaine,
/// redirigée vers la boîte qu'on relève. Ainsi l'adresse personnelle ne
/// part plus dans l'application, lisible par quiconque l'installe.
const String kEmailContact = 'contact@dropletmesh.app';

/// Le numéro WhatsApp de l'assistance — le même que pour les licences Pro.
const String kWhatsAppContact = '+237 678 963 221';

/// Le numéro sans espaces ni signe, tel que `wa.me` l'attend.
String get kWhatsAppNumero =>
    kWhatsAppContact.replaceAll(RegExp(r'[^0-9]'), '');

/// La version affichée dans l'écran de contact et jointe à un signalement.
///
/// ⚠️ À TENIR À JOUR AVEC `pubspec.yaml`. L'application n'embarque pas de
/// paquet qui lirait sa propre version à l'exécution ; ce serait une
/// dépendance de plus pour une chaîne de caractères. Le prix de ce choix,
/// c'est cette ligne : la changer en même temps que `version:` dans le
/// pubspec. Une version fausse dans un rapport de bug fait chercher au
/// mauvais endroit.
const String kVersionApp = '1.0.0';

/// La date de dernière mise à jour des textes légaux, affichée en bas de la
/// politique.
///
/// ⚠️ À CHANGER EN MÊME TEMPS QUE LES TEXTES. Une politique dont la date ne
/// bouge jamais est un signal de négligence ; pire, elle laisse croire qu'on
/// lit la version en vigueur alors qu'elle a changé.
const String kDatePolitique = '2026-09-29';

/// Les serveurs que Droplet utilise VRAIMENT, pour que l'écran des données
/// puisse les nommer un par un au lieu de parler de « nos partenaires ».
///
/// Toute nouvelle adresse dans `server_config.dart` doit apparaître ici,
/// sans quoi l'écran des données ment par omission.
enum ServeurDroplet {
  /// `droplet_directory` — retrouver quelqu'un par son pseudo, la page
  /// d'invitation, et le réveil par notification.
  annuaire,

  /// `droplet_mailbox` — les messages déposés pour quelqu'un qui n'est pas
  /// là, en attendant qu'il revienne.
  boiteAuxLettres,

  /// `droplet_server` — la mise en relation des appels et des salons
  /// vocaux. Aucune voix n'y passe : seulement les adresses pour se
  /// trouver.
  signalisation,

  /// Les relais TURN de Cloudflare — empruntés seulement quand deux
  /// téléphones n'arrivent pas à se joindre directement.
  relais,

  /// Le serveur de licences Pro. ⚠️ `kServeurLicences` est VIDE aujourd'hui
  /// (voir `paiement_service.dart`) : aucun paiement automatique n'existe,
  /// donc ce serveur ne reçoit rien. L'écran des données doit le dire tel
  /// quel plutôt que d'annoncer un traitement qui n'a pas lieu.
  licences,
}
