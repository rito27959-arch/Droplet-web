// LES FORMATS — les heures, les jours, les durées et les tailles, dans la
// langue de l'utilisateur, avec les mêmes règles que l'app :
//
//   • dans la liste : l'heure aujourd'hui, « Hier », le jour de la semaine
//     cette semaine, la date au-delà ;
//   • dans le fil : une pastille par jour (« Aujourd'hui », « Hier »,
//     « mardi », « 3 octobre 2026 »).
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../donnees/modeles.dart';
import '../l10n/generated/app_localizations.dart';

DateTime _jour(DateTime d) => DateTime(d.year, d.month, d.day);

int ecartJours(DateTime d) => _jour(DateTime.now()).difference(_jour(d)).inDays;

String heure(BuildContext context, DateTime d) =>
    DateFormat.Hm(Localizations.localeOf(context).languageCode).format(d);

String dateListe(BuildContext context, DateTime d) {
  final l = AppLocalizations.of(context);
  final langue = Localizations.localeOf(context).languageCode;
  final ecart = ecartJours(d);
  if (ecart <= 0) return DateFormat.Hm(langue).format(d);
  if (ecart == 1) return l.chYesterday;
  if (ecart < 7) return DateFormat.EEEE(langue).format(d);
  return DateFormat.yMd(langue).format(d);
}

String separateurJour(BuildContext context, DateTime d) {
  final l = AppLocalizations.of(context);
  final langue = Localizations.localeOf(context).languageCode;
  final ecart = ecartJours(d);
  if (ecart <= 0) return l.chToday;
  if (ecart == 1) return l.chYesterday;
  if (ecart < 7) return _majuscule(DateFormat.EEEE(langue).format(d));
  if (d.year == DateTime.now().year) return DateFormat.MMMMd(langue).format(d);
  return DateFormat.yMMMMd(langue).format(d);
}

String dateComplete(BuildContext context, DateTime d) {
  final langue = Localizations.localeOf(context).languageCode;
  return '${DateFormat.yMMMMd(langue).format(d)} · ${DateFormat.Hm(langue).format(d)}';
}

String _majuscule(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// « Vu il y a 12 min » — comme l'en-tête de l'app.
String vuA(BuildContext context, Contact c) {
  final l = AppLocalizations.of(context);
  if (c.enLigne) return l.chOnlineNow;
  final v = c.vuA;
  if (v == null) return '';
  final ecart = DateTime.now().difference(v);
  if (ecart.inMinutes < 1) return l.chSeenJustNow;
  if (ecart.inHours < 1) return l.chSeenMinutesAgo(ecart.inMinutes);
  if (ecart.inDays < 1) return l.chSeenHoursAgo(ecart.inHours);
  if (ecart.inDays == 1) return l.chSeenYesterday;
  return l.chSeenDaysAgo(ecart.inDays);
}

/// 2:34 — un vocal, un appel en cours.
String chrono(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(h > 0 ? 2 : 1, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String dureeAppel(BuildContext context, int secondes) {
  final l = AppLocalizations.of(context);
  if (secondes < 60) return l.callsSecOnly(secondes);
  return l.callsMinSec(secondes ~/ 60, secondes % 60);
}

String taille(BuildContext context, int octets) {
  final l = AppLocalizations.of(context);
  if (octets < 1024) return l.chSizeBytes(octets);
  if (octets < 1024 * 1024) return l.chSizeKb((octets / 1024).toStringAsFixed(0));
  return l.chSizeMb((octets / (1024 * 1024)).toStringAsFixed(1));
}

/// L'extension d'un fichier, en majuscules : « PDF ».
String extension(String nom) {
  final i = nom.lastIndexOf('.');
  return i < 0 || i == nom.length - 1 ? '' : nom.substring(i + 1).toUpperCase();
}
