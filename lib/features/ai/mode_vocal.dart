// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LE MODE VOCAL — parler à l'assistant et l'entendre répondre, SANS QUITTER
// LA CONVERSATION.
//
// ── ⚠️ CE N'EST PLUS UN ÉCRAN, C'EST UNE COUCHE ───────────────────────
//
// La première version était un écran noir plein cadre. Google a fait le
// chemin inverse en avril 2026 : Gemini Live a QUITTÉ le plein écran pour
// se poser sur la conversation, et la raison donnée vaut ici mot pour mot
// — « faire en sorte que la conversation continue ressemble moins à un
// mode séparé qui prend tout le téléphone ».
//
// Le plein écran coûtait trois choses :
//   • on ne voyait plus ce qui s'écrivait dans le fil, alors que le tour
//     vocal y atterrit vraiment ;
//   • on ne pouvait pas relire le message d'avant en parlant ;
//   • en sortir avait l'air d'annuler, alors que ça ne fait que rendre
//     le clavier.
//
// Ici, la couche REMPLACE LE COMPOSEUR et rien d'autre. La liste des
// messages reste visible, et elle défile pendant qu'on parle.
//
// ── LA FORME, REPRISE DE GEMINI LIVE ──────────────────────────────────
//
//   ┌──────────────────────────────── En direct    [CC] ──┐  barre du haut
//   │                                                     │
//   │   … la conversation, toujours là, qui défile …      │
//   │                                                     │
//   │        ╭───────────────────────────────╮            │  sous-titres :
//   │        │ trois lignes, la réponse en   │            │  trois lignes
//   │        │ train d'être dite             │            │  fixes
//   │        ╰───────────────────────────────╯            │
//   │              Toucher pour interrompre               │
//   │    ╭──────────────────────────────────────────╮     │
//   │    │  ✕        ▁▃▅▃▁ l'onde        🎙        │     │  la pastille
//   │    ╰──────────────────────────────────────────╯     │
//   └─────────────────────────────────────────────────────┘
//
// L'onde au centre, la sortie à gauche, le micro à droite : c'est
// l'agencement de Gemini Live, à un détail près — sa gauche porte aussi
// l'appareil photo et le partage d'écran. Droplet n'a ni l'un ni l'autre,
// et ce n'est pas un oubli : ils demandent un modèle de vision, et Groq
// n'en sert plus aucun.
//
// ⚠️ LA COULEUR N'EST PAS CELLE DE GEMINI. Son onde est bleue parce que
// le bleu est la marque de Google. Reprendre la forme d'une interface est
// une chose ; reprendre la couleur d'une marque en est une autre, et
// c'est celle qui se plaide. L'onde suit donc l'accent choisi dans
// Droplet, quel qu'il soit.
//
// ── ⚠️ DICTER ET PARLER SONT DEUX CHOSES ──────────────────────────────
//
// La DICTÉE écrit dans le champ : on relit, on corrige, on envoie. Le
// MODE VOCAL est une conversation : on parle, ça répond à haute voix.
// Le micro du composeur dicte, l'onde ouvre cette couche.
//
// ── ⚠️ IL N'EXISTE PAS HORS LIGNE, ET ÇA SE DIT AVANT ─────────────────
//
// La transcription passe par Whisper, donc par le réseau. Quand le mode
// en ligne n'est pas disponible, le bouton n'ouvre pas la couche : il
// mène à l'écran où l'on met la clé.
//
// ── CE QUI A ÉTÉ REPRIS, ET CE QUI A ÉTÉ LAISSÉ ───────────────────────
//
// REPRIS de Gemini Live : la couche au lieu du plein écran ; la pastille
// avec l'onde au centre ; le ✕ qui sort ; le micro coupé à droite ; les
// sous-titres en trois lignes fixes, réservés à CE QUE L'ASSISTANT DIT
// (pas à ce qu'on dit soi-même — Gemini ne les affiche qu'à la fin, et
// il a raison : voir sa propre parole se corriger en direct est une
// distraction) ; « Toucher pour interrompre », écrit, pas deviné.
//
// PAS REPRIS : l'avatar animé. Microsoft a retiré le sien de Copilot
// cette année. Une forme qui fait semblant d'écouter n'apprend rien de
// plus qu'une onde qui suit VRAIMENT le niveau du micro — et l'onde, elle,
// dit quand on n'est pas entendu.
//
// LAISSÉ DE CÔTÉ : le maintien du doigt pour parler. Gemini ne l'a pas —
// sa réponse au bruit est le micro coupé, pas le doigt sur un bouton.
// Suivre Gemini, c'était accepter ça aussi. Si le besoin revient, sa
// place est dans les réglages de l'assistant, pas dans la pastille.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/services/groq_service.dart';
import '../../design_system/design_tokens.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_motion.dart';
import '../../design_system/ouro_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'rendu_markdown.dart';

