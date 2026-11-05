// ============================================================================
// LA BULLE D'APPEL MANQUÉ, dans une conversation — comme WhatsApp.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/models/mesh_message.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// Un appel manqué dans la conversation, comme WhatsApp : une bulle reçue
/// (à gauche, avec sa petite pointe), l'icône rouge, le type d'appel,
/// « Appuyez pour rappeler » et l'heure. Toute la bulle rappelle ; le rond
/// à droite aussi, pour qu'on voie tout de suite qu'on peut le faire.
///
/// Plusieurs appels manqués à la suite, à moins d'une heure d'écart, ne
/// font qu'UNE bulle avec leur nombre — « Appel vocal manqué (3) » — au
/// lieu d'une pile de bulles identiques.
class BulleAppelManque extends StatelessWidget {
  const BulleAppelManque({
    required this.message,
    required this.onRappeler,
    this.nombre = 1,
    this.anime = true,
  });

  final MeshMessage message;
  final void Function(bool video) onRappeler;
  final int nombre;

  /// Faux : pas d'animation d'entrée (captures d'écran, tests).
  final bool anime;

  static bool estVideo(MeshMessage m) => m.content.contains('"video":true');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final video = estVideo(message);
    final heure = TimeOfDay.fromDateTime(message.timestamp).format(context);
    final titre = video ? l10n.clMissedVideo : l10n.clMissedVoice;
    final rouge = OuroColors.systemRed;
    final largeurMax = MediaQuery.sizeOf(context).width * 0.78;
    final bulle = Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 9, bottom: 1),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: largeurMax),
              child: Material(
                color: OuroColors.bubbleIncoming,
                // La forme d'une bulle reçue : coin bas-gauche resserré.
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusBubble),
                  topRight: Radius.circular(DesignTokens.radiusBubble),
                  bottomRight: Radius.circular(DesignTokens.radiusBubble),
                  bottomLeft: const Radius.circular(6),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onRappeler(video),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 9, 9, 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // L'icône rouge, qui « sonne » une fois quand l'appel
                        // vient d'être manqué (pas à chaque défilement).
                        _IconeAppelManque(
                          video: video,
                          recent: anime && DateTime.now().difference(message.timestamp) < const Duration(minutes: 2),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre > 1 ? '$titre ($nombre)' : titre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: OuroColors.bubbleIncomingText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // La flèche d'un appel reçu, en rouge : il
                                  // n'a pas abouti.
                                  Icon(Icons.south_west_rounded, size: 13, color: rouge),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      l10n.clTapToCallBack,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: OuroColors.secondaryLabel,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Tooltip(
                              message: l10n.clCallBack,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: OuroColors.accent.withValues(alpha: 0.14),
                                ),
                                child: Icon(
                                  video ? Icons.videocam_rounded : Icons.call_rounded,
                                  color: OuroColors.accent,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              heure,
                              style: TextStyle(
                                color: OuroColors.secondaryLabel,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    if (!anime) return bulle;
    return bulle
        .animate()
        .fadeIn(duration: 220.ms)
        .slideX(begin: -0.04, end: 0, duration: 260.ms);
  }
}

/// Le rond rouge du combiné manqué. Un appel qui vient d'être manqué
/// « sonne » une fois (petit rebond puis tremblement) ; les anciens restent
/// calmes, sinon chaque défilement de la discussion les ferait trembler.
class _IconeAppelManque extends StatelessWidget {
  const _IconeAppelManque({required this.video, required this.recent});

  final bool video;
  final bool recent;

  @override
  Widget build(BuildContext context) {
    final rouge = OuroColors.systemRed;
    final rond = Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: rouge.withValues(alpha: 0.14),
      ),
      child: Icon(
        video ? Icons.missed_video_call_rounded : Icons.phone_missed_rounded,
        color: rouge,
        size: 21,
      ),
    );
    if (!recent) return rond;
    return rond
        .animate()
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1, 1),
          duration: 320.ms,
          curve: Curves.easeOutBack,
        )
        .then(delay: 60.ms)
        .shake(hz: 5, rotation: 0.08, duration: 420.ms);
  }
}

/// Deux appels manqués se suivent-ils assez pour ne faire qu'une bulle ?
/// Même personne, même type (voix/vidéo), moins d'une heure d'écart.
bool appelsGroupes(Object? a, Object? b) =>
    a is MeshMessage &&
    b is MeshMessage &&
    a.type == 'appel' &&
    b.type == 'appel' &&
    a.senderId == b.senderId &&
    BulleAppelManque.estVideo(a) == BulleAppelManque.estVideo(b) &&
    b.timestamp.difference(a.timestamp).abs() <= const Duration(hours: 1);
