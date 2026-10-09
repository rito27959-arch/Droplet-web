// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES « PACKS DE CONNAISSANCE » DE L'ASSISTANT — des fiches de référence
// écrites à la main (premiers secours, situations d'urgence…) et une
// recherche lexicale qui, à chaque question, glisse la bonne fiche dans
// le contexte du modèle AVANT qu'il réponde.
//
// ── POURQUOI, ET POURQUOI COMME ÇA ────────────────────────────────────
//
// Un modèle de 1 milliard de paramètres ne RAISONNE pas mieux avec un
// prompt — mais il RÉCITE juste s'il a le bon texte sous les yeux. Pour
// les usages qui comptent vraiment sur une messagerie hors réseau —
// quelqu'un qui s'étouffe, une hémorragie, un séisme —, l'assistant doit
// pouvoir donner des gestes exacts, pas une approximation dangereuse.
//
// ⚠️ PAS DE RECHERCHE SÉMANTIQUE. Un vrai RAG (embeddings + index
// vectoriel) suppose les bibliothèques MediaPipe EXCLUES de l'APK pour
// l'alléger (voir `ai_chat_screen.dart`). La recherche ici est donc
// LEXICALE : on compare les mots de la question aux mots-clés et au corps
// de chaque fiche, insensible aux accents et à la casse. C'est fruste,
// mais sur un corpus petit et bien étiqueté, ça trouve la bonne fiche.
//
// ⚠️ CONTENU. Les fiches de secours reprennent des gestes de premiers
// secours d'usage courant (consensus type Croix-Rouge / ERC). Elles ne
// remplacent pas une formation ni un appel aux secours : chaque fiche qui
// s'y prête le rappelle. On s'en tient au largement admis — jamais de
// diagnostic, jamais de posologie.
//
// ── BUDGET ────────────────────────────────────────────────────────────
//
// L'extrait retenu est injecté À CHAQUE tour où il matche, et compte dans
// la fenêtre de 2048 jetons. D'où [budgetCars] ~600 (≈150 jetons) et un
// seuil de pertinence : une question sans rapport ne traîne aucune fiche.
// ============================================================================

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Une fiche de référence d'un pack.
@immutable
class DomainArticle {
  const DomainArticle({
    required this.titre,
    required this.motsCles,
    required this.corps,
  });

  /// Titre court, affiché en tête de l'extrait injecté.
  final String titre;

  /// Mots-clés pesant lourd dans le score (synonymes, termes familiers).
  final List<String> motsCles;

  /// Le texte de référence lui-même. Concis, factuel.
  final String corps;
}

/// Recherche lexicale dans les packs. Tout est statique : un seul corpus,
/// celui embarqué dans l'app.
class AiKnowledgePacks {
  AiKnowledgePacks._();

  /// Clé de réglage : les packs sont actifs par défaut, désactivables.
  static const _cleActif = 'ai_packs_enabled';

  static bool get actif => StorageService.getString(_cleActif) != 'off';

  static Future<void> definirActif(bool on) =>
      StorageService.setString(_cleActif, on ? 'on' : 'off');

  /// Score minimal pour qu'une fiche soit jugée pertinente. En dessous, on
  /// n'injecte rien — mieux vaut pas de référence qu'une mauvaise.
  ///
  /// Calé sur 4 = un seul mot-clé qui touche (poids 4). Les mots-clés des
  /// fiches sont volontairement spécifiques (« heimlich », « seisme »,
  /// « hemorragie »…), donc un match unique suffit à être pertinent. Le
  /// coût d'une injection à tort reste faible : l'extrait est étiqueté
  /// « utilise-la si pertinent », le modèle peut l'ignorer.
  static const _seuil = 4;

  /// Cherche la fiche la plus pertinente pour [question]. Renvoie un bloc
  /// prêt à injecter (titre + corps tronqué à [budgetCars]), ou `null`.
  static String? chercher(String question, {int budgetCars = 600}) {
    if (!actif) return null;
    final termes = _termes(question);
    if (termes.isEmpty) return null;

    DomainArticle? meilleur;
    var meilleurScore = 0;

    for (final art in kPacksArticles) {
      final motsClesNorm = art.motsCles.map(_sansAccent).toList();
      final corpsNorm = _sansAccent(art.corps.toLowerCase());
      var score = 0;
      for (final t in termes) {
        if (motsClesNorm.any((m) => m.contains(t) || t.contains(m))) {
          score += 4;
        }
        if (_motEntier(corpsNorm, t)) {
          score += 2;
        } else if (corpsNorm.contains(t)) {
          score += 1;
        }
      }
      if (score > meilleurScore) {
        meilleurScore = score;
        meilleur = art;
      }
    }

    if (meilleur == null || meilleurScore < _seuil) return null;

    var corps = meilleur.corps.trim();
    if (corps.length > budgetCars) {
      corps = corps.substring(0, budgetCars);
      // Couper à la dernière fin de phrase pour ne pas laisser un
      // fragment.
      final coupe = corps.lastIndexOf(RegExp(r'[.!?]\s'));
      if (coupe > budgetCars ~/ 2) corps = corps.substring(0, coupe + 1);
    }
    return '${meilleur.titre}\n$corps';
  }

