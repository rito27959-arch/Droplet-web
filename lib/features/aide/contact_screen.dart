// ============================================================================
// CONTACT ET ASSISTANCE.
// ----------------------------------------------------------------------------
// Ce que font les grandes applications, et ce qu'on en garde :
//
//   • WHATSAPP renvoie vers un formulaire web, puis répond par e-mail. On
//     garde le principe d'un canal unique et clair, pas le formulaire : ici
//     le canal est WhatsApp lui-même, celui que les gens ont déjà.
//   • TELEGRAM a « Poser une question » qui ouvre une vraie conversation
//     avec un bénévole. On garde ça : écrire à quelqu'un, pas à un ticket.
//   • SIGNAL propose de joindre son journal de débogage à la demande. On
//     garde ça aussi, et on va plus loin.
//
// ⚠️ CE QUE PERSONNE NE FAIT, ET QUI CHANGE TOUT : MONTRER CE QUI PART
// AVANT QUE ÇA PARTE. « Joindre les informations de diagnostic » est une
// case qu'on coche sans savoir ce qu'elle contient. Ici, le contenu exact
// s'affiche, en clair, dans une feuille qu'on peut lire et copier — et
// c'est seulement ensuite qu'on choisit de l'envoyer. Sur une application
// dont tout l'argument est « rien ne part sans vous », une case aveugle
// aurait contredit le reste de l'écran d'à côté.
//
// Et une honnêteté de plus, dans le pied de page : il n'y a pas d'équipe
// d'assistance. Il y a une personne. Autant le dire, plutôt que de laisser
// attendre une réponse en quatre minutes.
// ============================================================================

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/contact_config.dart';
import '../../core/services/crash_journal.dart';
import '../../core/services/media_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/afficher_toast.dart';
import '../../design_system/glassmorphism.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  /// Les informations d'appareil, telles qu'elles seront jointes. Rien de
  /// plus que ces quatre lignes : ni identifiant, ni pseudo, ni contact.
  static String infosAppareil() {
    final os = Platform.operatingSystem;
    final version = Platform.operatingSystemVersion;
    return 'Droplet $kVersionApp\n$os $version\n'
        '${Platform.localeName}\n'
        '${DateTime.now().toIso8601String().split('T').first}';
  }

  Future<void> _ouvrirWhatsApp(BuildContext context, String message) async {
    OuroHaptics.light();
    final texte = Uri.encodeComponent(message);
    final ok = await MediaService.ouvrirLien(
      'https://wa.me/$kWhatsAppNumero?text=$texte',
    );
    if (ok || !context.mounted) return;
    // WhatsApp absent : on ne laisse pas un bouton muet — le numéro part
    // dans le presse-papiers, prêt pour un SMS.
    await Clipboard.setData(const ClipboardData(text: kWhatsAppContact));
    if (!context.mounted) return;
    afficherToast(
      context,
      AppLocalizations.of(context).hlpWhatsAppMissing(kWhatsAppContact),
      type: DropletToastType.warning,
    );
  }

  Future<void> _ouvrirEmail(
    BuildContext context,
    String sujet,
    String corps,
  ) async {
    OuroHaptics.light();
    final lien = Uri(
      scheme: 'mailto',
      path: kEmailContact,
      query: 'subject=${Uri.encodeComponent(sujet)}'
          '&body=${Uri.encodeComponent(corps)}',
    ).toString();
    final ok = await MediaService.ouvrirLien(lien);
    if (ok || !context.mounted) return;
    await Clipboard.setData(const ClipboardData(text: kEmailContact));
    if (!context.mounted) return;
    afficherToast(
      context,
      AppLocalizations.of(context).hlpEmailCopied(kEmailContact),
      type: DropletToastType.info,
    );
  }

  Future<void> _signaler(BuildContext context) async {
    OuroHaptics.selection();
    final journal = await CrashJournal.lire();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FeuilleSignalement(
        infos: infosAppareil(),
        journal: journal,
        onWhatsApp: (m) => _ouvrirWhatsApp(context, m),
        onEmail: (m) => _ouvrirEmail(
          context,
          AppLocalizations.of(context).hlpReportSubject,
          m,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OuroLargeTitleScaffold(
      title: l10n.hlpContactTitle,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignTokens.space5),
                  child: Text(
                    l10n.hlpContactLead,
                    style: OuroTypography.subheadline.copyWith(
                      color: OuroColors.secondaryLabel,
                      height: 1.45,
                    ),
                  ),
                ),

                // ── Avant d'écrire : la réponse est peut-être déjà là ──
                OuroListSection(
                  header: l10n.hlpBeforeWriting,
                  children: [
                    OuroListRow(
                      icon: Icons.help_outline_rounded,
                      iconColor: OuroColors.systemIndigo,
                      title: l10n.hlpHelpTitle,
                      subtitle: l10n.hlpHelpRowBody,
                      onTap: () => context.push('/aide'),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space5),

                // ── Écrire ────────────────────────────────────────────
                OuroListSection(
                  header: l10n.hlpWriteUs,
                  children: [
                    OuroListRow(
                      icon: Icons.chat_rounded,
                      iconColor: OuroColors.successGreen,
                      title: l10n.hlpWhatsApp,
                      value: kWhatsAppContact,
                      onTap: () =>
                          _ouvrirWhatsApp(context, l10n.hlpWhatsAppHello),
                    ),
                    OuroListRow(
                      icon: Icons.alternate_email_rounded,
                      iconColor: OuroColors.accent,
                      title: l10n.hlpEmail,
                      subtitle: kEmailContact,
                      onTap: () => _ouvrirEmail(
                        context,
                        l10n.hlpEmailSubject,
                        '\n\n---\n${infosAppareil()}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space5),

                // ── Signaler ──────────────────────────────────────────
                OuroListSection(
                  header: l10n.hlpReportHeader,
                  footer: l10n.hlpReportFooter,
                  children: [
                    OuroListRow(
                      icon: Icons.bug_report_rounded,
                      iconColor: OuroColors.warningAmber,
                      title: l10n.hlpReport,
                      subtitle: l10n.hlpReportBody,
                      onTap: () => _signaler(context),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space5),

                // ── Confidentialité ───────────────────────────────────
                OuroListSection(
                  children: [
                    OuroListRow(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: OuroColors.systemIndigo,
                      title: l10n.hlpPrivacy,
                      onTap: () => context.push('/aide/confidentialite'),
                    ),
                    OuroListRow(
                      icon: Icons.shield_rounded,
                      iconColor: OuroColors.successGreen,
                      title: l10n.hlpData,
                      onTap: () => context.push('/aide/donnees'),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space5),

                // L'honnêteté finale : ce n'est pas un centre d'appels.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.hlpOnePerson,
                    textAlign: TextAlign.center,
                    style: OuroTypography.footnote.copyWith(
                      color: OuroColors.tertiaryLabel,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: DesignTokens.space8),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// CE QUI PART, AVANT QUE ÇA PARTE.
///
/// La feuille montre le texte exact — informations d'appareil et, s'il y en
/// a un, le journal d'erreurs local. On peut le lire, le copier, ou
/// l'envoyer. On ne peut pas l'envoyer sans l'avoir vu.
class _FeuilleSignalement extends StatefulWidget {
  const _FeuilleSignalement({
    required this.infos,
    required this.journal,
    required this.onWhatsApp,
    required this.onEmail,
  });

  final String infos;
  final String? journal;
  final ValueChanged<String> onWhatsApp;
  final ValueChanged<String> onEmail;

  @override
  State<_FeuilleSignalement> createState() => _FeuilleSignalementState();
}

class _FeuilleSignalementState extends State<_FeuilleSignalement> {
  final _description = TextEditingController();
  bool _joindreJournal = true;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  /// ⚠️ LE JOURNAL EST TRONQUÉ À 2 000 CARACTÈRES. Un message WhatsApp ne
  /// porte pas soixante kilo-octets, et personne ne lit une trace de pile
  /// de mille lignes : ce sont les dernières erreurs qui servent.
  String get _message {
    final l10n = AppLocalizations.of(context);
    final tampon = StringBuffer();
    final texte = _description.text.trim();
    if (texte.isNotEmpty) tampon.writeln('$texte\n');
    tampon.writeln('---');
    tampon.writeln(widget.infos);
    final j = widget.journal;
    if (_joindreJournal && j != null && j.trim().isNotEmpty) {
      tampon.writeln('---');
      tampon.writeln(l10n.hlpLogExcerpt);
      final court = j.length > 2000 ? j.substring(j.length - 2000) : j;
      tampon.writeln(court.trim());
    }
    return tampon.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final aJournal = (widget.journal ?? '').trim().isNotEmpty;
    return FrostedSheet(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.hlpReport,
              style: OuroTypography.title3.copyWith(color: OuroColors.label),
            ),
            const SizedBox(height: DesignTokens.space1),
            Text(
              l10n.hlpReportSheetLead,
              style: OuroTypography.footnote.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.4,
              ),
            ),
            const SizedBox(height: DesignTokens.space4),

            // Ce qui s'est passé, dans les mots de la personne.
            TextField(
              controller: _description,
              maxLines: 3,
              minLines: 2,
              onChanged: (_) => setState(() {}),
              style: OuroTypography.body.copyWith(color: OuroColors.label),
              decoration: InputDecoration(
                hintText: l10n.hlpReportHint,
                hintStyle: OuroTypography.body
                    .copyWith(color: OuroColors.tertiaryLabel),
                filled: true,
                fillColor: OuroColors.tertiarySystemFill,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(DesignTokens.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space4),

            if (aJournal) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  OuroHaptics.selection();
                  setState(() => _joindreJournal = !_joindreJournal);
                },
                child: Row(
                  children: [
                    Icon(
                      _joindreJournal
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 20,
                      color: _joindreJournal
                          ? OuroColors.accent
                          : OuroColors.tertiaryLabel,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.hlpAttachLog,
                        style: OuroTypography.subheadline
                            .copyWith(color: OuroColors.label),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space3),
            ],

            // LE TEXTE EXACT. C'est la pièce maîtresse de cette feuille.
            Text(
              l10n.hlpWhatWillBeSent,
              style: OuroTypography.caption1.copyWith(
                color: OuroColors.secondaryLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: DesignTokens.space2),
            Container(
              constraints: const BoxConstraints(maxHeight: 190),
              width: double.infinity,
              padding: const EdgeInsets.all(DesignTokens.space3),
              decoration: BoxDecoration(
                color: OuroColors.tertiarySystemFill,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _message,
                  style: OuroTypography.caption1.copyWith(
                    color: OuroColors.secondaryLabel,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: DesignTokens.space4),

            Row(
              children: [
                Expanded(
                  child: _Bouton(
                    icone: Icons.copy_rounded,
                    libelle: l10n.hlpCopy,
                    onTap: () async {
                      final m = _message;
                      await Clipboard.setData(ClipboardData(text: m));
                      if (!context.mounted) return;
                      OuroHaptics.success();
                      afficherToast(context, l10n.hlpCopied,
                          type: DropletToastType.success);
                    },
                  ),
                ),
                const SizedBox(width: DesignTokens.space2),
                Expanded(
                  child: _Bouton(
                    icone: Icons.chat_rounded,
                    libelle: l10n.hlpWhatsApp,
                    principal: true,
                    onTap: () {
                      final m = _message;
                      Navigator.of(context).pop();
                      widget.onWhatsApp(m);
                    },
                  ),
                ),
                const SizedBox(width: DesignTokens.space2),
                Expanded(
                  child: _Bouton(
                    icone: Icons.alternate_email_rounded,
                    libelle: l10n.hlpEmail,
                    onTap: () {
                      final m = _message;
                      Navigator.of(context).pop();
                      widget.onEmail(m);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Bouton extends StatefulWidget {
  const _Bouton({
    required this.icone,
    required this.libelle,
    required this.onTap,
    this.principal = false,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;
  final bool principal;

  @override
  State<_Bouton> createState() => _BoutonState();
}

class _BoutonState extends State<_Bouton> {
  bool _enfonce = false;

  @override
  Widget build(BuildContext context) {
    final fond = widget.principal
        ? OuroColors.accent
        : OuroColors.tertiarySystemFill;
    final devant = widget.principal ? Colors.white : OuroColors.label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _enfonce = true),
      onTapCancel: () => setState(() => _enfonce = false),
      onTap: () {
        setState(() => _enfonce = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _enfonce ? 0.96 : 1,
        duration: DesignTokens.durationFast,
        curve: DesignTokens.curveEnter,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: fond,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icone, size: 17, color: devant),
              const SizedBox(height: 2),
              Text(
                widget.libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.caption2.copyWith(
                  color: devant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
