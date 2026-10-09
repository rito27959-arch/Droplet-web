// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA FEUILLE QUI EXPLIQUE COMMENT UN MESSAGE EST PARTI.
//
// On l'ouvre en touchant l'heure d'un message. C'est l'endroit où Droplet
// dit ce qu'aucune autre messagerie ne peut dire : non pas seulement
// « envoyé », mais PAR OÙ.
//
// ── ⚠️ TOUT CE QUI EST AFFICHÉ ICI EST UNE DONNÉE RÉELLE ──────────────
//
// C'est la contrainte la plus importante de ce fichier, et elle a
// restreint ce qu'il montre.
//
// Il aurait été facile — et joli — de dessiner un chemin nommé :
//
//     Moi ↓ Pair A ↓ Pair B ↓ Michel
//
// Le modèle porte bien un champ `routeInfo` prévu pour ça, et la base de
// données a la colonne. Mais AUCUN code ne le remplit : seul le code
// généré par Drift le mentionne. Dessiner ce chemin reviendrait donc à
// inventer les noms des relais — c'est-à-dire à fabriquer une preuve
// technique fausse, dans une application dont l'argument principal est
// précisément qu'on peut lui faire confiance sur la transmission.
//
// Cette feuille montre donc ce que le système sait vraiment :
//
//   • `status` + `readAt` + `deliveryCount` → où en est le message ;
//   • `hopCount` → combien d'appareils il a traversés ;
//   • l'heure d'envoi et l'heure de lecture → le délai réel.
//
// Il n'y a délibérément AUCUNE ligne « chiffré / non chiffré ». Le
// chiffrement existe bel et bien — mais il vit dans l'enveloppe réseau
// (`e` et `n`, voir `resolveIncomingContent`), et n'est PAS conservé
// dans le message enregistré. Afficher un cadenas ici reviendrait donc à
// affirmer, sans preuve, quelque chose que le système ne sait plus. Sur
// une application dont le chiffrement est un argument central, une
// affirmation de sécurité non vérifiée est la pire chose à écrire.
//
// Le jour où la couche mesh enregistrera le chemin dans `routeInfo`, le
// bloc « Chemin » viendra ici sans rien changer d'autre.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/mesh_message.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/repositories/mesh_repository.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Ouvre la feuille de transmission pour [message].
Future<void> showTransmissionSheet(
  BuildContext context,
  MeshMessage message, {
  required bool mine,
}) {
  OuroHaptics.selection();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _TransmissionSheet(message: message, mine: mine),
  );
}

class _TransmissionSheet extends StatelessWidget {
  const _TransmissionSheet({required this.message, required this.mine});

  final MeshMessage message;
  final bool mine;

  /// L'état, en une phrase compréhensible sans rien connaître au mesh.
  ///
  /// Le brief est explicite : un utilisateur normal doit comprendre. Les
  /// mots « ACK », « saut » et « TTL » n'apparaissent donc nulle part.
  (String, IconData, Color) _etat(AppLocalizations l10n) {
    if (message.status == MessageStatus.failed) {
      return (l10n.tsNotDelivered, Icons.error_outline_rounded,
          OuroColors.errorRed);
    }
    if (message.readAt != null) {
      return (l10n.tsRead, Icons.done_all_rounded, OuroColors.meshBlueBright);
    }
    if (message.deliveryCount > 0) {
      return (l10n.tsDelivered, Icons.done_all_rounded, OuroColors.successGreen);
    }
    return switch (message.status) {
      MessageStatus.sending => (l10n.tsSendingInProgress, Icons.schedule_rounded,
          OuroColors.textSecondary),
      MessageStatus.pending => (l10n.tsWaitingForRelay,
          Icons.schedule_rounded, OuroColors.textSecondary),
      _ => (l10n.tsSent, Icons.done_rounded, OuroColors.textSecondary),
    };
  }

