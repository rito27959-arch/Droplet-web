// ============================================================================
// LE FLOU PROGRESSIF DE GLASMIO, pour les écrans Flutter.
// ----------------------------------------------------------------------------
// Portage direct du flou progressif de Glasmio (ProgressiveBackdropBlur.kt,
// Apache-2.0 — lui-même repris d'AndroidX) : un flou gaussien séparable en
// deux passes (horizontale puis verticale), dont le rayon varie à CHAQUE
// pixel — plein en haut, il s'éteint linéairement entre `uDebut` et `uFin`
// (fractions de la hauteur). Aucune teinte : les couleurs du contenu sont
// conservées, comme chez Glasmio.
// ============================================================================

#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;        // posé par Flutter : la taille de l'image filtrée
uniform float uVertical;   // 0 = passe horizontale, 1 = passe verticale
uniform float uRayon;      // rayon maximal, en pixels
uniform float uDebut;      // fraction de hauteur où le flou commence à décroître
uniform float uFin;        // fraction de hauteur où il est nul
uniform sampler2D uImage;  // posé par Flutter : l'image à flouter

out vec4 fragColor;

const float MAX_RAYON = 60.0;

vec4 echantillon(vec2 p) {
  return texture(uImage, clamp(p, vec2(0.5), uSize - vec2(0.5)) / uSize);
}

void main() {
  vec2 coord = FlutterFragCoord().xy;
  float y = coord.y / uSize.y;
  float intensite = 1.0 - clamp((y - uDebut) / max(uFin - uDebut, 0.0001), 0.0, 1.0);
  float rayon = uRayon * intensite;
  float r = floor(rayon);
  if (r < 1.0) {
    fragColor = echantillon(coord);
    return;
  }
  vec2 axe = uVertical > 0.5 ? vec2(0.0, 1.0) : vec2(1.0, 0.0);
  float sigma = max(rayon / 2.0, 1.0);
  float inv = 1.0 / (sigma * sigma);
  float rapport = exp(-0.5 * inv);
  float pasRapport = exp(-inv);
  float poids = 1.0;
  float somme = 1.0;
  vec4 resultat = echantillon(coord);
  for (float i = 1.0; i < MAX_RAYON; i += 2.0) {
    if (i >= r) { break; }
    poids *= rapport;
    rapport *= pasRapport;
    float pL = poids;
    poids *= rapport;
    rapport *= pasRapport;
    float pH = poids;
    float p = pL + pH;
    vec2 decalage = axe * (i + pH / p);
    resultat += p * echantillon(coord - decalage);
    resultat += p * echantillon(coord + decalage);
    somme += 2.0 * p;
  }
  fragColor = resultat / somme;
}
