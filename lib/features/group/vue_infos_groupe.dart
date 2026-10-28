// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE DESSIN DE L'ÉCRAN « INFOS DU GROUPE » — sans aucune logique : il reçoit
// tout ce qu'il affiche et rend la main pour chaque geste. C'est ce qui
// permet de le rendre dans les tests, avec un faux groupe.
//
// ── La composition, celle de WhatsApp sur iPhone ──────────────────────
//
//   • L'EN-TÊTE, sans carte : la grande photo, le nom en titre, « Groupe ·
//     6 membres ». Toucher la photo ou le nom les modifie (si on en a le
//     droit — le petit appareil photo et le crayon ne s'affichent que
//     dans ce cas).
//   • QUATRE TUILES D'ACTION : Appel, Ajouter, Inviter, Médias — les gestes
//     qu'on vient faire ici neuf fois sur dix, à portée immédiate.
//   • LA DESCRIPTION, puis des listes groupées comme les Réglages d'iOS,
//     chaque ligne avec son icône de couleur : médias, messages
//     importants ; notifications, chiffrement ; paramètres du groupe et
//     demandes en attente.
//   • LES MEMBRES : « Ajouter des membres » et « Inviter avec un code QR »
//     en tête, en bleu ; puis chacun, avec « Vous » pour soi, « en ligne »,
//     et une pastille « Admin ». Au-delà de huit, une recherche.
//   • TOUT EN BAS, en rouge : quitter le groupe. Et la date de création.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/mesh_message.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_pressable.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/peer_avatar.dart';
import 'reglages_groupe.dart';

/// Ce que l'écran affiche.
class DonneesInfosGroupe {
  const DonneesInfosGroupe({
    required this.groupe,
    required this.moi,
    required this.reglages,
    required this.nom,
    required this.enLigne,
    required this.photoMembre,
    this.demandes = const [],
    this.nbMedias,
    this.nbImportants,
  });

  final GroupInfo groupe;
  final String moi;
  final ReglagesGroupe reglages;
  final String Function(String peerId) nom;
  final bool Function(String peerId) enLigne;
  final String? Function(String peerId) photoMembre;
  final List<DemandeAdhesion> demandes;
  final int? nbMedias;
  final int? nbImportants;
}

/// Ce que l'écran demande de faire.
class ActionsInfosGroupe {
  const ActionsInfosGroupe({
    required this.changerPhoto,
    required this.renommer,
    required this.modifierDescription,
    required this.appeler,
    required this.ajouter,
    required this.inviter,
    required this.medias,
    required this.importants,
    required this.parametres,
    required this.membre,
    required this.accepterDemande,
    required this.refuserDemande,
    required this.quitter,
  });

  final VoidCallback changerPhoto;
  final VoidCallback renommer;
  final VoidCallback modifierDescription;
  final VoidCallback appeler;
  final VoidCallback ajouter;
  final VoidCallback inviter;
  final VoidCallback medias;
  final VoidCallback importants;
  final VoidCallback parametres;
  final void Function(GroupMemberRecord membre) membre;
  final void Function(DemandeAdhesion d) accepterDemande;
  final void Function(DemandeAdhesion d) refuserDemande;
  final VoidCallback quitter;
}

class VueInfosGroupe extends StatelessWidget {
  const VueInfosGroupe({super.key, required this.donnees, required this.actions, required this.ligneNotifs, this.retour});

  final DonneesInfosGroupe donnees;
  final ActionsInfosGroupe actions;

  /// La ligne « Notifications » (elle vit ailleurs, avec son propre état).
  final Widget ligneNotifs;

  /// Le bouton retour de la barre du haut.
  final Widget? retour;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = donnees;
    final g = d.groupe;
    final moi = d.moi;
    final infos = d.reglages.peutModifierInfos(g, moi);
    final ajout = d.reglages.peutAjouter(g, moi);
    final admin = g.isAdmin(moi);
    final membres = g.activeMembers
      ..sort((a, b) {
        // Moi d'abord, puis les admins, puis l'ordre alphabétique — comme
        // WhatsApp.
        if (a.peerId == moi) return -1;
        if (b.peerId == moi) return 1;
        if (a.isAdmin != b.isAdmin) return a.isAdmin ? -1 : 1;
        return d.nom(a.peerId).toLowerCase().compareTo(d.nom(b.peerId).toLowerCase());
      });
    final langue = Localizations.localeOf(context).toLanguageTag();
    final dateCreation = DateFormat.yMMMMd(langue).format(g.createdAt);
    final createur = g.createdBy == moi ? l10n.vgYou : d.nom(g.createdBy);

