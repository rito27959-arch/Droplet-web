// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// Gestionnaire du circuit Tor pour Droplet.
//
// Utilise le package `tor` (FFI natif Arti) pour créer un proxy SOCKS5
// local. Gère aussi l'identité Tor (clé Ed25519 + adresse .onion).
//
// ── ⚠️ UN SEUL ÉTAT, ET IL NE MENT PAS ────────────────────────────────
//
// C'est la règle qui structure tout ce fichier, et elle vient d'un vrai
// bug : l'app affichait « Tor actif » alors que RIEN ne passait par Tor.
//
// La cause était une double vérité. L'écran, l'indicateur et
// `torConnectedProvider` se fiaient à `_state == connected`. Le transport
// (`tor_transport.dart`), lui, exigeait EN PLUS `_tor.bootstrapped`. Or
// `start()` passait à `connected` sans jamais regarder `bootstrapped` :
// dès que le circuit ne s'établissait pas, les deux camps divergeaient —
// bandeau vert d'un côté, transport « indisponible » de l'autre, appareil
// jamais enregistré dans l'annuaire, recherche par pseudo vide.
//
// Désormais :
//   • [TorServiceState.connected] n'est atteint QUE si Tor est réellement
//     utilisable — voir [_vraimentPret] et la vérification du proxy ;
//   • [isConnected] vaut exactement `_state == connected`, sans condition
//     supplémentaire cachée. Plus aucun moyen que l'UI et le transport
//     soient en désaccord.
//
// ⚠️ NE RÉINTRODUIS PAS DE CONDITION ANNEXE DANS UN CONSOMMATEUR. Si une
// nouvelle exigence apparaît (port, identité, circuit…), elle doit être
// vérifiée ICI, avant de publier `connected`.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tor/tor.dart';

import 'onion_service.dart';

/// État du service Tor.
enum TorServiceState { stopped, connecting, connected, error }

/// Gestionnaire du proxy Tor local + identité hidden service.
class TorService {
  Tor? _tor;
  TorServiceState _state = TorServiceState.stopped;
  String? _lastError;
  OnionIdentity? _identity;
  Timer? _surveillance;

  final _stateCtrl = StreamController<TorServiceState>.broadcast();

  /// ⚠️ PLAFOND SUR L'ATTENTE DU CIRCUIT. `Tor.isReady()` (paquet `tor`)
  /// est une boucle `Future.doWhile` qui sonde toutes les secondes et ne
  /// s'arrête JAMAIS d'elle-même tant que le circuit ne s'établit pas.
  /// Sans plafond, un bootstrap qui n'aboutit pas (réseau filtré, FAI qui
  /// bloque Tor, horloge décalée) laissait `start()` suspendu pour
  /// toujours : l'utilisateur voyait « Connexion Tor » sans fin, sans
  /// message, sans moyen de comprendre.
  static const delaiBootstrap = Duration(seconds: 90);

  /// Rythme de la surveillance de santé — voir [_demarrerSurveillance].
  static const _intervalleSante = Duration(seconds: 30);

  TorServiceState get state => _state;
  String? get lastError => _lastError;

  /// ⚠️ REJOUE L'ÉTAT COURANT À CHAQUE NOUVEL ABONNÉ.
  ///
  /// `_stateCtrl` est un `broadcast` : il ne rejoue rien. Un widget qui
  /// s'abonnait APRÈS la connexion (le cas normal — l'écran Tor s'ouvre
  /// bien après le démarrage) restait donc bloqué sur `AsyncLoading`
  /// jusqu'au prochain changement, c'est-à-dire potentiellement jamais.
  /// `torStateProvider.valueOrNull` valait `null`, et l'écran affichait
  /// « Inactif » alors que Tor tournait — l'exact symétrique du bug
  /// décrit en tête de fichier.
  ///
  /// `Stream.multi` exécute son corps de façon synchrone à l'abonnement :
  /// l'état courant part avant tout autre événement, et `_setState` étant
  /// synchrone lui aussi, il n'y a aucune fenêtre où un changement
  /// pourrait se glisser dans le désordre.
  Stream<TorServiceState> get stateStream =>
      Stream<TorServiceState>.multi((controller) {
        controller.add(_state);
        final sub = _stateCtrl.stream.listen(
          controller.add,
          onError: controller.addError,
        );
        controller.onCancel = sub.cancel;
      });

  /// Vrai si Tor est réellement utilisable. Voir l'en-tête : c'est la
  /// SEULE condition, volontairement identique à celle de l'état publié.
  bool get isConnected => _state == TorServiceState.connected;

  /// Port SOCKS5 du proxy local. Retourne -1 si Tor n'est pas prêt.
  int get proxyPort => _tor?.port ?? -1;

  /// Identité Tor de cet appareil (clé + .onion).
  OnionIdentity? get identity => _identity;

  /// Adresse .onion de cet appareil.
  String? get onionAddress => _identity?.onionAddress;

  /// Les trois conditions que le paquet `tor` expose et qui, réunies,
  /// disent que le client est monté.
  ///
  /// ⚠️ `enabled` compte vraiment. `Tor.isReady()` sort de sa boucle
  /// d'attente sur `!enabled` AUTANT que sur `bootstrapped` — un Tor
  /// désactivé rendait donc la main immédiatement, et l'ancien code en
  /// concluait « connecté ». C'est l'un des chemins par lesquels le
  /// bandeau vert apparaissait sans le moindre circuit.
  bool get _vraimentPret {
    final t = _tor;
    return t != null && t.enabled && t.bootstrapped && t.port > 0;
  }

