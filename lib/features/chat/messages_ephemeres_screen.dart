import 'dart:async';
// ============================================================================
// L'ÉCRAN DES MESSAGES ÉPHÉMÈRES
// ----------------------------------------------------------------------------
// Le modèle est celui de WhatsApp : une illustration, une phrase qui dit
// exactement ce qui va se passer, puis un choix de durées en liste iOS.
// Rien d'autre — c'est un réglage qu'on prend en trois secondes.
// ============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'messages_ephemeres.dart';
import '../../core/services/storage_service.dart';

class MessagesEphemeresScreen extends StatefulWidget {
  const MessagesEphemeresScreen({
    super.key,
    required this.cleConversation,
    required this.nom,
  });

  final String cleConversation;
  final String nom;

  @override
  State<MessagesEphemeresScreen> createState() => _MessagesEphemeresScreenState();
}

class _MessagesEphemeresScreenState extends State<MessagesEphemeresScreen> {
  Duration? _choisie;

  @override
  void initState() {
    super.initState();
    // Le minuteur historique de Droplet, celui qui voyage avec le message
    // (`expiresInSeconds`). Cet écran n'en crée pas un second : il pilote
    // celui-là.
    final secondes = StorageService.getEphemeralTimer(widget.cleConversation);
    _choisie = secondes > 0 ? Duration(seconds: secondes) : null;
  }

  void _choisir(Duration? duree) {
    if (duree == _choisie) return;
    OuroHaptics.selection();
    setState(() => _choisie = duree);
    unawaited(StorageService.setEphemeralTimer(
      widget.cleConversation,
      duree?.inSeconds ?? 0,
    ));
  }

  /// Les durées proposées, du plus court au plus long. Les deux premières
  /// existaient déjà dans Droplet, les trois dernières sont celles de
  /// WhatsApp : on garde tout plutôt que d'enlever à quelqu'un ce dont il
  /// se servait.
  static const List<Duration> _durees = [
    Duration(seconds: 30),
    Duration(minutes: 5),
    Duration(hours: 1),
    Duration(hours: 24),
    Duration(days: 7),
    Duration(days: 90),
  ];

  String _libelle(AppLocalizations l10n, Duration d) => switch (d.inSeconds) {
        30 => l10n.ci30Seconds,
        300 => l10n.ci5Minutes,
        3600 => l10n.ci1Hour,
        86400 => l10n.epHours24,
        604800 => l10n.epDays7,
        _ => l10n.epDays90,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroLargeTitleScaffold(
      title: l10n.epTitle,
      backgroundColor: OuroColors.systemGroupedBackground,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 26),
            child: Column(
              children: [
                const SizedBox(
                  width: 128,
                  height: 128,
                  child: _GoutteQuiSEfface(),
                ),
                const SizedBox(height: DesignTokens.space5),
                Text(
                  l10n.epHeadline,
                  textAlign: TextAlign.center,
                  style: OuroTypography.body.copyWith(
                    color: OuroColors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.epBody,
                  textAlign: TextAlign.center,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.secondaryLabel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: OuroListSection(
            header: l10n.epDelayHeader,
            footer: l10n.epFooter,
            children: [
              for (final d in _durees)
                _LigneDuree(
                  titre: _libelle(l10n, d),
                  choisie: _choisie == d,
                  onTap: () => _choisir(d),
                ),
              _LigneDuree(
                titre: l10n.epOff,
                choisie: _choisie == null,
                onTap: () => _choisir(null),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

/// Une ligne de choix, avec la coche iOS à droite.
class _LigneDuree extends StatelessWidget {
  const _LigneDuree({required this.titre, required this.choisie, required this.onTap});

  final String titre;
  final bool choisie;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OuroListRow(
      title: titre,
      showChevron: false,
      onTap: onTap,
      trailing: AnimatedScale(
        scale: choisie ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        child: Icon(Icons.check_rounded, size: 21, color: OuroColors.accent),
      ),
    );
  }
}

/// La goutte Droplet qui s'évapore : trois bulles qui montent et s'effacent.
class _GoutteQuiSEfface extends StatefulWidget {
  const _GoutteQuiSEfface();

  @override
  State<_GoutteQuiSEfface> createState() => _GoutteQuiSEffaceState();
}

class _GoutteQuiSEffaceState extends State<_GoutteQuiSEfface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anime = !MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _PeintreGoutte(
          avancement: anime ? _c.value : 0.25,
          couleur: OuroColors.accent,
        ),
      ),
    );
  }
}

class _PeintreGoutte extends CustomPainter {
  _PeintreGoutte({required this.avancement, required this.couleur});

  final double avancement;
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.56);
    final r = size.width * 0.3;

    // Le corps de la goutte : un disque surmonté d'une pointe.
    final goutte = Path()
      ..moveTo(c.dx, c.dy - r * 1.9)
      ..cubicTo(c.dx + r * 0.95, c.dy - r * 0.6, c.dx + r, c.dy - r * 0.15, c.dx + r, c.dy + r * 0.12)
      ..arcToPoint(Offset(c.dx - r, c.dy + r * 0.12), radius: Radius.circular(r), clockwise: false)
      ..cubicTo(c.dx - r, c.dy - r * 0.15, c.dx - r * 0.95, c.dy - r * 0.6, c.dx, c.dy - r * 1.9)
      ..close();

    canvas.drawPath(
      goutte,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round
        ..color = couleur.withValues(alpha: 0.9),
    );
    canvas.drawPath(goutte, Paint()..color = couleur.withValues(alpha: 0.12));

    // Trois bulles qui montent et disparaissent : le temps qui passe.
    for (var i = 0; i < 3; i++) {
      final t = (avancement + i / 3) % 1;
      final rayon = (3.0 + i * 1.6) * (1 - t * 0.45);
      final x = c.dx + math.sin((i + 1) * 2.1 + t * math.pi) * size.width * 0.16;
      final y = c.dy - r * 0.2 - t * size.height * 0.42;
      canvas.drawCircle(
        Offset(x, y),
        rayon,
        Paint()..color = couleur.withValues(alpha: (1 - t) * 0.55),
      );
    }
  }

  @override
  bool shouldRepaint(_PeintreGoutte ancien) =>
      ancien.avancement != avancement || ancien.couleur != couleur;
}
