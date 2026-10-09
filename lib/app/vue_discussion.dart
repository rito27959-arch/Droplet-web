// LA DISCUSSION OUVERTE — l'écran de discussion de l'app, à la souris.
//
//   ┌─ en-tête en verre : avatar, nom, « en ligne » / « écrit… », appels,
//   │  recherche, menu ─────────────────────────────────────────────────
//   ├─ le message épinglé (un clic y mène, le suivant au clic suivant)
//   │
//   │  le fil : pastilles des jours, « N messages non lus », bulles,
//   │  « … écrit » en bas ; le bouton ⌄ pour revenir en bas
//   │
//   └─ la barre de saisie en verre ──────────────────────────────────────
//
// Tout passe par le dépôt : répondre, réagir, modifier, supprimer pour
// moi ou pour tous, transférer, épingler, marquer important, envoyer des
// photos, des fichiers, des vocaux. Glisser-déposer un fichier sur la
// discussion l'ouvre dans l'aperçu d'envoi.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/ouro_colors.dart';
import '../design_system/ouro_typography.dart';
import '../donnees/depot.dart';
import '../donnees/modeles.dart';
import '../features/chat/message_context_menu.dart';
import '../shared/widgets/typing_indicator.dart';
import '../web/navigateur.dart';
import 'apercu.dart';
import 'appels.dart';
import 'bulle.dart';
import 'composants.dart';
import 'emoji.dart';
import 'formats.dart';
import 'liste_discussions.dart' show confirmerSuppression;
import 'panneau_infos.dart' show choisirEphemere;
import 'portee.dart';
import 'saisie.dart';
import 'visionneuse.dart';

class VueDiscussion extends StatefulWidget {
  const VueDiscussion({super.key, required this.discussion, this.onRetour});

  final Discussion discussion;

  /// Sur un écran étroit : revenir à la liste.
  final VoidCallback? onRetour;

  @override
  State<VueDiscussion> createState() => _VueDiscussionState();
}

class _VueDiscussionState extends State<VueDiscussion> {
  late final TextEditingController _saisie = TextEditingController(text: widget.discussion.brouillon);
  final _focus = FocusNode();
  final _defilement = ScrollController();
  final Map<String, GlobalKey> _cles = {};
  late final Set<String> _connus;
  late final Depot _depot;
  StreamSubscription<List<PieceJointe>>? _depots;

  Message? _reponse;
  Message? _edition;
  List<PieceJointe>? _aEnvoyer;
  String? _clignote;
  bool _basLoin = false;
  int _nouveauxEnBas = 0;
  int _epingle = 0;

  // La recherche dans la discussion.
  final _champRecherche = TextEditingController();
  String _q = '';
  int _resultat = 0;

  /// Le séparateur « N messages non lus », posé à l'ouverture.
  String? _premierNonLu;
  int _nonLusOuverture = 0;

