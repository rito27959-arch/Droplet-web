// ============================================================================
// LE TEXTE DE LA POLITIQUE DE CONFIDENTIALITÉ.
// ----------------------------------------------------------------------------
// POURQUOI CE TEXTE N'EST PAS DANS LES FICHIERS `.arb` COMME LE RESTE.
//
// Deux raisons, et la seconde est la vraie.
//
// 1. Une politique se relit d'un bloc. Éclatée en soixante clés réparties
//    dans dix fichiers, plus personne ne peut vérifier qu'elle dit ce
//    qu'elle prétend dire. Ici elle tient en un fichier, dans l'ordre où on
//    la lit, avec sa date.
//
// 2. ⚠️ ELLE N'EST DISPONIBLE QU'EN FRANÇAIS ET EN ANGLAIS, DÉLIBÉRÉMENT.
//    Tout le reste de Droplet est traduit en dix langues. Pas ceci. Un
//    texte juridique engage : une tournure approximative en arabe ou en
//    chinois créerait une obligation que personne n'a voulue, et c'est
//    précisément le document où une traduction approximative devient une
//    responsabilité plutôt qu'un défaut de finition. Les autres langues
//    reçoivent la version française, et l'écran le dit en une ligne au lieu
//    de le cacher. Le jour où quelqu'un traduit ce texte pour de bon, il
//    s'ajoute ici, langue par langue.
//
// CE QUE CE TEXTE DOIT COUVRIR : les douze points de l'article 13 du RGPD
// (identité du responsable, finalités, base légale, destinataires,
// transferts hors UE, durée de conservation, droits, retrait du
// consentement, réclamation, caractère obligatoire ou non, décision
// automatisée). Chaque section ci-dessous porte en commentaire le point
// qu'elle couvre — retirer une section, c'est retirer une obligation.
//
// ET SURTOUT : IL DOIT ÊTRE VRAI. Chaque affirmation ici correspond à du
// code qu'on peut aller lire. Les quatre serveurs nommés sont ceux de
// `server_config.dart` et `contact_config.dart`, ni plus ni moins.
// ============================================================================

import '../../core/config/contact_config.dart';

/// Une section de la politique : un titre, et des paragraphes.
class SectionPolitique {
  const SectionPolitique(this.titre, this.paragraphes);

  final String titre;
  final List<String> paragraphes;
}

/// La politique dans la langue demandée. Toute langue autre que l'anglais
/// reçoit le français — voir l'en-tête de ce fichier.
List<SectionPolitique> politique(String langue) =>
    langue == 'en' ? _anglais : _francais;

/// Vrai quand la personne lit la politique dans une langue qui n'est pas la
/// sienne : l'écran doit le dire plutôt que de laisser croire à un bug.
bool politiqueTraduite(String langue) => langue == 'fr' || langue == 'en';

// ── FRANÇAIS ───────────────────────────────────────────────────────────

