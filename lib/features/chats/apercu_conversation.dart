// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE COUP D'ŒIL DANS UNE CONVERSATION — ce qu'on voit quand on garde le
// doigt sur une ligne de la liste d'accueil.
//
// ── LA VRAIE DISCUSSION, EN MINIATURE ─────────────────────────────────
//
// C'est ce que fait WhatsApp sur iPhone : l'aperçu n'est pas un résumé,
// c'est L'ÉCRAN DE LA DISCUSSION, réduit. Le même fond (dégradé et
// motifs choisis pour cette conversation), le même en-tête, les mêmes
// bulles — avec leur queue, leur heure, leurs coches, leurs réactions —,
// les vocaux avec leur onde, les photos en vignette, les séparateurs de
// jour. On doit reconnaître la conversation d'un coup d'œil, et le toucher
// y emmène.
//
// ⚠️ L'ANCIENNE VERSION ÉTAIT VOLONTAIREMENT PAUVRE, et ça se voyait :
// des pavés de couleur, et pour un vocal le NOM DE FICHIER encodé
// (« voix~15v~OOJFF933CCA88… .m4a ») écrit en toutes lettres.
//
// ── ⚠️ CE QUI RESTE SOBRE, ET POURQUOI ────────────────────────────────
//
// Le widget naît PENDANT l'animation d'ouverture du menu (≈ 320 ms) :
//
//   • le fond est le dégradé FIXE de la conversation, pas l'animation
//     premium (qui tourne en continu) ;
//   • les photos sont décodées à la taille de la vignette, jamais en
//     pleine résolution, et apparaissent en fondu quand elles sont prêtes ;
//   • rien n'est interactif : pas de lecture de vocal, pas de menus.
//
// ── POURQUOI UNE MISE À L'ÉCHELLE ─────────────────────────────────────
//
// Les bulles sont construites AUX MESURES DE LA VRAIE DISCUSSION (texte à
// 16, bulles à 76 % de la largeur), dans une surface plus grande que la
// carte, puis réduites d'un bloc à 82 %. C'est ce qui donne l'effet de
// « la même chose, en petit » — réécrire chaque mesure en plus petit
// donnerait une autre interface, pas une miniature.
// ============================================================================

import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/mesh_message.dart';
import '../../core/models/voice_note_meta.dart';
import '../../core/providers/chat_background_provider.dart';
import '../../core/providers/personnalisation_provider.dart';
import '../../core/services/avatar_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_typography.dart';
import '../../design_system/reglages_apparence.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/peer_avatar.dart';
import '../chat/fonds_premium.dart';
import '../chat/location_message.dart';
import '../chat/media_kind.dart';
import '../chat/motifs_droplet.dart';
import '../chat/poll_message.dart';
import '../chat/sticker_picker.dart';
import '../chat/telegram_gradient_background.dart';
import '../chat/voice_note.dart';

/// La hauteur de la carte. Fixée ici pour que l'appelant la donne au menu
/// contextuel SANS avoir à mesurer : le menu a besoin de la connaître
/// avant de peindre quoi que ce soit, pour placer les actions dessous.
///
/// Plus haute qu'avant (340) : une vraie discussion se juge sur plusieurs
/// échanges, pas sur deux bulles.
const double kHauteurApercuConversation = 430;

/// Combien de messages au plus. Au-delà, les plus anciens sortent par le
/// haut sans qu'on les ait lus — autant ne pas les construire.
const int kMessagesApercu = 14;

/// La réduction appliquée à la discussion.
const double _echelle = 0.82;

class ApercuConversation extends ConsumerWidget {
  const ApercuConversation({
    super.key,
    required this.pseudo,
    required this.messages,
    required this.monId,
    this.peerId,
    this.groupId,
    this.estGroupe = false,
    this.enLigne = false,
  });

  final String pseudo;

  /// Les messages de la conversation, du plus ancien au plus récent.
  final List<MeshMessage> messages;

  /// Mon identifiant, pour savoir de quel côté va chaque bulle.
  final String monId;

  final String? peerId;
  final String? groupId;
  final bool estGroupe;
  final bool enLigne;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sombre = Theme.of(context).brightness == Brightness.dark;
    // Les derniers, et seulement eux.
    final derniers = messages.length > kMessagesApercu
        ? messages.sublist(messages.length - kMessagesApercu)
        : messages;