  // ── Normalisation lexicale ──────────────────────────────────────────

  static const _motsVides = {
    'le',
    'la',
    'les',
    'un',
    'une',
    'des',
    'de',
    'du',
    'et',
    'ou',
    'a',
    'au',
    'aux',
    'en',
    'dans',
    'sur',
    'sous',
    'pour',
    'par',
    'avec',
    'sans',
    'que',
    'qui',
    'quoi',
    'dont',
    'ce',
    'ca',
    'se',
    'sa',
    'son',
    'ses',
    'mon',
    'ma',
    'mes',
    'ton',
    'ta',
    'tes',
    'il',
    'elle',
    'on',
    'nous',
    'vous',
    'ils',
    'elles',
    'je',
    'tu',
    'me',
    'te',
    'est',
    'sont',
    'etre',
    'avoir',
    'fait',
    'faire',
    'comment',
    'quand',
    'quel',
    'quelle',
    'plus',
    'moins',
    'tres',
    'pas',
    'ne',
    'non',
    'oui',
    'si',
    'mais',
    'donc',
    'car',
    'alors',
    'aussi',
    'bien',
    'peut',
    'doit',
    'the',
  };

  static List<String> _termes(String s) {
    final brut = _sansAccent(s.toLowerCase())
        .split(RegExp(r'[^a-z0-9]+'))
        .where((m) => m.length >= 3 && !_motsVides.contains(m))
        .toList();
    return brut.toSet().toList();
  }

  static String _sansAccent(String s) {
    const de = 'àâäáãéèêëíìîïóòôöõúùûüýÿçñ';
    const vers = 'aaaaaeeeeiiiiooooouuuuyycn';
    final b = StringBuffer();
    for (final c in s.split('')) {
      final i = de.indexOf(c);
      b.write(i >= 0 ? vers[i] : c);
    }
    return b.toString();
  }

  static bool _motEntier(String texte, String mot) {
    final i = texte.indexOf(mot);
    if (i < 0) return false;
    final avant = i == 0 || !_estLettre(texte[i - 1]);
    final fini = i + mot.length;
    final apres = fini >= texte.length || !_estLettre(texte[fini]);
    return avant && apres;
  }

  static bool _estLettre(String c) =>
      (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122) ||
      (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57);
}