final List<SectionPolitique> _francais = [
  const SectionPolitique('En une phrase', [
    'Droplet ne collecte rien sur vous. Pas de compte, pas de numéro de '
        'téléphone, pas d\'adresse e-mail, pas de publicité, pas de mesure '
        'd\'audience. Vos messages voyagent chiffrés d\'un téléphone à '
        'l\'autre et personne au milieu ne peut les lire — pas même nous.',
    'Le reste de ce document explique les quelques exceptions, parce '
        'qu\'une politique qui dit « nous ne collectons rien » et s\'arrête '
        'là est une politique qui ment.',
  ]),

  // RGPD art. 13.1.a — identité et coordonnées du responsable.
  SectionPolitique('Qui est responsable', [
    'L\'application est publiée sous le nom de $kEditeur, projet '
        'indépendant. Pour toute question sur ce document ou sur vos '
        'données : $kEmailContact.',
    'Droplet n\'a pas de délégué à la protection des données : la loi n\'en '
        'impose un qu\'au-delà d\'une certaine échelle de traitement, et '
        'Droplet ne traite presque rien. L\'adresse ci-dessus est le point '
        'de contact unique.',
  ]),

  // RGPD art. 13.1.c — finalités et base légale.
  const SectionPolitique('Ce que l\'application garde sur votre téléphone', [
    'Votre identité Droplet est une paire de clés fabriquée sur votre '
        'appareil à la première ouverture. Elle n\'est envoyée nulle part. '
        'Votre pseudo et votre photo restent sur votre téléphone et ne '
        'partent qu\'aux personnes à qui vous écrivez.',
    'Vos messages, vos discussions, vos contacts et vos réglages sont '
        'enregistrés dans le téléphone, dans l\'espace privé de '
        'l\'application. Désinstaller Droplet efface tout : il n\'existe '
        'aucune copie ailleurs, et donc aucune restauration possible.',
    'Le journal d\'erreurs est un fichier local. Il ne part jamais tout '
        'seul. Vous pouvez le lire dans les réglages, et c\'est vous qui '
        'décidez de nous l\'envoyer ou non.',
  ]),

  // RGPD art. 13.1.e — destinataires. Nommés un par un.
  const SectionPolitique('Les quatre serveurs, et ce qu\'ils voient', [
    'Sans Internet, Droplet n\'utilise aucun serveur : les téléphones se '
        'parlent directement en Bluetooth ou en Wi-Fi. Avec Internet, quatre '
        'serveurs interviennent, chacun pour une seule chose.',
    'L\'ANNUAIRE sert à retrouver quelqu\'un par son pseudo et à réveiller '
        'un téléphone par notification. Il voit un pseudo et un identifiant '
        'public. Les requêtes de l\'application passent par le réseau Tor : '
        'le serveur ne voit donc pas votre adresse IP réelle.',
    'LA BOÎTE AUX LETTRES garde un message chiffré pour quelqu\'un qui '
        'n\'est pas connecté, le temps qu\'il revienne. Elle ne peut pas le '
        'lire : elle transporte une enveloppe scellée dont elle n\'a pas la '
        'clé. Les requêtes passent également par Tor.',
    'LA MISE EN RELATION sert à établir un appel ou un salon vocal. Elle '
        'voit les identifiants publics des deux appareils et leurs adresses '
        'réseau le temps de les mettre en contact. AUCUNE VOIX N\'Y PASSE.',
    'LES RELAIS servent uniquement quand deux téléphones n\'arrivent pas à '
        'se joindre directement — ce qui arrive souvent entre deux réseaux '
        'mobiles. Le son et l\'image y transitent CHIFFRÉS : le relais les '
        'fait suivre sans pouvoir les ouvrir. Ces relais sont fournis par '
        'Cloudflare.',
  ]),

  // RGPD art. 13.1.f — transferts hors UE.
  const SectionPolitique('Où se trouvent ces serveurs', [
    'L\'annuaire, la boîte aux lettres et la mise en relation sont '
        'hébergés chez Railway. Les relais sont ceux de Cloudflare. Ces deux '
        'entreprises sont américaines et leurs machines peuvent se trouver '
        'hors de l\'Union européenne.',
    'Ce qui leur parvient reste minuscule et chiffré, et les requêtes de '
        'l\'annuaire et de la boîte aux lettres passent par Tor — mais la '
        'loi demande que ce transfert soit indiqué, et il l\'est.',
  ]),

  // RGPD art. 13.2.a — durée de conservation.
  const SectionPolitique('Combien de temps', [
    'Un message déposé dans la boîte aux lettres y reste jusqu\'à ce que '
        'son destinataire le récupère, puis il est effacé. S\'il n\'est '
        'jamais récupéré, il disparaît de lui-même.',
    'L\'annuaire garde une entrée tant que l\'appareil se manifeste. Un '
        'appareil qui ne revient plus finit par en sortir.',
    'La mise en relation et les relais ne gardent rien : ils font passer, '
        'et oublient à la fin de l\'appel.',
  ]),

  // RGPD art. 13.2.b, c, d — droits, retrait, réclamation.
  SectionPolitique('Vos droits', [
    'Le RGPD vous donne le droit d\'accéder à vos données, de les '
        'corriger, de les effacer, d\'en limiter l\'usage, de vous y opposer '
        'et de les emporter ailleurs.',
    'Comme il n\'existe aucun compte, presque tout cela se fait sans nous '
        'écrire : vos données sont sur votre téléphone. Les emporter '
        'ailleurs se fait avec l\'export des réglages. Les effacer se fait '
        'en désinstallant l\'application. Sortir de l\'annuaire se fait en '
        'coupant les fonctions Internet dans les réglages.',
    'Si quelque chose vous échappe, écrivez à $kEmailContact. Et si notre '
        'réponse ne vous satisfait pas, vous pouvez saisir l\'autorité de '
        'protection des données de votre pays.',
  ]),

  // RGPD art. 13.2.e et 13.2.f — caractère obligatoire, décision automatisée.
  const SectionPolitique('Deux précisions', [
    'Rien ne vous est demandé pour utiliser Droplet hors ligne. Les '
        'fonctions Internet — retrouver quelqu\'un par son pseudo, recevoir '
        'une notification, appeler à distance — ont besoin des serveurs '
        'ci-dessus ; les refuser dans les réglages fait perdre ces '
        'fonctions, pas l\'application.',
    'Droplet ne prend aucune décision automatisée à votre sujet et ne '
        'fabrique aucun profil.',
  ]),

  const SectionPolitique('Les mineurs', [
    'Droplet n\'est pas destiné aux enfants de moins de treize ans, et ne '
        'leur demande d\'ailleurs rien, puisqu\'il ne demande rien à '
        'personne.',
  ]),

  const SectionPolitique('Si ce texte change', [
    'La date de dernière mise à jour est indiquée en bas de cet écran. Un '
        'changement qui toucherait à ce que les serveurs voient sera '
        'annoncé dans l\'application, pas glissé discrètement dans une mise '
        'à jour.',
  ]),
];

