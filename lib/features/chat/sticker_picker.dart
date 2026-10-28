// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Le PANNEAU DE STICKERS de la conversation : une grille de grandes
// vignettes, rangées par thème, plus la rangée des derniers utilisés.
//
// ── Pourquoi des stickers en emoji, et pas des images ? ────────────────
//
// C'est une décision de fond, pas un raccourci.
//
// Un vrai lot de stickers, c'est une centaine d'images de 50 à 150 ko.
// Embarquées dans l'app, elles feraient grossir le téléchargement de
// plusieurs méga-octets pour du décor. Et surtout : envoyées dans une
// conversation, CHAQUE sticker deviendrait un transfert de fichier
// complet à faire traverser le Bluetooth — plusieurs secondes pour
// dire « 👍 », sur un réseau où les vrais messages attendent derrière.
//
// Un sticker en emoji, lui, pèse quelques octets. Il part
// instantanément, s'affiche partout, et fonctionne même avec les
// versions antérieures de Droplet, qui le verront simplement comme un
// message texte.
//
// La différence avec un emoji tapé au clavier tient à l'AFFICHAGE : un
// message qui ne contient que des emojis (trois au maximum) est rendu
// en grand et SANS BULLE, exactement comme le fait WhatsApp. C'est ce
// qui lui donne son allure de sticker.
// ============================================================================

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'animated_sticker.dart';
import 'stickers_droplet.dart';

import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';

/// Un lot de stickers.
class StickerPack {
  const StickerPack({
    required this.name,
    required this.icon,
    required this.stickers,
  });

  final String name;

  /// L'emoji qui représente le lot dans la barre d'onglets.
  final String icon;

  final List<String> stickers;
}

/// Le catalogue.
///
/// Volontairement resserré : une grille de mille emojis est un
/// dictionnaire, pas un choix. Chaque lot tient en deux ou trois écrans
/// et ne garde que ce qui sert vraiment dans une conversation.
const List<StickerPack> kStickerPacks = [
  StickerPack(
    name: 'Réactions',
    icon: '😀',
    stickers: [
      '😀', '😂', '🤣', '😊', '😍', '🥰', '😘', '😎',
      '🤩', '🥳', '😇', '🙃', '😉', '😌', '🤗', '🤔',
      '🤨', '😐', '😴', '🤯', '😱', '😭', '😢', '😤',
      '😡', '🥺', '😳', '🙄', '😬', '🤫', '🤐', '😷',
    ],
  ),
  StickerPack(
    name: 'Gestes',
    icon: '👍',
    stickers: [
      '👍', '👎', '👌', '✌️', '🤞', '🤟', '🤙', '👋',
      '🙌', '👏', '🙏', '💪', '🤝', '✊', '👊', '🫶',
      '☝️', '👉', '👈', '👆', '👇', '✋', '🖐️', '🫡',
    ],
  ),
  StickerPack(
    name: 'Cœurs',
    icon: '❤️',
    stickers: [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
      '💔', '❣️', '💕', '💞', '💓', '💗', '💖', '💘',
      '💝', '💟', '♥️', '💌', '🫂', '😻', '💐', '🌹',
    ],
  ),
  StickerPack(
    name: 'Sécurité',
    icon: '🆘',
    stickers: [
      '🆘', '⚠️', '🚨', '🔴', '🟢', '✅', '❌', '❗',
      '❓', '📍', '🧭', '🔦', '🔋', '📶', '🛜', '📡',
      '🏥', '🚑', '🚒', '🚓', '💊', '🩹', '💧', '🍞',
      '🏠', '⛺', '🔥', '🌧️', '⛈️', '🌊', '🌪️', '🕐',
    ],
  ),
  StickerPack(
    name: 'Animaux',
    icon: '🐶',
    stickers: [
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼',
      '🐨', '🐯', '🦁', '🐮', '🐷', '🐸', '🐵', '🐔',
      '🐧', '🐦', '🦆', '🦉', '🦅', '🐝', '🦋', '🐢',
    ],
  ),
  StickerPack(
    name: 'Fête',
    icon: '🎉',
    stickers: [
      '🎉', '🎊', '🥳', '🎂', '🍰', '🎁', '🎈', '🎀',
      '✨', '⭐', '🌟', '💫', '🔥', '💥', '🏆', '🥇',
      '🎵', '🎶', '🎤', '🥂', '🍻', '☕', '🍕', '🍫',
    ],
  ),
];

