// ============================================================================
// LES INFOS DU CONTACT EN GLASMIO (Android 13+) — la passerelle Dart.
// ----------------------------------------------------------------------------
// La route `/chat/:peerId/info` passe par ici : sur Android 13+ avec la couche
// Glasmio, l'écran est natif (photo en grand, nom, statut, boutons Message /
// Appeler / Sécurité, réglages de la conversation, statistiques, photos,
// notes vocales, fichiers, liens, bloquer, signaler) ; sinon c'est
// `ChatInfoScreen`, inchangé.
//
// ⚠️ PARITÉ AVEC `ChatInfoScreen`. Mêmes données, mêmes actions, mêmes
// services. Ce qui demande Flutter (biométrie du verrou, visionneuse de
// photo, choix du fond, minuteur, notifications, navigateur) s'ouvre côté
// Flutter, puis l'écran natif revient. Le canal de diffusion garde l'écran
// Flutter.
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/mesh_message.dart';
import '../../core/models/voice_note_meta.dart';
import '../../core/providers/chat_background_provider.dart';
import '../../core/providers/mesh_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/mesh_transport_service.dart' show ConnectedPeer;
import '../../core/services/notification_service.dart';
import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../core/services/reglages_notifs.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../navigateur/navigateur_integre.dart';
import '../notifications/notifs_conversation_screen.dart';
import '../settings/galerie_fonds.dart';
import 'chat_info_screen.dart';
import 'media_kind.dart';
import 'messages_ephemeres_screen.dart';
import 'vue_unique.dart';

final _motifLien = RegExp(r'https?://[^\s<>"{}|\\^`\[\]]+', caseSensitive: false);

class PasserelleInfosContact extends ConsumerStatefulWidget {
  const PasserelleInfosContact({super.key, required this.peerId});

  final String peerId;

  @override
  ConsumerState<PasserelleInfosContact> createState() => _PasserelleInfosContactState();
}

class _PasserelleInfosContactState extends EtatPasserelleGlasmio<PasserelleInfosContact> {
  final List<ProviderSubscription<Object?>> _ecoutes = [];

  /// Les messages affichés, par identifiant de geste (`photo:<id>`).
  final Map<String, MeshMessage> _parId = {};

  String get _peerId => widget.peerId;

  @override
  String get ecran => 'infos_contact';

  @override
  bool get natifPossible => _peerId != 'broadcast';

  @override
  Widget construireRepli(BuildContext context) => ChatInfoScreen(peerId: _peerId);

  @override
  void surOuvert() {
    surFerme();
    // Un message arrive, le contact se connecte, change de nom ou de fond :
    // l'écran suit.
    _ecoutes
      ..add(ref.listenManual(conversationMessagesProvider(_peerId), (_, __) => rafraichir()))
      ..add(ref.listenManual(meshPeerListProvider, (_, __) => rafraichir()))
      ..add(ref.listenManual(peerPseudoProvider(_peerId), (_, __) => rafraichir()))
      ..add(ref.listenManual(fondConversationProvider(_peerId), (_, __) => rafraichir()));
    ReglagesNotifs.revision.addListener(_rafraichirSansAttendre);
  }

  @override
  void surFerme() {
    for (final e in _ecoutes) {
      e.close();
    }
    _ecoutes.clear();
    ReglagesNotifs.revision.removeListener(_rafraichirSansAttendre);
  }

  void _rafraichirSansAttendre() => rafraichir();