  @override
  void initState() {
    super.initState();
    final p = context.lire;
    _depot = p.depot;
    _connus = {for (final m in p.depot.messages(widget.discussion.id)) m.id};
    _nonLusOuverture = p.ui.nonLusOuverture;
    p.ui.nonLusOuverture = 0;
    final liste = p.depot.messages(widget.discussion.id).where((m) => m.type != TypeMessage.systeme).toList();
    if (_nonLusOuverture > 0 && liste.length >= _nonLusOuverture) {
      _premierNonLu = liste[liste.length - _nonLusOuverture].id;
    }
    _defilement.addListener(() {
      final loin = _defilement.offset > 400;
      if (loin != _basLoin) setState(() => _basLoin = loin);
      if (!loin && _nouveauxEnBas > 0) setState(() => _nouveauxEnBas = 0);
    });
    _depots = Navigateur.deposes.listen((pieces) {
      if (mounted && pieces.isNotEmpty) setState(() => _aEnvoyer = [...?_aEnvoyer, ...pieces]);
    });
    p.depot.addListener(_surChangement);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cible = p.ui.messageCible;
      if (cible != null) {
        p.ui.messageCible = null;
        _allerA(cible);
      }
    });
  }

  @override
  void didUpdateWidget(VueDiscussion ancien) {
    super.didUpdateWidget(ancien);
    final cible = context.lire.ui.messageCible;
    if (cible != null) {
      context.lire.ui.messageCible = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _allerA(cible));
    }
  }

  /// Un message arrive pendant qu'on lit plus haut : on compte, sans
  /// faire sauter le fil.
  void _surChangement() {
    if (!mounted) return;
    final messages = context.lire.depot.messages(widget.discussion.id);
    var nouveaux = 0;
    for (final m in messages) {
      if (_connus.add(m.id) && !m.deMoi) nouveaux++;
    }
    if (nouveaux > 0 && _basLoin) setState(() => _nouveauxEnBas += nouveaux);
  }

  @override
  void dispose() {
    _depot.removeListener(_surChangement);
    _depots?.cancel();
    _saisie.dispose();
    _focus.dispose();
    _defilement.dispose();
    _champRecherche.dispose();
    super.dispose();
  }

  GlobalKey _cle(String id) => _cles.putIfAbsent(id, () => GlobalKey());

  // ══ ACTIONS ═══════════════════════════════════════════════════════════

  void _envoyer(String texte) {
    final depot = context.lire.depot;
    final d = widget.discussion;
    if (_edition != null) {
      depot.modifier(_edition!, texte);
    } else {
      depot.envoyerTexte(d, texte, reponseA: _reponse?.id);
      if (depot.reglages.sons) Navigateur.ploc(envoi: true);
    }
    _vider();
    _enBas();
  }

  void _vider() {
    _saisie.clear();
    // Sur le web, la touche Entrée peut encore glisser un retour à la ligne
    // juste après : on revide au tour suivant.
    Future<void>.delayed(Duration.zero, () {
      if (mounted && _saisie.text.trim().isEmpty) _saisie.clear();
    });
    context.lire.depot.enregistrerBrouillon(widget.discussion, '');
    setState(() {
      _reponse = null;
      _edition = null;
    });
    _focus.requestFocus();
  }

  void _enBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_defilement.hasClients) {
        _defilement.animateTo(0, duration: const Duration(milliseconds: 420), curve: kSortie);
      }
    });
    setState(() => _nouveauxEnBas = 0);
  }

  void _repondre(Message m) {
    setState(() {
      _reponse = m;
      _edition = null;
    });
    _focus.requestFocus();
  }

  void _modifier(Message m) {
    setState(() {
      _edition = m;
      _reponse = null;
      _saisie.text = m.texte;
      _saisie.selection = TextSelection.collapsed(offset: m.texte.length);
    });
    _focus.requestFocus();
  }

  void _annulerContexte() {
    if (_edition != null) _saisie.clear();
    setState(() {
      _reponse = null;
      _edition = null;
    });
  }

  void _modifierDernier() {
    final mes = context.lire.depot
        .messages(widget.discussion.id)
        .where((m) => m.deMoi && m.type == TypeMessage.texte && !m.supprime)
        .toList();
    if (mes.isNotEmpty) _modifier(mes.last);
  }

  Future<void> _supprimer(Message m) async {
    final l = context.l;
    final t = context.t;
    final depot = context.lire.depot;
    final actions = [
      if (m.deMoi) ActionAlerte(t.supprimerPourTous, destructif: true),
      ActionAlerte(t.supprimerPourMoi, destructif: true),
      ActionAlerte(l.actionCancel),
    ];
    final i = await alerte(context, titre: t.supprimerMessage, message: m.deMoi ? null : t.supprimerPourMoiTexte, actions: actions);
    if (i == null || actions[i].libelle == l.actionCancel) return;
    depot.supprimer(m, pourTous: m.deMoi && i == 0);
  }

  void _copier(Message m) {
    Clipboard.setData(ClipboardData(text: m.texte));
    annoncer(context, context.l.chMessageCopied, icone: Icons.copy_rounded);
  }

  Future<void> _infos(Message m) async {
    final l = context.l;
    final statut = switch (m.statut) {
      StatutMessage.lu => l.tsRead,
      StatutMessage.recu => l.tsDelivered,
      StatutMessage.envoye => l.tsSent,
      StatutMessage.envoi => l.tsSendingInProgress,
      StatutMessage.echec => l.tsNotDelivered,
    };
    await alerte(
      context,
      titre: l.msgInfo,
      message: '${dateComplete(context, m.date)}\n$statut\n\n${l.tsNoServerNoOperator}',
      actions: [ActionAlerte(l.actionDone, principal: true)],
    );
  }

  /// Le menu de l'app : la bulle se soulève, les réactions au-dessus, les
  /// actions en dessous.
  void _menu(Message m, {required bool debutSerie, required bool finSerie, required double largeurMax}) {
    final depot = context.lire.depot;
    final l = context.l;
    final t = context.t;
    final cle = _cle(m.id);
    final texte = m.type == TypeMessage.texte || m.texte.isNotEmpty;
    showMessageContextMenu(
      context: context,
      anchorKey: cle,
      mine: m.deMoi,
      current: [
        for (final e in m.reactions.entries)
          if (e.value.contains(kMoi)) e.key,
      ],
      onReact: (e) => depot.reagir(m, e),
      preview: Portee(
        depot: depot,
        ui: context.lire.ui,
        textes: context.lire.textes,
        child: CorpsBulle(
          message: m,
          discussion: widget.discussion,
          finSerie: finSerie,
          debutSerie: debutSerie,
          largeurMax: largeurMax,
        ),
      ),
      actions: [
        MessageAction(icon: Icons.reply_rounded, label: l.chReply, onTap: () => _repondre(m)),
        if (texte) MessageAction(icon: Icons.copy_rounded, label: l.chCopy, onTap: () => _copier(m)),
        if (m.deMoi && m.type == TypeMessage.texte)
          MessageAction(icon: Icons.edit_outlined, label: l.actionEdit, onTap: () => _modifier(m)),
        MessageAction(icon: Icons.shortcut_rounded, label: l.chForward, onTap: () => transferer(context, m)),
        MessageAction(
          icon: m.epingle ? Icons.push_pin_rounded : Icons.push_pin_outlined,
          label: m.epingle ? l.chUnpin : l.chPin,
          nouvelleSection: true,
          onTap: () => depot.epingler(m),
        ),
        MessageAction(
          icon: m.important ? Icons.star_rounded : Icons.star_outline_rounded,
          label: m.important ? l.imRemove : l.imAdd,
          onTap: () => depot.marquerImportant(m),
        ),
        if (m.piece != null && m.piece!.url.isNotEmpty)
          MessageAction(icon: Icons.file_download_outlined, label: t.telechargerFichier, onTap: () => Navigateur.telecharger(m.piece!)),
        if (m.deMoi) MessageAction(icon: Icons.info_outline_rounded, label: l.msgInfo, onTap: () => _infos(m)),
        if (m.statut == StatutMessage.echec)
          MessageAction(icon: Icons.refresh_rounded, label: l.actionRetry, onTap: () => depot.reessayer(m)),
        MessageAction(icon: Icons.delete_outline_rounded, label: l.actionDelete, destructive: true, onTap: () => _supprimer(m)),
      ],
    );
  }

  /// Aller à un message : on remonte le fil jusqu'à ce qu'il soit
  /// construit, puis on le centre et il clignote.
  Future<void> _allerA(String id) async {
    for (var essai = 0; essai < 60; essai++) {
      final ctx = _cles[id]?.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(ctx, alignment: 0.4, duration: const Duration(milliseconds: 420), curve: kSortie);
        if (mounted) setState(() => _clignote = id);
        Future<void>.delayed(const Duration(milliseconds: 1700), () {
          if (mounted && _clignote == id) setState(() => _clignote = null);
        });
        return;
      }
      if (!_defilement.hasClients) return;
      final pos = _defilement.position;
      if (pos.pixels >= pos.maxScrollExtent) {
        // Peut-être pas encore construit : un dernier tour.
        await Future<void>.delayed(const Duration(milliseconds: 16));
        if (_cles[id]?.currentContext == null && essai > 2) return;
      }
      _defilement.jumpTo((pos.pixels + pos.viewportDimension * 0.8).clamp(0, pos.maxScrollExtent));
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  void _envoyerPieces(List<PieceJointe> pieces, String legende) {
    final depot = context.lire.depot;
    for (final (i, p) in pieces.indexed) {
      depot.envoyerPiece(
        widget.discussion,
        p,
        p.mime.startsWith('image/') ? TypeMessage.image : TypeMessage.fichier,
        legende: i == pieces.length - 1 ? legende : '',
        reponseA: i == 0 ? _reponse?.id : null,
      );
    }
    setState(() {
      _aEnvoyer = null;
      _reponse = null;
    });
    if (depot.reglages.sons) Navigateur.ploc(envoi: true);
    _enBas();
  }

  // ══ AFFICHAGE ═════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final ui = context.ui;
    final d = depot.discussions[widget.discussion.id] ?? widget.discussion;
    final contact = depot.interlocuteur(d);
    final messages = depot.messages(d.id);
    final epingles = depot.epingles(d.id);
    final ecrivent = depot.enTrainDecrire[d.id] ?? const <String>{};
    final recherche = ui.rechercheDiscussion;
    final q = recherche ? _q : '';
    final resultats = q.length < 2
        ? const <Message>[]
        : messages.where((m) => !m.supprime && m.texte.toLowerCase().contains(q)).toList().reversed.toList();

    return LayoutBuilder(builder: (context, c) {
      final largeurMax = (c.maxWidth * 0.68).clamp(220.0, 560.0);
      final elements = _elements(messages);

      return ColoredBox(
        color: OuroColors.systemBackground,
        child: Stack(
          children: [
            Positioned.fill(child: Fond(index: depot.reglages.fond)),
            Positioned.fill(
              child: Column(
                children: [
                  _Entete(
                    discussion: d,
                    onRetour: widget.onRetour,
                    recherche: recherche,
                    champRecherche: _champRecherche,
                    resultats: resultats.length,
                    resultat: _resultat,
                    onRecherche: (v) => setState(() {
                      _q = v.trim().toLowerCase();
                      _resultat = 0;
                    }),
                    onResultat: (sens) {
                      if (resultats.isEmpty) return;
                      setState(() => _resultat = (_resultat + sens) % resultats.length);
                      _allerA(resultats[_resultat].id);
                    },
                  ),
                  if (epingles.isNotEmpty)
                    _BarreEpingle(
                      messages: epingles,
                      index: _epingle % epingles.length,
                      onTap: () {
                        final m = epingles[_epingle % epingles.length];
                        _allerA(m.id);
                        setState(() => _epingle++);
                      },
                      onRetirer: () => depot.epingler(epingles[_epingle % epingles.length]),
                    ),
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ListView.builder(
                              controller: _defilement,
                              reverse: true,
                              padding: EdgeInsets.fromLTRB(c.maxWidth > 900 ? 56 : 14, 14, c.maxWidth > 900 ? 56 : 14, 14),
                              itemCount: elements.length + 1,
                              itemBuilder: (context, i) {
                                if (i == 0) {
                                  return AnimatedSize(
                                    duration: const Duration(milliseconds: 240),
                                    curve: kSortie,
                                    child: ecrivent.isEmpty
                                        ? const SizedBox(width: double.infinity)
                                        : Padding(
                                            padding: const EdgeInsets.only(top: 2, bottom: 8),
                                            child: Row(
                                              children: [
                                                if (d.estGroupe) ...[
                                                  AvatarDroplet(
                                                    nom: depot.nom(ecrivent.first),
                                                    couleur: depot.contacts[ecrivent.first]?.couleur ?? 0,
                                                    taille: 30,
                                                  ),
                                                  const SizedBox(width: 8),
                                                ],
                                                const TypingIndicator(),
                                              ],
                                            ),
                                          ),
                                  );
                                }
                                final e = elements[elements.length - i];
                                return _construire(context, e, d, largeurMax, q);
                              },
                            ),
                        ),
                        // Le bouton ⌄ : revenir en bas, avec le nombre de
                        // messages arrivés entre-temps.
                        Positioned(
                          right: 18,
                          bottom: 14,
                          child: AnimatedScale(
                            scale: _basLoin ? 1 : 0,
                            duration: const Duration(milliseconds: 260),
                            curve: kSortie,
                            child: _BoutonBas(compte: _nouveauxEnBas, onTap: _enBas),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _pied(context, d, contact),
                ],
              ),
            ),
            // Glisser-déposer : un voile qui invite à lâcher.
            ValueListenableBuilder<bool>(
              valueListenable: Navigateur.survolDepot,
              builder: (context, survol, _) => IgnorePointer(
                child: AnimatedOpacity(
                  opacity: survol && _aEnvoyer == null ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: _VoileDepot(nom: d.titre),
                ),
              ),
            ),
            if (_aEnvoyer != null)
              Positioned.fill(
                child: _ApercuEnvoi(
                  pieces: _aEnvoyer!,
                  destinataire: d.titre,
                  onAjouter: (p) => setState(() => _aEnvoyer = [..._aEnvoyer!, ...p]),
                  onRetirer: (i) => setState(() {
                    final l = [..._aEnvoyer!]..removeAt(i);
                    _aEnvoyer = l.isEmpty ? null : l;
                  }),
                  onFermer: () => setState(() => _aEnvoyer = null),
                  onEnvoyer: (legende) => _envoyerPieces(_aEnvoyer!, legende),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _pied(BuildContext context, Discussion d, Contact? contact) {
    final l = context.l;
    final t = context.t;
    final depot = context.depot;
    if (contact != null && contact.bloque) {
      return Verre(
        bordHaut: true,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Column(
              children: [
                Text(l.blkYouBlocked, textAlign: TextAlign.center, style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel)),
                const SizedBox(height: 8),
                BoutonPlein(texte: l.blkUnblock, onTap: () => depot.bloquer(contact)),
              ],
            ),
          ),
        ),
      );
    }
    if (d.quitte) {
      return Verre(
        bordHaut: true,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: Text(t.plusMembre, style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel)),
          ),
        ),
      );
    }
    return BarreSaisie(
      discussion: d,
      controleur: _saisie,
      focus: _focus,
      reponse: _reponse,
      edition: _edition,
      onEnvoyer: _envoyer,
      onPieces: (p) => setState(() => _aEnvoyer = [...?_aEnvoyer, ...p]),
      onVocal: (p) {
        depot.envoyerPiece(d, p, TypeMessage.vocal, reponseA: _reponse?.id);
        setState(() => _reponse = null);
        if (depot.reglages.sons) Navigateur.ploc(envoi: true);
        _enBas();
      },
      onAnnuler: _annulerContexte,
      onModifierDernier: _modifierDernier,
    );
  }

  /// Le fil, dans l'ordre : avis de chiffrement, jours, non-lus, messages.
  List<_Element> _elements(List<Message> messages) {
    final elements = <_Element>[const _Element.chiffrement()];
    DateTime? jour;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      final j = DateTime(m.date.year, m.date.month, m.date.day);
      if (jour != j) {
        jour = j;
        elements.add(_Element.jour(m.date));
      }
      if (m.id == _premierNonLu) elements.add(_Element.nonLus(_nonLusOuverture));
      final avant = i > 0 ? messages[i - 1] : null;
      final apres = i < messages.length - 1 ? messages[i + 1] : null;
      bool meme(Message? a, Message b) =>
          a != null &&
          a.type != TypeMessage.systeme &&
          b.type != TypeMessage.systeme &&
          a.auteurId == b.auteurId &&
          a.date.difference(b.date).inMinutes.abs() < 3 &&
          a.date.day == b.date.day &&
          b.id != _premierNonLu &&
          a.id != _premierNonLu;
      elements.add(_Element.message(m, debut: !meme(avant, m), fin: !meme(apres, m)));
    }
    return elements;
  }

  Widget _construire(BuildContext context, _Element e, Discussion d, double largeurMax, String q) {
    switch (e.genre) {
      case _Genre.chiffrement:
        return _AvisChiffrement(vide: context.lire.depot.messages(d.id).isEmpty, onBonjour: () => _envoyer('👋'));
      case _Genre.jour:
        return _Pastille(texte: separateurJour(context, e.date!));
      case _Genre.nonLus:
        return _SeparateurNonLus(texte: context.l.chUnreadMessages(e.compte));
      case _Genre.message:
        final m = e.message!;
        if (m.type == TypeMessage.systeme) {
          return KeyedSubtree(key: _cle(m.id), child: _Pastille(texte: texteSysteme(context, m), systeme: true));
        }
        return Bulle(
          key: ValueKey(m.id),
          message: m,
          discussion: d,
          cle: _cle(m.id),
          debutSerie: e.debut,
          finSerie: e.fin,
          largeurMax: largeurMax,
          surligne: q.length >= 2 ? q : null,
          clignote: _clignote == m.id,
          nouveau: DateTime.now().difference(m.date).inSeconds < 3,
          onMenu: () => _menu(m, debutSerie: e.debut, finSerie: e.fin, largeurMax: largeurMax),
          onReagir: (pos) => barreReactions(
            context,
            position: pos,
            actuelles: [
              for (final r in m.reactions.entries)
                if (r.value.contains(kMoi)) r.key,
            ],
            onChoix: (emoji) => context.lire.depot.reagir(m, emoji),
          ),
          onAllerA: _allerA,
          onVoirImage: (m) => ouvrirVisionneuse(context, m),
        );
    }
  }
}

enum _Genre { chiffrement, jour, nonLus, message }

class _Element {
  const _Element.chiffrement()
      : genre = _Genre.chiffrement,
        message = null,
        date = null,
        compte = 0,
        debut = false,
        fin = false;
  _Element.jour(DateTime this.date)
      : genre = _Genre.jour,
        message = null,
        compte = 0,
        debut = false,
        fin = false;
  _Element.nonLus(this.compte)
      : genre = _Genre.nonLus,
        message = null,
        date = null,
        debut = false,
        fin = false;
  _Element.message(Message this.message, {required this.debut, required this.fin})
      : genre = _Genre.message,
        date = null,
        compte = 0;

  final _Genre genre;
  final Message? message;
  final DateTime? date;
  final int compte;
  final bool debut;
  final bool fin;
}

// ── L'en-tête ──────────────────────────────────────────────────────────

class _Entete extends StatelessWidget {
  const _Entete({
    required this.discussion,
    required this.onRetour,
    required this.recherche,
    required this.champRecherche,
    required this.onRecherche,
    required this.resultats,
    required this.resultat,
    required this.onResultat,
  });

  final Discussion discussion;
  final VoidCallback? onRetour;
  final bool recherche;
  final TextEditingController champRecherche;
  final ValueChanged<String> onRecherche;
  final int resultats;
  final int resultat;
  final ValueChanged<int> onResultat;

  @override
  Widget build(BuildContext context) {
    final depot = context.depot;
    final ui = context.ui;
    final l = context.l;
    final t = context.t;
    final d = discussion;
    final contact = depot.interlocuteur(d);
    final ecrivent = depot.enTrainDecrire[d.id] ?? const <String>{};
    final menu = GlobalKey();

    String sousTitre;
    Color couleurSous = OuroColors.secondaryLabel;
    if (ecrivent.isNotEmpty) {
      sousTitre = d.estGroupe ? l.chGroupTyping(ecrivent.map(depot.nom).join(', ')) : l.chTypingNow;
      couleurSous = OuroColors.accent;
    } else if (d.estGroupe) {
      sousTitre = [...d.membres.map(depot.nom), t.vous].join(', ');
    } else {
      sousTitre = contact == null ? '' : vuA(context, contact);
    }

    return Verre(
      bordBas: true,
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            if (onRetour != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: BoutonIcone(icone: Icons.arrow_back_ios_new_rounded, couleur: OuroColors.accent, taille: 20, onTap: onRetour),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: recherche
                    ? Row(
                        key: const ValueKey('recherche'),
                        children: [
                          Expanded(
                            child: ChampRecherche(
                              controleur: champRecherche,
                              indication: l.chSearchInConversation,
                              autofocus: true,
                              onChanged: onRecherche,
                              onSubmitted: (_) => onResultat(1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (champRecherche.text.trim().length >= 2)
                            Text(
                              resultats == 0 ? l.chNoneFound : l.chSearchResultPosition(resultat + 1, resultats),
                              style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
                            ),
                          BoutonIcone(icone: Icons.keyboard_arrow_up_rounded, aide: l.chOlderResult, onTap: resultats == 0 ? null : () => onResultat(1)),
                          BoutonIcone(icone: Icons.keyboard_arrow_down_rounded, aide: l.chNewerResult, onTap: resultats == 0 ? null : () => onResultat(-1)),
                          TextButton(
                            onPressed: () {
                              champRecherche.clear();
                              onRecherche('');
                              ui.basculerRecherche(false);
                            },
                            child: Text(l.actionDone, style: OuroTypography.headline.copyWith(color: OuroColors.accent)),
                          ),
                        ],
                      )
                    : Survol(
                        key: const ValueKey('titre'),
                        onTap: () => ui.basculerInfos(),
                        builder: (context, survol) => Row(
                          children: [
                            AvatarDroplet(
                              nom: d.titre,
                              couleur: d.couleur,
                              taille: 40,
                              groupe: d.estGroupe,
                              enLigne: contact?.enLigne ?? false,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          d.titre,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: OuroTypography.headline.copyWith(color: OuroColors.label),
                                        ),
                                      ),
                                      if (d.sourdine) ...[
                                        const SizedBox(width: 5),
                                        Icon(Icons.volume_off_rounded, size: 14, color: OuroColors.tertiaryLabel),
                                      ],
                                    ],
                                  ),
                                  if (sousTitre.isNotEmpty)
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Text(
                                        survol && ecrivent.isEmpty ? t.cliquerInfos : sousTitre,
                                        key: ValueKey(survol && ecrivent.isEmpty ? 'aide' : sousTitre),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: OuroTypography.caption1.copyWith(color: couleurSous),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (!recherche) ...[
              BoutonIcone(
                icone: Icons.videocam_outlined,
                aide: l.chVideoCall,
                couleur: OuroColors.accent,
                onTap: () => lancerAppel(context, d, video: true),
              ),
              BoutonIcone(
                icone: Icons.phone_outlined,
                aide: l.chVoiceCall,
                couleur: OuroColors.accent,
                onTap: () => lancerAppel(context, d, video: false),
              ),
              BoutonIcone(
                icone: Icons.search_rounded,
                aide: l.chSearchInConversation,
                onTap: () => ui.basculerRecherche(true),
              ),
              BoutonIcone(
                key: menu,
                icone: Icons.more_vert_rounded,
                aide: t.plus,
                onTap: () {
                  final box = menu.currentContext!.findRenderObject() as RenderBox;
                  menuEntete(context, d, box.localToGlobal(Offset(box.size.width, box.size.height)));
                },
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// Le menu « ⋮ » de l'en-tête.
void menuEntete(BuildContext context, Discussion d, Offset position) {
  final p = context.lire;
  final depot = p.depot;
  final l = context.l;
  final t = context.t;
  final contact = depot.interlocuteur(d);
  montrerMenu(
    context,
    position: position,
    elements: [
      ElementMenu(
        icone: Icons.info_outline_rounded,
        libelle: d.estGroupe ? l.giGroupInfo : l.ciInfoTitle,
        onTap: () => p.ui.basculerInfos(true),
      ),
      ElementMenu(
        icone: d.sourdine ? Icons.volume_up_outlined : Icons.volume_off_outlined,
        libelle: d.sourdine ? l.chatsUnmute : l.chatsMute,
        onTap: () => depot.sourdine(d),
      ),
      ElementMenu(icone: Icons.timer_outlined, libelle: l.ciEphemeralMessages, onTap: () => choisirEphemere(context, d)),
      ElementMenu(
        icone: Icons.cleaning_services_outlined,
        libelle: t.viderDiscussion,
        section: true,
        onTap: () async {
          final i = await alerte(
            context,
            titre: t.viderDiscussion,
            message: t.viderTexte,
            actions: [ActionAlerte(l.actionCancel), ActionAlerte(t.vider, destructif: true)],
          );
          if (i == 1) depot.vider(d);
        },
      ),
      if (contact != null)
        ElementMenu(
          icone: Icons.block_rounded,
          libelle: contact.bloque ? l.ciUnblock : l.ciBlock,
          destructif: !contact.bloque,
          onTap: () async {
            if (contact.bloque) {
              depot.bloquer(contact);
              return;
            }
            final i = await alerte(
              context,
              titre: l.ciBlockContactTitle,
              message: l.ciBlockContactBody(contact.pseudo),
              actions: [ActionAlerte(l.actionCancel), ActionAlerte(l.ciBlock, destructif: true)],
            );
            if (i == 1) depot.bloquer(contact);
          },
        ),
      ElementMenu(
        icone: Icons.delete_outline_rounded,
        libelle: l.chatsDelete,
        destructif: true,
        onTap: () => confirmerSuppression(context, d),
      ),
    ],
  );
}

// ── Les éléments du fil ────────────────────────────────────────────────

class _Pastille extends StatelessWidget {
  const _Pastille({required this.texte, this.systeme = false});

  final String texte;
  final bool systeme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemGroupedBackground.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 3, offset: const Offset(0, 1))],
        ),
        child: Text(
          texte,
          textAlign: TextAlign.center,
          style: OuroTypography.caption1.copyWith(
            color: OuroColors.secondaryLabel,
            fontWeight: systeme ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SeparateurNonLus extends StatelessWidget {
  const _SeparateurNonLus({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 6),
        color: OuroColors.accent.withValues(alpha: 0.08),
        alignment: Alignment.center,
        child: Text(texte, style: OuroTypography.caption1.copyWith(color: OuroColors.accent, fontWeight: FontWeight.w600)),
      );
}

class _AvisChiffrement extends StatelessWidget {
  const _AvisChiffrement({required this.vide, required this.onBonjour});

  final bool vide;
  final VoidCallback onBonjour;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Column(
      children: [
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            margin: const EdgeInsets.only(top: 6, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: (OuroColors.isDark ? const Color(0xFF3A3220) : const Color(0xFFFFF5D6)).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 13, color: OuroColors.isDark ? const Color(0xFFFFD60A) : const Color(0xFF8A6D00)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l.chE2eNotice,
                    textAlign: TextAlign.center,
                    style: OuroTypography.caption1.copyWith(color: OuroColors.isDark ? const Color(0xFFFFE58F) : const Color(0xFF6B5500)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (vide)
          Padding(
            padding: const EdgeInsets.only(top: 40, bottom: 20),
            child: Column(
              children: [
                const Text('👋', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 10),
                BoutonPlein(texte: l.chSayHello, onTap: onBonjour),
              ],
            ),
          ),
      ],
    );
  }
}

class _BarreEpingle extends StatelessWidget {
  const _BarreEpingle({required this.messages, required this.index, required this.onTap, required this.onRetirer});

  final List<Message> messages;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRetirer;

  @override
  Widget build(BuildContext context) {
    final m = messages[index];
    final l = context.l;
    return Verre(
      bordBas: true,
      child: Survol(
        onTap: onTap,
        builder: (context, survol) => Container(
          height: 50,
          color: survol ? OuroColors.label.withValues(alpha: 0.03) : Colors.transparent,
          padding: const EdgeInsets.only(left: 16, right: 6),
          child: Row(
            children: [
              // Les traits de gauche : un par message épinglé, le courant
              // en couleur.
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < messages.length; i++)
                    Container(
                      width: 3,
                      height: 30 / messages.length - 2,
                      margin: const EdgeInsets.symmetric(vertical: 1),
                      decoration: BoxDecoration(
                        color: i == messages.length - 1 - index ? OuroColors.accent : OuroColors.systemGray3,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Transform.rotate(angle: 0.6, child: Icon(Icons.push_pin_rounded, size: 16, color: OuroColors.accent)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      messages.length > 1 ? l.chPinnedMessageN('${index + 1}/${messages.length}') : l.chPinnedMessage,
                      style: OuroTypography.caption1.copyWith(color: OuroColors.accent, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      texteMessage(context, m).replaceAll('\n', ' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: OuroTypography.subheadline.copyWith(color: OuroColors.label),
                    ),
                  ],
                ),
              ),
              BoutonIcone(icone: Icons.close_rounded, taille: 18, diametre: 32, aide: l.chUnpin, onTap: onRetirer),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoutonBas extends StatelessWidget {
  const _BoutonBas({required this.compte, required this.onTap});

  final int compte;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Survol(
      onTap: onTap,
      builder: (context, survol) => Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: survol ? 0.2 : 0.12), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: Verre(
              rayon: 21,
              opacite: 0.9,
              child: SizedBox(
                width: 42,
                height: 42,
                child: Icon(Icons.keyboard_arrow_down_rounded, color: OuroColors.secondaryLabel, size: 28),
              ),
            ),
          ),
          if (compte > 0)
            Positioned(
              top: -6,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: OuroColors.accentRempli, borderRadius: BorderRadius.circular(10)),
                child: Text('$compte', style: OuroTypography.caption2.copyWith(color: OuroColors.texteSurAccent, fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

class _VoileDepot extends StatelessWidget {
  const _VoileDepot({required this.nom});

  final String nom;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OuroColors.systemBackground.withValues(alpha: 0.86),
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: OuroColors.accent, width: 2),
          color: OuroColors.accent.withValues(alpha: 0.06),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_upload_outlined, size: 56, color: OuroColors.accent),
            const SizedBox(height: 14),
            Text(context.t.deposerIci(nom), textAlign: TextAlign.center, style: OuroTypography.title3.copyWith(color: OuroColors.label)),
          ],
        ),
      ),
    );
  }
}

// ── L'aperçu avant envoi ───────────────────────────────────────────────

class _ApercuEnvoi extends StatefulWidget {
  const _ApercuEnvoi({
    required this.pieces,
    required this.destinataire,
    required this.onAjouter,
    required this.onRetirer,
    required this.onFermer,
    required this.onEnvoyer,
  });

  final List<PieceJointe> pieces;
  final String destinataire;
  final ValueChanged<List<PieceJointe>> onAjouter;
  final ValueChanged<int> onRetirer;
  final VoidCallback onFermer;
  final ValueChanged<String> onEnvoyer;

  @override
  State<_ApercuEnvoi> createState() => _ApercuEnvoiState();
}

class _ApercuEnvoiState extends State<_ApercuEnvoi> {
  final _legende = TextEditingController();
  int _choisie = 0;

  @override
  void dispose() {
    _legende.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = context.t;
    final pieces = widget.pieces;
    final i = _choisie.clamp(0, pieces.length - 1);
    final p = pieces[i];
    final image = p.mime.startsWith('image/');
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onFermer,
        const SingleActivator(LogicalKeyboardKey.enter): () => widget.onEnvoyer(_legende.text.trim()),
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: kSortie,
        builder: (context, v, enfant) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 30 * (1 - v)), child: enfant)),
        child: ColoredBox(
          color: OuroColors.systemGroupedBackground,
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    BoutonIcone(icone: Icons.close_rounded, aide: l.actionCancel, onTap: widget.onFermer),
                    Expanded(
                      child: Text(
                        image ? p.nom : l.chatsDocument,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: OuroTypography.headline.copyWith(color: OuroColors.label),
                      ),
                    ),
                    const SizedBox(width: 46),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  child: Center(
                    child: image
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(p.url, fit: BoxFit.contain),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 110,
                                height: 130,
                                decoration: BoxDecoration(color: OuroColors.secondarySystemGroupedBackground, borderRadius: BorderRadius.circular(16)),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.insert_drive_file_rounded, size: 52, color: OuroColors.systemIndigo),
                                    const SizedBox(height: 6),
                                    Text(extension(p.nom), style: OuroTypography.headline.copyWith(color: OuroColors.secondaryLabel)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(p.nom, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
                              const SizedBox(height: 4),
                              Text(taille(context, p.taille), style: OuroTypography.subheadline.copyWith(color: OuroColors.secondaryLabel)),
                            ],
                          ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ChampTexte(
                      controleur: _legende,
                      indication: l.apCaptionHint,
                      autofocus: true,
                      lignesMax: 4,
                      onSubmitted: (_) => widget.onEnvoyer(_legende.text.trim()),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                height: 96,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: OuroColors.separator, width: 0.5))),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (var k = 0; k < pieces.length; k++)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Survol(
                                onTap: () => setState(() => _choisie = k),
                                builder: (context, survol) => Stack(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 160),
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: k == i ? OuroColors.accent : Colors.transparent, width: 2.5),
                                        color: OuroColors.tertiarySystemFill,
                                        image: pieces[k].mime.startsWith('image/')
                                            ? DecorationImage(image: NetworkImage(pieces[k].url), fit: BoxFit.cover)
                                            : null,
                                      ),
                                      child: pieces[k].mime.startsWith('image/')
                                          ? null
                                          : Icon(Icons.insert_drive_file_rounded, color: OuroColors.secondaryLabel),
                                    ),
                                    if (survol)
                                      Positioned(
                                        right: 2,
                                        top: 2,
                                        child: GestureDetector(
                                          onTap: () => widget.onRetirer(k),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                            child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          Survol(
                            onTap: () async {
                              final p = await Navigateur.choisirFichiers();
                              if (p.isNotEmpty) widget.onAjouter(p);
                            },
                            builder: (context, survol) => Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: OuroColors.separator, width: 1.2),
                                color: survol ? OuroColors.tertiarySystemFill : Colors.transparent,
                              ),
                              child: Icon(Icons.add_rounded, color: OuroColors.secondaryLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Tooltip(
                      message: t.envoyerA(widget.destinataire),
                      child: Survol(
                        onTap: () => widget.onEnvoyer(_legende.text.trim()),
                        builder: (context, survol) => AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: OuroColors.accentRempli,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: OuroColors.accent.withValues(alpha: survol ? 0.45 : 0.3), blurRadius: 18, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.send_rounded, color: OuroColors.texteSurAccent, size: 26),
                              if (pieces.length > 1)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: OuroColors.systemBackground,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: OuroColors.accent, width: 1.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${pieces.length}',
                                      style: OuroTypography.caption2.copyWith(color: OuroColors.accent, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Une réaction rapide utilisée par d'autres écrans.
void reagirRapide(BuildContext context, Message m, String emoji) {
  retenirEmoji(emoji);
  context.lire.depot.reagir(m, emoji);
}
