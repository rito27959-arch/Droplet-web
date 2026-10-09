// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// L'écran plein écran pour REGARDER la photo de profil de quelqu'un —
// comme quand on tappe sur l'avatar dans WhatsApp : photo agrandie
// avec fond noir, pinch-to-zoom, swipe vers le bas pour fermer,
// et le pseudo en bas.
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/ouro_icon_button.dart';

/// Affiche la photo de profil en plein écran avec zoom et fermeture
/// par glissement.
///
/// Si [imagePath] est null ou que le fichier n'existe pas, affiche
/// les initiales en grand sur fond coloré — comme l'avatar original,
//  mais en beaucoup plus gros.
void showProfilePhoto(
  BuildContext context, {
  required String pseudo,
  String? imagePath,
  Color? color,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a, b) => ProfilePhotoViewer(
        pseudo: pseudo,
        imagePath: imagePath,
        color: color,
      ),
      transitionsBuilder: (ctx, animation, a, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    ),
  );
}

class ProfilePhotoViewer extends StatefulWidget {
  const ProfilePhotoViewer({
    super.key,
    required this.pseudo,
    this.imagePath,
    this.color,
  });

  final String pseudo;
  final String? imagePath;
  final Color? color;

  @override
  State<ProfilePhotoViewer> createState() => _ProfilePhotoViewerState();
}

class _ProfilePhotoViewerState extends State<ProfilePhotoViewer> {
  double _dragOffset = 0;
  double _opacity = 1;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      _opacity = (1 - (_dragOffset.abs() / 400)).clamp(0.2, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100 ||
        (details.primaryVelocity ?? 0).abs() > 500) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffset = 0;
        _opacity = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.pseudo.trim().isEmpty
        ? '?'
        : widget.pseudo.trim()[0].toUpperCase();

    final palette = OuroColors.avatarPalette;
    final avatarColor = widget.color ??
        palette[widget.pseudo.hashCode.abs() % palette.length];

    final hasImage = widget.imagePath != null &&
        widget.imagePath!.isNotEmpty &&
        File(widget.imagePath!).existsSync();

    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: _opacity),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Photo ou initiales en grand
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Center(
                child: hasImage
                    ? InteractiveViewer(
                        minScale: 1,
                        maxScale: 5,
                        child: Image.file(
                          File(widget.imagePath!),
                          fit: BoxFit.contain,
                          // Photo reçue tronquée ou abîmée : les initiales,
                          // plutôt qu'une erreur de décodage.
                          errorBuilder: (_, _, _) => _LargeInitial(
                            initial: initial,
                            color: avatarColor,
                            pseudo: widget.pseudo,
                          ),
                        ),
                      )
                    : _LargeInitial(
                        initial: initial,
                        color: avatarColor,
                        pseudo: widget.pseudo,
                      ),
              ),
            ),

            // Bouton fermer
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              child: OuroIconButton(
                icon: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Pseudo en bas
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
                  ),
                  child: Text(
                    widget.pseudo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Les initiales en grand, utilisées quand il n'y a pas de photo.
class _LargeInitial extends StatelessWidget {
  const _LargeInitial({
    required this.initial,
    required this.color,
    required this.pseudo,
  });

  final String initial;
  final Color color;
  final String pseudo;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.55;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.85, 0.85),
              end: const Offset(1, 1),
              duration: 300.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 200.ms),
        const SizedBox(height: 20),
        Text(
          pseudo,
          style: OuroTypography.title2.copyWith(color: Colors.white),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 250.ms)
            .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
      ],
    );
  }
}
