// ============================================================================
// LES RACCOURCIS DE CONVERSATION D'ANDROID.
// ----------------------------------------------------------------------------
// Depuis Android 11, une conversation n'est pas une notification comme une
// autre : le système lui réserve une place à part, à condition que
// l'application publie un « raccourci » pour elle et que la notification s'y
// réfère. C'est ce raccourci qui donne :
//
//   • l'appui long sur l'icône de Droplet → les dernières conversations ;
//   • les BULLES flottantes, qu'on garde par-dessus les autres applications ;
//   • la section « Conversations » des réglages de notification, où l'on
//     choisit qui est prioritaire ou en silencieux ;
//   • l'avatar de la personne dans la notification, et non l'icône de l'app.
//
// Droplet n'en publiait aucun : pour Android, ses notifications n'étaient pas
// des conversations. Voir `MainActivity.publierRaccourci`.
//
// ⚠️ RIEN NE SORT DU TÉLÉPHONE. Un raccourci vit dans le lanceur, en local.
// ============================================================================

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RaccourcisConversation {
  RaccourcisConversation._();

  static const MethodChannel _canal = MethodChannel('com.droplet.droplet/raccourcis');

  static bool get _disponible => !kIsWeb && Platform.isAndroid;

  /// Les raccourcis déjà publiés pendant cette session : Android limite leur
  /// nombre, et republier le même à chaque message ne sert à rien.
  static final Map<String, String> _publies = {};

  /// Publie (ou met à jour) le raccourci d'une conversation.
  static Future<void> publier({
    required String id,
    required String nom,
    required String route,
    String? photo,
  }) async {
    if (!_disponible || id.isEmpty || nom.trim().isEmpty) return;
    final empreinte = '$nom|$route|${photo ?? ''}';
    if (_publies[id] == empreinte) return;
    try {
      await _canal.invokeMethod<bool>('publier', {
        'id': id,
        'nom': nom,
        'route': route,
        'photo': photo,
      });
      _publies[id] = empreinte;
    } catch (e) {
      debugPrint('[Raccourcis] publication impossible: $e');
    }
  }

  /// Retire le raccourci d'une conversation (contact supprimé, groupe quitté).
  static Future<void> retirer(String id) async {
    if (!_disponible || id.isEmpty) return;
    _publies.remove(id);
    try {
      await _canal.invokeMethod<bool>('retirer', {'id': id});
    } catch (_) {}
  }

  /// La conversation à ouvrir quand l'application a été lancée par un
  /// raccourci (ou par une notification). Lue une seule fois.
  static Future<String?> routeDeLancement() async {
    if (!_disponible) return null;
    try {
      return await _canal.invokeMethod<String>('routeDeLancement');
    } catch (_) {
      return null;
    }
  }
}