/// Où en est la boucle.
enum EtatVocal { pret, ecoute, transcription, reflexion, parole, erreur }

/// La couche vocale, posée à la place du composeur.
class CoucheVocale extends StatefulWidget {
  const CoucheVocale({
    super.key,
    required this.groq,
    required this.repondre,
    required this.onQuitter,
    this.sousTitres = true,
    this.langue,
  });

  final GroqService groq;

  /// Envoie la question au chef et rend sa réponse en texte. C'est
  /// l'écran de conversation qui la fournit, pour que le mode vocal
  /// partage le MÊME fil : ce qu'on dit ici s'écrit là-bas.
  final Future<String> Function(String question) repondre;

  /// Ferme la couche et rend le composeur.
  final VoidCallback onQuitter;

  /// Les sous-titres sont-ils allumés ? La bascule est dans la barre du
  /// haut, donc l'état appartient à l'écran, pas à la couche.
  final bool sousTitres;

  /// La langue de l'interface, donnée à Whisper comme indice.
  final String? langue;

  @override
  State<CoucheVocale> createState() => _CoucheVocaleState();
}

class _CoucheVocaleState extends State<CoucheVocale>
    with SingleTickerProviderStateMixin {
  final _micro = AudioRecorder();
  final _voix = FlutterTts();

  EtatVocal _etat = EtatVocal.pret;
  String _derniereReponse = '';
  String? _erreur;

  /// Micro coupé — l'équivalent du bouton de Gemini. La couche reste
  /// ouverte, la boucle s'arrête net.
  bool _coupe = false;

  /// Le niveau du micro, lissé, pour l'onde.
  double _niveau = 0;
  StreamSubscription<Amplitude>? _amplitudes;

  /// Depuis combien de temps c'est silencieux.
  Timer? _silence;

  /// Combien de tours de suite n'ont rien rendu.
  ///
  /// ⚠️ SANS CE COMPTEUR, LA BOUCLE NE S'ARRÊTE JAMAIS. Un téléphone posé
  /// sur une table, ou un micro qui ne capte rien, enchaînerait les tours
  /// à vide indéfiniment — et ceux qui passent la transcription AVANT de
  /// rendre une chaîne vide sont facturés. Au troisième, on repasse au
  /// repos et on attend un appui.
  int _toursVides = 0;
  static const _videsMax = 3;

  /// La respiration de l'onde quand il n'y a pas de niveau à suivre.
  ///
  /// ⚠️ DEUX MOMENTS SUR TROIS N'ONT AUCUN NIVEAU À MONTRER. Pendant la
  /// transcription et pendant la réponse, le micro est fermé : l'onde
  /// retombait à cinq points immobiles, et la pastille avait l'air plantée
  /// précisément quand elle travaillait. Ce n'est PAS une animation
  /// décorative déguisée — elle ne tourne que dans ces deux états, et
  /// jamais pendant l'écoute, où seul le vrai niveau a le droit de bouger.
  /// Sous « réduire les animations », elle se pose au repos.
  late final AnimationController _respiration;

  @override
  void initState() {
    super.initState();
    _respiration = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..bouclerSiAmbiant(reverse: true);
    _voix
      ..setCompletionHandler(_finDeParole)
      ..setCancelHandler(_finDeParole)
      ..setErrorHandler((_) => _finDeParole());
    // La couche s'ouvre en écoutant : on l'a demandée pour parler.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_ecouter()));
  }

  @override
  void dispose() {
    _silence?.cancel();
    _amplitudes?.cancel();
    _respiration.dispose();
    unawaited(_micro.dispose());
    unawaited(_voix.stop());
    super.dispose();
  }

  void _finDeParole() {
    if (!mounted) return;
    setState(() => _etat = EtatVocal.pret);
    _toursVides = 0;
    // ⚠️ ON RÉÉCOUTE TOUT DE SUITE. C'est ce qui fait une conversation
    // plutôt qu'une suite de questions : sans ça, il faudrait rappuyer
    // après chaque réponse, et on rappuierait avant la fin de la phrase.
    if (!_coupe) unawaited(_ecouter());
  }

  /// Un tour qui n'a rien rendu : on relance, sauf si ça fait trois.
  void _tourVide() {
    if (!mounted) return;
    _toursVides++;
    setState(() => _etat = EtatVocal.pret);
    if (_toursVides >= _videsMax || _coupe) return;
    unawaited(_ecouter());
  }

  // ── Écouter ──────────────────────────────────────────────────────────

  Future<void> _ecouter() async {
    if (_etat == EtatVocal.ecoute || _coupe) return;
    if (!await _micro.hasPermission()) {
      if (mounted) {
        setState(() {
          _etat = EtatVocal.erreur;
          _erreur = AppLocalizations.of(context).mvNoMic;
        });
      }
      return;
    }
    final dossier = await getTemporaryDirectory();
    final chemin = p.join(
      dossier.path,
      'vocal_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    await _micro.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: chemin,
    );
    OuroHaptics.light();
    if (!mounted) return;
    setState(() {
      _etat = EtatVocal.ecoute;
      _erreur = null;
    });

    _amplitudes = _micro
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen(_suivreNiveau);
  }

  void _suivreNiveau(Amplitude a) {
    if (!mounted) return;
    // `current` va d'environ −45 dB (silence) à 0 (saturation). On le
    // ramène entre 0 et 1, et on lisse : une onde qui saute à chaque
    // mesure donne l'impression d'un défaut, pas d'une voix.
    final brut = ((a.current + 45) / 45).clamp(0.0, 1.0);
    setState(() => _niveau = _niveau * 0.6 + brut * 0.4);

    if (brut > 0.25) {
      _silence?.cancel();
      _silence = null;
    } else {
      // ⚠️ 1,4 SECONDE, PAS MOINS. En dessous, on coupe la parole de
      // quelqu'un qui cherche son mot — et se faire couper par une
      // machine est la chose la plus agaçante d'un mode vocal.
      _silence ??= Timer(
        const Duration(milliseconds: 1400),
        () => unawaited(_terminerTour()),
      );
    }
  }

  Future<void> _terminerTour() async {
    _silence?.cancel();
    _silence = null;
    await _amplitudes?.cancel();
    _amplitudes = null;
    final chemin = await _micro.stop();
    if (!mounted || chemin == null) return;

    final fichier = File(chemin);
    // Moins d'un demi-Ko : un souffle, pas une phrase. Le transcrire
    // coûterait un appel pour rendre une chaîne vide.
    if (!fichier.existsSync() || await fichier.length() < 512) {
      _tourVide();
      return;
    }

    setState(() {
      _etat = EtatVocal.transcription;
      _niveau = 0;
    });

    try {
      final dit = await widget.groq.transcrire(fichier, langue: widget.langue);
      if (!mounted) return;
      if (dit.trim().isEmpty) {
        _tourVide();
        return;
      }
      _toursVides = 0;
      setState(() => _etat = EtatVocal.reflexion);

      final reponse = await widget.repondre(dit);
      if (!mounted) return;
      setState(() {
        _derniereReponse = reponse;
        _etat = EtatVocal.parole;
      });
      await _dire(reponse);
    } on EchecIa catch (e) {
      if (!mounted) return;
      setState(() {
        _etat = EtatVocal.erreur;
        _erreur = _direEchec(e.cause);
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _etat = EtatVocal.erreur;
        _erreur = AppLocalizations.of(context).mvFailed;
      });
    } finally {
      // Le fichier a servi ; le garder remplirait le cache de la voix de
      // quelqu'un, ce qui n'a aucune raison de traîner.
      if (fichier.existsSync()) unawaited(fichier.delete());
    }
  }

  String _direEchec(CauseEchecIa cause) {
    final l = AppLocalizations.of(context);
    return switch (cause) {
      CauseEchecIa.pasDeCle || CauseEchecIa.cleRefusee => l.raRefused,
      CauseEchecIa.reseau => l.raNoNetwork,
      CauseEchecIa.quotaEpuise || CauseEchecIa.tropRapide => l.raQuota,
      _ => l.mvFailed,
    };
  }

  Future<void> _dire(String texte) async {
    // ⚠️ ON NE LIT PAS LE BALISAGE. Une réponse contient des astérisques
    // et des dièses ; les faire prononcer donne « étoile étoile gras
    // étoile étoile », ce qui est risible la première fois et insupportable
    // la deuxième.
    final propre = texteAPrononcer(texte);
    if (propre.isEmpty) {
      _finDeParole();
      return;
    }
    // Les sous-titres montrent CE QUI EST DIT, donc la version nettoyée —
    // pas le markdown brut, qu'on n'entendrait pas.
    if (mounted) setState(() => _derniereReponse = propre);
    if (widget.langue != null) await _voix.setLanguage(widget.langue!);
    await _voix.speak(propre);
  }

  /// Le micro coupé de Gemini : la couche reste, la boucle s'arrête.
  Future<void> _basculerMicro() async {
    OuroHaptics.selection();
    final coupe = !_coupe;
    setState(() => _coupe = coupe);
    if (coupe) {
      _silence?.cancel();
      await _amplitudes?.cancel();
      _amplitudes = null;
      await _micro.stop();
      await _voix.stop();
      if (mounted) setState(() => _etat = EtatVocal.pret);
    } else {
      _toursVides = 0;
      await _ecouter();
    }
  }

  Future<void> _quitter() async {
    _silence?.cancel();
    await _amplitudes?.cancel();
    await _micro.stop();
    await _voix.stop();
    widget.onQuitter();
  }

  // ── La couche ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final parle = _etat == EtatVocal.parole;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ⚠️ TROIS LIGNES, ET PAS UNE DE PLUS. Une boîte qui grandit avec
        // la réponse pousserait la pastille et ferait sauter ce qu'on
        // lisait. Gemini fige la sienne à trois lignes pour la même
        // raison ; au-delà, c'est le fil qui garde le texte entier.
        if (widget.sousTitres && _sousTitre().isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.space4,
              0,
              DesignTokens.space4,
              DesignTokens.space2,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space4,
                vertical: DesignTokens.space3,
              ),
              decoration: BoxDecoration(
                color: OuroColors.secondarySystemGroupedBackground,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
                border: Border.all(color: OuroColors.separator, width: 0.5),
              ),
              child: Text(
                _sousTitre(),
                maxLines: 3,
                // On coupe par le DÉBUT : la fin d'une phrase en train
                // d'être dite est ce qu'on veut lire, pas son début.
                overflow: TextOverflow.ellipsis,
                style: OuroTypography.subheadline.copyWith(
                  color: _etat == EtatVocal.erreur
                      ? OuroColors.systemRed
                      : OuroColors.label,
                  height: 1.4,
                ),
              ),
            ),
          ),

        // « Toucher pour interrompre » — écrit, pas deviné. Gemini l'a
        // ajouté après avoir caché ce geste derrière un double appui.
        AnimatedOpacity(
          duration: DesignTokens.durationFast,
          opacity: parle ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.space2),
            child: Text(
              l10n.mvTapToInterrupt,
              style: OuroTypography.caption1.copyWith(
                color: OuroColors.tertiaryLabel,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            DesignTokens.space3,
            0,
            DesignTokens.space3,
            DesignTokens.space3,
          ),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: OuroColors.secondarySystemGroupedBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              border: Border.all(color: OuroColors.separator, width: 0.5),
            ),
            child: Row(
              children: [
                const SizedBox(width: DesignTokens.space2),
                _RondVocal(
                  icone: Icons.close_rounded,
                  libelle: l10n.mvExit,
                  onTap: () => unawaited(_quitter()),
                ),
                // L'onde occupe tout le milieu, et l'appui dessus
                // interrompt : la cible est large parce que le geste est
                // fréquent.
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: parle
                        ? () {
                            OuroHaptics.light();
                            unawaited(_voix.stop());
                          }
                        : null,
                    child: Semantics(
                      liveRegion: true,
                      label: _libelleEtat(l10n),
                      child: _Onde(
                        niveau: _niveau,
                        etat: _coupe ? EtatVocal.pret : _etat,
                        coupe: _coupe,
                        respiration: _respiration,
                      ),
                    ),
                  ),
                ),
                _RondVocal(
                  icone: _coupe ? Icons.mic_off_rounded : Icons.mic_rounded,
                  libelle: _coupe ? l10n.mvUnmute : l10n.mvMute,
                  actif: _coupe,
                  onTap: () => unawaited(_basculerMicro()),
                ),
                const SizedBox(width: DesignTokens.space2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Ce que lit un lecteur d'écran, et ce que dirait un sous-titre si la
  /// réponse n'était pas encore là.
  String _libelleEtat(AppLocalizations l) => switch (_etat) {
        _ when _coupe => l.mvMuted,
        EtatVocal.ecoute => l.mvListening,
        EtatVocal.transcription => l.mvTranscribing,
        EtatVocal.reflexion => l.cpThinking,
        EtatVocal.parole => l.mvSpeaking,
        EtatVocal.erreur => l.mvProblem,
        EtatVocal.pret => l.mvTapToTalk,
      };

  String _sousTitre() => switch (_etat) {
        EtatVocal.erreur => _erreur ?? '',
        EtatVocal.parole => _derniereReponse,
        _ => '',
      };
}

