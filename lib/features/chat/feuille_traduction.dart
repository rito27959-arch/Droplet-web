// ============================================================================
// « TRADUIRE » — la feuille de Telegram et d'iOS, sur l'appareil.
// ----------------------------------------------------------------------------
// Ce que fait Telegram quand on touche « Traduire » sur un message : une
// feuille monte, annonce la langue détectée, propose d'en changer, montre la
// traduction (et l'original juste au-dessus, replié), et laisse copier. Ce que
// fait iOS en plus : on peut garder la traduction sous le message, dans la
// conversation.
//
// ⚠️ RIEN NE SORT DU TÉLÉPHONE. Le texte est chiffré de bout en bout : il part
// au moteur HORS LIGNE de l'appareil (voir `service_intelligence.dart`), jamais
// à un service en ligne. Si le modèle de la langue n'est pas installé,
// l'appareil propose de le télécharger — une fois, puis c'est définitif.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/service_intelligence.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_typography.dart';

/// Les langues proposées, avec leur nom écrit en français.
const Map<String, String> kLanguesTraduction = {
  'fr': 'Français',
  'en': 'English',
  'es': 'Español',
  'de': 'Deutsch',
  'it': 'Italiano',
  'pt': 'Português',
  'nl': 'Nederlands',
  'ru': 'Русский',
  'uk': 'Українська',
  'pl': 'Polski',
  'tr': 'Türkçe',
  'ar': 'العربية',
  'hi': 'हिन्दी',
  'zh': '中文',
  'ja': '日本語',
  'ko': '한국어',
};

String nomDeLangue(String? code, String inconnue) {
  if (code == null || code.isEmpty) return inconnue;
  final court = code.split(RegExp('[-_]')).first.toLowerCase();
  return kLanguesTraduction[court] ?? court.toUpperCase();
}

class FeuilleTraduction extends StatefulWidget {
  const FeuilleTraduction({
    super.key,
    required this.idMessage,
    required this.texte,
    required this.cible,
    this.surAfficherDansLaBulle,
  });

  final String idMessage;
  final String texte;

  /// La langue voulue au départ : celle de l'interface.
  final String cible;

  /// Pose la traduction sous le message, dans la conversation.
  final ValueChanged<String>? surAfficherDansLaBulle;

  static Future<void> afficher(
    BuildContext context, {
    required String idMessage,
    required String texte,
    required String cible,
    ValueChanged<String>? surAfficherDansLaBulle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FeuilleTraduction(
        idMessage: idMessage,
        texte: texte,
        cible: cible,
        surAfficherDansLaBulle: surAfficherDansLaBulle,
      ),
    );
  }

  @override
  State<FeuilleTraduction> createState() => _FeuilleTraductionState();
}

class _FeuilleTraductionState extends State<FeuilleTraduction> {
  late String _cible = widget.cible;
  ResultatIntelligence? _resultat;
  bool _enCours = true;
  bool _originalOuvert = false;

  @override
  void initState() {
    super.initState();
    _traduire();
  }

  Future<void> _traduire({bool enLigne = false}) async {
    setState(() => _enCours = true);
    final resultat = await ServiceIntelligence.traduire(
      idMessage: widget.idMessage,
      texte: widget.texte,
      cible: _cible,
      forcerEnLigne: enLigne,
    );
    if (!mounted) return;
    setState(() {
      _resultat = resultat;
      _enCours = false;
    });
  }