  void _ouvrirLaConversation() {
    final routeur = GoRouter.of(context);
    if (routeur.canPop()) {
      routeur.pop();
    } else {
      routeur.go('/chat/$_peerId');
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Les gestes
  // ─────────────────────────────────────────────────────────────

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    final t = textes;
    final pseudo = ref.read(peerPseudoProvider(_peerId));
    switch (id) {
      case 'message':
        // Comme la flèche : on revient à la discussion.
        return basculerVersFlutter(() async => _ouvrirLaConversation());
      case 'appeler':
        return allerA('/call/$_peerId');
      case 'securite':
        return allerA('/chat/$_peerId/security');
      case 'verrou':
        // La biométrie a besoin de l'écran Flutter au premier plan.
        final verrouille = StorageService.getLockedConversations().contains(_peerId);
        return feuille((c) => changerVerrouConversation(c, ref, _peerId, verrouille));
      case 'ephemere':
        return pousser(MaterialPageRoute<void>(
          builder: (_) => MessagesEphemeresScreen(cleConversation: _peerId, nom: pseudo),
        ));
      case 'fond':
        return feuille((c) => ouvrirFondsDeDiscussion(c, _peerId));
      case 'notifications':
        return pousser(MaterialPageRoute<void>(
          builder: (_) => NotifsConversationScreen(conversationId: _peerId, nom: pseudo, groupe: false),
        ));
      case 'bloquer':
        if (StorageService.isContactBlocked(_peerId)) {
          await StorageService.setContactBlocked(_peerId, false);
          break;
        }
        return ReponseGlasmio.alerte({
          'titre': t.ciBlockContactTitle,
          'message': t.ciBlockContactBody(pseudo),
          'confirmer': t.ciBlock,
          'annuler': t.actionCancel,
          'destructif': true,
          'id': 'bloquer_confirme',
        });
      case 'bloquer_confirme':
        await StorageService.setContactBlocked(_peerId, true);
      case 'signaler':
        return ReponseGlasmio.alerte({
          'titre': t.ciReportContactTitle,
          'message': t.ciReportContactBody(pseudo),
          'annuler': t.actionCancel,
          'choix': [
            for (final m in motifsSignalement(t)) {'id': 'motif:${m.code}', 'titre': m.label},
          ],
        });
      default:
        if (id.startsWith('motif:')) {
          // ⚠️ CE QUI PART VRAIMENT : un identifiant technique et ce motif,
          // rien d'autre (voir `_BlockSection._report`).
          final ok = await ref.read(meshRepositoryProvider).transport.reportContact(_peerId, id.substring(6));
          return ReponseGlasmio.alerte({
            'titre': ok ? t.ciReportSent : t.ciReportFailed,
            'annuler': MaterialLocalizations.of(context).okButtonLabel,
            'choix': <Object>[],
          });
        }
        final m = _parId[id];
        if (m != null && id.startsWith('photo:')) {
          return feuille((c) => ouvrirPhotoPartagee(c, m));
        }
        if (id.startsWith('lien:')) {
          final adresse = id.substring(5);
          return feuille((c) => ouvrirLienDansApp(c, adresse));
        }
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  // ─────────────────────────────────────────────────────────────
  //  La description
  // ─────────────────────────────────────────────────────────────

  static int _c(Color c) => c.toARGB32();

  static String _date(DateTime? d) => d == null
      ? '—'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _dateHeure(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} · '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _taille(int octets) {
    final t = textes;
    if (octets < 1024) return t.chSizeBytes(octets);
    if (octets < 1024 * 1024) return t.chSizeKb((octets / 1024).toStringAsFixed(1));
    return t.chSizeMb((octets / (1024 * 1024)).toStringAsFixed(1));
  }

  Map<String, Object?> _ligne(String id, String type,
          {String? icone, Color? teinte, required String titre, String? sous, String? valeur, bool coche = false, bool destructif = false}) =>
      {
        'id': id,
        'type': type,
        'icone': ?icone,
        if (teinte != null) 'teinte': _c(teinte),
        'titre': titre,
        'sous': ?sous,
        'valeur': ?valeur,
        'coche': coche,
        'destructif': destructif,
      };

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final langue = Localizations.localeOf(context).toLanguageTag();
    final messages = ref.read(conversationMessagesProvider(_peerId));
    final pseudo = ref.read(peerPseudoProvider(_peerId));
    ConnectedPeer? pair;
    for (final p in ref.read(meshPeerListProvider)) {
      if (p.peerId == _peerId) {
        pair = p;
        break;
      }
    }

    // Les mêmes tris que `ChatInfoScreen`.
    final medias = messages.where((m) => m.type == 'file' && !VueUnique.marquee(m.content)).toList();
    MediaKind genre(MeshMessage m) => mediaKindOf(m.fileMimeType, m.fileName);
    final images = medias.where((m) => genre(m) == MediaKind.image).toList();
    final audio = medias.where((m) => genre(m) == MediaKind.audio).toList();
    final docs = medias.where((m) => genre(m) != MediaKind.image && genre(m) != MediaKind.audio).toList();
    final liens = <Uri>[];
    final vus = <String>{};
    for (final m in messages.reversed) {
      for (final trouve in _motifLien.allMatches(m.content)) {
        final brut = trouve.group(0)!.replaceAll(RegExp(r'[.,;:!?)\]]+$'), '');
        final uri = Uri.tryParse(brut);
        if (uri != null && uri.host.isNotEmpty && vus.add(uri.toString())) liens.add(uri);
      }
      if (liens.length >= 30) break;
    }

    // Les vignettes : les fichiers sont sur le téléphone ; l'écran natif les
    // lit lui-même, en petit. Les plus récentes d'abord, 30 au plus.
    _parId.clear();
    final photos = <Map<String, Object?>>[];
    for (final m in images.reversed.take(30)) {
      final chemin = await StorageService.getSharedFilePath(m.fileId ?? '', m.fileName ?? '');
      final id = 'photo:${m.id}';
      _parId[id] = m;
      photos.add({'id': id, if (chemin != null && File(chemin).existsSync()) 'chemin': chemin});
    }
    if (!mounted) return const {};

    // Le code de sécurité, comme `_SecurityCodeRow`.
    final fiche = StorageService.getPeerRecord(_peerId);
    final verifie = fiche?.isVerifiedAndCurrent ?? false;
    final cleChangee = fiche?.keyChangedSinceVerification ?? false;

    // Les notifications, comme `LigneNotifsConversation`.
    final r = ReglagesNotifs.pour(_peerId);
    final etatNotifs = r.enSourdine(DateTime.now())
        ? (r.sourdineJusqua != null ? libelleFinSourdine(t, langue, r.sourdineJusqua!) : t.ncStateMuted)
        : r.discret
            ? t.ncStateQuiet
            : t.ncStateOn;

    final verrouille = StorageService.getLockedConversations().contains(_peerId);
    final minuteur = StorageService.getEphemeralTimer(_peerId);
    final fondPropre = ref.read(fondConversationProvider(_peerId));
    final bloque = StorageService.isContactBlocked(_peerId);

    return {
      'titre': pseudo,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': _c(OuroColors.accent),
      'entete': {
        'nom': pseudo,
        'statut': pair != null ? (pair.isGateway ? t.ciGatewayOnline : t.ciOnline) : t.ciOffline,
        'enLigne': pair != null,
        'photo': AvatarService.cheminPair(_peerId),
        'initiale': pseudo.characters.isEmpty ? '?' : pseudo.characters.first.toUpperCase(),
        'couleur': NotificationService.couleurAvatar(pseudo),
        'actions': [
          {'id': 'message', 'icone': 'forum', 'titre': t.pfMessage},
          if (pair != null) {'id': 'appeler', 'icone': 'call', 'titre': t.pfCall},
          {'id': 'securite', 'icone': 'verified_user', 'titre': t.pfSecurity},
        ],
      },
      'sections': [
        {
          'lignes': [
            _ligne('securite', 'nav',
                icone: verifie ? 'verified' : (cleChangee ? 'warning' : 'qr_code'),
                teinte: verifie
                    ? OuroColors.successGreen
                    : (cleChangee ? OuroColors.warningAmber : OuroColors.systemGray),
                titre: t.ciSecurityCode,
                sous: verifie ? t.ciVerified : (cleChangee ? t.ciKeyChanged : t.ciNotVerified)),
            // Le verrou demande la biométrie : la ligne s'ouvre côté
            // Flutter, l'interrupteur montre l'état réel.
            _ligne('verrou', 'nav',
                icone: verrouille ? 'lock' : 'lock_open',
                teinte: OuroColors.systemIndigo,
                titre: t.ciConversationLock,
                valeur: verrouille ? t.ciLockEnabled : t.ciDisabled),
            _ligne('ephemere', 'nav',
                icone: 'timer_off',
                teinte: OuroColors.systemTeal,
                titre: t.ciEphemeralMessages,
                valeur: libelleMinuteurEphemere(t, minuteur)),
            _ligne('fond', 'nav',
                icone: 'wallpaper',
                teinte: OuroColors.accent,
                titre: t.stBgThisChat,
                valeur: fondPropre == null ? t.stBgDefault : nomDuFond(fondPropre, t)),
            _ligne('notifications', 'nav',
                icone: 'notifications',
                teinte: OuroColors.systemRed,
                titre: t.ncTitle,
                valeur: etatNotifs),
          ],
        },
        if (photos.isNotEmpty) {'entete': t.ciPhotosCount(images.length), 'grille': photos},
        if (audio.isNotEmpty)
          {
            'entete': t.ciVoiceNotesCount(audio.length),
            'lignes': [
              for (final m in audio)
                _ligne('audio:${m.id}', 'info',
                    icone: 'mic',
                    teinte: OuroColors.errorRed,
                    titre: VoiceNoteMeta.describeAttachment(m.fileName),
                    sous: _dateHeure(m.timestamp)),
            ],
          },
        if (docs.isNotEmpty)
          {
            'entete': t.ciFilesCount(docs.length),
            'lignes': [
              for (final m in docs)
                _ligne('doc:${m.id}', 'info',
                    icone: 'file',
                    teinte: OuroColors.warningAmber,
                    titre: VoiceNoteMeta.describeAttachment(m.fileName),
                    sous: _taille(m.fileSize ?? 0)),
            ],
          },
        if (liens.isNotEmpty)
          {
            'entete': '${t.ciLinks} · ${liens.length}',
            'lignes': [
              for (final l in liens.take(12))
                _ligne('lien:$l', 'nav', icone: 'link', teinte: OuroColors.systemIndigo, titre: l.host, sous: l.toString()),
            ],
          },
        if (medias.isEmpty) {'pied': t.ciNoMediaSharedYet, 'lignes': <Object>[]},
        {
          'lignes': [
            _ligne('bloquer', 'bouton', titre: bloque ? t.ciUnblock : t.ciBlock, destructif: !bloque),
            _ligne('signaler', 'bouton', titre: t.ciReport, destructif: true),
          ],
        },
      ],
      'stats': [
        {'icone': 'forum', 'teinte': _c(OuroColors.meshBlueBright), 'valeur': '${messages.length}', 'titre': t.ciMessages},
        {'icone': 'photo_library', 'teinte': _c(OuroColors.accentPink), 'valeur': '${medias.length}', 'titre': t.ciMedia},
        {
          'icone': 'calendar_month',
          'teinte': _c(OuroColors.successGreen),
          'valeur': _date(messages.isEmpty ? null : messages.first.timestamp),
          'titre': t.ciStart,
        },
      ],
    };
  }
}
