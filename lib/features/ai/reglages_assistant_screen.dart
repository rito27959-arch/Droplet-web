// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA CLÉ DE L'ASSISTANT EN LIGNE — l'écran où on la met, et surtout où on
// VÉRIFIE qu'elle marche.
//
// ── POURQUOI UN BOUTON « TESTER » ─────────────────────────────────────
//
// ⚠️ SANS LUI, CET ÉCRAN NE SERT À RIEN. Une clé mal copiée, un compte
// sans crédit, un modèle retiré du catalogue : dans les trois cas, le
// seul symptôme serait une réponse qui n'arrive jamais, au milieu d'une
// conversation, sans qu'on sache si c'est la clé, le réseau ou
// l'application. Le test fait UN appel minimal et dit lequel des trois.
//
// C'est la différence entre « j'ai collé quelque chose » et « ça marche ».
//
// ── CE QUE LE TEST COÛTE ──────────────────────────────────────────────
//
// Un appel de huit jetons au plus. À peu près rien, et c'est voulu :
// un test qui coûterait cher serait un test qu'on n'ose pas relancer.
//
// ── ⚠️ LA CLÉ NE S'AFFICHE PAS UNE FOIS ENREGISTRÉE ───────────────────
//
// Elle dort dans le trousseau du système. L'écran montre qu'elle EXISTE
// et ses quatre derniers caractères, jamais sa valeur : un écran de
// réglages reste ouvert sur une table, et une clé API en clair est une
// facture pour quelqu'un d'autre.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/groq_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_list.dart';
import '../../design_system/ouro_scaffold.dart';
import '../../design_system/ouro_spinner.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Où en est la vérification.
enum _Verdict { jamais, encours, bonne, refusee, reseau, modele, quota }

class ReglagesAssistantScreen extends StatefulWidget {
  const ReglagesAssistantScreen({super.key, this.onChange});

  /// Prévient l'écran de conversation que la disponibilité a changé.
  final VoidCallback? onChange;

  @override
  State<ReglagesAssistantScreen> createState() =>
      _ReglagesAssistantScreenState();
}

class _ReglagesAssistantScreenState extends State<ReglagesAssistantScreen> {
  final _groq = GroqService();
  final _champ = TextEditingController();

  String? _cleEnregistree;
  _Verdict _verdict = _Verdict.jamais;
  String? _detail;

  @override
  void initState() {
    super.initState();
    _relire();
  }

  @override
  void dispose() {
    _champ.dispose();
    _groq.dispose();
    super.dispose();
  }

  Future<void> _relire() async {
    final c = await _groq.clePersonnelle();
    if (mounted) setState(() => _cleEnregistree = c);
  }

  Future<void> _enregistrer() async {
    final v = _champ.text.trim();
    if (v.isEmpty) return;
    OuroHaptics.success();
    await _groq.definirCle(v);
    _champ.clear();
    await _relire();
    widget.onChange?.call();
    if (mounted) setState(() => _verdict = _Verdict.jamais);
    await _tester();
  }

  Future<void> _effacer() async {
    OuroHaptics.light();
    await _groq.definirCle(null);
    await _relire();
    widget.onChange?.call();
    if (mounted) setState(() => _verdict = _Verdict.jamais);
  }

