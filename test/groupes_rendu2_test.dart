// ============================================================================
// LES ÉCRANS DE GROUPE, RENDUS AVEC UN FAUX GROUPE.
// ----------------------------------------------------------------------------
// « Infos du groupe » vu par un administrateur (avec une demande
// d'adhésion), puis par un simple membre ; « Paramètres du groupe ».
// Clair et sombre. Les images vont dans `build/rendu_accueil/`.
// ============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:droplet/core/models/mesh_message.dart';
import 'package:droplet/design_system/ouro_colors.dart';
import 'package:droplet/design_system/ouro_list.dart';
import 'package:droplet/design_system/ouro_theme.dart';
import 'package:droplet/features/chat/mise_en_forme.dart';
import 'package:droplet/features/group/group_create_screen.dart';
import 'package:droplet/features/group/parametres_groupe_screen.dart';
import 'package:droplet/features/group/reglages_groupe.dart';
import 'package:droplet/features/group/vue_infos_groupe.dart';
import 'package:droplet/l10n/generated/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _dossier = Directory('build/rendu_accueil');

Future<void> _polices() async {
  for (final (famille, fichier) in [
    ('Inter Tight', 'assets/fonts/InterTight_700Bold.ttf'),
    ('Inter', 'assets/fonts/InterTight_600SemiBold.ttf'),
    ('packages/cupertino_icons/CupertinoIcons', 'packages/cupertino_icons/assets/CupertinoIcons.ttf'),
    ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
  ]) {
    final f = FontLoader(famille)..addFont(rootBundle.load(fichier));
    await f.load();
  }
}

GroupInfo _groupe() {
  final t = DateTime(2026, 9, 14, 18, 30);
  GroupMemberRecord m(String id, {bool admin = false}) => GroupMemberRecord(peerId: id, role: admin ? 'admin' : 'member', addedAt: t, addedBy: 'moi');
  return GroupInfo(
    id: 'g1',
    name: 'Famille Ndongo',
    createdBy: 'moi',
    createdAt: t,
    updatedAt: t,
    members: [m('moi', admin: true), m('awa', admin: true), m('miguel'), m('sara'), m('yann'), m('lea')],
  );
}

