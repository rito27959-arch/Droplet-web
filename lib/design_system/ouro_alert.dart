// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LES BOÎTES DE DIALOGUE — « Voulez-vous vraiment… ? », « Supprimer ce
// groupe ? ». Celles d'iOS, pas celles d'Android.
//
// ── Pourquoi ça compte ────────────────────────────────────────────────
//
// Une boîte de dialogue est le seul moment où l'application ARRÊTE tout
// et exige une réponse. C'est donc l'élément le plus regardé de toute
// l'interface — et celui où une différence de plateforme saute le plus
// aux yeux.
//
// Android aligne ses boutons en bas à droite, en petites capitales.
// iOS les répartit sur toute la largeur, séparés par des traits fins :
// « Annuler » en gras à gauche, l'action à droite, en rouge si elle
// détruit quelque chose. Ce sont deux grammaires visuelles distinctes,
// et l'app en utilisait une par écran au petit bonheur.
//
// ── L'ENNUI TECHNIQUE QUI JUSTIFIE CE FICHIER ─────────────────────────
//
// `CupertinoAlertDialog` choisit ses couleurs d'après la luminosité
// qu'il trouve dans son contexte. Or Droplet n'utilise pas le thème de
// Cupertino : le choix clair/sombre de l'utilisateur vit dans
// `OuroColors`. Sans le `CupertinoTheme` posé ici, une boîte de dialogue
// resterait sombre alors que l'utilisateur a demandé le mode clair —
// ou l'inverse. C'est précisément le genre de détail qui ne se voit
// qu'une fois sur le téléphone de quelqu'un d'autre.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show showDialog;

import 'ouro_colors.dart';
import 'ouro_haptics.dart';
import 'liquid_bridge_native.dart';
import '../l10n/generated/app_localizations.dart';

/// Une question fermée, posée à la manière d'iOS.
///
/// Renvoie `true` si l'action est confirmée, `false` ou `null` sinon —
/// fermer la boîte sans choisir vaut refus.
///
/// [destructive] passe l'action en rouge : c'est la convention pour tout
/// ce qui efface, quitte ou révoque.
///
/// Sur iOS 26+ : utilise UIAlertController natif avec Liquid Glass.
/// Sur les autres : CupertinoAlertDialog classique.
Future<bool?> ouroConfirm(
  BuildContext context, {
  required String title,
  String? message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) {
  // Les libellés par défaut viennent de la langue de l'app, pas du
  // français : un bouton « Annuler » en chinois, c'est un bug visible.
  final l10n = AppLocalizations.of(context);
  OuroHaptics.light();

  if (isNativeGlassAvailable) {
    return showNativeGlassAlert<bool>(
      context,
      title: title,
      message: message,
      actions: [
        NativeGlassAlertAction(
          id: 'cancel',
          label: (cancelLabel ?? l10n.actionCancel),
          value: false,
          isCancel: true,
        ),
        NativeGlassAlertAction(
          id: 'confirm',
          label: (confirmLabel ?? l10n.obContinue),
          value: true,
          destructive: destructive,
        ),
      ],
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (context) => _themed(
      CupertinoAlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel ?? l10n.actionCancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: destructive,
            onPressed: () {
              if (destructive) OuroHaptics.warning();
              Navigator.of(context).pop(true);
            },
            child: Text((confirmLabel ?? l10n.obContinue)),
          ),
        ],
      ),
    ),
  );
}

/// Un choix parmi plusieurs, chacun avec sa propre valeur de retour.
///
/// Sert aux questions à trois branches — « avec ma position / sans ma
/// position / annuler » — qu'une simple confirmation ne sait pas poser.
Future<T?> ouroChoice<T>(
  BuildContext context, {
  required String title,
  String? message,
  required List<OuroChoiceOption<T>> options,
  String? cancelLabel,
}) {
  // Les libellés par défaut viennent de la langue de l'app, pas du
  // français : un bouton « Annuler » en chinois, c'est un bug visible.
  final l10n = AppLocalizations.of(context);
  OuroHaptics.light();

  if (isNativeGlassAvailable) {
    return showNativeGlassAlert<T>(
      context,
      title: title,
      message: message,
      actions: [
        for (final option in options)
          NativeGlassAlertAction(
            id: option.label,
            label: option.label,
            value: option.value,
            destructive: option.destructive,
          ),
        NativeGlassAlertAction(
          id: 'cancel',
          label: (cancelLabel ?? l10n.actionCancel),
          isCancel: true,
        ),
      ],
    );
  }

  return showDialog<T>(
    context: context,
    builder: (context) => _themed(
      CupertinoAlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          for (final option in options)
            CupertinoDialogAction(
              isDestructiveAction: option.destructive,
              onPressed: () => Navigator.of(context).pop(option.value),
              child: Text(option.label),
            ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelLabel ?? l10n.actionCancel),
          ),
        ],
      ),
    ),
  );
}

/// Une boîte de dialogue qui DEMANDE UN TEXTE — renommer un groupe,
/// saisir le mot de passe d'une sauvegarde.
///
/// Renvoie la saisie, ou `null` si l'utilisateur a annulé. La touche
/// « entrée » du clavier valide, comme sur iOS : taper son texte puis
/// chercher un bouton du doigt est un aller-retour inutile.
Future<String?> ouroPrompt(
  BuildContext context, {
  required String title,
  String? message,
  String initialValue = '',
  String placeholder = '',
  String? confirmLabel,
  String? cancelLabel,
  bool obscure = false,
  int? maxLength,
}) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialValue);
  OuroHaptics.light();

  if (isNativeGlassAvailable) {
    // Sur iOS 26+, on utilise un UITextField natif dans un alert controller
    // Pour l'instant, fallback sur CupertinoAlertDialog pour le prompt
    // car LiquidGlassAlert ne supporte pas les champs de saisie
  }

  return showDialog<String>(
    context: context,
    builder: (context) => _themed(
      CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message != null) ...[
                Text(message),
                const SizedBox(height: 12),
              ],
              CupertinoTextField(
                controller: controller,
                autofocus: true,
                obscureText: obscure,
                maxLength: maxLength,
                placeholder: placeholder.isEmpty ? null : placeholder,
                onSubmitted: (value) => Navigator.of(context).pop(value),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelLabel ?? l10n.actionCancel),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text((confirmLabel ?? l10n.actionSave)),
          ),
        ],
      ),
    ),
  );
}

class OuroChoiceOption<T> {
  const OuroChoiceOption({
    required this.label,
    required this.value,
    this.destructive = false,
  });

  final String label;
  final T value;
  final bool destructive;
}

/// Impose au dialogue la luminosité choisie par l'utilisateur — voir
/// l'explication en tête de fichier.
Widget _themed(Widget child) => CupertinoTheme(
      data: CupertinoThemeData(brightness: OuroColors.brightness),
      child: child,
    );