  /// « Vu par » : le détail, membre par membre, d'un message de groupe.
  List<Widget> _lignesGroupe(BuildContext context, AppLocalizations l10n) {
    final groupe = StorageService.getGroup(message.groupId!);
    if (groupe == null) return const [];
    final repo = ProviderScope.containerOf(context, listen: false).read(meshRepositoryProvider);
    String nom(String id) =>
        StorageService.getPeerRecord(id)?.pseudo ?? (id.length > 8 ? id.substring(0, 8) : id);
    final membres = groupe.activeMembers
        .map((m) => m.peerId)
        .where((id) => id != message.senderId)
        .toList();
    final lus = repo.lecteursGroupe(message.id);
    final recus = repo.recepteursGroupe(message.id).difference(lus);
    final enAttente = membres.where((id) => !lus.contains(id) && !recus.contains(id)).toList();
    return [
      if (lus.isNotEmpty)
        _Ligne(
          icone: Icons.done_all_rounded,
          couleur: OuroColors.meshBlueBright,
          titre: l10n.tsReadBy,
          valeur: lus.map(nom).join(', '),
        ),
      if (recus.isNotEmpty)
        _Ligne(
          icone: Icons.done_all_rounded,
          couleur: OuroColors.systemGray,
          titre: l10n.tsDeliveredTo,
          valeur: recus.map(nom).join(', '),
        ),
      if (enAttente.isNotEmpty)
        _Ligne(
          icone: Icons.schedule_rounded,
          couleur: OuroColors.systemGray,
          titre: l10n.tsWaitingFor,
          valeur: enAttente.map(nom).join(', '),
        ),
    ];
  }