    // ── LE FOND DE CETTE CONVERSATION ───────────────────────────────
    final cle = groupId ?? peerId ?? 'broadcast';
    // ⚠️ TYPÉ EXPLICITEMENT, AVEC UN DERNIER RECOURS. Selon la version
    // du fournisseur, l'une ou l'autre valeur peut être nulle : sans le
    // `?? kFondAucun`, l'expression restait `String?` et ne compilait pas.
    final String? fondBrut = ref.watch(fondConversationProvider(cle)) ??
        ref.watch(chatBackgroundProvider);
    final String fondChoisi = fondBrut ?? kFondAucun;
    // Mêmes règles que la discussion : un fond premium (animé) est
    // remplacé ici par le dégradé Droplet, fixe ; « Aucun » donne le fond
    // uni.
    final couleurs = FondsPremium.trouver(fondChoisi) != null
        ? TelegramGradientPalettes.pour('mesh', sombre: sombre)
        : fondChoisi == 'adaptatif'
            ? TelegramGradientPalettes.pourContenu('text', sombre: sombre)
            : TelegramGradientPalettes.pour(fondChoisi, sombre: sombre);
    final motifs = ref.watch(chatMotifsProvider);
    final pack = PackMotifs.values[ref
        .watch(personnalisationProvider)
        .packMotifs
        .clamp(0, PackMotifs.values.length - 1)];

    final elements = _elements(derniers, l10n, Localizations.localeOf(context));

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (couleurs != null)
            TelegramGradientBackground(tick: 0, couleurs: couleurs)
          else
            ColoredBox(color: OuroColors.systemBackground),
          if (motifs)
            CalqueMotifsDroplet(
              pack: pack,
              couleur: MotifsDroplet.couleur(sombre: sombre),
            ),
          Column(
            children: [
              _Entete(
                pseudo: pseudo,
                peerId: peerId,
                estGroupe: estGroupe,
                enLigne: enLigne,
              ),
              Expanded(
                child: derniers.isEmpty
                    ? Center(
                        child: Text(
                          l10n.apcNothingYet,
                          style: OuroTypography.footnote.copyWith(
                            color: OuroColors.secondaryLabel,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, contraintes) {
                          // La discussion est construite en grand, puis
                          // réduite d'un bloc (voir l'en-tête du fichier).
                          final largeur = contraintes.maxWidth / _echelle;
                          final hauteur = contraintes.maxHeight / _echelle;
                          return ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.bottomCenter,
                              minWidth: largeur,
                              maxWidth: largeur,
                              minHeight: hauteur,
                              maxHeight: hauteur,
                              child: Transform.scale(
                                scale: _echelle,
                                alignment: Alignment.bottomCenter,
                                child: MediaQuery(
                                  data: MediaQuery.of(context).copyWith(
                                    size: Size(largeur, hauteur),
                                  ),
                                  child: ShaderMask(
                                    // Le fondu du haut : « ça continue
                                    // au-dessus », au lieu d'un message
                                    // tranché net au milieu d'un mot.
                                    shaderCallback: (rect) =>
                                        const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black,
                                      ],
                                      stops: [0, 0.12],
                                    ).createShader(rect),
                                    blendMode: BlendMode.dstIn,
                                    child: ListView.builder(
                                      reverse: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.fromLTRB(
                                          12, 12, 12, 14),
                                      itemCount: elements.length,
                                      itemBuilder: (context, i) =>
                                          elements[elements.length - 1 - i],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Les bulles et les séparateurs de jour, dans l'ordre chronologique.
  List<Widget> _elements(
    List<MeshMessage> liste,
    AppLocalizations l10n,
    Locale langue,
  ) {
    final sortie = <Widget>[];
    DateTime? jourPrecedent;
    for (var i = 0; i < liste.length; i++) {
      final m = liste[i];
      final jour = DateTime(m.timestamp.year, m.timestamp.month, m.timestamp.day);
      if (jourPrecedent == null || jour != jourPrecedent) {
        sortie.add(_SeparateurJour(jour: jour, l10n: l10n, langue: langue));
        jourPrecedent = jour;
      }
      final deMoi = m.senderId == monId;
      final suivant = i + 1 < liste.length ? liste[i + 1] : null;
      final precedent = i > 0 ? liste[i - 1] : null;
      bool memeSerie(MeshMessage? a) =>
          a != null &&
          a.senderId == m.senderId &&
          a.timestamp.difference(m.timestamp).abs() <
              const Duration(minutes: 3) &&
          a.timestamp.day == m.timestamp.day;
      sortie.add(_Bulle(
        message: m,
        deMoi: deMoi,
        // La queue ne se dessine que sur la DERNIÈRE bulle d'une série,
        // et le nom de l'auteur (en groupe) sur la première.
        finDeSerie: !memeSerie(suivant),
        avecAuteur: estGroupe && !deMoi && !memeSerie(precedent),
        l10n: l10n,
      ));
    }
    return sortie;
  }
}

// ══ L'EN-TÊTE ══════════════════════════════════════════════════════════

/// Celui de la discussion : chevron, avatar, nom et état, caméra et
/// téléphone — au trait, comme sur l'écran lui-même.
class _Entete extends StatelessWidget {
  const _Entete({
    required this.pseudo,
    required this.peerId,
    required this.estGroupe,
    required this.enLigne,
  });

  final String pseudo;
  final String? peerId;
  final bool estGroupe;
  final bool enLigne;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: 54,
      padding: const EdgeInsets.only(left: 6, right: 10),
      decoration: BoxDecoration(
        color: OuroColors.systemBackground.withValues(alpha: 0.86),
        border: Border(
          bottom: BorderSide(
            color: OuroColors.separator.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.chevron_left_rounded, size: 28, color: OuroColors.accent),
          if (estGroupe)
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: OuroColors.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.groups_rounded, size: 20, color: OuroColors.accent),
            )
          else
            PeerAvatar(
              pseudo: pseudo,
              radius: 17,
              online: enLigne,
              imagePath: AvatarService.cheminPair(peerId),
            ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pseudo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.label,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!estGroupe)
                  Text(
                    enLigne ? l10n.apcOnline : l10n.apcOffline,
                    style: OuroTypography.caption2.copyWith(
                      color: enLigne
                          ? OuroColors.presenceMaintenant
                          : OuroColors.secondaryLabel,
                    ),
                  ),
              ],
            ),
          ),
          if (!estGroupe) ...[
            Icon(Icons.videocam_outlined, size: 23, color: OuroColors.accent),
            const SizedBox(width: 16),
            Icon(Icons.phone_outlined, size: 20, color: OuroColors.accent),
          ],
        ],
      ),
    );
  }
}

// ══ LE SÉPARATEUR DE JOUR ══════════════════════════════════════════════

class _SeparateurJour extends StatelessWidget {
  const _SeparateurJour({
    required this.jour,
    required this.l10n,
    required this.langue,
  });