  Future<void> start() async {
    if (_state == TorServiceState.connecting || isConnected) return;

    // ⚠️ TRACE AVANT LE MOINDRE `await`. Lors d'un test sur appareil, taper
    // « Activer Tor » ne produisait AUCUN log `[TorService]` — pas même la
    // ligne d'identité. Impossible de distinguer « start() n'a jamais été
    // appelé » de « start() est bloqué dans son premier await ». Ce
    // premier repère lève l'ambiguïté : s'il n'apparaît pas, le problème
    // est en amont (le geste n'atteint pas le service) ; s'il apparaît
    // seul, le blocage est dans l'identité juste en dessous.
    debugPrint('[TorService] start() demandé');
    _setState(TorServiceState.connecting);
    _lastError = null;

    try {
      // Charger ou générer l'identité Tor.
      //
      // ⚠️ PLAFOND ICI AUSSI. `OnionService.ensureIdentity()` passe par
      // `FlutterSecureStorage`, donc par le Keystore Android — qui peut
      // se bloquer durablement sur certains appareils (verrou d'écran
      // modifié, keystore abîmé après une restauration). Sans plafond,
      // l'activation de Tor restait suspendue là, silencieuse, et l'état
      // ne bougeait plus jamais de `connecting`.
      _identity = await OnionService.ensureIdentity().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw const TorIndisponible(
          "L'identité Tor n'a pas pu être lue sur cet appareil "
          '(stockage sécurisé injoignable).',
        ),
      );
      debugPrint('[TorService] Identité: ${_identity!.shortOnion}');

      _tor = await Tor.init(enabled: true);
      await _tor!.start();

      // Attendre que le circuit soit établi — avec un plafond.
      try {
        await _tor!.isReady().timeout(delaiBootstrap);
      } on TimeoutException {
        throw const TorIndisponible(
          "Le circuit Tor n'a pas pu s'établir. Le réseau utilisé bloque "
          'peut-être Tor.',
        );
      }

      if (!_vraimentPret) {
        throw const TorIndisponible(
          "Tor s'est lancé mais aucun circuit n'est utilisable.",
        );
      }

      // ⚠️ DERNIÈRE VÉRIFICATION, LA SEULE QUI PROUVE QUELQUE CHOSE.
      // `bootstrapped` est un drapeau posé une fois par le paquet ; il ne
      // dit pas que le proxy local écoute vraiment. Ouvrir une socket sur
      // le port SOCKS coûte quelques millisecondes et transforme une
      // supposition en fait constaté.
      if (!await _proxyRepond()) {
        throw const TorIndisponible(
          "Le proxy Tor local ne répond pas.",
        );
      }

      debugPrint(
        '[TorService] Circuit Tor établi — SOCKS5 sur port ${_tor!.port}',
      );
      _setState(TorServiceState.connected);
      _demarrerSurveillance();
    } catch (e) {
      _lastError = e is TorIndisponible ? e.message : e.toString();
      _arreterSurveillance();
      _setState(TorServiceState.error);
      debugPrint('[TorService] Erreur: $_lastError');
    }
  }

  Future<void> stop() async {
    _arreterSurveillance();
    try {
      await _tor?.stop();
    } catch (_) {}
    _tor = null;
    _setState(TorServiceState.stopped);
    debugPrint('[TorService] Arrêté');
  }

  void disable() {
    _tor?.disable();
    // ⚠️ Couper le proxy, c'est cesser d'être connecté. Sans cette ligne,
    // l'état restait `connected` alors que `port` retombait à -1 et que
    // plus rien ne transitait — encore un bandeau vert mensonger.
    if (isConnected) {
      _arreterSurveillance();
      _lastError = 'Tor a été désactivé.';
      _setState(TorServiceState.error);
    }
  }

  /// Ouvre une connexion TCP sur le port SOCKS local pour vérifier que le
  /// proxy écoute réellement. Purement local : aucun trafic réseau.
  Future<bool> _proxyRepond() async {
    final port = _tor?.port ?? -1;
    if (port <= 0) return false;
    try {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      return true;
    } catch (e) {
      debugPrint('[TorService] Proxy injoignable sur $port: $e');
      return false;
    }
  }

  /// ⚠️ POURQUOI SURVEILLER APRÈS COUP. Un circuit peut mourir en cours de
  /// route — veille prolongée, changement de réseau, Wi-Fi qui tombe. Sans
  /// cette vérification périodique, l'état restait figé sur `connected`
  /// pour le reste de la session : le bandeau vert redevenait un mensonge,
  /// simplement plus tard. On repasse alors en `error`, ce que l'écran Tor
  /// sait présenter avec un bouton pour relancer.
  void _demarrerSurveillance() {
    _arreterSurveillance();
    _surveillance = Timer.periodic(_intervalleSante, (_) async {
      if (_state != TorServiceState.connected) return;
      if (_vraimentPret && await _proxyRepond()) return;
      _lastError = 'La connexion Tor a été perdue.';
      _arreterSurveillance();
      _setState(TorServiceState.error);
      debugPrint('[TorService] Circuit perdu — état repassé en erreur');
    });
  }

  void _arreterSurveillance() {
    _surveillance?.cancel();
    _surveillance = null;
  }

  void _setState(TorServiceState newState) {
    if (_state == newState) return;
    _state = newState;
    _stateCtrl.add(newState);
  }

  void dispose() {
    _arreterSurveillance();
    stop();
    _stateCtrl.close();
  }
}

/// Tor n'est pas utilisable, avec une raison présentable à l'utilisateur.
class TorIndisponible implements Exception {
  const TorIndisponible(this.message);
  final String message;

  @override
  String toString() => message;
}
