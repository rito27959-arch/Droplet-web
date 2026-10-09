// ============================================================================
// LES APERÇUS SYSTÈME — traduits au moment de l'affichage.
// ----------------------------------------------------------------------------
// La liste des discussions est construite dans un fournisseur, loin de tout
// `BuildContext` : impossible d'y traduire quoi que ce soit. On y pose donc
// une marque, et c'est la ligne qui, elle, sait dans quelle langue écrire.
// ============================================================================

import '../../l10n/generated/app_localizations.dart';

class ApercuSysteme {
  ApercuSysteme._();

  /// Les marques commencent par un caractère de contrôle : personne ne peut
  /// l'écrire dans un message, donc aucune confusion possible.
  static const String verrouille = '\u0001verrou';
  static const String appelManque = '\u0001appel';
  static const String appelVideoManque = '\u0001appelVideo';

  /// Un groupe créé, où personne n'a encore écrit.
  static const String groupeCree = '\u0001groupe';

  /// Le nom de la diffusion à tout le maillage.
  static const String diffusion = '\u0001diffusion';

  /// Les pièces jointes, dites par ce qu'elles sont — pas par leur nom de
  /// fichier. « IMG_2043.PNG » ne dit rien à personne.
  static const String photo = '\u0001photo';
  static const String video = '\u0001video';
  static const String document = '\u0001document';

  /// Reconnaît une pièce jointe à son extension.
  static String pourFichier(String? nomFichier) {
    final nom = (nomFichier ?? '').toLowerCase();
    const images = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.bmp'];
    const videos = ['.mp4', '.mov', '.m4v', '.avi', '.mkv', '.webm'];
    if (images.any(nom.endsWith)) return photo;
    if (videos.any(nom.endsWith)) return video;
    return document;
  }

  /// Le « Message vocal » historique, écrit en français dans les modèles.
  static const String _vocalFr = '🎤 Message vocal';

  /// Rend l'aperçu dans la langue de l'app.
  static String localiser(String brut, AppLocalizations l10n) {
    switch (brut) {
      case verrouille:
        return l10n.chatsLockedTitle;
      case appelManque:
        return '📞 ${l10n.callsMissed}';
      case appelVideoManque:
        return '📹 ${l10n.callsMissed}';
      case groupeCree:
        return l10n.grCreatedNoMessages;
      case diffusion:
        return l10n.chBroadcastChannel;
      case photo:
        return '📷 ${l10n.vuPhoto}';
      case video:
        return '🎥 ${l10n.vuVideo}';
      case document:
        return '📎 ${l10n.chatsDocument}';
    }
    // Le vocal garde sa durée : « 🎤 Message vocal · 0:12 ».
    if (brut.startsWith(_vocalFr)) {
      return '🎤 ${l10n.chVoiceMessageLabel}${brut.substring(_vocalFr.length)}';
    }
    return brut;
  }
}
