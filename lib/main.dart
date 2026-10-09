// DROPLET WEB — vos discussions Droplet dans le navigateur.
//
// Deux portes d'entrée :
//
//   • l'ÉCRAN DE LIAISON : le code QR que le téléphone scanne pour faire de
//     ce navigateur un appareil associé (le modèle de l'étude « Droplet
//     Web — étude de faisabilité ») ;
//   • la DÉMONSTRATION (`?apercu`, ou le lien sous la carte) : l'interface
//     complète, avec des discussions d'exemple et un réseau simulé.
//
// Les deux mènent à la même coquille, sur le même dépôt. Seul le transport
// change : `TransportDemo` aujourd'hui, le transport chiffré des serveurs
// Droplet demain (voir `donnees/transport.dart`).
//
// Lancer : flutter run -d chrome
// Construire : flutter build web --release   (sortie dans build/web)
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:web/web.dart' as web;

import 'app/coquille.dart';
import 'app/portee.dart';
import 'design_system/ouro_colors.dart';
import 'design_system/ouro_typography.dart';
import 'design_system/reglages_apparence.dart';
import 'donnees/depot.dart';
import 'donnees/modeles.dart';
import 'donnees/transport.dart';
import 'l10n/generated/app_localizations.dart';
import 'liaison/ecran_liaison.dart';
import 'textes.dart';
import 'web/navigateur.dart';

Future<void> main() async {
  await initializeDateFormatting();
  // Le rose de la goutte : la couleur de Droplet tant que les réglages
  // n'en ont pas choisi une autre.
  ReglagesApparence.accent = ReglagesApparence.accentParCle('rose');
  runApp(const DropletWeb());
}

class DropletWeb extends StatefulWidget {
  const DropletWeb({super.key});

  @override
  State<DropletWeb> createState() => _DropletWebState();
}

class _DropletWebState extends State<DropletWeb> with WidgetsBindingObserver {
  final Textes _textes = Textes.choisies();
  Interface _ui = Interface();
  Depot? _depot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Uri.base.queryParameters.containsKey('apercu')) _entrerDemo();
  }

  void _entrerDemo() {
    _ui = Interface();
    final depot = Depot(transport: TransportDemo(langue: _textes.code), langue: _textes.code, demo: true);
    depot.addListener(_appliquerReglages);
    depot.onMessageRecu = (d, m) {
      if (d.sourdine) return;
      if (depot.reglages.sons) Navigateur.ploc();
      if (depot.reglages.notifications) {
        Navigateur.notifier(
          d.estGroupe ? '${depot.nom(m.auteurId)} · ${d.titre}' : d.titre,
          m.texte.isEmpty ? '📎' : m.texte,
          auClic: () {
            _ui.onglet = Onglet.discussions;
            depot.ouvrir(d.id);
            _ui.rafraichir();
          },
        );
      }
    };
    depot.demarrer();
    setState(() => _depot = depot);
    // L'adresse garde `?apercu` : un rechargement revient dans la démo.
    if (!Uri.base.queryParameters.containsKey('apercu')) {
      web.window.history.replaceState(null, '', '?apercu');
    }
  }

  void _quitter() {
    _depot?.removeListener(_appliquerReglages);
    _depot?.dispose();
    web.window.history.replaceState(null, '', web.window.location.pathname);
    setState(() => _depot = null);
  }

  /// Le thème, l'accent et la taille du texte suivent les réglages.
  void _appliquerReglages() {
    final r = _depot?.reglages;
    if (r == null) return;
    final accent = ReglagesApparence.accentParCle(r.accent);
    if (accent != ReglagesApparence.accent ||
        r.tailleTexte != ReglagesApparence.tailleTexte ||
        _theme != r.theme) {
      ReglagesApparence.accent = accent;
      ReglagesApparence.tailleTexte = r.tailleTexte;
      setState(() => _theme = r.theme);
    }
    Navigateur.titre(_depot!.totalNonLus);
  }

  ThemeChoisi _theme = ThemeChoisi.systeme;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _depot?.dispose();
    super.dispose();
  }

  // Le système passe en sombre (ou en clair) : toute la palette suit.
  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final systeme = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final luminosite = switch (_theme) {
      ThemeChoisi.clair => Brightness.light,
      ThemeChoisi.sombre => Brightness.dark,
      ThemeChoisi.systeme => systeme,
    };
    OuroColors.setBrightness(luminosite);

    final depot = _depot;
    return MaterialApp(
      // Un nouveau dépôt (démo, liaison, déconnexion) = une app neuve :
      // le navigateur repart de zéro, sans écran de l'ancienne session.
      key: ObjectKey(depot),
      title: 'Droplet Web',
      debugShowCheckedModeBanner: false,
      locale: Locale(_textes.code),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: luminosite,
        fontFamily: OuroTypography.fontFamily,
        scaffoldBackgroundColor: OuroColors.systemGroupedBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: OuroColors.accent, brightness: luminosite),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: OuroColors.accent,
          selectionColor: OuroColors.accent.withValues(alpha: 0.3),
        ),
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: OuroColors.isDark ? const Color(0xF23A3A3C) : const Color(0xF21C1C1E),
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: OuroTypography.caption1.copyWith(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStatePropertyAll(OuroColors.label.withValues(alpha: 0.22)),
          thickness: const WidgetStatePropertyAll(6),
          radius: const Radius.circular(3),
        ),
      ),
      // La portée enveloppe le navigateur lui-même : les alertes, menus et
      // écrans plein écran (appel, visionneuse) y ont accès aussi.
      builder: (context, enfant) => depot == null
          ? enfant!
          : Portee(depot: depot, ui: _ui, textes: _textes, child: enfant!),
      home: depot == null
          ? EcranLiaison(textes: _textes, onDemo: _entrerDemo)
          : Coquille(onDeconnexion: _quitter),
    );
  }
}
