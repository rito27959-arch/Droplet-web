// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA MÉMOIRE LONGUE DE L'ASSISTANT — la liste des choses que
// l'utilisateur a explicitement demandé à l'assistant de retenir, et qui
// lui sont réinjectées AU DÉBUT de chaque conversation, même après une
// « nouvelle conversation » ou un redémarrage de l'app.
//
// ── POURQUOI SÉPARÉ DE L'HISTORIQUE DE CONVERSATION ───────────────────
//
// `ai_chat_screen.dart` persiste déjà les ~40 derniers messages et en
// réinjecte une partie dans le contexte du modèle. Mais cet historique
// glisse : au 41ᵉ message, le 1ᵉʳ disparaît. « Je m'appelle Sara », dit
// une fois en haut d'une longue conversation, serait perdu.
//
// La mémoire longue, elle, ne glisse pas avec la conversation. Elle ne
// contient que des faits que l'utilisateur a EXPLICITEMENT épinglés
// (« retiens que… », « souviens-toi que… », « je m'appelle… »). Elle
// survit à l'effacement de la conversation. C'est ce qui permet à
// l'assistant de « se souvenir » d'une chose dite il y a une semaine.
//
// ── LES LIMITES, ASSUMÉES ─────────────────────────────────────────────
//
// Ce n'est pas une base de connaissances vectorielle. Il n'y a pas de
// recherche sémantique : tout le bloc est injecté tel quel, en entier, à
// chaque ouverture. Donc c'est BORNÉ — [_maxFaits] entrées, [_maxCars]
// caractères au total. Au-delà, les plus anciennes entrées tombent. Un
// modèle de 1 milliard de paramètres avec 4096 jetons de contexte ne
// peut de toute façon pas raisonner sur des centaines de faits à la
// fois ; garder les ~40 plus récents est la bonne proportion.
// ============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'storage_service.dart';

/// Un fait épinglé par l'utilisateur, avec la date où il a été retenu.
@immutable
class FaitMemorise {
  const FaitMemorise(this.texte, this.retenuLe);

  final String texte;
  final DateTime retenuLe;

  Map<String, dynamic> _toJson() => {
    't': texte,
    'd': retenuLe.millisecondsSinceEpoch,
  };

  static FaitMemorise? _fromJson(Object? brut) {
    if (brut is! Map) return null;
    final t = (brut['t'] as String?)?.trim();
    if (t == null || t.isEmpty) return null;
    final d = brut['d'];
    return FaitMemorise(
      t,
      d is int ? DateTime.fromMillisecondsSinceEpoch(d) : DateTime.now(),
    );
  }
}

/// La mémoire longue de l'assistant. Tout est statique : il n'y a qu'une
/// seule mémoire, celle de l'appareil.
class AiMemoire {
  AiMemoire._();

  static const _cle = 'ai_memoire_longue';

  /// Au-delà, on retire les plus anciennes entrées. Voir l'en-tête pour
  /// pourquoi c'est borné.
  static const _maxFaits = 40;
  static const _maxCars = 2400;

  static List<FaitMemorise> _faits = [];
  static bool _charge = false;

  /// Recharge la mémoire depuis le stockage. Sûr à appeler plusieurs
  /// fois — ne relit le disque qu'une fois.
  static void charger() {
    if (_charge) return;
    _charge = true;
    final brut = StorageService.getString(_cle);
    if (brut == null || brut.isEmpty) return;
    try {
      final liste = jsonDecode(brut);
      if (liste is! List) return;
      _faits = liste
          .map(FaitMemorise._fromJson)
          .whereType<FaitMemorise>()
          .toList();
    } catch (_) {
      // Mémoire illisible (format changé, fichier tronqué) : on repart
      // d'une mémoire vide plutôt que de faire échouer l'assistant.
      _faits = [];
    }
  }

  static Future<void> _sauver() async {
    // Rogner d'abord par nombre, puis par volume total (les plus
    // anciennes d'abord dans les deux cas).
    while (_faits.length > _maxFaits) {
      _faits.removeAt(0);
    }
    while (_faits.length > 1 &&
        _faits.fold<int>(0, (s, f) => s + f.texte.length) > _maxCars) {
      _faits.removeAt(0);
    }
    await StorageService.setString(
      _cle,
      jsonEncode(_faits.map((f) => f._toJson()).toList()),
    );
  }

  /// La liste des faits retenus, du plus ancien au plus récent.
  static List<FaitMemorise> get tout {
    charger();
    return List.unmodifiable(_faits);
  }

  static bool get estVide {
    charger();
    return _faits.isEmpty;
  }

