import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_tab_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../chats/chats_screen.dart';
import '../news/news_screen.dart';
import '../calls/calls_screen.dart';
import '../peers/peers_screen.dart';
import '../tor/tor_status_indicator.dart';
import '../../core/providers/mesh_provider.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _currentIndex = 0;
  bool _tabBarMinimized = false;
  double _scrollRun = 0;

  static const double _minimizeThreshold = 24;
  static const double _alwaysVisibleZone = 40;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta == 0) return false;

      if (delta.sign != _scrollRun.sign) _scrollRun = 0;
      _scrollRun += delta;

      final atTop = notification.metrics.pixels < _alwaysVisibleZone;
      final minimize = !atTop && _scrollRun > _minimizeThreshold;
      final restore = _scrollRun < -_minimizeThreshold || atTop;

      if (minimize && !_tabBarMinimized) {
        setState(() => _tabBarMinimized = true);
      } else if (restore && _tabBarMinimized) {
        setState(() => _tabBarMinimized = false);
      }
    }
    return false;
  }

  static const _pages = [
    ChatsScreen(),
    NewsScreen(),
    CallsScreen(),
    PeersScreen(),
  ];

  // ⚠️ CE N'EST PLUS `static const`.
  //
  // Les libellés viennent maintenant de `AppLocalizations`, qui a
  // besoin d'un `BuildContext` — une constante ne peut pas en dépendre.
  // Le coût (reconstruire quatre petits objets à chaque `build`) est
  // négligeable à côté de ce que gagne l'app entière à afficher la
  // bonne langue.
  List<OuroTabItem> _items(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Ce qui attend derrière l'onglet : on le dit sur l'icône plutôt que de
    // laisser la personne ouvrir pour vérifier.
    final nonLus = ref
        .watch(conversationsProvider)
        .fold<int>(0, (t, c) => t + c.unreadCount);
    return [
      OuroTabItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: l10n.tabChats,
        badge: nonLus,
      ),
      OuroTabItem(
        // L'icône des ondes, revenue à la demande : le cercle ouvert qui
        // l'avait remplacée ressemblait à un indicateur de chargement.
        icon: Icons.podcasts_outlined,
        activeIcon: Icons.podcasts_rounded,
        label: l10n.tabNews,
      ),
      OuroTabItem(
        icon: Icons.phone_outlined,
        activeIcon: Icons.phone_rounded,
        label: l10n.tabCalls,
      ),
      OuroTabItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: l10n.tabPeers,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // ⚠️ CLAVIER OUVERT : LA BARRE D'ONGLETS DISPARAÎT. L'écran se réduit
    // au-dessus du clavier, et la barre (avec l'indicateur Tor), posée en
    // bas, remontait avec lui jusqu'au milieu de l'écran et recouvrait la
    // liste pendant qu'on cherchait. WhatsApp la masque de la même façon.
    final clavier = mq.viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: OuroColors.systemBackground,
      body: Stack(
        children: [
          MediaQuery(
            data: mq.copyWith(
              // ⚠️ LE CLAVIER ÉTAIT COMPTÉ DEUX FOIS. Ce `Scaffold` réduit
              // déjà son corps au-dessus du clavier, mais `mq` a été lu
              // AVANT lui et contient encore la hauteur du clavier : les
              // écrans des onglets (qui ont leur propre `Scaffold`) se
              // réduisaient une seconde fois. Résultat à l'accueil : la
              // liste coupée au premier tiers de l'écran pendant une
              // recherche, et le grand titre poussé sous la barre.
              viewInsets: mq.viewInsets.copyWith(bottom: 0),
              padding: mq.padding.copyWith(
                bottom: clavier ? 0 : OuroTabBar.reservedHeight(mq.padding.bottom),
              ),
            ),
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ),
          // LE FONDU DU BAS — la profondeur de Telegram, faite à l'iOS.
          //
          // Sans lui, le contenu passe derrière la barre flottante et se
          // coupe net sur son bord : on voit un demi-mot, une demi-ligne.
          // Ici, les dernières lignes s'effacent progressivement dans le
          // fond ET se brouillent d'un cheveu, exactement comme la barre
          // de lecture d'Apple Music. Le dégradé sert aussi de masque au
          // flou : pas de bande floue à bord franc, ce qui trahirait le
          // procédé.
          if (!clavier)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: OuroTabBar.reservedHeight(mq.padding.bottom) + 30,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  // Barre repliée : le fondu s'efface avec elle, sinon il
                  // resterait un voile sans raison.
                  opacity: _tabBarMinimized ? 0.35 : 1,
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (rect) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // Le fondu ne devient franc qu'au niveau de la
                      // barre : la dernière ligne reste lisible, elle
                      // s'estompe seulement quand elle passe dessous.
                      colors: [Color(0x00000000), Color(0xFF000000)],
                      stops: [0.08, 0.82],
                    ).createShader(rect),
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                OuroColors.systemBackground.withValues(alpha: 0),
                                OuroColors.systemBackground.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (!clavier)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TorStatusIndicator(),
                OuroTabBar(
                  items: _items(context),
                  currentIndex: _currentIndex,
                  minimized: _tabBarMinimized,
                  onTap: (i) => setState(() {
                    _currentIndex = i;
                    _tabBarMinimized = false;
                    _scrollRun = 0;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
