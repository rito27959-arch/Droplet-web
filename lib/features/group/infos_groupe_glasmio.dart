// ============================================================================
// LES INFOS D'UN GROUPE EN GLASMIO (Android 13+). Mêmes données que
// `VueInfosGroupe` et mêmes actions que `GroupInfoScreen` (l'écran de repli,
// dont les méthodes sont réutilisées telles quelles) : photo, nom, membres,
// appeler, ajouter, inviter, médias, description, messages importants,
// notifications, chiffrement, paramètres, demandes d'adhésion, membres,
// quitter le groupe.
//
// Ce qui demande Flutter (choix de photo, saisie, invitation QR, médias,
// paramètres, feuille d'un membre) s'ouvre par-dessus l'écran Flutter
// d'origine, puis l'écran natif revient.
// ============================================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/mesh_provider.dart';
import '../../core/services/nom_pair.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/reglages_notifs.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../notifications/notifs_conversation_screen.dart';
import 'group_info_screen.dart';
import 'invitation_groupe_screen.dart';
import 'parametres_groupe_screen.dart';
import 'reglages_groupe.dart';

class PasserelleInfosGroupe extends ConsumerStatefulWidget {
  const PasserelleInfosGroupe({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<PasserelleInfosGroupe> createState() => _PasserelleInfosGroupeState();
}

class _PasserelleInfosGroupeState extends EtatPasserelleGlasmio<PasserelleInfosGroupe> {
  final List<ProviderSubscription<Object?>> _ecoutes = [];
  late final GroupInfoScreen _ecranFlutter = GroupInfoScreen(groupId: widget.groupId);

  String get _id => widget.groupId;

  @override
  String get ecran => 'infos_groupe';

  @override
  bool get natifPossible => ref.read(groupInfoProvider(_id)) != null;

  @override
  Widget construireRepli(BuildContext context) => _ecranFlutter;

  void _maj() => rafraichir();

  @override
  void surOuvert() {
    surFerme();
    _ecoutes
      ..add(ref.listenManual(groupInfoProvider(_id), (_, __) => rafraichir()))
      ..add(ref.listenManual(meshPeerListProvider, (_, __) => rafraichir()));
    ReglagesGroupes.revision.addListener(_maj);
    DemandesAdhesion.revision.addListener(_maj);
    ReglagesNotifs.revision.addListener(_maj);
  }

  @override
  void surFerme() {
    for (final e in _ecoutes) {
      e.close();
    }
    _ecoutes.clear();
    ReglagesGroupes.revision.removeListener(_maj);
    DemandesAdhesion.revision.removeListener(_maj);
    ReglagesNotifs.revision.removeListener(_maj);
  }

  String _nom(String peerId) {
    final moi = ref.read(meshRepositoryProvider).myId;
    for (final p in ref.read(meshPeerListProvider)) {
      if (p.peerId == peerId) return p.pseudo;
    }
    if (peerId == moi) return StorageService.currentUser?.pseudo ?? textes.vgYou;
    return nomDuPair(peerId, [StorageService.getPeerRecord(peerId)?.pseudo]);
  }

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final t = textes;
    final g = ref.read(groupInfoProvider(_id));
    if (g == null) return const ReponseGlasmio.fermer();
    final moi = ref.read(meshRepositoryProvider).myId;
    final reglages = ReglagesGroupes.de(_id);
    final infos = reglages.peutModifierInfos(g, moi);
    final ajout = reglages.peutAjouter(g, moi);
    final e = _ecranFlutter;
    ReponseGlasmio refus() => ReponseGlasmio.alerte({'titre': t.vgOnlyAdminsEdit, 'annuler': MaterialLocalizations.of(context).okButtonLabel, 'choix': <Object>[]});

    switch (id) {
      case 'photo':
        if (!infos) return refus();
        return feuille((c) => e.changerPhoto(c, ref, g));
      case 'nom':
        if (!infos) return refus();
        return feuille((c) => e.renommer(c, ref, g.name));
      case 'description':
        if (!infos) return refus();
        return feuille((c) => e.modifierDescription(c, ref, reglages));
      case 'appeler':
        return feuille((c) => e.appelerGroupe(c, ref, g, moi, _nom));
      case 'ajouter':
        if (!ajout) return refus();
        return feuille((c) => e.ajouterMembre(c, ref, g));
      case 'inviter':
        if (!ajout) return refus();
        return feuille((c) => ouvrirCodeGroupe(c, groupId: _id, nom: g.name, moi: moi));
      case 'medias':
        return feuille((c) => e.ouvrirStockage(c, g));
      case 'importants':
        return allerA('/starred');
      case 'notifications':
        return pousser(MaterialPageRoute<void>(
          builder: (_) => NotifsConversationScreen(conversationId: _id, nom: g.name, groupe: true),
        ));
      case 'parametres':
        return pousser(CupertinoPageRoute<void>(builder: (_) => ParametresGroupeScreen(groupId: _id)));
      case 'quitter':
        return feuille((c) => e.quitterGroupe(c, ref));
      default:
        if (id.startsWith('membre:')) {
          final peerId = id.substring(7);
          final m = g.activeMembers.where((x) => x.peerId == peerId).firstOrNull;
          if (m == null || peerId == moi) break;
          return feuille((c) => e.ficheMembre(c, ref, g, moi, m, _nom(peerId)));
        }
        if (id.startsWith('demande:')) {
          final peerId = id.substring(8);
          return ReponseGlasmio.alerte({
            'titre': _nom(peerId),
            'message': t.vgRequests,
            'annuler': t.actionCancel,
            'choix': [
              {'id': 'accepter:$peerId', 'titre': t.vgAccept},
              {'id': 'refuser:$peerId', 'titre': t.vgDecline, 'destructif': true},
            ],
          });
        }
        if (id.startsWith('accepter:')) {
          try {
            await ref.read(meshRepositoryProvider).addGroupMember(groupId: _id, peerId: id.substring(9));
          } catch (_) {}
        } else if (id.startsWith('refuser:')) {
          ref.read(meshRepositoryProvider).refuserDemandeAdhesion(groupId: _id, peerId: id.substring(8));
        }
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  static int _c(Color c) => c.toARGB32();

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final g = ref.read(groupInfoProvider(_id));
    if (g == null) return const {};
    final moi = ref.read(meshRepositoryProvider).myId;
    final reglages = ReglagesGroupes.de(_id);
    final infos = reglages.peutModifierInfos(g, moi);
    final ajout = reglages.peutAjouter(g, moi);
    final enLigne = {for (final p in ref.read(meshPeerListProvider)) p.peerId};
    final membres = [...g.activeMembers]
      ..sort((a, b) {
        if (a.peerId == moi) return -1;
        if (b.peerId == moi) return 1;
        if (a.isAdmin != b.isAdmin) return a.isAdmin ? -1 : 1;
        return _nom(a.peerId).toLowerCase().compareTo(_nom(b.peerId).toLowerCase());
      });
    final langue = Localizations.localeOf(context).toLanguageTag();
    final createur = g.createdBy == moi ? t.vgYou : _nom(g.createdBy);
    final demandes = DemandesAdhesion.pour(_id);
    final r = ReglagesNotifs.pour(_id);
    final etatNotifs = r.enSourdine(DateTime.now())
        ? (r.sourdineJusqua != null ? libelleFinSourdine(t, langue, r.sourdineJusqua!) : t.ncStateMuted)
        : r.discret
            ? t.ncStateQuiet
            : r.mentionsSeulement
                ? t.ncStateMentions
                : t.ncStateOn;
    final nbMedias = ref.read(groupMessagesProvider(_id)).where((m) => m.type == 'file').length;

    Map<String, Object?> ligne(String id, String type, String icone, Color teinte, String titre, {String? sous, String? valeur, bool destructif = false}) => {
          'id': id,
          'type': type,
          'icone': icone,
          'teinte': _c(teinte),
          'titre': titre,
          'sous': ?sous,
          'valeur': ?valeur,
          'destructif': destructif,
        };

    return {
      'titre': t.giGroupInfo,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': _c(OuroColors.accent),
      'entete': {
        if (infos) 'idPhoto': 'photo',
        'nom': g.name,
        'statut': '${t.vgGroup} · ${t.giMemberCount(membres.length)}',
        'photo': g.avatarUrl,
        'initiale': g.name.characters.isEmpty ? '?' : g.name.characters.first.toUpperCase(),
        'couleur': NotificationService.couleurAvatar(g.name),
        'actions': [
          {'id': 'appeler', 'icone': 'call', 'titre': t.vgCall},
          if (ajout) {'id': 'ajouter', 'icone': 'person_add', 'titre': t.vgAdd},
          if (ajout) {'id': 'inviter', 'icone': 'qr_code', 'titre': t.vgInvite},
          {'id': 'medias', 'icone': 'photo_library', 'titre': t.vgMedia},
        ],
      },
      'sections': [
        {
          'pied': t.vgCreatedBy(createur, DateFormat.yMMMMd(langue).format(g.createdAt)),
          'lignes': [
            if (infos) ligne('nom', 'nav', 'edit', OuroColors.systemGray, g.name),
            {
              'id': 'description',
              'type': 'paragraphe',
              'cliquable': infos,
              'titre': '',
              'sous': reglages.description.isEmpty ? (infos ? t.giDescriptionAdd : t.giDescriptionNone) : reglages.description,
            },
          ],
        },
        {
          'lignes': [
            ligne('medias', 'nav', 'photo_library', OuroColors.systemIndigo, t.vgMediaLinksDocs, valeur: nbMedias == 0 ? null : '$nbMedias'),
            ligne('importants', 'nav', 'star', OuroColors.systemOrange, t.imTitle),
          ],
        },
        {
          'lignes': [
            ligne('notifications', 'nav', 'notifications', OuroColors.systemRed, t.ncTitle, valeur: etatNotifs),
            ligne('chiffrement', 'info', 'lock', OuroColors.systemGray, t.vgEncryption, sous: t.vgEncryptionBody),
            ligne('parametres', 'nav', 'settings_applications', OuroColors.systemGray, t.vgSettings),
          ],
        },
        if (demandes.isNotEmpty)
          {
            'entete': t.vgRequests,
            'lignes': [
              for (final d in demandes) ligne('demande:${d.peerId}', 'nav', 'person_add', OuroColors.accent, _nom(d.peerId)),
            ],
          },
        {
          'entete': t.giMemberCount(membres.length),
          'lignes': [
            if (ajout) ligne('ajouter', 'nav', 'person_add', OuroColors.accent, t.vgAddMembers),
            if (ajout) ligne('inviter', 'nav', 'qr_code', OuroColors.accent, t.vgInviteQr),
            for (final m in membres)
              {
                'id': 'membre:${m.peerId}',
                'type': m.peerId == moi ? 'info' : 'nav',
                'icone': 'lettre:${_nom(m.peerId).characters.isEmpty ? '?' : _nom(m.peerId).characters.first.toUpperCase()}',
                'teinte': NotificationService.couleurAvatar(_nom(m.peerId)),
                'titre': m.peerId == moi ? t.vgYou : _nom(m.peerId),
                if (m.peerId != moi && enLigne.contains(m.peerId)) 'sous': t.vgOnline,
                if (m.isAdmin) 'valeur': t.vgAdmin,
              },
          ],
        },
        {
          'lignes': [
            {'id': 'quitter', 'type': 'bouton', 'titre': t.giLeaveGroup, 'destructif': true},
          ],
        },
      ],
    };
  }
}