  final DateTime jour;
  final AppLocalizations l10n;
  final Locale langue;

  @override
  Widget build(BuildContext context) {
    final maintenant = DateTime.now();
    final aujourdhui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final ecart = aujourdhui.difference(jour).inDays;
    final texte = ecart == 0
        ? l10n.chToday
        : ecart == 1
            ? l10n.chYesterday
            : ecart < 7
                ? DateFormat.EEEE(langue.toLanguageTag()).format(jour)
                : DateFormat.yMMMd(langue.toLanguageTag()).format(jour);
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: OuroColors.systemBackground.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          texte,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: OuroColors.secondaryLabel,
          ),
        ),
      ),
    );
  }
}

// ══ LA BULLE ═══════════════════════════════════════════════════════════

class _Bulle extends StatelessWidget {
  const _Bulle({
    required this.message,
    required this.deMoi,
    required this.finDeSerie,
    required this.avecAuteur,
    required this.l10n,
  });

  final MeshMessage message;
  final bool deMoi;
  final bool finDeSerie;
  final bool avecAuteur;
  final AppLocalizations l10n;

  bool get _estFichier {
    final nom = message.fileName;
    return message.type == 'file' ||
        (nom != null && message.content.trim() == nom);
  }

  /// La légende d'un fichier, s'il en a une : son contenu, sinon, est son
  /// nom — qui ne doit jamais s'afficher.
  String? get _legende {
    final c = message.content.trim();
    if (c.isEmpty || c == message.fileName) return null;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final sombre = Theme.of(context).brightness == Brightness.dark;
    final fond = deMoi
        ? OuroColors.bubbleOutgoing
        : (sombre ? OuroColors.bubbleIncoming : Colors.white);
    final encre = deMoi ? OuroColors.bubbleOutgoingText : OuroColors.label;
    final secondaire = deMoi
        ? OuroColors.bubbleOutgoingText.withValues(alpha: 0.62)
        : OuroColors.secondaryLabel;
    final largeurMax = MediaQuery.sizeOf(context).width * 0.76;

    final pied = _Pied(
      message: message,
      deMoi: deMoi,
      couleur: secondaire,
      encre: encre,
    );

    Widget corps;
    var media = false;
    final nom = message.fileName;
    final genre = _estFichier ? mediaKindOf(message.fileMimeType, nom) : null;
    if (_estFichier && VoiceNoteMeta.isVoiceNote(nom)) {
      corps = _Vocal(nom: nom, deMoi: deMoi, encre: encre, pied: pied);
    } else if (genre == MediaKind.image) {
      media = true;
      corps = _Photo(message: message, legende: _legende, encre: encre, pied: pied);
    } else if (_estFichier) {
      corps = _Fichier(
        icone: genre == MediaKind.video
            ? Icons.play_circle_fill_rounded
            : Icons.insert_drive_file_rounded,
        texte: _legende ??
            (genre == MediaKind.video ? l10n.apcVideo : (nom ?? l10n.apcAttachment)),
        encre: encre,
        pied: pied,
      );
    } else if (isStickerMessage(message.content)) {
      // Un autocollant : sans bulle, comme dans la discussion.
      return Align(
        alignment: deMoi ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(l10n.chStickerPreview,
              style: TextStyle(fontSize: 15, color: OuroColors.secondaryLabel)),
        ),
      );
    } else {
      corps = _Texte(
        texte: LocationMessage.describe(PollMessage.describe(message.content)),
        encre: encre,
        pied: pied,
        auteur: avecAuteur ? message.authorPseudo : null,
      );
    }

