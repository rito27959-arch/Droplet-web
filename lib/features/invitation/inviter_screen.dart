// ============================================================================
// « INVITER UNE PERSONNE » — trois façons, une seule page.
// ----------------------------------------------------------------------------
// Il n'y avait qu'une entrée « Inviter par un lien », qui ouvrait directement
// le partage. Comme Zangi (qui propose l'invitation par SMS vers un contact et
// le partage d'un lien), et avec ce que Droplet sait faire de plus :
//
//   • PAR NUMÉRO — saisi, ou choisi dans les contacts du téléphone (le
//     sélecteur d'Android : une seule personne est confiée à l'application).
//     Le message part par SMS ou par WhatsApp, déjà rédigé avec le lien ;
//   • PAR LIEN — à copier ou à partager n'importe où ;
//   • PAR QR CODE — face à face, sans rien envoyer du tout.
//
// Le lien et le code ne contiennent que l'identifiant public et la clé
// publique (voir `invitation.dart`). Le numéro saisi ne quitte le téléphone
// que dans le SMS ou le message que la personne envoie elle-même.
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/invitation.dart';
import '../../core/services/media_service.dart';
import '../../core/services/qr_code_exchange.dart';
import '../../core/services/storage_service.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/droplet_logo.dart';
import '../../design_system/ouro_icon_button.dart';

/// Un numéro prêt pour un lien `sms:` ou `wa.me` : chiffres, et le `+`
/// initial s'il y en a un.
String numeroNormalise(String saisie) {
  final propre = saisie.trim();
  final chiffres = propre.replaceAll(RegExp(r'[^0-9]'), '');
  if (chiffres.isEmpty) return '';
  return propre.startsWith('+') || propre.startsWith('00')
      ? '+${propre.startsWith('00') ? chiffres.substring(2) : chiffres}'
      : chiffres;
}

class InviterScreen extends StatefulWidget {
  const InviterScreen({super.key});

  @override
  State<InviterScreen> createState() => _InviterScreenState();
}

class _InviterScreenState extends State<InviterScreen> {
  static const MethodChannel _contacts = MethodChannel('com.droplet.droplet/contacts');

  final _numero = TextEditingController();
  String? _donneesQr;
  String? _lien;
  String? _nomContact;

  @override
  void initState() {
    super.initState();
    _preparer();
  }

  @override
  void dispose() {
    _numero.dispose();
    super.dispose();
  }

  Future<void> _preparer() async {
    // Une identité pas encore prête (premier lancement, stockage occupé)
    // ne doit pas laisser la page vide sans explication : on réessaie une
    // fois, puis on laisse la carte dans son état d'attente.
    for (var essai = 0; essai < 2; essai++) {
      try {
        final donnees = await QrCodeExchange.generateQrData();
        if (!mounted) return;
        setState(() {
          _donneesQr = donnees;
          _lien = InvitationDroplet.lien(donnees);
        });
        return;
      } catch (e) {
        debugPrint('[Inviter] code d\'invitation indisponible: $e');
        await Future<void>.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
      }
    }
  }

  String _message(AppLocalizations l10n) =>
      l10n.invShareText(StorageService.currentUser?.pseudo ?? '', _lien ?? '');

  Future<void> _choisirContact() async {
    if (!Platform.isAndroid) return;
    OuroHaptics.selection();
    try {
      final choix = await _contacts.invokeMapMethod<String, String>('choisirNumero');
      if (choix == null || !mounted) return;
      setState(() {
        _numero.text = choix['numero'] ?? '';
        _nomContact = choix['nom'];
      });
    } catch (_) {}
  }

  Future<void> _envoyer({required bool whatsapp}) async {
    final l10n = AppLocalizations.of(context);
    final numero = numeroNormalise(_numero.text);
    if (numero.isEmpty || _lien == null) {
      OuroHaptics.error();
      return;
    }
    OuroHaptics.medium();
    final texte = Uri.encodeComponent(_message(l10n));
    final url = whatsapp
        ? 'https://wa.me/${numero.replaceAll('+', '')}?text=$texte'
        : 'sms:$numero?body=$texte';
    await MediaService.ouvrirLien(url);
  }