  Future<void> _changerDeLangue() async {
    final choix = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ChoixLangue(courante: _cible),
    );
    if (choix == null || choix == _cible) return;
    OuroHaptics.selection();
    setState(() => _cible = choix);
    await _traduire();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final resultat = _resultat;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: OuroColors.tertiaryLabel,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.trTitle,
                    style: OuroTypography.headline.copyWith(
                      color: OuroColors.label,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _changerDeLangue,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: OuroColors.tertiarySystemFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nomDeLangue(_cible, l10n.trUnknownLang),
                          style: OuroTypography.footnote.copyWith(
                            color: OuroColors.accent,
                          ),
                        ),
                        Icon(
                          Icons.expand_more_rounded,
                          size: 16,
                          color: OuroColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _enCours
                  ? l10n.trOnDevice
                  : '${nomDeLangue(resultat?.langueSource, l10n.trUnknownLang)}'
                      ' → ${nomDeLangue(_cible, l10n.trUnknownLang)}',
              style: OuroTypography.caption.copyWith(
                color: OuroColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 14),

            // ── L'original, replié comme chez Telegram ─────────────────
            GestureDetector(
              onTap: () => setState(() => _originalOuvert = !_originalOuvert),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: OuroColors.tertiarySystemFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.trOriginal,
                          style: OuroTypography.caption.copyWith(
                            color: OuroColors.secondaryLabel,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _originalOuvert
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 16,
                          color: OuroColors.secondaryLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.texte,
                      maxLines: _originalOuvert ? null : 2,
                      overflow: _originalOuvert ? null : TextOverflow.ellipsis,
                      style: OuroTypography.footnote.copyWith(
                        color: OuroColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── La traduction ──────────────────────────────────────────
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.34,
              ),
              child: SingleChildScrollView(
                child: _enCours
                    ? const _Squelette()
                    : (resultat != null && resultat.reussi
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                resultat.texte!,
                                style: OuroTypography.body.copyWith(
                                  color: OuroColors.label,
                                ),
                              ),
                              // Transparence : ce texte a quitté l'appareil.
                              if (resultat.enLigne) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.cloud_outlined,
                                        size: 13, color: OuroColors.tertiaryLabel),
                                    const SizedBox(width: 5),
                                    Text(
                                      l10n.trViaOnline,
                                      style: OuroTypography.caption.copyWith(
                                        color: OuroColors.tertiaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          )
                        : _Echec(
                            etat: resultat?.etat ?? EtatIntelligence.echec,
                            surReessayer: _traduire,
                            surEnLigne: ServiceIntelligence.enLigneAutorise
                                ? null
                                : () => _traduire(enLigne: true),
                          )),
              ),
            ),
            const SizedBox(height: 16),

            // ── Les actions ────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _Bouton(
                    icone: Icons.copy_rounded,
                    libelle: l10n.trCopy,
                    actif: resultat?.reussi ?? false,
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: resultat!.texte!));
                      OuroHaptics.selection();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Bouton(
                    icone: Icons.chat_bubble_outline_rounded,
                    libelle: l10n.trInChat,
                    actif: (resultat?.reussi ?? false) &&
                        widget.surAfficherDansLaBulle != null,
                    principal: true,
                    onTap: () {
                      widget.surAfficherDansLaBulle!(resultat!.texte!);
                      OuroHaptics.selection();
                      Navigator.of(context).pop();
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

/// Les trois lignes grises qui battent pendant le calcul.
class _Squelette extends StatefulWidget {
  const _Squelette();

  @override
  State<_Squelette> createState() => _SqueletteState();
}

class _SqueletteState extends State<_Squelette>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Opacity(
        opacity: 0.35 + 0.35 * _ctrl.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final largeur in [1.0, 0.92, 0.6])
              FractionallySizedBox(
                widthFactor: largeur,
                child: Container(
                  height: 13,
                  margin: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(
                    color: OuroColors.tertiaryLabel,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Echec extends StatelessWidget {
  const _Echec({
    required this.etat,
    required this.surReessayer,
    this.surEnLigne,
  });

  final EtatIntelligence etat;
  final VoidCallback surReessayer;

  /// « Traduire en ligne », proposé quand le moteur de l'appareil n'a pas
  /// pu — `null` si l'utilisateur a déjà autorisé les services en ligne.
  final VoidCallback? surEnLigne;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final message = switch (etat) {
      EtatIntelligence.identique => l10n.trSame,
      EtatIntelligence.modele => l10n.trModel,
      EtatIntelligence.indisponible => l10n.trUnavailable,
      _ => l10n.trFailed,
    };
    final enLigne = surEnLigne;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: OuroTypography.footnote.copyWith(color: OuroColors.secondaryLabel),
        ),
        if (etat != EtatIntelligence.identique &&
            etat != EtatIntelligence.indisponible) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: surReessayer,
            child: Text(
              l10n.trRetry,
              style: OuroTypography.footnote.copyWith(color: OuroColors.accent),
            ),
          ),
        ],
        if (enLigne != null && etat != EtatIntelligence.identique) ...[
          const SizedBox(height: 14),
          GestureDetector(
            onTap: enLigne,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: OuroColors.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_outlined, size: 16, color: OuroColors.accent),
                  const SizedBox(width: 6),
                  Text(
                    l10n.trOnline,
                    style: OuroTypography.footnote.copyWith(
                      color: OuroColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.trOnlineNote,
            style: OuroTypography.caption.copyWith(color: OuroColors.tertiaryLabel),
          ),
        ],
      ],
    );
  }
}

class _Bouton extends StatelessWidget {
  const _Bouton({
    required this.icone,
    required this.libelle,
    required this.actif,
    required this.onTap,
    this.principal = false,
  });

  final IconData icone;
  final String libelle;
  final bool actif;
  final bool principal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleur = principal ? OuroColors.accent : OuroColors.tertiarySystemFill;
    final encre = principal ? Colors.white : OuroColors.label;
    return Opacity(
      opacity: actif ? 1 : 0.4,
      child: GestureDetector(
        onTap: actif ? onTap : null,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: couleur,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icone, size: 17, color: encre),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  libelle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: OuroTypography.footnote.copyWith(color: encre),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoixLangue extends StatelessWidget {
  const _ChoixLangue({required this.courante});

  final String courante;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: OuroColors.secondarySystemBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            for (final entree in kLanguesTraduction.entries)
              ListTile(
                title: Text(
                  entree.value,
                  style: OuroTypography.body.copyWith(color: OuroColors.label),
                ),
                trailing: entree.key == courante
                    ? Icon(Icons.check_rounded, color: OuroColors.accent)
                    : null,
                onTap: () => Navigator.of(context).pop(entree.key),
              ),
          ],
        ),
      ),
    );
  }
}
