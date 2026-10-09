// ============================================================================
// C'EST QUOI CE FICHIER ?
// ----------------------------------------------------------------------------
// LA CRÉATION D'UN SONDAGE : une question, et ses options — deux au
// minimum, dix au maximum (au-delà, ce n'est plus un sondage qu'on lit
// d'un coup d'œil, c'est un formulaire).
//
// Le résultat n'est PAS envoyé par cette feuille. Elle renvoie juste le
// texte encodé (`PollMessage.encode`) à l'écran de conversation, qui
// l'envoie par le même chemin qu'un message ordinaire — voir la note en
// tête de `poll_message.dart` sur pourquoi.
// ============================================================================

import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../design_system/glassmorphism.dart';
import '../../design_system/ouro_colors.dart';
import '../../design_system/ouro_haptics.dart';
import '../../design_system/ouro_pressable.dart';
import '../../design_system/ouro_typography.dart';
import 'poll_message.dart';
import '../../design_system/ouro_icon_button.dart';
import '../../design_system/ouro_retour_ios.dart';

/// Ouvre le compositeur de sondage. Renvoie le texte encodé du sondage,
/// ou `null` si l'utilisateur a renoncé.
Future<String?> composePoll(BuildContext context) {
  OuroHaptics.selection();
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.18),
    isScrollControlled: true,
    builder: (context) => const _PollComposerSheet(),
  );
}

class _PollComposerSheet extends StatefulWidget {
  const _PollComposerSheet();

  @override
  State<_PollComposerSheet> createState() => _PollComposerSheetState();
}

class _PollComposerSheetState extends State<_PollComposerSheet> {
  static const int _maxOptions = 10;

  final _question = TextEditingController();
  /// Combien de temps le sondage reste ouvert. `null` = sans fin.
  Duration? _duree;

  static const List<(Duration?, String)> _durees = [
    (null, '∞'),
    (Duration(hours: 1), '1 h'),
    (Duration(hours: 6), '6 h'),
    (Duration(hours: 24), '24 h'),
    (Duration(days: 3), '3 j'),
  ];

  final List<TextEditingController> _options = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _question.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _peutCreer {
    if (_question.text.trim().isEmpty) return false;
    final remplies = _options.where((c) => c.text.trim().isNotEmpty).length;
    return remplies >= 2;
  }

  void _ajouterOption() {
    if (_options.length >= _maxOptions) return;
    OuroHaptics.selection();
    setState(() => _options.add(TextEditingController()));
  }

  void _retirerOption(int i) {
    OuroHaptics.selection();
    setState(() {
      _options[i].dispose();
      _options.removeAt(i);
    });
  }

  void _creer() {
    // Les options vides sont abandonnées silencieusement — une ligne
    // laissée blanche est une hésitation, pas une troisième option
    // qu'on voulait vraiment proposer.
    final options = _options
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (_question.text.trim().isEmpty || options.length < 2) return;
    OuroHaptics.medium();
    Navigator.of(context)
        .pop(PollMessage.encode(
          _question.text.trim(),
          options,
          fin: _duree == null ? null : DateTime.now().add(_duree!),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Remonte la feuille au-dessus du clavier — sans ça, les derniers
      // champs d'option seraient masqués dès qu'on les atteint.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: FrostedSheet(
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.poll_rounded, color: OuroColors.systemPink),
                  const SizedBox(width: DesignTokens.space2),
                  Text(
                    'Nouveau sondage',
                    style: OuroTypography.title2.copyWith(color: OuroColors.label),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space4),
              _Champ(
                controller: _question,
                hint: 'Poser une question',
                style: OuroTypography.body.copyWith(
                  color: OuroColors.label,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: DesignTokens.space4),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (var i = 0; i < _options.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: DesignTokens.space2),
                          child: Row(
                            children: [
                              Expanded(
                                child: _Champ(
                                  controller: _options[i],
                                  hint: 'Option ${i + 1}',
                                  style: OuroTypography.body.copyWith(
                                    color: OuroColors.label,
                                  ),
                                  onChanged: () => setState(() {}),
                                ),
                              ),
                              // Retirer une option : seulement au-delà de
                              // deux — un sondage a besoin d'au moins un
                              // choix face à un autre, sinon ce n'est pas
                              // une question.
                              if (_options.length > 2)
                                OuroIconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline_rounded,
                                    color: OuroColors.tertiaryLabel,
                                    size: 20,
                                  ),
                                  onPressed: () => _retirerOption(i),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_options.length < _maxOptions)
                OuroPressable(
                  onTap: _ajouterOption,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.space2,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded,
                            color: OuroColors.accent, size: 20),
                        const SizedBox(width: DesignTokens.space2),
                        Text(
                          'Ajouter une option',
                          style: OuroTypography.body.copyWith(
                            color: OuroColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Jusqu'à quand on peut voter. « ∞ » = sans limite, comme
              // avant ; les autres ferment le sondage à l'heure dite.
              Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.space3),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 17, color: OuroColors.secondaryLabel),
                    const SizedBox(width: DesignTokens.space2),
                    for (final (duree, libelle) in _durees)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () {
                            OuroHaptics.selection();
                            setState(() => _duree = duree);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _duree == duree
                                  ? OuroColors.accent
                                  : OuroColors.tertiarySystemFill,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              libelle,
                              style: OuroTypography.footnote.copyWith(
                                color: _duree == duree ? Colors.white : OuroColors.label,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space4),
              SizedBox(
                width: double.infinity,
                child: OuroRetourIos(child: FilledButton(
                  onPressed: _peutCreer ? _creer : null,
                  style: FilledButton.styleFrom(overlayColor: Colors.transparent, 
                    backgroundColor: OuroColors.accent,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.space3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                  ),
                  child: const Text('Créer le sondage'),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un champ de texte simple, dans une pilule — même habillage que la
/// barre de saisie de la conversation, pour que la feuille se sente à sa
/// place plutôt que comme un formulaire rapporté.
class _Champ extends StatelessWidget {
  const _Champ({
    required this.controller,
    required this.hint,
    required this.style,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextStyle style;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OuroColors.tertiarySystemBackground,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: TextField(
        controller: controller,
        style: style,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: OuroTypography.body.copyWith(color: OuroColors.tertiaryLabel),
        ),
      ),
    );
  }
}
