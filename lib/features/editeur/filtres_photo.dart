// ============================================================================
// FILTRES ET RÉGLAGES DE L'ÉDITEUR PHOTO — en matrices de couleur.
// ----------------------------------------------------------------------------
// Tout passe par des matrices 4×5 (`ColorFilter.matrix`) : le processeur
// graphique les applique à l'image sans la recopier, ce qui rend l'aperçu
// instantané même pendant qu'on fait glisser un curseur. Recalculer les pixels
// en Dart figerait l'écran à chaque mouvement.
//
// Les mêmes matrices servent à l'export : ce qu'on voit est exactement ce qui
// part. Le filtre s'applique d'abord (dosé par son intensité), puis les
// réglages par-dessus, comme dans les éditeurs de référence.
//
// Les noms des filtres sont des noms propres, identiques dans toutes les
// langues (comme ceux d'Instagram) ; seul « Original » est traduit.
// ============================================================================

typedef Matrice = List<double>;

const Matrice matriceIdentite = <double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0, //
  0, 0, 1, 0, 0, //
  0, 0, 0, 1, 0, //
];

/// `a ∘ b` : applique `b`, puis `a`.
Matrice composer(Matrice a, Matrice b) {
  final r = List<double>.filled(20, 0);
  for (var i = 0; i < 4; i++) {
    for (var j = 0; j < 5; j++) {
      var v = 0.0;
      for (var k = 0; k < 4; k++) {
        v += a[i * 5 + k] * b[k * 5 + j];
      }
      if (j == 4) v += a[i * 5 + 4];
      r[i * 5 + j] = v;
    }
  }
  return r;
}

/// Dose une matrice : 0 = aucun effet, 1 = effet entier. Comme la matrice
/// est affine, mélanger les matrices revient à mélanger les images.
Matrice doser(Matrice m, double t) => <double>[
      for (var i = 0; i < 20; i++) matriceIdentite[i] + (m[i] - matriceIdentite[i]) * t,
    ];

Matrice luminosite(double v) {
  final o = v * 0.22 * 255;
  return <double>[1, 0, 0, 0, o, 0, 1, 0, 0, o, 0, 0, 1, 0, o, 0, 0, 0, 1, 0];
}

Matrice contraste(double v) {
  final c = 1 + v * 0.55;
  final t = 127.5 * (1 - c);
  return <double>[c, 0, 0, 0, t, 0, c, 0, 0, t, 0, 0, c, 0, t, 0, 0, 0, 1, 0];
}

Matrice saturation(double v) {
  final s = (1 + v).clamp(0.0, 3.0).toDouble();
  const lr = 0.2126, lg = 0.7152, lb = 0.0722;
  final sr = (1 - s) * lr;
  final sg = (1 - s) * lg;
  final sb = (1 - s) * lb;
  return <double>[
    sr + s, sg, sb, 0, 0, //
    sr, sg + s, sb, 0, 0, //
    sr, sg, sb + s, 0, 0, //
    0, 0, 0, 1, 0, //
  ];
}

Matrice chaleur(double v) => <double>[
      1 + 0.10 * v, 0, 0, 0, 10 * v, //
      0, 1 + 0.02 * v, 0, 0, 2 * v, //
      0, 0, 1 - 0.10 * v, 0, -10 * v, //
      0, 0, 0, 1, 0, //
    ];

Matrice teinte(double r, double g, double b) =>
    <double>[1, 0, 0, 0, r, 0, 1, 0, 0, g, 0, 0, 1, 0, b, 0, 0, 0, 1, 0];

const Matrice _sepia = <double>[
  0.393, 0.769, 0.189, 0, 0, //
  0.349, 0.686, 0.168, 0, 0, //
  0.272, 0.534, 0.131, 0, 0, //
  0, 0, 0, 1, 0, //
];

class FiltrePhoto {
  const FiltrePhoto(this.id, this.nom, this.matrice);

  final String id;
  final String nom;
  final Matrice matrice;

  bool get original => id == 'original';
}

final List<FiltrePhoto> filtresPhoto = <FiltrePhoto>[
  const FiltrePhoto('original', 'Original', matriceIdentite),
  FiltrePhoto('aube', 'Aube', composer(saturation(0.08), composer(contraste(0.08), luminosite(0.10)))),
  FiltrePhoto('lagon', 'Lagon', composer(teinte(-6, 6, 14), composer(saturation(0.12), chaleur(-0.5)))),
  FiltrePhoto('ambre', 'Ambre', composer(contraste(0.06), composer(saturation(0.10), chaleur(0.6)))),
  FiltrePhoto('soiree', 'Soirée', composer(teinte(10, -6, 20), composer(luminosite(-0.04), saturation(0.06)))),
  FiltrePhoto('brume', 'Brume', composer(teinte(14, 14, 16), composer(saturation(-0.2), contraste(-0.28)))),
  FiltrePhoto('givre', 'Givre', composer(luminosite(0.05), composer(chaleur(-0.35), saturation(-0.35)))),
  FiltrePhoto('retro', 'Rétro', composer(contraste(-0.06), doser(_sepia, 0.55))),
  FiltrePhoto('noir', 'Noir', composer(contraste(0.28), saturation(-1))),
  FiltrePhoto('argent', 'Argent', composer(luminosite(0.06), composer(contraste(-0.1), saturation(-1)))),
  FiltrePhoto('vif', 'Vif', composer(contraste(0.12), saturation(0.38))),
  FiltrePhoto('doux', 'Doux', composer(luminosite(0.08), composer(contraste(-0.12), saturation(-0.12)))),
];

enum Reglage { luminosite, contraste, saturation, chaleur, vignette }

/// Les réglages de couleur (la vignette, elle, est un voile posé dessus).
Matrice matriceReglages(Map<Reglage, double> r) {
  var m = matriceIdentite;
  final l = r[Reglage.luminosite] ?? 0;
  final c = r[Reglage.contraste] ?? 0;
  final s = r[Reglage.saturation] ?? 0;
  final w = r[Reglage.chaleur] ?? 0;
  if (l != 0) m = composer(luminosite(l), m);
  if (c != 0) m = composer(contraste(c), m);
  if (s != 0) m = composer(saturation(s), m);
  if (w != 0) m = composer(chaleur(w), m);
  return m;
}

Matrice matriceFinale(FiltrePhoto filtre, double intensite, Map<Reglage, double> reglages) =>
    composer(matriceReglages(reglages), doser(filtre.matrice, intensite));
