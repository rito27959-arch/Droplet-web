// ============================================================================
// QUEL GENRE DE MÉDIA EST CE FICHIER ?
//
// ⚠️ UNE SEULE RÉPONSE POUR TOUTE L'APPLICATION. La décision « image / vidéo
// / audio » était recopiée à une douzaine d'endroits, chacun lisant
// seulement le type MIME. Or une vidéo envoyée par « Joindre un fichier »
// partait en `application/octet-stream` (la table des extensions ne
// connaissait aucune vidéo) : ces messages s'affichent en carte « fichier
// .mp4 » au lieu du lecteur. Le correctif de la table ne répare que les
// NOUVEAUX envois ; pour les messages déjà reçus, on se replie donc sur
// l'extension du nom de fichier.
// ============================================================================

enum MediaKind { image, video, audio, autre }

const _extensionsImage = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif', 'bmp'};
const _extensionsVideo = {'mp4', 'm4v', 'mov', '3gp', 'webm', 'mkv'};
const _extensionsAudio = {'mp3', 'm4a', 'aac', 'wav', 'ogg', 'opus', 'flac'};

/// Le genre de média, d'après le type MIME, sinon d'après l'extension.
MediaKind mediaKindOf(String? mimeType, String? fileName) {
  final mime = (mimeType ?? '').toLowerCase();
  if (mime.startsWith('image/') || mime == 'image') return MediaKind.image;
  if (mime.startsWith('video/') || mime == 'video') return MediaKind.video;
  if (mime.startsWith('audio/') || mime == 'audio') return MediaKind.audio;

  final nom = (fileName ?? '').toLowerCase();
  final point = nom.lastIndexOf('.');
  if (point < 0 || point == nom.length - 1) return MediaKind.autre;
  final ext = nom.substring(point + 1);
  if (_extensionsImage.contains(ext)) return MediaKind.image;
  if (_extensionsVideo.contains(ext)) return MediaKind.video;
  if (_extensionsAudio.contains(ext)) return MediaKind.audio;
  return MediaKind.autre;
}