  /// Ajoute un fait. Ignore les doublons — si le nouveau fait est déjà
  /// contenu dans un fait existant (ou l'inverse), on garde le plus
  /// informatif et on le remonte en tête de fraîcheur.
  static Future<void> retenir(String faitBrut) async {
    charger();
    final fait = _nettoyer(faitBrut);
    if (fait.length < 3) return;
    final normNouveau = _normaliser(fait);

    for (var i = 0; i < _faits.length; i++) {
      final normExistant = _normaliser(_faits[i].texte);
      if (normExistant == normNouveau ||
          normExistant.contains(normNouveau) ||
          normNouveau.contains(normExistant)) {
        // Garder la formulation la plus longue (la plus informative),
        // rafraîchir la date, la remettre en fin de liste.
        final garde = fait.length >= _faits[i].texte.length
            ? fait
            : _faits[i].texte;
        _faits.removeAt(i);
        _faits.add(FaitMemorise(garde, DateTime.now()));
        await _sauver();
        return;
      }
    }

    _faits.add(FaitMemorise(fait, DateTime.now()));
    await _sauver();
  }

  /// Oublie un fait précis (par son index dans [tout]).
  static Future<void> oublier(int index) async {
    charger();
    if (index < 0 || index >= _faits.length) return;
    _faits.removeAt(index);
    await _sauver();
  }

  /// Efface toute la mémoire longue.
  static Future<void> toutOublier() async {
    _faits = [];
    _charge = true;
    await StorageService.setString(_cle, '');
  }

  /// Le bloc de texte réinjecté dans le contexte du modèle en amorce de
  /// conversation, ou `null` si la mémoire est vide.
  static String? get bloc {
    charger();
    if (_faits.isEmpty) return null;
    final lignes = _faits.map((f) => '- ${f.texte}').join('\n');
    return "Ce que l'utilisateur t'a demandé de retenir (traite-le comme "
        'vrai et actuel) :\n$lignes';
  }

  // ── Détection d'une demande explicite de mémorisation ────────────────

  /// Si [message] est une demande explicite de retenir quelque chose,
  /// renvoie le fait à mémoriser (déjà nettoyé). Sinon `null`.
  ///
  /// Volontairement CONSERVATEUR : on ne capture que les tournures
  /// impératives sans ambiguïté et la présentation du prénom. Capturer
  /// « tout ce que dit l'utilisateur » saturerait la mémoire de phrases
  /// sans valeur en quelques échanges (voir l'en-tête sur le budget).
  static String? detecterDemande(String message) {
    final m = message.trim();
    if (m.isEmpty) return null;

    for (final r in _motifs) {
      final match = r.firstMatch(m);
      if (match != null) {
        final capture = match.groupCount >= 1 ? match.group(1) : null;
        final fait = _nettoyer(capture ?? m);
        if (fait.length >= 3) return fait;
      }
    }
    return null;
  }

  /// Préfixe optionnel « que / qu' / de / d' / : / , » après le verbe,
  /// avec ou sans espace (gère l'élision : « n'oublie pas d'appeler »).
  static const _lien = r"(?:qu[e']\s?|d[e']\s?|:|,)?\s*";

  static final List<RegExp> _motifs = [
    RegExp(
      '^retiens(?:\\s+bien)?\\s*$_lien(.+)\$',
      caseSensitive: false,
      dotAll: true,
    ),
    RegExp(
      '^souviens[- ]?toi\\s*$_lien(.+)\$',
      caseSensitive: false,
      dotAll: true,
    ),
    RegExp(
      "^n'?oublie\\s+pas\\s*$_lien(.+)\$",
      caseSensitive: false,
      dotAll: true,
    ),
    RegExp(
      '^rappelle[- ]?toi\\s*$_lien(.+)\$',
      caseSensitive: false,
      dotAll: true,
    ),
    RegExp('^m[ée]morise\\s*$_lien(.+)\$', caseSensitive: false, dotAll: true),
    RegExp(
      '^note\\s*(?:bien\\s*)?$_lien(.+)\$',
      caseSensitive: false,
      dotAll: true,
    ),
    // Présentation du prénom : on garde la phrase entière, c'est elle
    // qui est utile (« Je m'appelle Sara »).
    RegExp(r"^(je m'appelle\s+.+)$", caseSensitive: false, dotAll: true),
    RegExp(
      r'^(mon (?:pr[ée]nom|nom) est\s+.+)$',
      caseSensitive: false,
      dotAll: true,
    ),
  ];

  static String _nettoyer(String s) {
    var t = s.trim();
    // Enlever une ponctuation de fin isolée qui n'apporte rien.
    t = t.replaceAll(RegExp(r'\s+'), ' ');
    if (t.length > 200) t = '${t.substring(0, 197)}…';
    return t;
  }

  static String _normaliser(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\wàâäéèêëïîôöùûüç ]', unicode: true), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
