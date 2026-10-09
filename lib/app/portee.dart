// LA PORTÉE — ce que tous les écrans partagent.
//
//   • le DÉPÔT : les données (discussions, messages, statuts, appels…) ;
//   • l'INTERFACE : ce qui est ouvert à l'écran (onglet, discussion, panneau
//     d'infos, recherche dans la discussion) ;
//   • les TEXTES propres au web, en plus des traductions de l'app.
//
// Un écran qui lit `context.depot` se reconstruit à chaque changement ;
// `context.lire` donne la même chose sans s'abonner, pour les rappels.
import 'package:flutter/widgets.dart';

import '../donnees/depot.dart';
import '../l10n/generated/app_localizations.dart';
import '../textes.dart';

enum Onglet { discussions, actus, appels, reglages }

class Interface extends ChangeNotifier {
  Onglet onglet = Onglet.discussions;

  /// Le panneau d'infos (contact ou groupe) à droite de la discussion.
  bool infos = false;

  /// La recherche dans la discussion ouverte.
  bool rechercheDiscussion = false;

  /// Le message à faire clignoter (arrivée depuis la recherche, une
  /// réponse citée, un message important…).
  String? messageCible;

  /// Les non-lus de la discussion au moment où on l'ouvre : la vue y
  /// pose le séparateur « N messages non lus ».
  int nonLusOuverture = 0;

  /// Un navigateur par onglet dans la colonne de gauche : les panneaux
  /// (nouvelle discussion, archives, profil…) s'y empilent comme sur iOS,
  /// et chaque onglet garde sa pile.
  final Map<Onglet, GlobalKey<NavigatorState>> cles = {
    for (final o in Onglet.values) o: GlobalKey<NavigatorState>(debugLabel: 'gauche-${o.name}'),
  };

  GlobalKey<NavigatorState> get cleGauche => cles[onglet]!;

  /// Le champ de recherche de la liste (Ctrl+Alt+/).
  final focusRecherche = FocusNode();

  void changerOnglet(Onglet o) {
    if (onglet == o) {
      // Retoucher l'onglet actif ramène à sa racine, comme sur iPhone.
      cleGauche.currentState?.popUntil((r) => r.isFirst);
      return;
    }
    onglet = o;
    notifyListeners();
  }

  void basculerInfos([bool? valeur]) {
    infos = valeur ?? !infos;
    notifyListeners();
  }

  void basculerRecherche([bool? valeur]) {
    rechercheDiscussion = valeur ?? !rechercheDiscussion;
    notifyListeners();
  }

  void cibler(String? id) {
    messageCible = id;
    notifyListeners();
  }

  void rafraichir() => notifyListeners();
}

class Portee extends InheritedNotifier<Listenable> {
  Portee({
    super.key,
    required this.depot,
    required this.ui,
    required this.textes,
    required super.child,
  }) : super(notifier: Listenable.merge([depot, ui]));

  final Depot depot;
  final Interface ui;
  final Textes textes;

  static Portee of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Portee>()!;

  static Portee lire(BuildContext context) => context.getInheritedWidgetOfExactType<Portee>()!;
}

extension PorteeContexte on BuildContext {
  Depot get depot => Portee.of(this).depot;
  Interface get ui => Portee.of(this).ui;
  Textes get t => Portee.lire(this).textes;
  AppLocalizations get l => AppLocalizations.of(this);

  /// Sans s'abonner : pour les rappels (onTap…).
  Portee get lire => Portee.lire(this);
}