  /// L'appel réel, le plus petit possible.
  ///
  /// ⚠️ ON DISTINGUE LES CAUSES. Un seul message « échec » renverrait la
  /// personne à ses suppositions ; c'est précisément ce qu'on veut lui
  /// éviter.
  Future<void> _tester() async {
    setState(() {
      _verdict = _Verdict.encours;
      _detail = null;
    });
    try {
      var recu = false;
      await for (final m in _groq.repondre(
        messages: const [MessageIa(role: 'user', contenu: 'Dis « ok ».')],
        maxJetons: 8,
        effort: 'low',
      )) {
        if (m is MorceauTexte) recu = true;
      }
      if (!mounted) return;
      setState(() {
        // Une clé acceptée qui ne rend aucun jeton veut presque toujours
        // dire que le modèle n'est plus servi sous ce nom.
        _verdict = recu ? _Verdict.bonne : _Verdict.modele;
        _detail = recu ? null : kGroqModele;
      });
    } on EchecIa catch (e) {
      if (!mounted) return;
      setState(() {
        _verdict = switch (e.cause) {
          CauseEchecIa.cleRefusee => _Verdict.refusee,
          CauseEchecIa.quotaEpuise ||
          CauseEchecIa.tropRapide =>
            _Verdict.quota,
          CauseEchecIa.pasDeCle => _Verdict.jamais,
          _ => _Verdict.reseau,
        };
        _detail = e.detail;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _verdict = _Verdict.reseau;
        _detail = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final aUneCle = _cleEnregistree != null;

    return OuroLargeTitleScaffold(
      title: l10n.raTitle,
      leading: const OuroBackButton(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.screenMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.raIntro,
                  style: OuroTypography.subheadline.copyWith(
                    color: OuroColors.secondaryLabel,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: DesignTokens.space5),

                if (aUneCle) ...[
                  OuroListSection(
                    header: l10n.raKey,
                    footer: l10n.raKeyFooter,
                    children: [
                      OuroListRow(
                        icon: Icons.key_rounded,
                        iconColor: OuroColors.accent,
                        title: l10n.raKeySaved,
                        // Les quatre derniers caractères suffisent à
                        // reconnaître LAQUELLE on a mise, sans la révéler.
                        value: '••••${_finDe(_cleEnregistree!)}',
                        showChevron: false,
                      ),
                      OuroListRow(
                        icon: Icons.delete_outline_rounded,
                        iconColor: OuroColors.systemRed,
                        title: l10n.raKeyRemove,
                        isDestructive: true,
                        showChevron: false,
                        onTap: _effacer,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space5),
                  _BlocVerdict(
                    verdict: _verdict,
                    detail: _detail,
                    onTester: _verdict == _Verdict.encours ? null : _tester,
                  ),
                ] else ...[
                  OuroListSection(
                    header: l10n.raKey,
                    footer: l10n.raWhere,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          DesignTokens.screenMargin,
                          10,
                          DesignTokens.screenMargin,
                          10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _champ,
                                autocorrect: false,
                                enableSuggestions: false,
                                // ⚠️ MASQUÉ MÊME PENDANT LA SAISIE : on
                                // colle une clé, on ne la tape pas, et un
                                // écran de réglages se lit par-dessus
                                // l'épaule.
                                obscureText: true,
                                style: OuroTypography.body.copyWith(
                                  color: OuroColors.label,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'gsk_…',
                                  hintStyle: OuroTypography.body.copyWith(
                                    color: OuroColors.tertiaryLabel,
                                  ),
                                ),
                                onSubmitted: (_) => _enregistrer(),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () async {
                                final d = await Clipboard.getData(
                                  Clipboard.kTextPlain,
                                );
                                final t = d?.text?.trim();
                                if (t != null && t.isNotEmpty) {
                                  OuroHaptics.selection();
                                  _champ.text = t;
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                child: Text(
                                  l10n.raPaste,
                                  style: OuroTypography.subheadline.copyWith(
                                    color: OuroColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space4),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _enregistrer,
                      child: Text(l10n.raSaveAndTest),
                    ),
                  ),
                ],

                const SizedBox(height: DesignTokens.space6),
                OuroListSection(
                  header: l10n.raWhatGoesOut,
                  footer: l10n.raWhatGoesOutFooter,
                  children: [
                    OuroListRow(
                      icon: Icons.cloud_outlined,
                      iconColor: OuroColors.secondaryLabel,
                      title: l10n.raModel,
                      value: kGroqModele,
                      showChevron: false,
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _finDe(String cle) =>
      cle.length <= 4 ? cle : cle.substring(cle.length - 4);
}

/// Le résultat du test, en clair.
class _BlocVerdict extends StatelessWidget {
  const _BlocVerdict({
    required this.verdict,
    required this.detail,
    required this.onTester,
  });

  final _Verdict verdict;
  final String? detail;
  final VoidCallback? onTester;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (icone, couleur, titre, corps) = switch (verdict) {
      _Verdict.jamais => (
          Icons.help_outline_rounded,
          OuroColors.secondaryLabel,
          l10n.raNotTested,
          l10n.raNotTestedBody,
        ),
      _Verdict.encours => (
          Icons.more_horiz_rounded,
          OuroColors.secondaryLabel,
          l10n.raTesting,
          '',
        ),
      _Verdict.bonne => (
          Icons.check_circle_rounded,
          OuroColors.presenceMaintenant,
          l10n.raWorks,
          l10n.raWorksBody,
        ),
      _Verdict.refusee => (
          Icons.error_outline_rounded,
          OuroColors.systemRed,
          l10n.raRefused,
          l10n.raRefusedBody,
        ),
      _Verdict.reseau => (
          Icons.wifi_off_rounded,
          OuroColors.systemOrange,
          l10n.raNoNetwork,
          l10n.raNoNetworkBody,
        ),
      _Verdict.modele => (
          Icons.help_outline_rounded,
          OuroColors.systemOrange,
          l10n.raModelGone,
          l10n.raModelGoneBody,
        ),
      _Verdict.quota => (
          Icons.hourglass_empty_rounded,
          OuroColors.systemOrange,
          l10n.raQuota,
          l10n.raQuotaBody,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.space4),
      decoration: BoxDecoration(
        color: OuroColors.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusGroupedList),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (verdict == _Verdict.encours)
                OuroSpinner(color: OuroColors.secondaryLabel, radius: 8)
              else
                Icon(icone, size: DesignTokens.iconLg, color: couleur),
              const SizedBox(width: DesignTokens.space2),
              Expanded(
                child: Text(
                  titre,
                  style: OuroTypography.headline.copyWith(
                    color: OuroColors.label,
                  ),
                ),
              ),
            ],
          ),
          if (corps.isNotEmpty) ...[
            const SizedBox(height: DesignTokens.space2),
            Text(
              corps,
              style: OuroTypography.subheadline.copyWith(
                color: OuroColors.secondaryLabel,
                height: 1.45,
              ),
            ),
          ],
          // ⚠️ LE DÉTAIL BRUT EST MONTRÉ, PAS CACHÉ. C'est ce qu'on copie
          // dans un message d'assistance ; le masquer par souci
          // d'esthétique rend le diagnostic impossible à distance.
          if (detail != null && detail!.trim().isNotEmpty) ...[
            const SizedBox(height: DesignTokens.space2),
            SelectableText(
              detail!.length > 300
                  ? '${detail!.substring(0, 300)}…'
                  : detail!,
              style: OuroTypography.caption1.copyWith(
                color: OuroColors.tertiaryLabel,
                fontFamily: 'monospace',
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.space3),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTester,
              child: Text(l10n.raTest),
            ),
          ),
        ],
      ),
    );
  }
}
