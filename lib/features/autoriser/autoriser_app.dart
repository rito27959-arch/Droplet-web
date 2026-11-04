// ============================================================================
// « SE CONNECTER AVEC DROPLET » — une autre app de l'écosystème (Kunfox)
// demande à l'élève de prouver qui il est, sans mot de passe.
// ----------------------------------------------------------------------------
// Le lien reçu : droplet://droplet/autoriser?app=kunfox&cle=…&etat=…
//
// ── CE QUE L'APP REÇOIT ─────────────────────────────────────────────────
// • le pseudo ;
// • un SECRET PROPRE À CETTE APP, dérivé de la clé d'identité de Droplet
//   (HKDF, étiquette « droplet-app-v1:<app> »). Le même compte donne
//   toujours le même secret à la même app — c'est ce qui permet de
//   retrouver une progression sur un nouveau téléphone — mais deux apps
//   différentes reçoivent deux secrets sans lien, et aucun ne permet de
//   remonter à l'identité Droplet ni de lire quoi que ce soit dans Droplet.
//
// ── POURQUOI LA RÉPONSE EST CHIFFRÉE ────────────────────────────────────
// Sur Android, n'importe quelle app peut déclarer le schéma `kunfox://`.
// La réponse voyage donc chiffrée pour la clé éphémère que l'app a envoyée
// (`cle`, X25519) : une app qui intercepterait le lien ne pourrait pas la
// lire. Le lien de retour est FIXE par app (liste ci-dessous) : on ne
// renvoie jamais vers une adresse fournie par la demande.
//
// ── LIMITE CONNUE ───────────────────────────────────────────────────────
// Une app malveillante peut se faire passer pour Kunfox en envoyant sa
// propre clé. Elle n'obtiendrait que le secret « Kunfox » de l'élève
// (donc sa progression de révision), et seulement si l'élève accepte
// l'écran ci-dessous, qui nomme l'app. Rien de Droplet n'est exposé.
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/crypto_service.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_retour_ios.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Les apps autorisées à demander une connexion, et leur lien de retour.
const Map<String, ({String nom, String retour, Color couleur, IconData icone})> kAppsDroplet = {
  'kunfox': (
    nom: 'Kunfox',
    retour: 'kunfox://kunfox/connexion',
    couleur: Color(0xFFFF6B2B),
    icone: Icons.school_rounded,
  ),
};

String _b64(List<int> o) => base64Url.encode(o).replaceAll('=', '');
List<int> _deb64(String s) => base64Url.decode(base64Url.normalize(s));

class AutoriserAppScreen extends StatefulWidget {
  const AutoriserAppScreen({super.key, required this.parametres});
  final Map<String, String> parametres;

  @override
  State<AutoriserAppScreen> createState() => _AutoriserAppScreenState();
}

class _AutoriserAppScreenState extends State<AutoriserAppScreen> {
  bool _occupe = false;

  ({String nom, String retour, Color couleur, IconData icone})? get _app => kAppsDroplet[widget.parametres['app']];

  bool get _valide {
    final cle = widget.parametres['cle'];
    final etat = widget.parametres['etat'];
    if (_app == null || cle == null || etat == null || etat.length > 64) return false;
    try {
      return _deb64(cle).length == 32;
    } catch (_) {
      return false;
    }
  }

  Future<void> _repondre(bool accepte) async {
    if (_occupe) return;
    setState(() => _occupe = true);
    final app = _app!;
    final etat = widget.parametres['etat']!;
    Uri lien;
    if (!accepte) {
      lien = Uri.parse('${app.retour}?refus=1&etat=${Uri.encodeComponent(etat)}');
    } else {
      OuroHaptics.success();
      final graine = await CryptoService.exportPrivateKeySeed();
      if (graine == null) {
        setState(() => _occupe = false);
        return;
      }
      // Le secret propre à cette app.
      final secret = await Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
        secretKey: SecretKey(base64Decode(graine)),
        info: utf8.encode('droplet-app-v1:${widget.parametres['app']}'),
        nonce: utf8.encode('droplet-mesh'),
      );
      final contenu = utf8.encode(jsonEncode({
        'v': 1,
        'etat': etat,
        's': _b64(await secret.extractBytes()),
        'p': StorageService.currentUser?.pseudo ?? '',
      }));
      // Chiffré pour la clé éphémère de l'app.
      final x = X25519();
      final moi = await x.newKeyPair();
      final partage = await x.sharedSecretKey(
        keyPair: moi,
        remotePublicKey: SimplePublicKey(_deb64(widget.parametres['cle']!), type: KeyPairType.x25519),
      );
      final cle = await Hkdf(hmac: Hmac.sha256(), outputLength: 32).deriveKey(
        secretKey: partage,
        info: utf8.encode('droplet-autoriser-v1'),
        nonce: utf8.encode(etat),
      );
      final boite = await AesGcm.with256bits().encrypt(contenu, secretKey: cle);
      final pub = await moi.extractPublicKey();
      lien = Uri.parse('${app.retour}?etat=${Uri.encodeComponent(etat)}'
          '&e=${_b64(pub.bytes)}&n=${_b64(boite.nonce)}'
          '&c=${_b64(Uint8List.fromList([...boite.cipherText, ...boite.mac.bytes]))}');
    }
    await launchUrl(lien, mode: LaunchMode.externalApplication);
    if (mounted) context.go('/chats');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final app = _app;
    final aCompte = StorageService.currentUser != null;

    Widget contenu;
    if (!_valide || app == null) {
      contenu = Text(l10n.autInvalide,
          textAlign: TextAlign.center, style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel));
    } else if (!aCompte) {
      contenu = Text(l10n.autSansCompte,
          textAlign: TextAlign.center, style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel));
    } else {
      contenu = Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(color: app.couleur, borderRadius: BorderRadius.circular(22)),
          child: Icon(app.icone, color: Colors.white, size: 44),
        ),
        const SizedBox(height: DesignTokens.space4),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: '${app.nom} ', style: const TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: l10n.autDemande),
          ]),
          textAlign: TextAlign.center,
          style: OuroTypography.title3.copyWith(color: OuroColors.label),
        ),
        const SizedBox(height: DesignTokens.space4),
        Text(l10n.autRecoit,
            textAlign: TextAlign.center, style: OuroTypography.body.copyWith(color: OuroColors.secondaryLabel)),
        const SizedBox(height: DesignTokens.space2),
        Text(l10n.autPasVu,
            textAlign: TextAlign.center, style: OuroTypography.footnote.copyWith(color: OuroColors.tertiaryLabel)),
        const SizedBox(height: DesignTokens.space6),
        SizedBox(
          width: double.infinity,
          child: OuroRetourIos(
            child: FilledButton(
              onPressed: _occupe ? null : () => _repondre(true),
              style: FilledButton.styleFrom(
                overlayColor: Colors.transparent,
                backgroundColor: OuroColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.autAutoriser),
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space2),
        TextButton(
          onPressed: _occupe ? null : () => _repondre(false),
          child: Text(l10n.autRefuser, style: TextStyle(color: OuroColors.secondaryLabel)),
        ),
      ]);
    }

    return Scaffold(
      backgroundColor: OuroColors.systemBackground,
      appBar: AppBar(
        backgroundColor: OuroColors.systemBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(l10n.autTitle, style: OuroTypography.headline.copyWith(color: OuroColors.label)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.screenMargin),
            child: contenu,
          ),
        ),
      ),
    );
  }
}
