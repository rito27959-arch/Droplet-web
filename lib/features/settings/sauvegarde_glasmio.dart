// ============================================================================
// LA SAUVEGARDE DE L'IDENTITÉ EN GLASMIO (Android 13+). Mêmes règles et mêmes
// services que `BackupExportScreen` (l'écran de repli) : l'avertissement, le
// mot de passe (8 caractères au moins, saisi deux fois, masqué, avec sa
// solidité), l'historique des messages ou non, la création et le partage du
// fichier chiffré ; puis la sauvegarde automatique en ligne.
//
// ⚠️ Le mot de passe est saisi dans un champ masqué de Glasmio et ne quitte
// pas l'appli : il passe du champ natif au code Dart de la sauvegarde, dans le
// même processus, au moment où l'on appuie sur le bouton. Il est effacé des
// champs dès que la sauvegarde est créée.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/backup_service.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/sauvegarde_en_ligne.dart';
import '../../design_system/ouro_colors.dart';
import 'backup_export_screen.dart';

class PasserelleSauvegarde extends ConsumerStatefulWidget {
  const PasserelleSauvegarde({super.key});

  @override
  ConsumerState<PasserelleSauvegarde> createState() => _PasserelleSauvegardeState();
}

class _PasserelleSauvegardeState extends EtatPasserelleGlasmio<PasserelleSauvegarde> {
  bool _avecMessages = true;
  bool _occupe = false;
  bool _effacer = false;
  String _motDePasse = '';

  @override
  String get ecran => 'sauvegarde';

  @override
  Widget construireRepli(BuildContext context) => const BackupExportScreen();

  // Mêmes calculs que l'écran Flutter.
  static double _solidite(String p) {
    if (p.isEmpty) return 0;
    var n = 0;
    if (p.length >= 8) n++;
    if (p.length >= 12) n++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) n++;
    if (RegExp(r'[0-9]').hasMatch(p)) n++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) n++;
    return (n / 5).clamp(0.0, 1.0);
  }

  ReponseGlasmio _info(String titre) => ReponseGlasmio.alerte({
        'titre': titre,
        'annuler': MaterialLocalizations.of(context).okButtonLabel,
        'choix': <Object>[],
      });

  /// Le mot de passe et sa confirmation, tels que saisis.
  (String, String) get _saisie => (PontGlasmio.champs['mdp'] ?? '', PontGlasmio.champs['confirmation'] ?? '');

  String? _probleme() {
    final t = textes;
    final (mdp, conf) = _saisie;
    if (mdp.length < 8) return t.bePasswordTooShort;
    if (mdp != conf) return t.bePasswordsDontMatch;
    return null;
  }

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final t = textes;
    switch (id) {
      case 'mdp':
        _motDePasse = valeur as String? ?? '';
      case 'messages':
        _avecMessages = valeur == true;
      case 'creer':
        final p = _probleme();
        if (p != null) return _info(p);
        _occupe = true;
        await rafraichir();
        try {
          final fichier = await BackupService.createBackup(password: _saisie.$1, includeMessages: _avecMessages);
          await Share.shareXFiles([XFile(fichier.path)], subject: t.beBackupSubject, text: t.beBackupShareText);
          _occupe = false;
          _effacer = true;
          _motDePasse = '';
          if (!mounted) return ReponseGlasmio.rien;
          return ReponseGlasmio.alerte({
            'titre': t.beBackupCreated,
            'annuler': MaterialLocalizations.of(context).okButtonLabel,
            'choix': <Object>[],
            'description': await decrire(),
          });
        } catch (_) {
          _occupe = false;
          if (!mounted) return ReponseGlasmio.rien;
          return _info(t.beBackupFailed);
        }
      case 'en_ligne':
        if (valeur != true) {
          await SauvegardeEnLigne.desactiver();
          break;
        }
        final p = _probleme();
        if (p != null) {
          return ReponseGlasmio.alerte({
            'titre': p,
            'annuler': MaterialLocalizations.of(context).okButtonLabel,
            'choix': <Object>[],
            // L'interrupteur revient à sa vraie position.
            'description': await decrire(),
          });
        }
        _occupe = true;
        await rafraichir();
        final ok = await SauvegardeEnLigne.activer(_saisie.$1);
        _occupe = false;
        if (!mounted) return ReponseGlasmio.rien;
        return ReponseGlasmio.alerte({
          'titre': ok ? t.beOnlineDone : t.beOnlineFailed,
          'annuler': MaterialLocalizations.of(context).okButtonLabel,
          'choix': <Object>[],
          'description': await decrire(),
        });
      case 'maintenant':
        _occupe = true;
        await rafraichir();
        final ok = await SauvegardeEnLigne.sauvegarderMaintenant();
        _occupe = false;
        if (!mounted) return ReponseGlasmio.rien;
        return _info(ok ? t.beOnlineDone : t.beOnlineFailed);
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  String _date(DateTime d) {
    String deux(int n) => n.toString().padLeft(2, '0');
    return '${deux(d.day)}/${deux(d.month)}/${d.year} ${deux(d.hour)}:${deux(d.minute)}';
  }

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final s = _solidite(_motDePasse);
    final (couleur, libelle) = s <= 0
        ? (OuroColors.textTertiary, '')
        : s < 0.4
            ? (OuroColors.errorRed, t.beWeak)
            : s < 0.8
                ? (OuroColors.warningAmber, t.beOkay)
                : (OuroColors.successGreen, t.beStrong);
    final derniere = SauvegardeEnLigne.derniere;
    final effacer = _effacer;
    _effacer = false;
    return {
      'titre': t.beBackupMyIdentity,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': OuroColors.accent.toARGB32(),
      if (effacer) 'effacerChamps': true,
      'vitrine': {'icone': 'lock', 'teinte': OuroColors.warningAmber.toARGB32(), 'texte': t.beWarningBody},
      'sections': [
        {
          'entete': t.bePasswordProtects,
          'lignes': [
            {
              'id': 'mdp',
              'type': 'champ',
              'masque': true,
              'signaler': true,
              'titre': t.bePassword,
              if (libelle.isNotEmpty) 'valeur': libelle,
              'teinte': couleur.toARGB32(),
              'actif': !_occupe,
            },
            {'id': 'confirmation', 'type': 'champ', 'masque': true, 'titre': t.beConfirmPassword, 'actif': !_occupe},
          ],
        },
        {
          'lignes': [
            {
              'id': 'messages',
              'type': 'interrupteur',
              'icone': 'forum',
              'teinte': OuroColors.accent.toARGB32(),
              'titre': t.beIncludeMessageHistory,
              'sous': t.beOtherwiseOnlyIdentity,
              'coche': _avecMessages,
              'actif': !_occupe,
            },
          ],
        },
        {
          'lignes': [
            {'id': 'creer', 'type': 'bouton', 'titre': _occupe ? '…' : t.beCreateAndShare, 'actif': !_occupe},
          ],
        },
        {
          'entete': t.beOnlineTitle,
          'pied': t.beOnlineBody,
          'lignes': [
            {
              'id': 'en_ligne',
              'type': 'interrupteur',
              'icone': 'cloud_done',
              'teinte': OuroColors.meshBlue.toARGB32(),
              'titre': t.beOnlineSwitch,
              'sous': derniere == null ? t.beOnlineNever : t.beOnlineLast(_date(derniere)),
              'coche': SauvegardeEnLigne.active,
              'actif': !_occupe,
            },
            if (SauvegardeEnLigne.active)
              {'id': 'maintenant', 'type': 'bouton', 'titre': t.beOnlineNow, 'actif': !_occupe},
          ],
        },
      ],
    };
  }
}