// ── ENGLISH ────────────────────────────────────────────────────────────

final List<SectionPolitique> _anglais = [
  const SectionPolitique('In one sentence', [
    'Droplet collects nothing about you. No account, no phone number, no '
        'email address, no advertising, no analytics. Your messages travel '
        'encrypted from one phone to another, and nobody in between can '
        'read them — not even us.',
    'The rest of this document explains the few exceptions, because a '
        'policy that says "we collect nothing" and stops there is a policy '
        'that lies.',
  ]),

  SectionPolitique('Who is responsible', [
    'The app is published under the name $kEditeur, an independent '
        'project. For any question about this document or about your data: '
        '$kEmailContact.',
    'Droplet has no data protection officer: the law only requires one '
        'above a certain scale of processing, and Droplet processes almost '
        'nothing. The address above is the single point of contact.',
  ]),

  const SectionPolitique('What the app keeps on your phone', [
    'Your Droplet identity is a key pair generated on your device the '
        'first time you open the app. It is never sent anywhere. Your name '
        'and photo stay on your phone and only reach the people you write '
        'to.',
    'Your messages, chats, contacts and settings are stored on the phone, '
        'in the app\'s private storage. Uninstalling Droplet erases '
        'everything: no copy exists elsewhere, and so no restore is '
        'possible.',
    'The error log is a local file. It never leaves on its own. You can '
        'read it in Settings, and it is up to you whether to send it to us.',
  ]),

  const SectionPolitique('The four servers, and what they see', [
    'Without the internet, Droplet uses no server at all: phones talk '
        'directly over Bluetooth or Wi-Fi. With the internet, four servers '
        'are involved, each for one thing only.',
    'THE DIRECTORY is used to find someone by their name and to wake a '
        'phone with a notification. It sees a name and a public identifier. '
        'The app\'s requests go through the Tor network, so the server does '
        'not see your real IP address.',
    'THE MAILBOX holds an encrypted message for someone who is offline '
        'until they come back. It cannot read it: it carries a sealed '
        'envelope it has no key to. These requests also go through Tor.',
    'THE SIGNALLING SERVER is used to set up a call or a voice room. It '
        'sees both devices\' public identifiers and network addresses for '
        'as long as it takes to connect them. NO AUDIO PASSES THROUGH IT.',
    'THE RELAYS are used only when two phones cannot reach each other '
        'directly — which happens often between two mobile networks. Audio '
        'and video pass through them ENCRYPTED: the relay forwards them '
        'without being able to open them. These relays are provided by '
        'Cloudflare.',
  ]),

  const SectionPolitique('Where those servers are', [
    'The directory, the mailbox and the signalling server are hosted on '
        'Railway. The relays are Cloudflare\'s. Both companies are American '
        'and their machines may sit outside the European Union.',
    'What reaches them stays tiny and encrypted, and directory and mailbox '
        'requests go through Tor — but the law requires that this transfer '
        'be stated, and here it is.',
  ]),

  const SectionPolitique('For how long', [
    'A message left in the mailbox stays there until its recipient picks '
        'it up, and is then erased. If it is never picked up, it disappears '
        'on its own.',
    'The directory keeps an entry for as long as the device shows up. A '
        'device that stops coming back eventually drops out.',
    'The signalling server and the relays keep nothing: they pass things '
        'along, and forget at the end of the call.',
  ]),

  SectionPolitique('Your rights', [
    'The GDPR gives you the right to access your data, correct it, erase '
        'it, restrict its use, object to it, and take it elsewhere.',
    'Since there is no account, almost all of this happens without writing '
        'to us: your data is on your phone. Taking it elsewhere is done '
        'with the settings export. Erasing it is done by uninstalling the '
        'app. Leaving the directory is done by turning off the internet '
        'features in Settings.',
    'If something is unclear, write to $kEmailContact. And if our answer '
        'does not satisfy you, you can lodge a complaint with the data '
        'protection authority in your country.',
  ]),

  const SectionPolitique('Two clarifications', [
    'Nothing is asked of you to use Droplet offline. The internet features '
        '— finding someone by name, receiving a notification, calling at a '
        'distance — need the servers above; refusing them in Settings costs '
        'you those features, not the app.',
    'Droplet makes no automated decisions about you and builds no profile.',
  ]),

  const SectionPolitique('Children', [
    'Droplet is not intended for children under thirteen, and asks them '
        'for nothing anyway, since it asks nobody for anything.',
  ]),

  const SectionPolitique('If this text changes', [
    'The date of the last update is shown at the bottom of this screen. A '
        'change affecting what the servers see will be announced in the '
        'app, not slipped quietly into an update.',
  ]),
];
