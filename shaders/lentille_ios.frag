// ============================================================================
// LE REFLET DE LA LENTILLE — la barre d'onglets d'iOS 26.
// ----------------------------------------------------------------------------
// Ce shader ne réfracte rien : la réfraction (ce qui est derrière la
// lentille, grossi et tordu) est faite par `liquid_glass_renderer`. Lui
// ajoute ce qui fait qu'on CROIT au verre, et que le paquet ne dessine pas
// comme Apple :
//
//   • un LISERÉ SPÉCULAIRE sur le pourtour de la capsule — fort du côté de
//     la lumière (en haut à gauche), faible à l'opposé (la contre-lumière
//     qui traverse l'épaisseur) ;
//   • un ÉCLAT qui glisse le long du bord supérieur DANS LE SENS DU
//     MOUVEMENT : la lumière semble rester fixe pendant que le verre passe
//     dessous ;
//   • un VOILE très léger dans la moitié haute, la caustique d'une lentille
//     bombée.
//
// Le tout est peint en blanc prémultiplié, par-dessus la lentille, et
// s'éteint avec `uEpaisseur` : au repos, la lentille redevient un aplat.
// ============================================================================

#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;        // taille de la lentille, en points
uniform float uEpaisseur;  // 0 = aplat au repos, 1 = verre en mouvement
uniform float uVitesse;    // -1..1 : vitesse horizontale normalisée
uniform float uSombre;     // 0 = mode clair, 1 = mode sombre

out vec4 fragColor;

// Distance signée à une capsule (rectangle aux bouts entièrement ronds).
float capsule(vec2 p, vec2 demi, float r) {
  vec2 q = abs(p) - demi + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
  vec2 pixel = FlutterFragCoord().xy;
  vec2 demi = uSize * 0.5;
  vec2 p = pixel - demi;
  float r = min(demi.x, demi.y);
  float d = capsule(p, demi, r);

  if (d > 1.0 || uEpaisseur <= 0.001) {
    fragColor = vec4(0.0);
    return;
  }

  // La normale de la surface, tirée du gradient de la distance.
  vec2 e = vec2(1.0, 0.0);
  vec2 g = vec2(
    capsule(p + e.xy, demi, r) - capsule(p - e.xy, demi, r),
    capsule(p + e.yx, demi, r) - capsule(p - e.yx, demi, r)
  );
  vec2 n = g / max(length(g), 1e-4);

  // La lumière vient d'en haut à gauche ; le mouvement l'incline un peu,
  // comme un reflet qui « traîne » derrière l'objet.
  vec2 lumiere = normalize(vec2(-0.55 - uVitesse * 0.6, -0.85));

  // Le liseré : une bande de 3,5 points à l'intérieur du bord.
  float bande = smoothstep(-3.5, -0.2, d) * (1.0 - smoothstep(-0.2, 0.8, d));
  float spec = pow(max(dot(n, lumiere), 0.0), 3.0);
  float contre = pow(max(dot(n, -lumiere), 0.0), 4.0) * 0.45;
  float lisere = bande * (spec + contre);

  // L'éclat : une tache gaussienne sur le bord supérieur, déplacée par la
  // vitesse (sens opposé au mouvement : la lumière reste, le verre passe).
  float x = pixel.x / uSize.x;
  float centre = 0.32 - uVitesse * 0.22;
  // ⚠️ `v * v` et non `pow(v, 2.0)` : en GLSL, `pow` d'un nombre
  // négatif n'est pas défini, et certains GPU rendent alors du noir.
  float ecart = (x - centre) * 5.5;
  float eclat = exp(-ecart * ecart)
              * smoothstep(-7.0, -1.0, d)
              * max(-n.y, 0.0);

  // Le voile de la moitié haute : la caustique d'une lentille bombée.
  // (bornes croissantes : `smoothstep` à bornes inversées n'est pas défini.)
  float dedans = 1.0 - smoothstep(-r, 0.0, d);
  float voile = (1.0 - pixel.y / uSize.y) * 0.09 * dedans;

  float a = (lisere * 0.85 + eclat * 0.45 + voile) * uEpaisseur;
  // En sombre, un peu moins fort : sur du noir, le même blanc éblouit.
  a *= mix(1.0, 0.8, uSombre);
  a = clamp(a, 0.0, 1.0);

  fragColor = vec4(vec3(a), a);
}
