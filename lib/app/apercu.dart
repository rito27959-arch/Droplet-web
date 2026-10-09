// L'APERÇU D'UN MESSAGE — la ligne grise sous le nom dans la liste, la
// citation d'une réponse, la notification, le message épinglé.
//
// Les messages « système » (groupe créé, messages éphémères activés…) sont
// enregistrés sous forme de code et traduits ici, au moment de l'affichage :
// la même discussion se lit dans la langue de chacun.
import 'package:flutter/material.dart';

import '../donnees/modeles.dart';
import 'formats.dart';
import 'portee.dart';

IconData? iconeMessage(Message m) {
  if (m.supprime) return Icons.block_rounded;
  return switch (m.type) {
    TypeMessage.image => Icons.photo_rounded,
    TypeMessage.vocal => Icons.mic_rounded,
    TypeMessage.fichier => Icons.insert_drive_file_rounded,
    _ => null,
  };
}

String texteMessage(BuildContext context, Message m) {
  final l = context.l;
  final t = context.t;
  if (m.supprime) return m.deMoi ? t.vousAvezSupprime : t.messageSupprime;
  switch (m.type) {
    case TypeMessage.systeme:
      return texteSysteme(context, m);
    case TypeMessage.image:
      return m.texte.isNotEmpty ? m.texte : l.chPhotoLabel;
    case TypeMessage.vocal:
      final d = m.piece?.dureeMs;
      return d == null ? l.chVoiceMessageLabel : '${l.chVoiceMessageLabel} (${chrono(Duration(milliseconds: d))})';
    case TypeMessage.fichier:
      return m.texte.isNotEmpty ? m.texte : (m.piece?.nom ?? l.chatsDocument);
    case TypeMessage.texte:
      return m.texte;
  }
}

String texteSysteme(BuildContext context, Message m) {
  final t = context.t;
  final l = context.l;
  final depot = context.lire.depot;
  final code = m.texte;
  if (code == 'groupe_cree') return l.grCreatedBy(depot.nom(m.auteurId));
  if (code == 'quitte') return t.aQuitte(depot.nom(m.auteurId));
  if (code.startsWith('ephemere:')) {
    final s = int.tryParse(code.substring(9)) ?? 0;
    return s == 0 ? t.ephemereDesactive : t.ephemereActive(dureeEphemere(context, s));
  }
  if (code.startsWith('ajoute:')) return l.grAdded(depot.nom(m.auteurId), depot.nom(code.substring(7)));
  if (code.startsWith('retire:')) return t.aRetire(depot.nom(m.auteurId), depot.nom(code.substring(7)));
  if (code.startsWith('renomme:')) return t.aRenomme(depot.nom(m.auteurId), code.substring(8));
  return code;
}

/// Les durées proposées pour les messages éphémères, et leur nom.
const List<int> dureesEphemeres = [0, 86400, 604800, 7776000];

String dureeEphemere(BuildContext context, int secondes) {
  final l = context.l;
  return switch (secondes) {
    0 => l.epOff,
    86400 => l.epHours24,
    604800 => l.epDays7,
    7776000 => l.epDays90,
    _ => '${secondes}s',
  };
}