    return Scaffold(
      backgroundColor: OuroColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: OuroColors.systemGroupedBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: retour,
            centerTitle: true,
            title: Text(l10n.giGroupInfo, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: OuroColors.label)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
            sliver: SliverList.list(
              children: [
                // ── L'en-tête.
                Center(
                  child: OuroPressable(
                    onTap: infos ? actions.changerPhoto : null,
                    semantique: l10n.giPhotoChanged,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        PeerAvatar(pseudo: g.name, radius: 54, imagePath: g.avatarUrl),
                        if (infos)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: OuroColors.accentRempli,
                                shape: BoxShape.circle,
                                border: Border.all(color: OuroColors.systemGroupedBackground, width: 3),
                              ),
                              child: Icon(CupertinoIcons.camera_fill, size: 14, color: OuroColors.texteSurAccent),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: infos ? actions.renommer : null,
                  child: Text(
                    g.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Inter Tight', fontSize: 26, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: OuroColors.label),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.vgGroup} · ${l10n.giMemberCount(membres.length)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: OuroColors.secondaryLabel),
                ),
                const SizedBox(height: 18),

                // ── Les quatre tuiles d'action.
                Row(
                  children: [
                    _Tuile(icone: CupertinoIcons.phone_fill, libelle: l10n.vgCall, onTap: actions.appeler),
                    const SizedBox(width: 8),
                    _Tuile(icone: CupertinoIcons.person_add_solid, libelle: l10n.vgAdd, onTap: ajout ? actions.ajouter : null),
                    const SizedBox(width: 8),
                    _Tuile(icone: CupertinoIcons.qrcode, libelle: l10n.vgInvite, onTap: ajout ? actions.inviter : null),
                    const SizedBox(width: 8),
                    _Tuile(icone: CupertinoIcons.photo_on_rectangle, libelle: l10n.vgMedia, onTap: actions.medias),
                  ],
                ),
                const SizedBox(height: 22),

                // ── La description.
                _Carte(
                  onTap: infos ? actions.modifierDescription : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.reglages.description.isEmpty ? (infos ? l10n.giDescriptionAdd : l10n.giDescriptionNone) : d.reglages.description,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.35,
                          color: d.reglages.description.isEmpty ? (infos ? OuroColors.accent : OuroColors.tertiaryLabel) : OuroColors.label,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(l10n.vgCreatedBy(createur, dateCreation), style: TextStyle(fontSize: 13, color: OuroColors.secondaryLabel)),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                OuroListSection(
                  children: [
                    OuroListRow(
                      title: l10n.vgMediaLinksDocs,
                      icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                      iconColor: const Color(0xFF0A84FF),
                      value: d.nbMedias == null || d.nbMedias == 0 ? null : '${d.nbMedias}',
                      onTap: actions.medias,
                    ),
                    OuroListRow(
                      title: l10n.imTitle,
                      icon: CupertinoIcons.star_fill,
                      iconColor: OuroColors.systemYellow,
                      value: d.nbImportants == null || d.nbImportants == 0 ? null : '${d.nbImportants}',
                      onTap: actions.importants,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                ligneNotifs,
                const SizedBox(height: 10),
                OuroListSection(
                  children: [
                    OuroListRow(
                      title: l10n.vgEncryption,
                      subtitle: l10n.vgEncryptionBody,
                      icon: CupertinoIcons.lock_fill,
                      iconColor: OuroColors.systemGreen,
                    ),
                    OuroListRow(
                      title: l10n.vgSettings,
                      icon: CupertinoIcons.gear_solid,
                      iconColor: OuroColors.systemGray,
                      onTap: actions.parametres,
                    ),
                  ],
                ),

                // ── Les demandes d'adhésion en attente (admins).
                if (admin && d.demandes.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  OuroListSection(
                    header: l10n.vgRequests,
                    children: [
                      for (final dem in d.demandes)
                        OuroListRow(
                          title: d.nom(dem.peerId),
                          subtitle: DateFormat.MMMd(langue).add_Hm().format(dem.quand),
                          leading: PeerAvatar(pseudo: d.nom(dem.peerId), radius: 18, imagePath: d.photoMembre(dem.peerId)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PetitBouton(libelle: l10n.vgDecline, plein: false, onTap: () => actions.refuserDemande(dem)),
                              const SizedBox(width: 6),
                              _PetitBouton(libelle: l10n.vgAccept, plein: true, onTap: () => actions.accepterDemande(dem)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],

                // ── Les membres.
                const SizedBox(height: 8),
                _ListeMembres(donnees: d, membres: membres, ajout: ajout, actions: actions),

                const SizedBox(height: 22),
                OuroListSection(
                  children: [
                    OuroListRow(
                      title: l10n.giLeaveGroup,
                      icon: CupertinoIcons.square_arrow_right,
                      iconColor: OuroColors.systemRed,
                      isDestructive: true,
                      showChevron: false,
                      onTap: actions.quitter,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tuile extends StatelessWidget {
  const _Tuile({required this.icone, required this.libelle, required this.onTap});
  final IconData icone;
  final String libelle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final actif = onTap != null;
    return Expanded(
      child: OuroPressable(
        onTap: onTap == null
            ? null
            : () {
                OuroHaptics.selection();
                onTap!();
              },
        semantique: libelle,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: actif ? 1 : 0.4,
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, size: 22, color: OuroColors.accent),
                const SizedBox(height: 5),
                Text(
                  libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: OuroColors.accent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Carte extends StatelessWidget {
  const _Carte({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground,
          borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
        ),
        child: child,
      ),
    );
  }
}

class _PetitBouton extends StatelessWidget {
  const _PetitBouton({required this.libelle, required this.plein, required this.onTap});
  final String libelle;
  final bool plein;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OuroPressable(
      onTap: onTap,
      semantique: libelle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: plein ? OuroColors.accentRempli : OuroColors.tertiarySystemFill,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          libelle,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: plein ? OuroColors.texteSurAccent : OuroColors.label),
        ),
      ),
    );
  }
}

/// La liste des membres, avec recherche au-delà de huit.
class _ListeMembres extends StatefulWidget {
  const _ListeMembres({required this.donnees, required this.membres, required this.ajout, required this.actions});

  final DonneesInfosGroupe donnees;
  final List<GroupMemberRecord> membres;
  final bool ajout;
  final ActionsInfosGroupe actions;

  @override
  State<_ListeMembres> createState() => _ListeMembresState();
}

class _ListeMembresState extends State<_ListeMembres> {
  String _requete = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = widget.donnees;
    final filtres = _requete.isEmpty
        ? widget.membres
        : [
            for (final m in widget.membres)
              if (d.nom(m.peerId).toLowerCase().contains(_requete)) m,
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.giMemberCount(widget.membres.length).toUpperCase(),
            style: TextStyle(fontSize: 13, letterSpacing: 0.4, color: OuroColors.secondaryLabel),
          ),
        ),
        if (widget.membres.length > 8)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: CupertinoSearchTextField(
              placeholder: l10n.giSearchMembers,
              onChanged: (v) => setState(() => _requete = v.trim().toLowerCase()),
            ),
          ),
        OuroListSection(
          separatorInset: 68,
          children: [
            if (widget.ajout && _requete.isEmpty) ...[
              _LigneAction(icone: CupertinoIcons.person_add, libelle: l10n.vgAddMembers, onTap: widget.actions.ajouter),
              _LigneAction(icone: CupertinoIcons.qrcode, libelle: l10n.vgInviteQr, onTap: widget.actions.inviter),
            ],
            for (final m in filtres) _LigneMembre(donnees: d, membre: m, onTap: m.peerId == d.moi ? null : () => widget.actions.membre(m)),
          ],
        ),
      ],
    );
  }
}

class _LigneAction extends StatelessWidget {
  const _LigneAction({required this.icone, required this.libelle, required this.onTap});
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OuroListRow(
      title: libelle,
      showChevron: false,
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: OuroColors.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
        child: Icon(icone, size: 20, color: OuroColors.accent),
      ),
      trailing: const SizedBox.shrink(),
    );
  }
}

class _LigneMembre extends StatelessWidget {
  const _LigneMembre({required this.donnees, required this.membre, required this.onTap});
  final DonneesInfosGroupe donnees;
  final GroupMemberRecord membre;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final d = donnees;
    final estMoi = membre.peerId == d.moi;
    final nom = estMoi ? l10n.vgYou : d.nom(membre.peerId);
    final enLigne = !estMoi && d.enLigne(membre.peerId);
    return OuroListRow(
      title: nom,
      subtitle: enLigne ? l10n.vgOnline : null,
      showChevron: false,
      onTap: onTap,
      leading: PeerAvatar(pseudo: estMoi ? d.nom(d.moi) : nom, radius: 20, online: enLigne, imagePath: d.photoMembre(membre.peerId)),
      trailing: membre.isAdmin
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: OuroColors.tertiarySystemFill, borderRadius: BorderRadius.circular(8)),
              child: Text(l10n.vgAdmin, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: OuroColors.secondaryLabel)),
            )
          : const SizedBox.shrink(),
    );
  }
}
