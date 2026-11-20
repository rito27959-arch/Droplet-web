// ============================================================================
// L'ORBE DE DROPLET — la présence de l'assistant.
// ----------------------------------------------------------------------------
// Une sphère de verre qui contient un liquide lumineux en mouvement : c'est
// elle qui accueille, qui pense pendant que la réponse s'écrit, et qui écoute
// et parle en direct. Un seul shader pour les trois moments, réglé par
// `uMode` et `uNiveau`.
//
// Ce qu'on voit, de l'intérieur vers l'extérieur :
//   • UN LIQUIDE de lumière : un bruit fractal replié sur lui-même (« domain
//     warping »), projeté sur la sphère (la normale courbe le motif vers les
//     bords, d'où le volume) ; deux teintes tirées de la couleur d'accent ;
//   • UNE CAUSTIQUE : des filaments clairs, là où le liquide se replie ;
//   • LE VERRE : un liseré irisé (une pellicule mince — la teinte tourne
//     avec l'angle, comme une bulle de savon), un reflet spéculaire en haut
//     à gauche et une contre-lumière en bas ;
//   • UN HALO autour, qui respire.
//
// Les moments :
//   uMode 0 repos      — le liquide tourne lentement, la sphère respire ;
//   uMode 1 écoute     — le bord ondule avec la voix (uNiveau) ;
//   uMode 2 réflexion  — le liquide tourbillonne plus vite, le halo pulse ;
//   uMode 3 parole     — la sphère gonfle et se ride au rythme de la voix.
// Les passages d'un mode à l'autre sont lissés côté Dart (uMode est un
// flottant qui glisse), donc le shader mélange.
//
// ⚠️ ÉCRIT POUR TOUS LES MOTEURS DE RENDU. Impeller le compile, mais Skia
// (SkSL, les vieux Android) refuse les tableaux initialisés et les boucles
// dont le compteur ne part pas d'une constante — deux erreurs vues dans le
// journal de la CI pour d'autres shaders. Ici : aucun tableau, des boucles
// `for (int i = 0; i < N; i++)` à bornes constantes, et rien d'autre.
// ============================================================================

#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;      // taille de la zone, en pixels
uniform float uTemps;    // secondes
uniform float uNiveau;   // 0..1 : la voix (écoute ou parole)
uniform float uMode;     // 0 repos, 1 écoute, 2 réflexion, 3 parole (glissant)
uniform vec3 uCouleur;   // la couleur d'accent, 0..1
uniform float uSombre;   // 0 mode clair, 1 mode sombre

out vec4 fragColor;

// ── Bruit ───────────────────────────────────────────────────────────────

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float bruit(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  // Une rotation entre les octaves : sans elle, le motif s'aligne sur la
  // grille et on voit des carrés.
  mat2 r = mat2(0.8, 0.6, -0.6, 0.8);
  for (int i = 0; i < 4; i++) {
    v += a * bruit(p);
    p = r * p * 2.03 + vec2(17.1, 9.2);
    a *= 0.5;
  }
  return v;
}

// La teinte d'une pellicule mince : un arc-en-ciel doux, décalé par t.
vec3 irise(float t) {
  return 0.5 + 0.5 * cos(6.28318 * (vec3(0.0, 0.33, 0.67) + t));
}

// La teinte sombre du fond du liquide.
vec3 fonce(vec3 c) {
  return c * 0.32 + vec3(0.01, 0.01, 0.03);
}

