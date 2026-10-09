// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Le petit rond coloré avec une initiale qui représente chaque personne,
// faute de photo de profil (Droplet n'a ni compte ni serveur pour en
// héberger).
//
// CE QUI A CHANGÉ À LA REFONTE :
//   - Plus de DÉGRADÉ. Un aplat de couleur unie, comme les avatars de
//     Contacts et Messages sur iOS. Le dégradé sur un si petit élément
//     se lit comme du bruit, jamais comme une intention.
//   - Plus d'OMBRE PORTÉE. Sur un fond noir, elle ne se voit pas et
//     coûte du temps de rendu à chaque image affichée.
//   - Palette limitée aux teintes système d'Apple (voir `ouro_colors`).
//
// L'astuce d'origine est conservée : la couleur est CALCULÉE à partir du
// pseudo, donc la même personne garde toujours la même, sans que Droplet
// ait à la mémoriser où que ce soit.
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import '../../design_system/ouro_colors.dart';
import 'profile_photo_viewer.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_avatar.dart';
import 'package:intl/intl.dart' show DateFormat;

/// Avatar circulaire à initiale, en aplat de couleur système.
///
/// L'avatar réagit à l'état du réseau :
/// - **En ligne** : pastille verte avec un léger pulse lumineux.
/// - **Reconnexion** : pastille orange (pas de pulse, statut transitoire).
/// - **Hors ligne** : pastille grise (désaturée), sans pastille d'état.
/// - **Pulse** : un anneau lumineux se propage quand le peer est en ligne.
class PeerAvatar extends StatefulWidget {
  const PeerAvatar({
    super.key,
    required this.pseudo,
    this.radius = 24,
    this.online = false,
    this.reconnecting = false,
    this.gradient,
    this.color,
    this.imagePath,
    this.onViewPhoto,
    this.viewable = false,
  });

  final String pseudo;
  final double radius;

  /// Le chemin ABSOLU d'une photo de profil, s'il y en a une.
  final String? imagePath;

  /// Affiche la pastille verte « en ligne » en bas à droite.
  final bool online;

  /// Le pair a perdu ses liens mais on lui laisse sa chance.
  final bool reconnecting;

  /// Conservé pour compatibilité avec les écrans pas encore migrés.
  final Gradient? gradient;

  /// Force une couleur précise, sinon elle est dérivée du pseudo.
  final Color? color;

  /// Callback quand on veut voir la photo en grand (tap sur l'avatar).
  final VoidCallback? onViewPhoto;

  /// Si vrai, l'avatar est cliquable pour voir la photo en grand.
  final bool viewable;

  @override
  State<PeerAvatar> createState() => _PeerAvatarState();
}

class _PeerAvatarState extends State<PeerAvatar>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.online) _startPulse();
  }

  @override
  void didUpdateWidget(PeerAvatar old) {
    super.didUpdateWidget(old);
    if (widget.online && !old.online) {
      _startPulse();
    } else if (!widget.online && old.online) {
      _stopPulse();
    }
  }

  void _startPulse() {
    _pulseController?.dispose();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    // Pulse subtil : l'opacité de l'anneau varie, pas la taille
    _pulseController!.bouclerSiAmbiant(reverse: true);
  }

  void _stopPulse() {
    _pulseController?.stop();
    _pulseController?.dispose();
    _pulseController = null;
  }

  @override
  void dispose() {
    _stopPulse();
    super.dispose();
  }

  Widget _initiale(String initial) => DecoratedBox(
        decoration: const BoxDecoration(gradient: DegradesAvatar.reflet),
        child: Center(
          child: Text(
            initial,
            maxLines: 1,
            style: TextStyle(
              fontSize: DegradesAvatar.tailleInitiales(initial, widget.radius),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: initial.characters.length > 1 ? 0.4 : 0,
              height: 1,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final initial = DegradesAvatar.initiales(widget.pseudo);

    final palette = OuroColors.avatarPalette;
    final resolved =
        widget.color ?? palette[widget.pseudo.hashCode.abs() % palette.length];

    // ⚠️ PLUS DE COULEUR DÉLAVÉE HORS LIGNE. Mélangée à 55 % de gris, la
    // pastille de quelqu'un d'absent devenait une tache boueuse — dans la
    // liste des discussions, presque tout le monde. WhatsApp et Telegram ne
    // grisent jamais un avatar : la pastille verte suffit à dire qui est là.
    final avatarColor = resolved;

    final avatar = SizedBox(
      width: widget.radius * 2,
      height: widget.radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Anneau pulse quand en ligne
          if (widget.online && _pulseController != null)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController!,
                builder: (context, child) {
                  final t = _pulseController!.value;
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: OuroColors.systemGreen.withValues(alpha: t * 0.3),
                        width: 2 + t * 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          // Avatar principal
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Un aplat seulement si l'appelant impose une couleur ; sinon
              // le dégradé propre à cette personne (voir `ouro_avatar.dart`).
              color: widget.gradient == null && widget.color != null ? avatarColor : null,
              gradient: widget.gradient ??
                  (widget.color == null ? DegradesAvatar.pour(widget.pseudo) : null),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: widget.imagePath != null
                ? Image.file(
                    File(widget.imagePath!),
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    fit: BoxFit.cover,
                    cacheWidth: (widget.radius * 2 * 3).round(),
                    errorBuilder: (_, _, _) => _initiale(initial),
                    gaplessPlayback: true,
                    // La photo apparaît en fondu sur la couleur, au lieu de
                    // surgir d'un coup une fois décodée.
                    frameBuilder: (context, child, frame, synchrone) => synchrone
                        ? child
                        : AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: child,
                          ),
                  )
                : _initiale(initial),
          ),
          // Pastille d'état
          if (widget.online || widget.reconnecting)
            Positioned(
              right: 0,
              bottom: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: widget.radius * 0.5,
                height: widget.radius * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.online
                      ? OuroColors.systemGreen
                      : OuroColors.systemOrange,
                  border: Border.all(
                    color: OuroColors.systemBackground,
                    width: widget.radius * 0.09,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.viewable || widget.onViewPhoto != null) {
      return GestureDetector(
        onTap: widget.onViewPhoto ??
            () => showProfilePhoto(
                  context,
                  pseudo: widget.pseudo,
                  imagePath: widget.imagePath,
                  color: resolved,
                ),
        child: avatar,
      );
    }

    return avatar;
  }
}

/// Formatte un horodatage à la façon de Messages sur iOS : l'heure seule
/// si c'est aujourd'hui, « Hier », le jour de la semaine si c'est dans la
/// semaine écoulée, sinon la date.
/// L'heure ou la date d'une conversation, dans la langue de l'app.
///
/// Aujourd'hui : l'heure, au format du pays (13:40 ou 1:40 PM). Hier : le
/// mot passé par l'appelant, qui a le `l10n`. Cette semaine : le jour.
/// Avant : la date courte locale.
String formatMessageTime(DateTime t, {String? langue, String? hier}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(t.year, t.month, t.day);
  final diffDays = today.difference(that).inDays;

  if (diffDays == 0) return DateFormat.Hm(langue).format(t);
  if (diffDays == 1) return hier ?? DateFormat.MEd(langue).format(t);
  if (diffDays < 7) {
    final jour = DateFormat.EEEE(langue).format(t);
    return jour.isEmpty ? jour : jour[0].toUpperCase() + jour.substring(1);
  }
  return DateFormat.yMd(langue).format(t);
}
