// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Canvas de dessin pour les statuts photo. Permet d'annoter une image avec :
// - Un crayon libre (multi-couleurs, taille variable)
// - Du texte positionnable
// - Des emojis redimensionnables
//
// Le dessin est superposé à l'image capturée et fusionné avant publication.
// ============================================================================

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../design_system/ouro_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';

/// Un trait de crayon dessiné sur le canvas.
class _Stroke {
  _Stroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
}

/// Un texte positionné sur le canvas.
class _TextItem {
  _TextItem({
    required this.text,
    required this.position,
    required this.style,
  });

  final String text;
  Offset position;
  TextStyle style;
}

/// Un emoji positionné sur le canvas.
class _EmojiItem {
  _EmojiItem({
    required this.emoji,
    required this.position,
    required this.size,
  });

  final String emoji;
  Offset position;
  double size;
}

/// Outils de dessin disponibles.
enum DrawTool { pen, text, emoji, none }

/// Éditeur de dessin superposé à une image.
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    required this.imageProvider,
    this.onDrawingChanged,
  });

  final ImageProvider imageProvider;
  final ValueChanged<ui.Image?>? onDrawingChanged;

  @override
  State<DrawingCanvas> createState() => DrawingCanvasState();
}

class DrawingCanvasState extends State<DrawingCanvas> {
  DrawTool _activeTool = DrawTool.none;
  Color _selectedColor = Colors.white;
  double _strokeWidth = 4.0;
  String _selectedEmoji = '😀';

  final List<_Stroke> _strokes = [];
  final List<_TextItem> _texts = [];
  final List<_EmojiItem> _emojis = [];

  List<Offset> _currentPoints = [];

  // ── Drag-to-delete for emojis/texts ──
  int? _draggingIndex;
  bool _isDraggingEmoji = false;
  bool _isDraggingText = false;
  Offset _dragOffset = Offset.zero;
  bool _nearTrash = false;

  void setTool(DrawTool tool) {
    setState(() => _activeTool = tool);
  }

  void setColor(Color color) {
    setState(() => _selectedColor = color);
  }

  void setStrokeWidth(double width) {
    setState(() => _strokeWidth = width);
  }

  void setEmoji(String emoji) {
    setState(() {
      _selectedEmoji = emoji;
      _activeTool = DrawTool.emoji;
    });
  }

