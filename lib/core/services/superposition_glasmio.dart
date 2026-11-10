// ============================================================================
// LES SUPERPOSITIONS GLASMIO, CÔTÉ DART — alertes, feuilles d'actions, menus
// d'appui long en vrai verre Glasmio par-dessus l'écran Flutter (Android 13+).
// ----------------------------------------------------------------------------
// Chaque fonction renvoie `null` quand Glasmio n'est pas disponible : l'appelant
// affiche alors sa version Flutter habituelle. Rien ne dépend de Glasmio.
// ============================================================================

import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../design_system/ouro_colors.dart';
import 'pont_glasmio.dart';

/// Ce que la personne a choisi. [id] est `null` si elle a fermé sans choisir.
class ChoixGlasmio {
  const ChoixGlasmio(this.id, this.texte);

  final String? id;
  final String? texte;
}

/// Un bouton d'alerte ou de feuille d'actions.
class BoutonGlasmio {
  const BoutonGlasmio(this.id, this.titre, {this.annuler = false, this.destructif = false});

  final String id;
  final String titre;
  final bool annuler;
  final bool destructif;

  Map<String, Object?> versCarte() => {
        'id': id,
        'titre': titre,
        'role': annuler ? 'annuler' : (destructif ? 'destructif' : 'defaut'),
      };
}

/// Une action de menu d'appui long, avec son icône Flutter.
class ElementMenuGlasmio {
  const ElementMenuGlasmio(this.id, this.titre, {this.icone, this.destructif = false});

  final String id;
  final String titre;
  final IconData? icone;
  final bool destructif;

  Map<String, Object?> versCarte() => {
        'id': id,
        'titre': titre,
        'destructif': destructif,
        if (icone != null) ...{
          'glyphe': icone!.codePoint,
          'police': icone!.fontFamily,
          'paquet': icone!.fontPackage,
          if (_cles[icone!.codePoint] != null) 'cle': _cles[icone!.codePoint],
        },
      };

  /// Le nom de l'icône côté natif (clé d'ICONES dans BlocsGlasmio.kt) : le
  /// menu des messages de Glasmio dessine ses icônes lui-même, par leur nom.
  static final Map<int, String> _cles = {
    Icons.archive_rounded.codePoint: 'archive',
    Icons.auto_awesome_rounded.codePoint: 'auto_awesome',
    Icons.check_circle_outline_rounded.codePoint: 'check_circle',
    Icons.copy_rounded.codePoint: 'content_copy',
    Icons.delete_outline_rounded.codePoint: 'delete',
    Icons.download_rounded.codePoint: 'download',
    Icons.edit_rounded.codePoint: 'edit',
    Icons.forum_rounded.codePoint: 'forum',
    Icons.info_outline_rounded.codePoint: 'info',
    Icons.mark_chat_read_outlined.codePoint: 'mark_chat_read',
    Icons.mark_chat_unread_outlined.codePoint: 'mark_chat_unread',
    Icons.more_horiz_rounded.codePoint: 'more_horiz',
    Icons.push_pin_outlined.codePoint: 'push_pin',
    Icons.push_pin_rounded.codePoint: 'push_pin',
    Icons.refresh_rounded.codePoint: 'refresh',
    Icons.reply_rounded.codePoint: 'reply',
    Icons.shortcut_rounded.codePoint: 'shortcut',
    Icons.star_outline_rounded.codePoint: 'star_outline',
    Icons.star_rounded.codePoint: 'star',
    Icons.translate_rounded.codePoint: 'translate',
    Icons.volume_off_rounded.codePoint: 'volume_off',
    Icons.volume_up_rounded.codePoint: 'volume_up',
  };
}

class SuperpositionGlasmio {
  SuperpositionGlasmio._();

  static const _canal = MethodChannel('droplet/glasmio');

  static Future<ChoixGlasmio?> _afficher(Map<String, Object?> description) async {
    if (kIsWeb || !Platform.isAndroid) return null;
    if (!await PontGlasmio.disponible()) return null;
    try {
      final r = await _canal.invokeMethod<Map<Object?, Object?>>('superposition', {
        'description': jsonEncode({
          'sombre': OuroColors.isDark,
          'accent': OuroColors.accent.toARGB32(),
          ...description,
        }),
      });
      if (r == null || r['indisponible'] == true) return null;
      return ChoixGlasmio(r['id'] as String?, r['texte'] as String?);
    } catch (e) {
      debugPrint('[SuperpositionGlasmio] $e');
      return null;
    }
  }

  /// Une alerte au centre (GlasmioAlertDialog). [champ] : une saisie de
  /// texte (valeur de départ, indice, longueur maximale).
  static Future<ChoixGlasmio?> alerte({
    required String titre,
    String? message,
    required List<BoutonGlasmio> boutons,
    ({String texte, String indice, int? max})? champ,
  }) =>
      _afficher({
        'type': 'alerte',
        'titre': titre,
        'message': ?message,
        'boutons': [for (final b in boutons) b.versCarte()],
        if (champ != null) 'champ': {'texte': champ.texte, 'indice': champ.indice, 'max': champ.max ?? 0},
      });

