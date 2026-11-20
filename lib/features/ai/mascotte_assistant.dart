// ============================================================================
// LA PHRASE D'ACCUEIL DE L'ASSISTANT, qui s'écrit lettre après lettre.
// ----------------------------------------------------------------------------
// (Ce fichier portait aussi une mascotte, une goutte avec des yeux ; elle a
// été remplacée par l'orbe en shader, voir `orbe_droplet.dart`.)
// ============================================================================

import 'package:flutter/material.dart';

import '../../design_system/ouro_colors.dart';

/// Une phrase qui s'écrit lettre après lettre, avec un curseur qui
/// clignote pendant l'écriture puis s'efface. Une seule fois.
class PhraseProgressive extends StatefulWidget {
  const PhraseProgressive({super.key, required this.texte, required this.style, this.delai = Duration.zero});

  final String texte;
  final TextStyle style;
  final Duration delai;

  @override
  State<PhraseProgressive> createState() => _PhraseProgressiveState();
}

class _PhraseProgressiveState extends State<PhraseProgressive> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // ~38 ms par caractère, entre 0,9 et 2,2 s.
    duration: Duration(milliseconds: (widget.texte.characters.length * 38).clamp(900, 2200)),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delai, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _c.value = 1;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lettres = widget.texte.characters.toList();
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final n = (Curves.easeOut.transform(_c.value) * lettres.length).round();
        final ecrit = lettres.take(n).join();
        final fini = _c.isCompleted;
        // Le reste du texte est là, invisible : la hauteur ne saute pas
        // pendant l'écriture, et le centrage reste juste.
        return Semantics(
          label: widget.texte,
          child: ExcludeSemantics(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: ecrit),
                  if (!fini)
                    TextSpan(
                      text: '|',
                      style: TextStyle(color: OuroColors.accent, fontWeight: FontWeight.w300),
                    ),
                  TextSpan(text: lettres.skip(n).join(), style: const TextStyle(color: Colors.transparent)),
                ],
              ),
              textAlign: TextAlign.center,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}