  void undo() {
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.removeLast();
      } else if (_emojis.isNotEmpty) {
        _emojis.removeLast();
      } else if (_texts.isNotEmpty) {
        _texts.removeLast();
      }
    });
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _texts.clear();
      _emojis.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapUp: _onTapUp,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond
          Image(image: widget.imageProvider, fit: BoxFit.contain),

          // Canvas de dessin
          CustomPaint(
            painter: _DrawingPainter(
              strokes: _strokes,
              texts: _texts,
              emojis: _emojis,
              currentPoints: _currentPoints,
              currentColor: _selectedColor,
              currentStrokeWidth: _strokeWidth,
              draggingIndex: _draggingIndex,
              isDraggingEmoji: _isDraggingEmoji,
              isDraggingText: _isDraggingText,
              dragOffset: _dragOffset,
              nearTrash: _nearTrash,
            ),
          ),

          // Trash indicator when dragging
          if (_draggingIndex != null)
            Positioned(
              left: 16,
              top: MediaQuery.of(context).padding.top + 16,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _nearTrash
                      ? Colors.red.withValues(alpha: 0.8)
                      : Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: _nearTrash ? 28 : 22,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (_activeTool != DrawTool.pen) return;
    setState(() {
      _currentPoints = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeTool != DrawTool.pen) return;
    setState(() {
      _currentPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeTool != DrawTool.pen) return;
    if (_currentPoints.length > 1) {
      setState(() {
        _strokes.add(_Stroke(
          points: List.from(_currentPoints),
          color: _selectedColor,
          strokeWidth: _strokeWidth,
        ));
        _currentPoints = [];
      });
    }
  }

  void _onTapUp(TapUpDetails details) {
    final pos = details.localPosition;

    if (_activeTool == DrawTool.emoji) {
      setState(() {
        _emojis.add(_EmojiItem(
          emoji: _selectedEmoji,
          position: pos,
          size: 48,
        ));
      });
    } else if (_activeTool == DrawTool.text) {
      _showTextDialog(pos);
    }
  }

  /// Long press on an emoji or text to start dragging it toward trash.
  void _onLongPressStart(LongPressStartDetails details) {
    final pos = details.localPosition;

    // Check emojis first (they're on top)
    for (var i = _emojis.length - 1; i >= 0; i--) {
      final emoji = _emojis[i];
      final dist = (pos - emoji.position).distance;
      if (dist < emoji.size) {
        setState(() {
          _draggingIndex = i;
          _isDraggingEmoji = true;
          _isDraggingText = false;
          _dragOffset = pos - emoji.position;
        });
        return;
      }
    }

    // Check texts
    for (var i = _texts.length - 1; i >= 0; i--) {
      final text = _texts[i];
      final dist = (pos - text.position).distance;
      if (dist < 40) {
        setState(() {
          _draggingIndex = i;
          _isDraggingText = true;
          _isDraggingEmoji = false;
          _dragOffset = pos - text.position;
        });
        return;
      }
    }
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_draggingIndex == null) return;
    final pos = details.localPosition;

    setState(() {
      if (_isDraggingEmoji && _draggingIndex! < _emojis.length) {
        _emojis[_draggingIndex!].position = pos - _dragOffset;
      } else if (_isDraggingText && _draggingIndex! < _texts.length) {
        _texts[_draggingIndex!].position = pos - _dragOffset;
      }

      // Check if near trash (top-left area)
      _nearTrash = pos.dx < 80 && pos.dy < 120;
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    if (_draggingIndex == null) return;

    if (_nearTrash) {
      // Delete the item
      setState(() {
        if (_isDraggingEmoji && _draggingIndex! < _emojis.length) {
          _emojis.removeAt(_draggingIndex!);
        } else if (_isDraggingText && _draggingIndex! < _texts.length) {
          _texts.removeAt(_draggingIndex!);
        }
        _draggingIndex = null;
        _isDraggingEmoji = false;
        _isDraggingText = false;
        _nearTrash = false;
      });
    } else {
      setState(() {
        _draggingIndex = null;
        _isDraggingEmoji = false;
        _isDraggingText = false;
        _nearTrash = false;
      });
    }
  }

  void _showTextDialog(Offset position) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);
    showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.dark),
      child: CupertinoAlertDialog(
      title: Text(l10n.dcAddText, style: const TextStyle(color: Colors.white)),
      content: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: CupertinoTextField(controller: controller, autofocus: true, style: const TextStyle(color: Colors.white, fontSize: 18), placeholder: l10n.dcYourTextHint, placeholderStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.actionCancel),
        ),
        CupertinoDialogAction(
          isDefaultAction: true, onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _texts.add(_TextItem(
                    text: controller.text.trim(),
                    position: position,
                    style: TextStyle(
                      color: _selectedColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ));
                });
              }
              Navigator.pop(ctx);
            },
          child: Text(l10n.giAdd, style: TextStyle(color: OuroColors.accent)),
        ),
      ],
    ),
    ),
  );
  }
}

/// Painter personnalisé qui dessine tous les éléments sur le canvas.
class _DrawingPainter extends CustomPainter {
  _DrawingPainter({
    required this.strokes,
    required this.texts,
    required this.emojis,
    required this.currentPoints,
    required this.currentColor,
    required this.currentStrokeWidth,
    this.draggingIndex,
    this.isDraggingEmoji = false,
    this.isDraggingText = false,
    this.dragOffset = Offset.zero,
    this.nearTrash = false,
  });

  final List<_Stroke> strokes;
  final List<_TextItem> texts;
  final List<_EmojiItem> emojis;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentStrokeWidth;
  final int? draggingIndex;
  final bool isDraggingEmoji;
  final bool isDraggingText;
  final Offset dragOffset;
  final bool nearTrash;