  /// Le temps écoulé entre l'envoi et la lecture.
  ///
  /// Renvoie `null` tant que le message n'a pas été lu : il n'existe
  /// aucun horodatage de simple réception dans le modèle, et en inventer
  /// un à partir de `deliveryCount` donnerait un chiffre faux.
  String? _delai(AppLocalizations l10n) {
    final lu = message.readAt;
    if (lu == null) return null;
    final d = lu.difference(message.timestamp);
    if (d.isNegative) return null;
    if (d.inSeconds < 60) {
      final valeur = (d.inMilliseconds / 1000).toStringAsFixed(1);
      return d.inSeconds > 1
          ? l10n.tsSecondsPlural(valeur)
          : l10n.tsSecondsSingular(valeur);
    }
    if (d.inMinutes < 60) return l10n.tsMinutes(d.inMinutes);
    if (d.inHours < 24) return l10n.tsHours(d.inHours);
    return l10n.tsDays(d.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (libelle, icone, couleur) = _etat(l10n);
    final delai = _delai(l10n);
    // ⚠️ LE CALCUL DES SAUTS, ET POURQUOI IL NE VAUT QUE POUR LES
    // MESSAGES REÇUS.
    //
    // `hopCount` n'est PAS le nombre de relais traversés : c'est le
    // nombre de relais qu'il RESTE au message avant qu'on cesse de le
    // faire suivre. Il part de `kDefaultHopCount` (5) et perd un point à
    // chaque appareil traversé (voir `_relayNow`).
    //
    // Sur un message REÇU, la soustraction donne donc le trajet réel :
    // arrivé avec 3 points restants, il a franchi deux appareils.
    //
    // Sur un message ENVOYÉ, la valeur stockée est toujours 5 — celle du
    // départ. Elle ne dit rien du trajet, parce que rien ne revient nous
    // le raconter : l'accusé de réception ne transporte pas le chemin.
    // Une version précédente affichait ce 5 comme « relayé par 5
    // appareils » sur chacun de nos propres messages. C'était faux à tous
    // les coups.
    final sauts = mine ? null : (MeshRepository.kDefaultHopCount - message.hopCount);

    // ⚠️ UN CONTACT TOR-ONLY N'EST JAMAIS PASSÉ PAR LE MAILLAGE LOCAL —
    // AUCUN DE SES MESSAGES NE LE POURRAIT. Ce n'est pas une estimation
    // au cas par cas : c'est une conséquence directe de la seule façon
    // dont ce pair est joignable (voir `isTorOnlyPeer`), donc vraie pour
    // chaque message de cette conversation, y compris les plus anciens.
    // Continuer à afficher un nombre de sauts ou « Réseau maillé
    // Droplet, pas de serveur » pour ces messages-là serait exactement
    // le genre d'affirmation non vérifiée que ce fichier s'interdit
    // ailleurs.
    final autrePersonneId = mine ? message.targetId : message.senderId;
    final viaTor = autrePersonneId != null &&
        isTorOnlyPeer(StorageService.getPeerRecord(autrePersonneId));

    return FrostedSheet(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tsTitle,
              style: OuroTypography.title3.copyWith(color: OuroColors.label),
            ),
            const SizedBox(height: DesignTokens.space4),

            _Ligne(
              icone: icone,
              couleur: couleur,
              titre: l10n.tsStatus,
              valeur: libelle,
            ),

            // Dans un groupe : QUI a lu, qui a seulement reçu, qui attend.
            if (mine && message.groupId != null) ..._lignesGroupe(context, l10n),

            if (delai != null)
              _Ligne(
                icone: Icons.timer_outlined,
                couleur: OuroColors.systemGray,
                titre: l10n.tsDelayUntilRead,
                valeur: delai,
              ),

            // ── LE CHEMIN NOMMÉ ─────────────────────────────────
            //
            // Ce que cette feuille ne pouvait pas montrer jusqu'ici : par
            // QUELS appareils le message est passé. Chaque relais signe
            // désormais son passage dans l'enveloppe (`_signerLePassage`),
            // et le destinataire reçoit le trajet complet.
            //
            // C'est la seule chose qu'aucune autre messagerie ne peut
            // afficher — parce qu'aucune autre ne fait transiter les
            // messages par les téléphones de ses utilisateurs.
            if (viaTor)
              // Le seul cas où « Chemin » ne parle ni de sauts, ni de
              // relais mesh nommés : rien de tout ça ne s'applique.
              _Ligne(
                icone: Icons.shield_rounded,
                couleur: OuroColors.systemGreen,
                titre: l10n.tsPath,
                valeur: l10n.chViaTor,
                detail: l10n.tsPathTorDetail,
              )
            else if (message.routeInfo != null && message.routeInfo!.isNotEmpty)
              _Ligne(
                icone: Icons.route_rounded,
                couleur: OuroColors.systemPurple,
                titre: l10n.tsRoute,
                valeur: message.routeInfo!,
                detail: l10n.tsRouteDetail,
              )
            else if (sauts != null)
              _Ligne(
                icone: sauts > 0
                    ? Icons.alt_route_rounded
                    : Icons.arrow_forward_rounded,
                couleur: sauts > 0
                    ? OuroColors.systemPurple
                    : OuroColors.systemGreen,
                titre: l10n.tsPath,
                valeur: sauts > 0
                    ? l10n.tsPassedThroughDevices(sauts)
                    : l10n.tsReceivedDirect,
                // ⚠️ La phrase qui justifie toute l'application. Un
                // relais n'est pas une dégradation : c'est ce qui permet
                // au message d'arriver là où aucun réseau ne va.
                detail: sauts > 0
                    ? l10n.tsIntermediateDevicesDetail
                    : null,
              )
            else
              // Pour nos propres messages, on dit qu'on ne sait pas —
              // plutôt que de meubler avec un chiffre inventé.
              _Ligne(
                icone: Icons.help_outline_rounded,
                couleur: OuroColors.systemGray,
                titre: l10n.tsPath,
                valeur: l10n.tsUnknown,
                detail: l10n.tsSentRouteNotReturned,
              ),

            _Ligne(
              icone: viaTor ? Icons.shield_rounded : Icons.wifi_tethering_rounded,
              couleur: viaTor ? OuroColors.systemGreen : OuroColors.accent,
              titre: l10n.tsNetwork,
              valeur: viaTor ? l10n.chViaTor : l10n.tsMeshDroplet,
              detail: viaTor ? l10n.tsNetworkTorDetail : l10n.tsNoServerNoOperator,
            ),

            const SizedBox(height: DesignTokens.space2),
          ],
        ),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne({
    required this.icone,
    required this.couleur,
    required this.titre,
    required this.valeur,
    this.detail,
  });

  final IconData icone;
  final Color couleur;
  final String titre;
  final String valeur;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$titre : $valeur${detail != null ? '. $detail' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: DesignTokens.space4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 19, color: couleur),
            const SizedBox(width: DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titre,
                    style: OuroTypography.caption1.copyWith(
                      color: OuroColors.tertiaryLabel,
                    ),
                  ),
                  Text(
                    valeur,
                    style: OuroTypography.body.copyWith(
                      color: OuroColors.label,
                    ),
                  ),
                  if (detail != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        detail!,
                        style: OuroTypography.footnote.copyWith(
                          color: OuroColors.secondaryLabel,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