    // La queue : le coin du bas, côté auteur, presque carré sur la
    // dernière bulle d'une série — l'esprit de la goutte de la discussion.
    const r = Radius.circular(18);
    const petit = Radius.circular(5);
    final rayon = BorderRadius.only(
      topLeft: r,
      topRight: r,
      bottomLeft: !deMoi && finDeSerie ? petit : r,
      bottomRight: deMoi && finDeSerie ? petit : r,
    );

    final reactions = message.reactions;
    Widget bulle = Container(
      constraints: BoxConstraints(maxWidth: largeurMax),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: rayon,
        boxShadow: deMoi || sombre
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 1,
                  offset: const Offset(0, 0.5),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: rayon,
        child: Padding(
          padding: media ? const EdgeInsets.all(3) : EdgeInsets.zero,
          child: corps,
        ),
      ),
    );

    if (reactions.isNotEmpty) {
      final distincts = <String>[];
      for (final e in reactions) {
        if (!distincts.contains(e)) distincts.add(e);
      }
      bulle = Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            bulle,
            Positioned(
              bottom: -18,
              left: deMoi ? 10 : null,
              right: deMoi ? null : 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: sombre ? OuroColors.bubbleIncoming : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: OuroColors.systemBackground,
                    width: 2,
                  ),
                ),
                child: Text(
                  distincts.take(3).join() +
                      (reactions.length > 1 ? ' ${reactions.length}' : ''),
                  style: TextStyle(
                    fontSize: 13,
                    color: OuroColors.secondaryLabel,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: finDeSerie ? 6 : 0),
      child: Align(
        alignment: deMoi ? Alignment.centerRight : Alignment.centerLeft,
        child: bulle,
      ),
    );
  }
}

/// L'heure et, pour mes messages, les coches — comme dans la discussion.
class _Pied extends StatelessWidget {
  const _Pied({
    required this.message,
    required this.deMoi,
    required this.couleur,
    required this.encre,
    this.surPhoto = false,
  });

  final MeshMessage message;
  final bool deMoi;
  final Color couleur;
  final Color encre;
  final bool surPhoto;

  _Pied surImage() => _Pied(
        message: message,
        deMoi: deMoi,
        couleur: Colors.white,
        encre: Colors.white,
        surPhoto: true,
      );

  @override
  Widget build(BuildContext context) {
    final heure = DateFormat.Hm(Localizations.localeOf(context).toLanguageTag())
        .format(message.timestamp);
    IconData? coche;
    var couleurCoche = couleur;
    if (deMoi) {
      final lu = message.readAt != null;
      coche = switch (message.status) {
        MessageStatus.failed => Icons.error_outline_rounded,
        MessageStatus.sending || MessageStatus.pending => Icons.schedule_rounded,
        _ => (lu || message.deliveryCount > 0)
            ? Icons.done_all_rounded
            : Icons.done_rounded,
      };
      if (lu) couleurCoche = encre;
      if (message.status == MessageStatus.failed) {
        couleurCoche = OuroColors.systemRed;
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.editedAt != null) ...[
          Text(
            l10nEdited(context),
            style: TextStyle(
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              color: couleur,
            ),
          ),
          const SizedBox(width: 3),
        ],
        Text(heure, style: TextStyle(fontSize: 11, color: couleur)),
        if (coche != null) ...[
          const SizedBox(width: 3),
          Icon(coche, size: 15, color: couleurCoche),
        ],
      ],
    );
  }

  static String l10nEdited(BuildContext context) =>
      AppLocalizations.of(context).chEditedBadge;
}

