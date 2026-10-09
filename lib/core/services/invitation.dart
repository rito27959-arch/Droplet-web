// ============================================================================
// LE LIEN D'INVITATION — écrire à quelqu'un qui n'a pas encore Droplet.
// ----------------------------------------------------------------------------
// Le lien porte exactement ce que porte le QR code de l'appareil (identifiant,
// pseudo, clé publique X25519…), encodé en base64 APRÈS le `#` :
//
//     https://dropletmesh.app/i/#eyJ0eXBlIjoiZHJvcGxldC1v…
//
// ⚠️ LE `#` N'EST PAS UN DÉTAIL. Un navigateur n'envoie jamais ce qui suit le
// `#` au serveur : la page d'invitation (le site, `src/pages/i.astro` dans le
// dépôt droplet-site) ne voit donc ni qui invite, ni sa clé. C'est le script de la page, sur le
// téléphone de la personne invitée, qui ouvre ensuite
// `droplet://droplet/invite?d=…` — reçu par l'app comme la route `/invite`.
//
// À la réception, le contenu passe par le MÊME décodeur que le scanner QR
// (`QrPeerData.decode`) : un lien vaut un QR code, ni plus ni moins.
// ============================================================================

import 'dart:convert';

import '../config/server_config.dart';
import 'qr_code_exchange.dart';

class InvitationDroplet {
  InvitationDroplet._();

  /// La page d'invitation, servie par le site — dans la langue de l'invité,
  /// à une adresse qui porte le nom de Droplet. Les liens déjà partagés,
  /// qui pointent vers l'ancienne page de l'annuaire (`…/i#…`), continuent
  /// de fonctionner : l'annuaire la sert toujours.
  static const adresse = '$kSiteUrl/i/';

  /// Bien plus qu'un QR Droplet : refuse d'emblée un lien démesuré.
  static const int tailleMax = 4096;

  static String encoder(String qrJson) =>
      base64Url.encode(utf8.encode(qrJson)).replaceAll('=', '');

  /// Le lien à partager, à partir des données du QR code de l'appareil.
  static String lien(String qrJson) => '$adresse#${encoder(qrJson)}';

  /// Décode les données d'un lien, sans les valider. `null` si illisibles.
  static String? decoderBrut(String? donnees) {
    if (donnees == null) return null;
    final texte = donnees.trim();
    if (texte.isEmpty || texte.length > tailleMax) return null;
    try {
      return utf8.decode(base64Url.decode(base64Url.normalize(texte)));
    } catch (_) {
      return null;
    }
  }

  /// Les données QR d'une invitation VALIDE (mêmes règles qu'un QR scanné),
  /// sinon `null`.
  static String? extraire(String? donnees) {
    final json = decoderBrut(donnees);
    if (json == null) return null;
    return QrPeerData.decode(json) == null ? null : json;
  }
}