  @override
  void paint(Canvas canvas, Size size) {
    // Dessiner les traits existants
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint);
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Dessiner le trait en cours
    if (currentPoints.isNotEmpty) {
      final paint = Paint()
        ..color = currentColor
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (currentPoints.length == 1) {
        canvas.drawCircle(currentPoints.first, currentStrokeWidth / 2, paint);
      } else {
        final path = Path();
        path.moveTo(currentPoints.first.dx, currentPoints.first.dy);
        for (int i = 1; i < currentPoints.length; i++) {
          path.lineTo(currentPoints[i].dx, currentPoints[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }

    // Dessiner les textes
    for (var i = 0; i < texts.length; i++) {
      final text = texts[i];
      final isBeingDragged = isDraggingText && draggingIndex == i;
      final opacity = isBeingDragged && nearTrash ? 0.4 : 1.0;

      final tp = TextPainter(
        text: TextSpan(
          text: text.text,
          style: text.style.copyWith(
            color: text.style.color?.withValues(alpha: opacity),
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, text.position);
    }

    // Dessiner les emojis
    for (var i = 0; i < emojis.length; i++) {
      final emoji = emojis[i];

      final tp = TextPainter(
        text: TextSpan(
          text: emoji.emoji,
          style: TextStyle(fontSize: emoji.size),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();

      tp.paint(canvas, emoji.position - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

/// Barre d'outils de dessin verticale sur la droite — style WhatsApp.
///
/// Les outils sont empilés verticalement à droite de l'écran, avec un
/// slider de couleur vertical en dessous. C'est exactement la disposition
/// de WhatsApp pour l'annotation de photos/stories.
class DrawingToolbar extends StatelessWidget {
  const DrawingToolbar({
    super.key,
    required this.activeTool,
    required this.selectedColor,
    required this.strokeWidth,
    required this.onToolChanged,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onUndo,
    required this.onClear,
  });

  final DrawTool activeTool;
  final Color selectedColor;
  final double strokeWidth;
  final ValueChanged<DrawTool> onToolChanged;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onStrokeWidthChanged;
  final VoidCallback onUndo;
  final VoidCallback onClear;

  static const List<Color> _colors = [
    Colors.white,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      top: MediaQuery.of(context).padding.top + 60,
      bottom: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Outils principaux (empilés verticalement) ──
          _VerticalToolButton(
            icon: Icons.edit_rounded,
            active: activeTool == DrawTool.pen,
            onTap: () => onToolChanged(
              activeTool == DrawTool.pen ? DrawTool.none : DrawTool.pen,
            ),
          ),
          const SizedBox(height: 8),
          _VerticalToolButton(
            icon: Icons.text_fields_rounded,
            active: activeTool == DrawTool.text,
            onTap: () => onToolChanged(
              activeTool == DrawTool.text ? DrawTool.none : DrawTool.text,
            ),
          ),
          const SizedBox(height: 8),
          _VerticalToolButton(
            icon: Icons.emoji_emotions_rounded,
            active: activeTool == DrawTool.emoji,
            onTap: () => onToolChanged(
              activeTool == DrawTool.emoji ? DrawTool.none : DrawTool.emoji,
            ),
          ),
          const SizedBox(height: 12),

          // ── Sélecteur de couleur vertical (style WhatsApp) ──
          if (activeTool == DrawTool.pen)
            _VerticalColorSlider(
              colors: _colors,
              selectedColor: selectedColor,
              onColorChanged: onColorChanged,
            ),

          const SizedBox(height: 12),

          // ── Undo ──
          _VerticalToolButton(
            icon: Icons.undo_rounded,
            active: false,
            onTap: onUndo,
          ),
        ],
      ),
    );
  }
}

/// Bouton d'outil vertical — rond, avec fond semi-transparent.
class _VerticalToolButton extends StatelessWidget {
  const _VerticalToolButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

/// Slider de couleur vertical — la couleur sélectionnée est mise en
/// avant avec un cercle plus grand et un bord blanc.
///
/// Style WhatsApp : les couleurs sont empilées verticalement, la
/// couleur active est plus grosse avec un anneau blanc.
class _VerticalColorSlider extends StatelessWidget {
  const _VerticalColorSlider({
    required this.colors,
    required this.selectedColor,
    required this.onColorChanged,
  });

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: colors.map((c) {
          final isSelected = c.toARGB32() == selectedColor.toARGB32();
          return GestureDetector(
            onTap: () => onColorChanged(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(vertical: 2),
              width: isSelected ? 24 : 16,
              height: isSelected ? 24 : 16,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