  Future<void> _copier() async {
    final lien = _lien;
    if (lien == null) return;
    await Clipboard.setData(ClipboardData(text: lien));
    OuroHaptics.success();
    if (!mounted) return;
    // La confirmation se lit SUR la ligne qu'on vient de toucher : une
    // bannière qui passe en bas de l'écran oblige à regarder ailleurs.
    setState(() => _copie = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copie = false);
    });
  }

  Future<void> _partager() async {
    if (_lien == null) return;
    OuroHaptics.light();
    await Share.share(_message(AppLocalizations.of(context)));
  }

  /// La copie vient d'être faite : la ligne montre une coche, deux secondes.
  bool _copie = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pseudo = StorageService.currentUser?.pseudo ?? '';

    return OuroLargeTitleScaffold(
      title: l10n.ivTitle,
      subtitle: l10n.ivSubtitle,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          sliver: SliverList.list(
            children: [
              // ── LA CARTE D'INVITATION ────────────────────────────────
              //
              // Une seule pièce, comme une carte d'embarquement : le code
              // à faire scanner, le nom dessous, et la marque en haut. Ce
              // n'est pas décoratif — c'est l'objet qu'on TEND à quelqu'un,
              // et il doit se reconnaître à un mètre.
              _CarteInvitation(donnees: _donneesQr, pseudo: pseudo, l10n: l10n),

              const SizedBox(height: 22),

              // ── Le lien ──────────────────────────────────────────────
              OuroListSection(
                header: l10n.ivByLink,
                children: [
                  OuroListRow(
                    icon: Icons.ios_share_rounded,
                    iconColor: OuroColors.accent,
                    title: l10n.ivShare,
                    onTap: _lien == null ? null : _partager,
                  ),
                  OuroListRow(
                    icon: _copie ? Icons.check_rounded : Icons.link_rounded,
                    iconColor: _copie ? OuroColors.systemGreen : OuroColors.systemIndigo,
                    title: _copie ? l10n.ivCopied : l10n.ivCopy,
                    subtitle: _lienCourt(),
                    showChevron: false,
                    onTap: _lien == null ? null : _copier,
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // ── Le numéro ────────────────────────────────────────────
              OuroListSection(
                header: l10n.ivByNumber,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _numero,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) => setState(() => _nomContact = null),
                            style: OuroTypography.body,
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: l10n.ivNumberHint,
                              hintStyle: OuroTypography.body.copyWith(
                                color: OuroColors.tertiaryLabel,
                              ),
                              helperText: _nomContact,
                              helperStyle: OuroTypography.caption1.copyWith(
                                color: OuroColors.secondaryLabel,
                              ),
                            ),
                          ),
                        ),
                        if (Platform.isAndroid)
                          OuroIconButton(
                            tooltip: l10n.ivContacts,
                            icon: Icon(
                              Icons.contacts_rounded,
                              color: OuroColors.accent,
                              size: 22,
                            ),
                            onPressed: _choisirContact,
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Bouton(
                            icone: Icons.sms_rounded,
                            libelle: l10n.ivSms,
                            couleur: OuroColors.accent,
                            onTap: () => _envoyer(whatsapp: false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Bouton(
                            icone: Icons.chat_rounded,
                            libelle: l10n.ivWhatsapp,
                            couleur: const Color(0xFF25D366),
                            onTap: () => _envoyer(whatsapp: true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              OuroListSection(
                footer: l10n.ivPrivacy,
                children: [
                  OuroListRow(
                    icon: Icons.qr_code_scanner_rounded,
                    iconColor: OuroColors.systemPurple,
                    title: l10n.ivScan,
                    onTap: () => context.push('/tor/scan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Le lien sans son `https://`, coupé au milieu : ce qu'on lit d'un
  /// coup d'œil pour vérifier que c'est bien une adresse Droplet.
  String _lienCourt() {
    final lien = _lien;
    if (lien == null) return '…';
    final propre = lien.replaceFirst(RegExp(r'^https?://'), '');
    final coupe = propre.indexOf('#');
    final base = coupe > 0 ? propre.substring(0, coupe) : propre;
    return '$base#…';
  }
}

/// La carte qu'on tend à la personne : le QR, le nom, la marque.
class _CarteInvitation extends StatefulWidget {
  const _CarteInvitation({
    required this.donnees,
    required this.pseudo,
    required this.l10n,
  });

  final String? donnees;
  final String pseudo;
  final AppLocalizations l10n;

  @override
  State<_CarteInvitation> createState() => _CarteInvitationState();
}

class _CarteInvitationState extends State<_CarteInvitation> {
  bool _appui = false;

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final accent = OuroColors.accent;
    return GestureDetector(
      onTapDown: (_) => setState(() => _appui = true),
      onTapCancel: () => setState(() => _appui = false),
      onTapUp: (_) => setState(() => _appui = false),
      child: AnimatedScale(
        scale: _appui ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent,
                Color.lerp(accent, OuroColors.systemIndigo, 0.7)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.30),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          // Un reflet en diagonale, comme sur une carte plastifiée : il
          // donne l'épaisseur que ne donne jamais un dégradé seul.
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            gradient: LinearGradient(
              begin: const Alignment(-1, -1.2),
              end: const Alignment(0.4, 1),
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.02),
                Colors.transparent,
              ],
              stops: const [0, 0.45, 0.75],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const DropletLogo(radius: 11, glow: false),
                  Text(
                    'Droplet',
                    style: OuroTypography.headline.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    l10n.ivByQr.toUpperCase(),
                    style: OuroTypography.caption2.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Le code, sur son carton blanc. Tant qu'il n'est pas prêt,
              // la carte garde EXACTEMENT la même hauteur : rien ne saute
              // à l'affichage.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: widget.donnees == null
                    // Le carton blanc est là AVANT le code : la carte a
                    // sa forme définitive dès la première image, et rien
                    // ne saute quand le code arrive.
                    ? Container(
                        key: const ValueKey('vide'),
                        height: 228,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(22),
                        ),
                      )
                    : Container(
                        key: const ValueKey('qr'),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: QrImageView(
                          data: widget.donnees!,
                          size: 200,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.circle,
                            color: Color(0xFF0A1420),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: Color(0xFF0A1420),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              if (widget.pseudo.isNotEmpty)
                Text(
                  widget.pseudo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.title3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                l10n.ivQrHint,
                textAlign: TextAlign.center,
                style: OuroTypography.footnote.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 380.ms)
        .slideY(begin: 0.08, end: 0, duration: 460.ms, curve: Curves.easeOutCubic);
  }
}

class _Bouton extends StatelessWidget {
  const _Bouton({
    required this.icone,
    required this.libelle,
    required this.couleur,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final Color couleur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: couleur,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 19, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                libelle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