class _Texte extends StatelessWidget {
  const _Texte({
    required this.texte,
    required this.encre,
    required this.pied,
    this.auteur,
  });

  final String texte;
  final Color encre;
  final Widget pied;
  final String? auteur;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 7, 10, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (auteur != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                auteur!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: OuroColors.accent,
                ),
              ),
            ),
          // L'heure se pose sur la dernière ligne s'il y a la place,
          // dessous sinon — comme dans la discussion.
          Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            children: [
              Text(
                texte,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: encre,
                  fontSize: ReglagesApparence.tailleTexte,
                  height: ReglagesApparence.interligne,
                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 3), child: pied),
            ],
          ),
        ],
      ),
    );
  }
}

class _Vocal extends StatelessWidget {
  const _Vocal({
    required this.nom,
    required this.deMoi,
    required this.encre,
    required this.pied,
  });

  final String? nom;
  final bool deMoi;
  final Color encre;
  final Widget pied;

  @override
  Widget build(BuildContext context) {
    final meta = VoiceNoteMeta.tryParse(nom);
    final s = meta?.duration.inSeconds ?? 0;
    final duree = '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
    final trait = deMoi ? encre : OuroColors.accent;
    return SizedBox(
      width: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 10, 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: deMoi ? encre : OuroColors.accent,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: deMoi ? OuroColors.bubbleOutgoing : Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VoiceWaveform(
                    waveform: meta?.waveform ?? const [],
                    progress: 0,
                    activeColor: trait,
                    inactiveColor: trait.withValues(alpha: 0.45),
                    height: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const SizedBox(width: 44),
                Text(
                  duree,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: encre.withValues(alpha: 0.7),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const Spacer(),
                pied,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Fichier extends StatelessWidget {
  const _Fichier({
    required this.icone,
    required this.texte,
    required this.encre,
    required this.pied,
  });

  final IconData icone;
  final String texte;
  final Color encre;
  final Widget pied;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icone, size: 30, color: encre.withValues(alpha: 0.85)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    texte,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: encre, fontSize: 15),
                  ),
                ),
              ],
            ),
            Align(alignment: Alignment.centerRight, child: pied),
          ],
        ),
      ),
    );
  }
}

/// Une photo : la vignette, décodée petite, qui apparaît en fondu.
class _Photo extends StatefulWidget {
  const _Photo({
    required this.message,
    required this.legende,
    required this.encre,
    required this.pied,
  });

  final MeshMessage message;
  final String? legende;
  final Color encre;
  final _Pied pied;

  @override
  State<_Photo> createState() => _PhotoState();
}

class _PhotoState extends State<_Photo> {
  late final Future<String?> _chemin = widget.message.fileId == null
      ? Future.value(null)
      : StorageService.getSharedFilePath(
          widget.message.fileId!,
          widget.message.fileName ?? '',
        );

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final image = SizedBox(
      width: 230,
      height: 230 * 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FutureBuilder<String?>(
          future: _chemin,
          builder: (context, snap) {
            final chemin = snap.data;
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: OuroColors.systemFill),
                if (chemin != null)
                  Image(
                    image: ResizeImage(
                      FileImage(File(chemin)),
                      width: (230 * _echelle * dpr).round(),
                    ),
                    fit: BoxFit.cover,
                    frameBuilder: (_, enfant, frame, synchrone) =>
                        synchrone
                            ? enfant
                            : AnimatedOpacity(
                                opacity: frame == null ? 0 : 1,
                                duration: const Duration(milliseconds: 200),
                                child: enfant,
                              ),
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                if (widget.legende == null)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: widget.pied.surImage(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
    if (widget.legende == null) return image;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        SizedBox(
          width: 230,
          child: _Texte(
            texte: widget.legende!,
            encre: widget.encre,
            pied: widget.pied,
          ),
        ),
      ],
    );
  }
}