/// Vrai si ce texte doit s'afficher en GRAND et sans bulle.
///
/// La règle est celle de WhatsApp : uniquement des emojis, trois au
/// maximum. Au-delà, le message redevient une phrase, et une phrase se
/// lit dans une bulle.
bool isStickerMessage(String content) {
  final text = content.trim();
  if (text.isEmpty) return false;

  var glyphs = 0;
  for (final ch in text.characters) {
    // Les sélecteurs de variante et les jointures qui composent un
    // emoji (le ❤️ est un cœur SUIVI d'un sélecteur, 👨‍👩‍👧 est une
    // famille jointe) ne comptent pas comme des caractères de plus :
    // sans cette exception, un seul emoji composé serait pris pour
    // trois et perdrait son affichage en grand.
    if (ch == '\u{FE0F}' || ch == '\u{200D}') continue;

    final code = ch.runes.first;
    final isEmoji = code >= 0x1F000 ||
        (code >= 0x2190 && code <= 0x2BFF) ||
        (code >= 0x2600 && code <= 0x27BF) ||
        (code >= 0xFE00 && code <= 0xFE0F) ||
        (code >= 0x1F1E6 && code <= 0x1F1FF);
    if (!isEmoji) return false;

    glyphs++;
    if (glyphs > 3) return false;
  }
  return glyphs > 0;
}

/// Taille d'affichage d'un sticker, selon le nombre d'emojis.
double stickerFontSize(String content) {
  final count = content.trim().characters
      .where((c) => c != '\u{FE0F}' && c != '\u{200D}')
      .length;
  return switch (count) {
    1 => 62,
    2 => 48,
    _ => 38,
  };
}

/// Ouvre le panneau en feuille et renvoie le sticker choisi, ou `null`.
///
/// ⚠️ GARDÉ POUR LES AUTRES APPELANTS. Dans la conversation, le panneau
/// est désormais EN LIGNE, à la place du clavier — voir [PanneauStickers]
/// et le commentaire qui l'accompagne. Ailleurs (l'assistant, par
/// exemple), une feuille reste le bon geste.
Future<String?> pickSticker(BuildContext context) {
  OuroHaptics.selection();
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => FrostedSheet(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.46,
          child: PanneauStickers(
            onChoisi: (s) => Navigator.of(context).pop(s),
          ),
        ),
      ),
    ),
  );
}

/// La grille de stickers, SANS son habillage.
///
/// ── ⚠️ POURQUOI ELLE EST SORTIE DE SA FEUILLE ─────────────────────────
///
/// Le geste d'iOS — celui d'iMessage, de WhatsApp, de Telegram — veut que
/// le bouton stickers REMPLACE le clavier par la grille, au même endroit
/// et à la même hauteur, et que l'icône devienne un clavier pour faire le
/// chemin inverse. Une feuille modale ne peut pas faire ça : elle se pose
/// PAR-DESSUS, le clavier se referme sous elle, et la barre de saisie
/// disparaît — on ne peut plus écrire pendant qu'on cherche un sticker.
///
/// Ce widget ne connaît donc ni sa hauteur ni son fond : il remplit la
/// boîte qu'on lui donne. C'est l'appelant qui décide s'il est dans une
/// feuille ou à la place du clavier.
class PanneauStickers extends StatefulWidget {
  const PanneauStickers({super.key, required this.onChoisi});

  final ValueChanged<String> onChoisi;

  @override
  State<PanneauStickers> createState() => _PanneauStickersState();
}

class _PanneauStickersState extends State<PanneauStickers> {
  static const String _recentKey = 'recent_stickers';
  static const int _recentMax = 16;

  int _pack = 0;
  List<String> _recent = const [];

  @override
  void initState() {
    super.initState();
    _recent = _loadRecent();
  }

  List<String> _loadRecent() {
    final raw = StorageService.getString(_recentKey) ?? '';
    if (raw.isEmpty) return const [];
    return raw.split('').where((s) => s.isNotEmpty).toList();
  }

  Future<void> _remember(String sticker) async {
    final next = [sticker, ..._recent.where((s) => s != sticker)]
        .take(_recentMax)
        .toList();
    await StorageService.setString(_recentKey, next.join(''));
  }

  /// Transforme un nom de dossier en libellé d'onglet.
  ///
  /// Les dossiers d'assets se nomment sans accent ni majuscule
  /// (`fetes`, `humeurs`) parce que c'est ce qui traverse le mieux les
  /// systèmes de fichiers. L'utilisateur, lui, n'a pas à voir ça.
  static String _joliNomDeLot(String dossier) {
    if (dossier.isEmpty) return 'Stickers';
    final propre = dossier.replaceAll('_', ' ').replaceAll('-', ' ');
    return propre[0].toUpperCase() + propre.substring(1);
  }

  void _choose(String sticker) {
    // Un sticker premium, sans le pack : on montre ce qu'il faut pour
    // l'envoyer plutôt que de l'envoyer quand même ou de ne rien faire.
    final droplet = StickersDroplet.resoudre(sticker);
    if (droplet != null && !StickersDroplet.envoyable(droplet)) {
      OuroHaptics.selection();
      GoRouter.maybeOf(context)?.push('/premium');
      return;
    }
    OuroHaptics.light();
    _remember(sticker);
    // ⚠️ ON NE FERME RIEN ICI. En ligne, le panneau RESTE ouvert après un
    // envoi : on enchaîne deux ou trois stickers sans rouvrir le panneau
    // à chaque fois, exactement comme dans les autres messageries. C'est
    // à l'appelant de fermer s'il le veut — et la feuille, elle, le fait.
    setState(() => _recent = _loadRecent());
    widget.onChoisi(sticker);
  }