/// Le corpus complet. Ajouter une fiche = ajouter une entrée ici. Garder
/// les corps courts (quelques phrases) et factuels.
const List<DomainArticle> kPacksArticles = [
  // ── PACK : PREMIERS SECOURS ────────────────────────────────────────
  DomainArticle(
    titre: 'Étouffement (adulte ou grand enfant)',
    motsCles: [
      'etouffement',
      'etouffe',
      'avale',
      'travers',
      'gorge',
      'suffoque',
      'heimlich',
      'obstruction',
      'toux',
    ],
    corps:
        "La personne ne peut plus parler, tousser ni respirer. Donne 5 claques "
        "vigoureuses dans le dos, entre les omoplates, avec le talon de la main, "
        "penché en avant. Si ça ne suffit pas, fais 5 compressions abdominales "
        "(manœuvre de Heimlich) : place-toi derrière, un poing au creux de "
        "l'estomac au-dessus du nombril, l'autre main par-dessus, tire "
        "franchement vers toi et vers le haut. Alterne 5 claques / 5 "
        "compressions jusqu'à ce que l'objet sorte. Si la personne perd "
        "connaissance, allonge-la et commence le massage cardiaque. Préviens "
        "les secours dès que possible. Si elle tousse encore, n'interviens "
        "pas : encourage-la à tousser.",
  ),
  DomainArticle(
    titre: 'Hémorragie externe (saignement abondant)',
    motsCles: [
      'hemorragie',
      'saigne',
      'saignement',
      'sang',
      'plaie',
      'coupure',
      'blessure',
      'garrot',
      'compression',
    ],
    corps:
        "Appuie tout de suite, fort et sans relâcher, directement sur la plaie "
        "avec un tissu propre ou ta main (protège-toi si tu peux). Allonge la "
        "personne. Maintiens la pression en continu ; si le sang traverse, "
        "ajoute un tissu par-dessus sans retirer le premier. Ne pose un garrot "
        "que si le saignement d'un membre ne s'arrête pas malgré la "
        "compression : large lien serré entre la plaie et le cœur, note "
        "l'heure, ne le desserre plus. Couvre la personne, parle-lui, "
        "surveille-la. Préviens les secours en urgence.",
  ),
  DomainArticle(
    titre: 'Personne inconsciente qui respire — position latérale',
    motsCles: [
      'inconscient',
      'inconsciente',
      'evanoui',
      'evanouissement',
      'pls',
      'position',
      'laterale',
      'securite',
      'coma',
      'respire',
      'connaissance',
    ],
    corps:
        "Vérifie qu'elle respire (regarde, écoute, sens pendant 10 secondes). "
        "Si elle respire mais ne réagit pas, mets-la en position latérale de "
        "sécurité : sur le côté, bouche ouverte vers le sol pour qu'elle ne "
        "s'étouffe pas si elle vomit. Bascule doucement la tête en arrière. "
        "Couvre-la, surveille sa respiration sans arrêt. Préviens les secours. "
        "Si elle cesse de respirer, remets-la sur le dos et commence le "
        "massage cardiaque.",
  ),
  DomainArticle(
    titre: 'Arrêt cardiaque — massage cardiaque',
    motsCles: [
      'arret',
      'cardiaque',
      'coeur',
      'massage',
      'reanimation',
      'rcp',
      'respire',
      'pouls',
      'defibrillateur',
      'dae',
      'ranime',
    ],
    corps:
        "La personne ne réagit pas et ne respire pas normalement. Allonge-la "
        "sur le dos, sur un plan dur. Place le talon d'une main au centre de la "
        "poitrine, l'autre main par-dessus, bras tendus. Appuie fort et vite : "
        "5 à 6 cm d'enfoncement, environ 100 à 120 compressions par minute, en "
        "laissant la poitrine remonter à chaque fois. Ne t'arrête pas. Si "
        "quelqu'un peut chercher un défibrillateur, envoie-le. Relaie-toi "
        "toutes les 2 minutes si possible. Continue jusqu'à l'arrivée des "
        "secours ou une reprise de respiration.",
  ),
  DomainArticle(
    titre: 'Brûlure',
    motsCles: [
      'brulure',
      'brule',
      'brulee',
      'feu',
      'ebouillante',
      'chaud',
      'flamme',
      'cloque',
    ],
    corps:
        "Refroidis la brûlure sous l'eau tiède à fraîche (15-25 °C) qui "
        "ruisselle, pendant au moins 15 à 20 minutes, dès que possible. Retire "
        "bagues, montre et vêtements non collés avant que ça gonfle. Ne perce "
        "pas les cloques, n'applique ni glace, ni pommade, ni corps gras. "
        "Couvre ensuite d'un linge propre. Consulte ou préviens les secours si "
        "la brûlure est étendue, profonde, sur le visage, les mains, les "
        "articulations ou les parties génitales, ou si c'est un enfant.",
  ),
  DomainArticle(
    titre: 'Malaise (faiblesse, vertige, sensation de perte de connaissance)',
    motsCles: [
      'malaise',
      'vertige',
      'faiblesse',
      'tourne',
      'tete',
      'nausee',
      'sueur',
      'pale',
      'malade',
      'faible',
    ],
    corps:
        "Installe la personne au calme, allongée ou assise, et desserre ses "
        "vêtements. Demande-lui ce qu'elle ressent, si elle prend un "
        "traitement, si c'est déjà arrivé. Si elle est diabétique et "
        "consciente, du sucre peut aider. Ne la laisse pas seule, surveille sa "
        "respiration. Si le malaise dure, se répète, ou s'accompagne d'une "
        "douleur dans la poitrine, de difficultés à parler ou à bouger un "
        "côté : c'est une urgence, préviens les secours immédiatement.",
  ),
  DomainArticle(
    titre: 'Chute, choc, fracture possible',
    motsCles: [
      'fracture',
      'casse',
      'chute',
      'tombe',
      'os',
      'entorse',
      'membre',
      'immobilise',
      'choc',
      'traumatisme',
    ],
    corps:
        "Ne déplace pas la personne sauf danger immédiat. Ne cherche pas à "
        "remettre un membre déformé en place. Immobilise la zone dans la "
        "position où elle est, avec des vêtements roulés de part et d'autre. "
        "Applique du froid enveloppé dans un linge (jamais à même la peau). "
        "Après un choc à la tête, au dos ou au cou : maintiens la tête dans "
        "l'axe, ne mobilise pas, surveille la conscience. Préviens les "
        "secours.",
  ),
  DomainArticle(
    titre: 'Coup de chaleur',
    motsCles: [
      'chaleur',
      'canicule',
      'hyperthermie',
      'insolation',
      'deshydratation',
      'chaud',
      'soleil',
      'surchauffe',
    ],
    corps:
        "Peau très chaude, maux de tête, confusion, parfois arrêt de la "
        "transpiration : c'est grave. Mets la personne à l'ombre, au frais, "
        "allongée jambes surélevées. Déshabille-la, asperge-la d'eau, "
        "évente-la, place du linge humide sur la nuque, les aisselles, l'aine. "
        "Si elle est consciente, fais-la boire par petites gorgées. Préviens "
        "les secours : un coup de chaleur peut être mortel.",
  ),
  DomainArticle(
    titre: 'Hypothermie (froid)',
    motsCles: [
      'hypothermie',
      'froid',
      'gele',
      'gelure',
      'grelotte',
      'frigorifie',
      'neige',
      'glace',
      'refroidissement',
    ],
    corps:
        "Mets la personne à l'abri du froid et du vent, retire les vêtements "
        "mouillés, enveloppe-la dans des couches sèches et une couverture, y "
        "compris la tête. Manipule-la doucement. Si elle est consciente, "
        "donne une boisson chaude et sucrée, jamais d'alcool. Ne frictionne "
        "pas les extrémités gelées. Réchauffe progressivement. Si elle est "
        "confuse, somnolente ou ne grelotte plus alors qu'elle a très froid, "
        "c'est sévère : préviens les secours.",
  ),
  DomainArticle(
    titre: 'Convulsions / crise (type épilepsie)',
    motsCles: [
      'convulsion',
      'convulsions',
      'crise',
      'epilepsie',
      'epileptique',
      'tremble',
      'secousses',
      'spasme',
    ],
    corps:
        "Ne retiens pas la personne, ne mets rien dans sa bouche. Écarte les "
        "objets dangereux, protège sa tête avec quelque chose de mou, note "
        "l'heure de début. Quand les secousses s'arrêtent, mets-la sur le "
        "côté (position latérale) et laisse-la revenir à elle doucement. "
        "Préviens les secours si la crise dure plus de 5 minutes, se répète, "
        "si c'est la première, si la personne est blessée, enceinte, "
        "diabétique, ou ne reprend pas conscience.",
  ),

  // ── PACK : SITUATIONS D'URGENCE ────────────────────────────────────
  DomainArticle(
    titre: 'Séisme (tremblement de terre)',
    motsCles: [
      'seisme',
      'tremblement',
      'terre',
      'secousse',
      'tremble',
      'earthquake',
      'repliques',
    ],
    corps:
        "Pendant la secousse : reste où tu es, ne cours pas dehors. À "
        "l'intérieur, mets-toi sous une table solide, à genoux, protège ta "
        "tête et ta nuque, tiens le pied de la table. Éloigne-toi des "
        "fenêtres, des meubles hauts, des cheminées. Dehors, va dans un espace "
        "dégagé, loin des bâtiments, des lignes électriques et des arbres. En "
        "voiture, arrête-toi à l'écart et reste dedans. Après : attends-toi à "
        "des répliques, coupe le gaz si tu sens une odeur, n'utilise pas "
        "d'ascenseur, méfie-toi des structures fragilisées, garde tes "
        "chaussures aux pieds.",
  ),
  DomainArticle(
    titre: 'Inondation, montée des eaux',
    motsCles: [
      'inondation',
      'inonde',
      'eau',
      'crue',
      'monte',
      'deborde',
      'pluie',
      'noye',
      'evacuation',
    ],
    corps:
        "Monte vers les étages, n'entre jamais dans une cave qui se remplit. "
        "Ne marche pas et ne roule pas dans une eau en mouvement : 30 cm "
        "suffisent à emporter une voiture, 15 cm à faire tomber un adulte. "
        "Coupe l'électricité si tu peux le faire sans te mouiller. Emporte eau "
        "potable, papiers, téléphone, médicaments. Signale ta position et le "
        "nombre de personnes. N'essaie pas de traverser un pont submergé.",
  ),
  DomainArticle(
    titre: 'Se signaler quand on est perdu ou bloqué',
    motsCles: [
      'perdu',
      'perdue',
      'bloque',
      'coince',
      'secours',
      'signaler',
      'signal',
      'retrouver',
      'localiser',
      'sos',
      'appel',
    ],
    corps:
        "Reste sur place si on te sait parti : tu es plus facile à retrouver "
        "immobile. Mets-toi au sec, à l'abri du vent, isolé du sol. Rends-toi "
        "visible : couleurs vives, tissu au sol dans une clairière, feu ou "
        "lampe la nuit. Le signal de détresse est un rythme de 6 (sifflet, "
        "lampe, coups) répété chaque minute. Économise ta batterie : coupe les "
        "données, baisse la luminosité, n'allume que pour envoyer un message "
        "avec ta position et ton état.",
  ),
  DomainArticle(
    titre: "Rendre de l'eau potable",
    motsCles: [
      'eau',
      'potable',
      'boire',
      'purifier',
      'desinfecter',
      'javel',
      'bouillir',
      'filtrer',
      'soif',
    ],
    corps:
        "Le plus sûr : porter l'eau à gros bouillons pendant 1 minute (3 "
        "minutes en altitude), puis laisser refroidir à couvert. Sinon, "
        "filtre l'eau trouble dans un linge propre, puis désinfecte : 2 "
        "gouttes d'eau de Javel courante (non parfumée) par litre, mélange, "
        "attends 30 minutes — une légère odeur de chlore doit rester. Les "
        "pastilles de purification s'utilisent selon leur notice. Ça ne retire "
        "ni les produits chimiques ni les métaux.",
  ),
  DomainArticle(
    titre: 'Coupure d\'électricité prolongée',
    motsCles: [
      'coupure',
      'electricite',
      'courant',
      'panne',
      'blackout',
      'noir',
      'frigo',
      'congelateur',
      'chauffage',
      'bougie',
    ],
    corps:
        "Garde le réfrigérateur et le congélateur fermés : le froid tient "
        "environ 4 h au frigo, 24 à 48 h dans un congélateur plein. Débranche "
        "les appareils sensibles pour éviter la surtension au retour du "
        "courant. Ne fais jamais fonctionner un groupe électrogène, un "
        "barbecue ou un chauffage à combustible dans un espace fermé : risque "
        "d'intoxication au monoxyde de carbone. Préfère les lampes aux "
        "bougies. Habille-toi chaudement plutôt que de surchauffer une seule "
        "pièce.",
  ),
  DomainArticle(
    titre: 'Odeur de gaz',
    motsCles: [
      'gaz',
      'odeur',
      'fuite',
      'monoxyde',
      'intoxication',
      'explosion',
      'sent',
    ],
    corps:
        "N'allume aucune flamme, ne touche à aucun interrupteur, ne branche "
        "ni ne débranche rien : une étincelle suffit. Ouvre les fenêtres, "
        "ferme le robinet d'arrivée du gaz si tu peux l'atteindre sans "
        "risque, sors tout le monde. Une fois dehors et à distance, préviens "
        "les secours et le fournisseur de gaz. Ne rentre pas avant le feu "
        "vert d'un professionnel. Maux de tête, nausées et vertiges chez "
        "plusieurs personnes d'un même lieu évoquent le monoxyde de carbone : "
        "sortez immédiatement à l'air libre.",
  ),
  DomainArticle(
    titre: 'Trousse et réserves pour tenir 72 heures',
    motsCles: [
      'trousse',
      'kit',
      'reserve',
      'preparation',
      'stock',
      'urgence',
      'provisions',
      'sac',
      'evacuation',
      'preparer',
    ],
    corps:
        "Prévois par personne : 3 litres d'eau par jour sur 3 jours, des "
        "aliments qui se conservent et se mangent sans cuisson, une lampe et "
        "des piles, une radio à piles ou à manivelle, un sifflet, une trousse "
        "de premiers secours, les médicaments habituels, des copies des "
        "papiers dans une pochette étanche, de l'argent liquide, des "
        "vêtements chauds, une couverture de survie, un chargeur externe "
        "chargé. Garde le tout dans un sac accessible et vérifie les dates "
        "deux fois par an.",
  ),
];