// Fait tourner une couleur autour de l'axe gris (change la teinte).
vec3 tourneTeinte(vec3 c, float a) {
  const vec3 k = vec3(0.57735);
  float co = cos(a);
  return c * co + cross(k, c) * sin(a) + k * dot(k, c) * (1.0 - co);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float cote = min(uSize.x, uSize.y);
  // Coordonnées centrées, la sphère de rayon ~0.62 au repos.
  vec2 p = (frag - 0.5 * uSize) / (0.5 * cote);

  float t = uTemps;
  float ecoute = clamp(1.0 - abs(uMode - 1.0), 0.0, 1.0);
  float reflexion = clamp(1.0 - abs(uMode - 2.0), 0.0, 1.0);
  float parole = clamp(1.0 - abs(uMode - 3.0), 0.0, 1.0);
  float voix = uNiveau * (ecoute + parole);

  // ── La silhouette : un cercle dont le bord ondule ─────────────────────
  float ang = atan(p.y, p.x);
  float onde = 0.0;
  onde += sin(ang * 3.0 + t * 2.1) * 0.012;
  onde += sin(ang * 5.0 - t * 2.9) * 0.008;
  // Le bruit est lu sur le cercle (cos, sin) et non sur l'angle : l'angle
  // saute de +π à −π à gauche, et le bord s'y couperait net.
  vec2 cercle = vec2(cos(ang), sin(ang));
  onde += (bruit(cercle * 1.8 + vec2(t * 0.9, -t * 0.7)) - 0.5) * (0.04 + 0.16 * voix);
  float souffle = 0.012 * sin(t * 1.6) + 0.05 * parole * uNiveau + 0.02 * reflexion * sin(t * 4.0);
  float rayon = 0.62 + souffle + onde * (0.4 + 1.6 * voix + 0.6 * reflexion);
  float d = length(p) - rayon;

  // ── Le halo, hors de la sphère ────────────────────────────────────────
  vec3 base = uCouleur;
  vec3 seconde = tourneTeinte(base, 0.9);
  vec3 troisieme = tourneTeinte(base, -0.7);
  float halo = exp(-max(d, 0.0) * (5.0 - 1.5 * reflexion - 2.0 * voix));
  halo *= 0.35 + 0.15 * sin(t * 1.6) + 0.25 * reflexion * (0.5 + 0.5 * sin(t * 4.0)) + 0.4 * voix;

  // Bord adouci sur ~1,5 pixel : pas d'escalier.
  float px = 3.0 / cote;
  float dedans = 1.0 - smoothstep(-px, px, d);

  // ── L'intérieur : un liquide de lumière sur une sphère ────────────────
  vec2 q = p / rayon;
  float r2 = clamp(dot(q, q), 0.0, 1.0);
  float z = sqrt(1.0 - r2);
  vec3 n = vec3(q, z);
  // La projection sphérique : le motif se tasse vers le bord.
  vec2 uv = q / (0.55 + z) * 1.4;

  float vitesse = 0.12 + 0.35 * reflexion + 0.2 * voix;
  float tt = t * vitesse;
  // Domain warping : le bruit déforme le bruit, deux fois.
  vec2 w1 = vec2(fbm(uv * 1.6 + vec2(tt, -tt * 0.7)), fbm(uv * 1.6 + vec2(-tt * 0.8, tt) + 5.2));
  vec2 w2 = vec2(fbm(uv * 1.9 + 2.2 * w1 + vec2(1.7, 9.2) + tt * 0.6), fbm(uv * 1.9 + 2.2 * w1 + vec2(8.3, 2.8) - tt * 0.5));
  float f = fbm(uv * 1.3 + 2.6 * w2);

  vec3 liquide = mix(fonce(base), seconde, smoothstep(0.25, 0.75, f));
  liquide = mix(liquide, troisieme, smoothstep(0.55, 0.95, length(w2)) * 0.6);
  // La caustique : des filaments là où le liquide se replie.
  float fil = pow(1.0 - abs(f * 2.0 - 1.0), 6.0);
  liquide += vec3(1.0) * fil * (0.35 + 0.4 * reflexion + 0.5 * voix);
  // Le cœur s'allume quand on parle ou qu'on pense.
  liquide += base * (0.25 * reflexion + 0.6 * voix) * z * z;

  // ── Le verre ──────────────────────────────────────────────────────────
  // y vers le bas (coordonnées d'écran) : la lumière vient d'en haut à gauche.
  vec3 lumiere = normalize(vec3(-0.45, -0.55, 0.7));
  float diffus = clamp(dot(n, lumiere), 0.0, 1.0);
  vec3 couleur = liquide * (0.55 + 0.6 * diffus);
  // Fresnel : le bord reflète plus qu'il ne laisse voir.
  float fresnel = pow(1.0 - z, 3.0);
  vec3 film = irise(0.25 * cercle.x + 0.15 * cercle.y + t * 0.05 + f * 0.3);
  couleur = mix(couleur, film * 0.9 + base * 0.3, fresnel * 0.65);
  // Le reflet spéculaire (fenêtre en haut à gauche) et un petit éclat.
  vec3 h = normalize(lumiere + vec3(0.0, 0.0, 1.0));
  float spec = pow(clamp(dot(n, h), 0.0, 1.0), 60.0);
  couleur += vec3(1.0) * spec * 0.9;
  float eclat = smoothstep(0.10, 0.0, length(q - vec2(-0.38, -0.42)));
  couleur += vec3(1.0) * eclat * 0.35;
  // La contre-lumière en bas, qui traverse l'épaisseur.
  float contre = smoothstep(0.5, 1.0, q.y) * fresnel;
  couleur += seconde * contre * 0.8;

  // ── Assemblage, en alpha prémultiplié ─────────────────────────────────
  vec3 couleurHalo = mix(base, seconde, 0.5 + 0.5 * sin(ang + t * 0.5));
  float aHalo = halo * (1.0 - dedans) * (uSombre > 0.5 ? 0.9 : 0.6);
  vec3 rgb = couleur * dedans + couleurHalo * aHalo;
  float a = clamp(dedans + aHalo, 0.0, 1.0);
  fragColor = vec4(rgb, a);
}