  @override
  Widget build(BuildContext context) {
    // Les récents forment un lot supplémentaire, en tête — c'est là
    // qu'on trouve neuf fois sur dix ce qu'on cherche.
    // Les lots de stickers ANIMÉS, s'il y en a sur cet appareil.
    //
    // Ils n'ont rien de particulier du point de vue du panneau : un
    // sticker animé est, ici aussi, une simple chaîne — sa référence
    // (`🎞tgs:lot/nom`). C'est `_StickerTile` qui décide de dessiner un
    // emoji ou de jouer une animation. Tout le reste — les récents, le
    // choix, l'envoi — fonctionne sans une ligne de plus.
    final lotsAnimes = AnimatedStickerCatalog.parLot;

    final packs = <StickerPack>[
      if (_recent.isNotEmpty)
        StickerPack(name: 'Récents', icon: '🕐', stickers: _recent),
      // Les stickers de Droplet, en tête : dessinés en direct, et légers
      // comme un mot sur le réseau (voir `stickers_droplet.dart`).
      StickerPack(
        name: 'Goutte',
        icon: '💧',
        stickers: [for (final s in StickersDroplet.gratuits) s.reference],
      ),
      StickerPack(
        name: 'Éclat',
        icon: '✨',
        stickers: [for (final s in StickersDroplet.premiums) s.reference],
      ),
      for (final entree in lotsAnimes.entries)
        StickerPack(
          name: _joliNomDeLot(entree.key),
          icon: '🎞',
          stickers: [for (final s in entree.value) s.reference],
        ),
      ...kStickerPacks,
    ];
    final current = packs[_pack.clamp(0, packs.length - 1)];
    // Les lots Droplet en grandes vignettes (quatre par ligne, comme les
    // lots de WhatsApp) : ce sont des scènes, pas des pictogrammes.
    final grandes = current.stickers.isNotEmpty && StickersDroplet.resoudre(current.stickers.first) != null;

    return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DesignTokens.space2),
              Row(
                children: [
                  Text(current.name,
                      style: OuroTypography.headline
                          .copyWith(color: OuroColors.label)),
                  if (current.name == 'Éclat') ...[
                    const SizedBox(width: 8),
                    const _PastillePremium(),
                  ],
                ],
              ),
              const SizedBox(height: DesignTokens.space3),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: grandes ? 96 : 68,
                    childAspectRatio: 1,
                  ),
                  itemCount: current.stickers.length,
                  itemBuilder: (context, i) {
                    final sticker = current.stickers[i];
                    return _StickerTile(
                      sticker: sticker,
                      taille: grandes ? 84 : 60,
                      onTap: () => _choose(sticker),
                    );
                  },
                ),
              ),
              const SizedBox(height: DesignTokens.space2),
              // La barre des lots, en bas : le pouce y est déjà.
              SizedBox(
                height: 46,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: packs.length,
                  itemBuilder: (context, i) {
                    final selected = i == _pack;
                    return GestureDetector(
                      onTap: () {
                        OuroHaptics.selection();
                        setState(() => _pack = i);
                      },
                      child: Container(
                        width: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: selected
                              ? OuroColors.tertiarySystemFill
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        alignment: Alignment.center,
                        child: Text(packs[i].icon,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}

class _StickerTile extends StatefulWidget {
  const _StickerTile({required this.sticker, required this.onTap, this.taille = 60});
  final String sticker;
  final double taille;
  final VoidCallback onTap;

  @override
  State<_StickerTile> createState() => _StickerTileState();
}

class _StickerTileState extends State<_StickerTile> {
  bool _pressed = false;

  bool get _verrouille {
    final d = StickersDroplet.resoudre(widget.sticker);
    return d != null && !StickersDroplet.envoyable(d);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.82 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        // Une vignette porte soit un emoji, soit une animation. Rien
        // d'autre ne change : le reste du panneau ne sait pas — et n'a
        // pas besoin de savoir — de quel type il s'agit.
        child: Center(
          child: AnimatedStickerCatalog.estUneReference(widget.sticker)
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedStickerView(reference: widget.sticker, taille: widget.taille),
                    // Le cadenas des premium qu'on ne peut pas encore envoyer.
                    if (_verrouille)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Color(0xFF6C51FF), Color(0xFFE151B0)]),
                          ),
                          child: const Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                  ],
                )
              : Text(widget.sticker, style: const TextStyle(fontSize: 34)),
        ),
      ),
    );
  }
}

/// La petite pastille « Premium » à côté du nom du lot Éclat.
class _PastillePremium extends StatelessWidget {
  const _PastillePremium();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(colors: [Color(0xFF6C51FF), Color(0xFFE151B0), Color(0xFFFFA932)]),
      ),
      child: const Text(
        'PREMIUM',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: Colors.white),
      ),
    );
  }
}