const _noms = {'moi': 'Rito', 'awa': 'Awa', 'miguel': 'Miguel', 'sara': 'Sara Mballa', 'yann': 'Yann', 'lea': 'Léa', 'paul': 'Paul Essomba'};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await _polices();
    _dossier.createSync(recursive: true);
  });

  final actions = ActionsInfosGroupe(
    changerPhoto: () {},
    renommer: () {},
    modifierDescription: () {},
    appeler: () {},
    ajouter: () {},
    inviter: () {},
    medias: () {},
    importants: () {},
    parametres: () {},
    membre: (_) {},
    accepterDemande: (_) {},
    refuserDemande: (_) {},
    quitter: () {},
  );

  Future<void> rendre(WidgetTester tester, Widget ecran, String nom, {required bool sombre, double hauteur = 2000}) async {
    tester.view.physicalSize = Size(390, hauteur) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final b = sombre ? Brightness.dark : Brightness.light;
    OuroColors.setBrightness(b);
    final cle = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: cle,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: OuroTheme.of(b),
        home: ecran,
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(() async {
      final boite = cle.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boite.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('${_dossier.path}/$nom.png').writeAsBytesSync(png!.buffer.asUint8List());
      image.dispose();
    });
    await tester.pumpWidget(const SizedBox());
  }

  for (final sombre in [false, true]) {
    final mode = sombre ? 'sombre' : 'clair';
    for (final (qui, moi) in [('admin', 'moi'), ('membre', 'yann')]) {
      testWidgets('infos du groupe $qui $mode', (tester) async {
        final reglages = ReglagesGroupe(
          description: 'Le groupe de la famille 💙 Photos, nouvelles et organisation des fêtes.',
          infosAdminsSeuls: qui == 'membre',
          majA: DateTime(2026),
        );
        await rendre(
          tester,
          VueInfosGroupe(
            retour: const Icon(CupertinoIcons.chevron_back),
            donnees: DonneesInfosGroupe(
              groupe: _groupe(),
              moi: moi,
              reglages: reglages,
              nom: (id) => _noms[id] ?? id,
              enLigne: (id) => id == 'awa' || id == 'miguel',
              photoMembre: (_) => null,
              demandes: [DemandeAdhesion(groupId: 'g1', peerId: 'paul', quand: DateTime(2026, 10, 28, 19, 12))],
              nbMedias: 128,
              nbImportants: 4,
            ),
            actions: actions,
            ligneNotifs: OuroListSection(children: [
              OuroListRow(title: 'Notifications', subtitle: 'Activées', icon: CupertinoIcons.bell_fill, iconColor: OuroColors.systemRed, onTap: () {}),
            ]),
          ),
          'groupe_infos_${qui}_$mode',
          sombre: sombre,
        );
      });
    }
    testWidgets('paramètres du groupe $mode', (tester) async {
      await rendre(
        tester,
        VueParametresGroupe(
          reglages: ReglagesGroupe(ajoutAdminsSeuls: false, approbation: true, majA: DateTime(2026)),
          admin: true,
          changer: (_) {},
          modifierAdmins: () {},
          retour: const Icon(CupertinoIcons.chevron_back),
        ),
        'groupe_parametres_$mode',
        sombre: sombre,
        hauteur: 844,
      );
    });
  }

  const candidats = [
    CandidatGroupe(peerId: 'awa', pseudo: 'Awa', enLigne: true),
    CandidatGroupe(peerId: 'miguel', pseudo: 'Miguel', enLigne: true),
    CandidatGroupe(peerId: 'sara', pseudo: 'Sara Mballa', enLigne: false),
    CandidatGroupe(peerId: 'yann', pseudo: 'Yann', enLigne: false),
    CandidatGroupe(peerId: 'lea', pseudo: 'Léa', enLigne: false),
    CandidatGroupe(peerId: 'paul', pseudo: 'Paul Essomba', enLigne: false),
  ];
  for (final sombre in [false, true]) {
    final mode = sombre ? 'sombre' : 'clair';
    for (final etape in [0, 1]) {
      testWidgets('création de groupe étape $etape $mode', (tester) async {
        await rendre(
          tester,
          VueCreationGroupe(
            candidats: candidats,
            creer: (_, _, _, _) async => true,
            fermer: () {},
            choisirPhoto: () async => null,
            etapeInitiale: etape,
            selectionInitiale: const {'awa', 'sara', 'yann'},
            nomInitial: etape == 1 ? 'Famille Ndongo' : '',
          ),
          'groupe_creation_${etape}_$mode',
          sombre: sombre,
          hauteur: 844,
        );
      });
    }
  }

  // Les mentions en pastille, dans une bulle reçue et dans une des miennes.
  for (final sombre in [false, true]) {
    final mode = sombre ? 'sombre' : 'clair';
    testWidgets('mentions $mode', (tester) async {
      Mentions.pseudos = ['Awa', 'Miguel', 'Rito'];
      Mentions.monPseudo = 'Rito';
      Mentions.couleurDe = (p) => p.toLowerCase() == 'awa' ? const Color(0xFF34C759) : const Color(0xFFFF9500);
      Widget bulle(String texte, {required bool mien}) => Align(
            alignment: mien ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              constraints: const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                color: mien ? OuroColors.bubbleOutgoing : OuroColors.bubbleIncoming,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TexteMisEnForme(
                texte: texte,
                surCouleur: mien,
                style: TextStyle(fontSize: 16, color: mien ? OuroColors.bubbleOutgoingText : OuroColors.bubbleIncomingText),
              ),
            ),
          );
      await rendre(
        tester,
        Scaffold(
          backgroundColor: OuroColors.systemBackground,
          body: SafeArea(
            child: Column(
              children: [
                bulle('@tous le cours a commencé…', mien: false),
                bulle('@Awa tu peux envoyer le TD1 ? Merci @Miguel aussi', mien: false),
                bulle('@Rito tu as vu le message ?', mien: false),
                bulle('Écris-moi à rito@exemple.cm', mien: false),
                bulle('@tous rendez-vous à 14 h, @Awa apporte le projecteur', mien: true),
              ],
            ),
          ),
        ),
        'mentions_$mode',
        sombre: sombre,
        hauteur: 520,
      );
    });
  }
}