  /// Une feuille d'actions en bas de l'écran (GlasmioActionSheet).
  static Future<ChoixGlasmio?> feuille({
    String? titre,
    String? message,
    required List<BoutonGlasmio> boutons,
  }) =>
      _afficher({
        'type': 'feuille',
        'titre': titre ?? '',
        'message': ?message,
        'boutons': [for (final b in boutons) b.versCarte()],
      });

  /// Le menu d'appui long : [zone] est le rectangle de l'élément touché, en
  /// coordonnées de l'écran (points logiques).
  static Future<ChoixGlasmio?> menu({
    required Rect zone,
    required List<ElementMenuGlasmio> elements,
    List<String> reactions = const [],
    List<String> actuelles = const [],
    bool aDroite = false,
    bool apercuTouchable = false,
    bool message = false,
  }) =>
      _afficher({
        // « message » : le vrai menu des messages de Glasmio (la bulle se
        // soulève, la bulle de verre des réactions s'ouvre au-dessus).
        'type': message ? 'message' : 'menu',
        'zone': {'x': zone.left, 'y': zone.top, 'l': zone.width, 'h': zone.height},
        'elements': [for (final e in elements) e.versCarte()],
        'reactions': reactions,
        'actuelles': actuelles,
        'aDroite': aDroite,
        'apercuTouchable': apercuTouchable,
      });

  /// Le menu d'édition d'Apple au-dessus d'une sélection de texte
  /// (GlasmioTextSelectionMenu). [zone] : la sélection, en points logiques
  /// de l'écran. Réponses : `pN` (une action principale), `aN` (une autre,
  /// sous « Plus »), ou `null` (fermé sans choix, ou Glasmio absent).
  static Future<ChoixGlasmio?> selection({
    required Rect zone,
    required List<String> principales,
    List<String> autres = const [],
    String plus = 'Plus',
  }) =>
      _afficher({
        'type': 'selection',
        'zone': {'x': zone.left, 'y': zone.top, 'l': zone.width, 'h': zone.height},
        'principales': [for (var i = 0; i < principales.length; i++) {'id': 'p$i', 'titre': principales[i]}],
        'autres': [for (var i = 0; i < autres.length; i++) {'id': 'a$i', 'titre': autres[i]}],
        'etiquettes': {'plus': plus},
      });

  /// Glasmio peut-il dessiner ses superpositions ici ?
  static Future<bool> disponible() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    return PontGlasmio.disponible();
  }
}

/// Le menu d'édition d'un champ de texte, dessiné par Glasmio. À rendre
/// depuis `contextMenuBuilder` ; retombe sur [repli] sans Glasmio.
class MenuSelectionGlasmio extends StatefulWidget {
  const MenuSelectionGlasmio({
    super.key,
    required this.etat,
    required this.principaux,
    this.autres = const [],
    required this.repli,
  });

  final EditableTextState etat;
  final List<ContextMenuButtonItem> principaux;
  final List<ContextMenuButtonItem> autres;
  final WidgetBuilder repli;

  @override
  State<MenuSelectionGlasmio> createState() => _MenuSelectionGlasmioState();
}

class _MenuSelectionGlasmioState extends State<MenuSelectionGlasmio> {
  bool _repli = false;
  bool _pret = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ouvrir());
  }

  String _libelle(ContextMenuButtonItem b) =>
      b.label ?? AdaptiveTextSelectionToolbar.getButtonLabel(context, b);

  Future<void> _ouvrir() async {
    if (!mounted) return;
    if (!await SuperpositionGlasmio.disponible()) {
      if (mounted) setState(() => _repli = true);
      return;
    }
    if (!mounted) return;
    final principaux = List.of(widget.principaux);
    final autres = List.of(widget.autres);
    final ancres = widget.etat.contextMenuAnchors;
    final p = ancres.primaryAnchor;
    final s = ancres.secondaryAnchor ?? p + const Offset(0, 22);
    final zone = Rect.fromLTRB(
      p.dx < s.dx ? p.dx : s.dx,
      p.dy < s.dy ? p.dy : s.dy,
      (p.dx > s.dx ? p.dx : s.dx) + 1,
      (p.dy > s.dy ? p.dy : s.dy) + 1,
    );
    _pret = true;
    final r = await SuperpositionGlasmio.selection(
      zone: zone,
      principales: [for (final b in principaux) _libelle(b)],
      autres: [for (final b in autres) _libelle(b)],
      plus: MaterialLocalizations.of(context).moreButtonTooltip,
    );
    final id = r?.id;
    if (id == null || id.length < 2) {
      widget.etat.hideToolbar();
      return;
    }
    final n = int.tryParse(id.substring(1));
    final liste = id.startsWith('p') ? principaux : autres;
    if (n == null || n >= liste.length) return;
    liste[n].onPressed?.call();
  }

  @override
  Widget build(BuildContext context) =>
      _repli ? widget.repli(context) : SizedBox.shrink(key: ValueKey(_pret));
}
