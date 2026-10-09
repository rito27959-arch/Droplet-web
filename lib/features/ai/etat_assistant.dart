// ============================================================================
// L'ASSISTANT EST-IL EN TRAIN D'ÉCRIRE ? — un seul drapeau, lisible partout.
// ----------------------------------------------------------------------------
// La réponse continue de s'écrire même quand on quitte l'écran de l'Assistant
// (la boucle qui reçoit les mots n'est pas liée à l'écran). Ce drapeau permet
// à la liste des Discussions de le montrer : la goutte de l'Assistant fait
// des ronds dans l'eau tant qu'il écrit.
//
// Dans l'écran de l'Assistant lui-même, rien ne change : l'étoile et la
// lueur façon Gemini restent l'animation de réflexion.
// ============================================================================

import 'package:flutter/foundation.dart';

final ValueNotifier<bool> assistantEcrit = ValueNotifier<bool>(false);