// ══ L'ONDE ══════════════════════════════════════════════════════════════

/// Cinq barres qui suivent VRAIMENT le niveau du micro.
///
/// ⚠️ PAS UNE ANIMATION DÉCORATIVE. Une onde qui bouge toute seule ment :
/// elle bouge autant quand le micro est coupé. Celle-ci retombe à plat
/// quand rien n'entre, et c'est le seul moyen de comprendre qu'on n'est
/// pas entendu sans avoir à attendre une réponse absurde.
class _Onde extends StatelessWidget {
  const _Onde({
    required this.niveau,
    required this.etat,
    required this.coupe,
    required this.respiration,
  });

  final double niveau;
  final EtatVocal etat;
  final bool coupe;
  final Animation<double> respiration;

  @override
  Widget build(BuildContext context) {
    final ecoute = etat == EtatVocal.ecoute;
    final anime = !coupe &&
        (etat == EtatVocal.transcription ||
            etat == EtatVocal.reflexion ||
            etat == EtatVocal.parole);

    return SizedBox(
      height: 44,
      child: AnimatedBuilder(
        animation: respiration,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              AnimatedContainer(
                duration: DesignTokens.durationInstant,
                curve: DesignTokens.curveEnter,
                width: 5,
                height: _hauteur(i, ecoute, anime),
                decoration: BoxDecoration(
                  color: switch (etat) {
                    _ when coupe => OuroColors.tertiaryLabel,
                    EtatVocal.erreur => OuroColors.systemRed,
                    EtatVocal.parole => OuroColors.presenceMaintenant,
                    _ => OuroColors.accent,
                  },
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Hauteur d'une barre. Trois régimes, et un seul à la fois.
  ///
  /// La boîte fait 44 : aucune valeur rendue ici ne doit la dépasser.
  double _hauteur(int i, bool ecoute, bool anime) {
    // Les barres du centre réagissent plus que celles des bords : c'est
    // ce qui fait lire l'ensemble comme une onde et non comme cinq
    // curseurs.
    final poids = 1 - (i - 2).abs() * 0.22;
    // 6 + 36 = 42, pas 44 : à saturation, une barre calculée pile à la
    // hauteur de sa boîte n'a plus aucune marge, et le moindre arrondi
    // la ferait déborder.
    if (ecoute) return 6 + niveau * 36 * poids;
    if (!anime) return 6;
    // Un décalage par barre, sinon les cinq montent ensemble et on lit
    // un seul bloc qui grandit — pas une onde.
    final t = (respiration.value + i * 0.16) % 1.0;
    final v = t < 0.5 ? t * 2 : (1 - t) * 2;
    return 8 + v * 20 * poids;
  }
}

// ══ LES COMMANDES ═══════════════════════════════════════════════════════

class _RondVocal extends StatelessWidget {
  const _RondVocal({
    required this.icone,
    required this.libelle,
    required this.onTap,
    this.actif = false,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  /// Vrai quand le bouton signale un état en cours — le micro coupé, par
  /// exemple, qui doit se voir sans avoir à le tester.
  final bool actif;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: libelle,
      child: Tooltip(
        message: libelle,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // 48 : la cible tactile minimale. La pastille fait 64 de haut,
          // donc elle tient sans serrer.
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: AnimatedContainer(
                duration: DesignTokens.durationFast,
                curve: DesignTokens.curveEnter,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: actif
                      ? OuroColors.systemRed
                      : OuroColors.tertiarySystemFill,
                ),
                child: Icon(
                  icone,
                  size: DesignTokens.iconMd,
                  color: actif ? Colors.white : OuroColors.label,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══ CE QU'ON DONNE À LA VOIX ════════════════════════════════════════════

/// Le texte d'une réponse, prêt à être prononcé.
///
/// ⚠️ ON NE RÉÉCRIT PAS UN NETTOYEUR DE MARKDOWN. `texteBrutDepuisMarkdown`
/// existe déjà et sert à copier, à partager et à « lire à voix haute »
/// dans le fil — et surtout, il passe par le MÊME analyseur que le rendu
/// à l'écran. Une seconde expression régulière maison aurait divergé du
/// rendu au premier balisage un peu tordu, et on aurait entendu autre
/// chose que ce qu'on lit. C'est exactement le défaut « deux sources de
/// vérité » corrigé partout ailleurs dans cette application.
///
/// La seule règle ajoutée ici est propre à la voix : ON NE LIT PAS LES
/// BLOCS DE CODE. `texteBrutDepuisMarkdown` les garde — c'est juste pour
/// copier — mais entendre prononcer une accolade ligne à ligne est
/// insupportable, et le code reste de toute façon lisible dans le fil.
String texteAPrononcer(String texte) =>
    texteBrutDepuisMarkdown(texte.replaceAll(RegExp(r'```[\s\S]*?```'), ' '))
        .trim();
