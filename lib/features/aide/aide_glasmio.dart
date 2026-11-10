// ============================================================================
// L'AIDE EN GLASMIO (Android 13+). Même contenu que `AideScreen` (l'écran de
// repli) : la recherche dans les questions (sans accents, comme l'écran
// Flutter), les questions qui se déplient, « Écrire à l'équipe ».
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/passerelle_glasmio.dart';
import '../../core/services/pont_glasmio.dart';
import '../../design_system/ouro_colors.dart';
import 'aide_screen.dart';

class PasserelleAide extends ConsumerStatefulWidget {
  const PasserelleAide({super.key});

  @override
  ConsumerState<PasserelleAide> createState() => _PasserelleAideState();
}

class _PasserelleAideState extends EtatPasserelleGlasmio<PasserelleAide> {
  final Set<int> _ouvertes = {};
  String _filtre = '';

  @override
  String get ecran => 'aide';

  @override
  Widget construireRepli(BuildContext context) => const AideScreen();

  static String _aplati(String s) {
    const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
    const sans = 'aaaaaaceeeeiiiinooooouuuuyy';
    final b = StringBuffer();
    for (final c in s.toLowerCase().runes) {
      final ch = String.fromCharCode(c);
      final i = avec.indexOf(ch);
      b.write(i >= 0 ? sans[i] : ch);
    }
    return b.toString();
  }

  @override
  Future<ReponseGlasmio> gerer(String id, Object? valeur) async {
    if (id == 'recherche') {
      final t = (valeur as String? ?? '').trim().toLowerCase();
      if (t != _filtre) {
        _filtre = t;
        _ouvertes.clear();
      }
    } else if (id == 'contact') {
      return allerA('/aide/contact');
    } else if (id.startsWith('q:')) {
      final i = int.parse(id.substring(2));
      if (!_ouvertes.remove(i)) _ouvertes.add(i);
    }
    if (!mounted) return ReponseGlasmio.rien;
    return ReponseGlasmio.maj(await decrire());
  }

  @override
  Future<Map<String, Object?>> decrire() async {
    final t = textes;
    final toutes = questionsAide(t);
    final f = _aplati(_filtre);
    final visibles = [
      for (var i = 0; i < toutes.length; i++)
        if (f.isEmpty || _aplati(toutes[i].question).contains(f) || _aplati(toutes[i].reponse).contains(f)) i,
    ];
    return {
      'titre': t.hlpHelpTitle,
      'retour': MaterialLocalizations.of(context).backButtonTooltip,
      'sombre': OuroColors.isDark,
      'accent': OuroColors.accent.toARGB32(),
      'recherche': {
        'id': 'recherche',
        'texte': _filtre,
        'indice': MaterialLocalizations.of(context).searchFieldLabel,
        'fermer': MaterialLocalizations.of(context).cancelButtonLabel,
      },
      'sections': [
        if (visibles.isEmpty)
          {'pied': t.hlpNoResult, 'lignes': <Object>[]}
        else
          {
            'lignes': [
              for (final i in visibles)
                {
                  'id': 'q:$i',
                  'type': 'paragraphe',
                  'cliquable': true,
                  'titre': toutes[i].question,
                  if (_ouvertes.contains(i) || f.isNotEmpty) 'sous': toutes[i].reponse,
                },
            ],
          },
        {
          'pied': t.hlpStillStuckFooter,
          'lignes': [
            {'id': 'contact', 'type': 'nav', 'icone': 'support_agent', 'teinte': OuroColors.accent.toARGB32(), 'titre': t.hlpContact},
          ],
        },
      ],
    };
  }
}
