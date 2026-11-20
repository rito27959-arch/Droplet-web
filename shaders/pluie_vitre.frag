// ============================================================================
// LA PLUIE SUR LA VITRE — le fond de l'accueil de l'assistant.
// ----------------------------------------------------------------------------
// On regarde dehors à travers une fenêtre embuée, un soir de pluie. Derrière
// la vitre, la ville n'est qu'un flou de lumières ; sur la vitre, des gouttes
// se forment, s'alourdissent, glissent en zigzag et laissent derrière elles
// une traînée NETTE, où la buée est partie. Chaque goutte est une petite
// lentille : on y voit la ville à l'envers, nette.
//
// C'est l'idée de Droplet sans dessiner une goutte avec des yeux : la pluie
// est partout, elle EST la goutte.
//
// Ce qui vit :
//   • le doigt essuie la buée là où il passe (uDoigt, uEssuie) ;
//   • en écoute ou en parole, la vitre vibre avec la voix (uNiveau) ;
//   • en réflexion, la pluie redouble et les gouttes filent plus vite ;
//   • la ville prend la couleur d'accent ; en clair, c'est un soir gris-bleu,
//     en sombre, une nuit.
//
// Tout est procédural : pas d'image, pas de texture. La ville est un champ de
// « bokeh » (des disques de lumière flous posés sur une grille), lu deux fois :
// très flou pour la buée, net pour l'intérieur des gouttes et les traînées.
//
// ⚠️ ÉCRIT POUR TOUS LES MOTEURS (Impeller et Skia/SkSL) : aucun tableau, des
// boucles à bornes constantes, rien d'autre. Code original, écrit pour Droplet.
// ============================================================================

#version 460 core
#include <flutter/runtime_effect.glsl>

precision mediump float;

uniform vec2 uSize;     // pixels
uniform float uTemps;   // secondes
uniform float uNiveau;  // 0..1 la voix
uniform float uMode;    // 0 repos, 1 écoute, 2 réflexion, 3 parole (glissant)
uniform vec3 uCouleur;  // l'accent, 0..1
uniform float uSombre;  // 0 clair, 1 sombre
uniform vec2 uDoigt;    // position du doigt, en pixels
uniform float uEssuie;  // 0..1 : le doigt vient d'essuyer (retombe seul)

out vec4 fragColor;

float h11(float p) {
  p = fract(p * 0.1031);
  p *= p + 33.33;
  p *= p + p;
  return fract(p);
}

vec3 h31(float p) {
  vec3 q = fract(vec3(p) * vec3(0.1031, 0.1030, 0.0973));
  q += dot(q, q.yzx + 33.33);
  return fract((q.xxy + q.yzz) * q.zyx);
}

float h21(vec2 p) {
  vec3 q = fract(vec3(p.xyx) * 0.1031);
  q += dot(q, q.yzx + 33.33);
  return fract((q.x + q.y) * q.z);
}

// ── LA VILLE DERRIÈRE LA VITRE ────────────────────────────────────────────
// Une couche de bokeh : une lumière par case, de taille et de couleur au
// hasard. On lit la case et ses trois voisines les plus proches (4 lectures,
// toujours) : les disques débordent sans être coupés.
vec3 bokeh(vec2 uv, float echelle, float flou, float graine) {
  vec2 g = uv * echelle;
  vec2 base = floor(g - 0.5);
  vec3 somme = vec3(0.0);
  for (int j = 0; j < 2; j++) {
    for (int i = 0; i < 2; i++) {
      vec2 c = base + vec2(float(i), float(j));
      float id = h21(c + graine);
      vec3 r = h31(id * 917.0 + graine);
      vec2 centre = c + 0.2 + 0.6 * r.xy;
      float rayon = 0.07 + 0.10 * r.z;
      float d = length(g - centre);
      // Le flou élargit le disque et l'atténue d'autant : la même lumière,
      // étalée (c'est ce que fait la buée).
      float r2 = rayon * (1.0 + 2.2 * flou);
      float bord = r2 * (0.15 + 0.85 * min(flou, 1.0));
      float disque = (1.0 - smoothstep(r2 - bord, r2 + bord, d)) / (1.0 + 2.5 * flou);
      // Une lumière sur trois est chaude (réverbères, fenêtres), les autres
      // prennent la couleur d'accent ou un blanc froid.
      vec3 teinte = id < 0.33 ? vec3(1.0, 0.72, 0.38) : (id < 0.75 ? uCouleur : vec3(0.85, 0.9, 1.0));
      // Toutes ne sont pas allumées, et certaines clignotent à peine.
      float allume = step(0.12, fract(id * 7.13)) * (0.65 + 0.35 * sin(uTemps * (0.3 + id) + id * 40.0));
      somme += teinte * disque * allume * (0.55 + 0.45 * r.y);
    }
  }
  return somme;
}

vec3 ville(vec2 uv, float flou) {
  // Le ciel : un dégradé teinté d'accent (nuit) ou un gris-bleu (soir).
  vec3 haut = mix(vec3(0.58, 0.64, 0.74), vec3(0.02, 0.03, 0.07), uSombre);
  vec3 bas = mix(vec3(0.80, 0.80, 0.84), vec3(0.06, 0.06, 0.12), uSombre);
  vec3 ciel = mix(haut, bas, smoothstep(-0.2, 1.1, uv.y));
  ciel += uCouleur * 0.10 * (1.0 - uv.y) * (0.4 + 0.6 * uSombre);
  // Les lumières, plus nombreuses vers le bas (la rue).
  float rue = smoothstep(0.15, 0.95, uv.y);
  vec3 l = bokeh(uv + vec2(uTemps * 0.004, 0.0), 6.0, flou, 3.1) * (0.45 + 0.55 * rue);
  l += bokeh(uv + vec2(-uTemps * 0.007, 0.0), 11.0, flou, 11.7) * 0.8 * (0.3 + 0.7 * rue);
  l += bokeh(uv + vec2(uTemps * 0.002, 0.0), 17.0, flou, 23.9) * 0.6 * rue;
  // Deux phares qui passent en bas, de temps en temps.
  float passe = fract(uTemps * 0.05);
  float phare = exp(-pow((uv.x - (passe * 1.6 - 0.3)) * 7.0, 2.0)) * exp(-pow((uv.y - 0.86) * 18.0, 2.0));
  l += vec3(1.0, 0.85, 0.6) * phare * 1.2;
  float force = mix(0.55, 1.0, uSombre);
  return ciel + l * force;
}

// ── LES GOUTTES ───────────────────────────────────────────────────────────
// Une couche : une goutte par case, qui descend en dents de scie (lente,
// puis elle lâche), en zigzag, et sème une traînée de gouttelettes au-dessus
// d'elle. Rend (décalage x, décalage y, traînée nette).
vec3 couche(vec2 uv, float t, float graine) {
  vec2 rapport = vec2(1.0, 2.0);
  vec2 g = uv * rapport * 2.0;
  // Chaque colonne a sa propre vitesse : la pluie ne tombe pas au pas.
  float col = floor(g.x);
  float decal = h11(col * 7.31 + graine);
  g.y += decal;
  vec2 id = floor(g);
  vec2 st = fract(g) - 0.5;
  float n = h21(id + graine);
  float tt = t + n * 6.2831;
  // Un zigzag doux : la goutte hésite un peu en descendant.
  float x = (n - 0.5) * 0.6;
  x += sin(st.y * 5.0 + n * 20.0) * 0.04 + sin(tt * 0.7) * 0.02;
  // Les dents de scie : elle s'alourdit (lente), puis lâche (rapide).
  float f = fract(tt * 0.16);
  // Écran : y grandit vers le bas, la goutte va de -0.42 (haut) à 0.42.
  float y = mix(-0.42, 0.42, f < 0.8 ? f / 0.8 * 0.25 : 0.25 + (f - 0.8) / 0.2 * 0.75);
  vec2 p = (st - vec2(x, y)) / rapport;
  // La goutte : un disque un peu écrasé, plus lourd en bas.
  float rayon = 0.038 + 0.02 * n;
  float d = length(p * vec2(1.0, 1.15 - 0.3 * step(0.0, p.y)));
  float goutte = smoothstep(rayon, rayon * 0.6, d);
  // La traînée : une bande droite au-dessus (y plus grand = plus haut, la
  // goutte descend vers -y), nette et pâle, qui s'efface en remontant.
  float dessus = y - st.y;
  float trace = smoothstep(0.0, 0.03, dessus) * smoothstep(0.75, 0.05, dessus);
  trace *= smoothstep(0.026, 0.010, abs((st.x - x) / rapport.x));
  // Des gouttelettes laissées dans la traînée.
  float k = fract(dessus * 9.0) - 0.5;
  vec2 sp = vec2((st.x - x) / rapport.x, k / 9.0 / rapport.y * 2.0);
  float semis = smoothstep(0.012, 0.004, length(sp)) * step(0.05, dessus) * smoothstep(0.7, 0.1, dessus) * step(0.5, h21(id + floor(dessus * 9.0)));
  vec2 offs = (p / rayon) * goutte * 1.0 + (sp / 0.012) * semis * 0.5;
  return vec3(offs, max(trace * 0.75, max(goutte, semis)));
}

// La condensation fine : des perles fixes qui apparaissent et s'effacent.
float perles(vec2 uv, float t) {
  vec2 g = uv * 42.0;
  vec2 id = floor(g);
  vec2 st = fract(g) - 0.5;
  vec3 r = h31(h21(id) * 391.0);
  float vie = sin(t * (0.5 + r.z) + r.x * 6.2831) * 0.5 + 0.5;
  float d = length(st - (r.xy - 0.5) * 0.7);
  return smoothstep(0.32, 0.0, d) * pow(vie, 6.0) * step(0.55, r.z);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = frag / uSize.y;              // carré : y de 0 (haut) à 1 (bas)
  vec2 uvEcran = frag / uSize;

  float t = uTemps;
  float reflexion = clamp(1.0 - abs(uMode - 2.0), 0.0, 1.0);
  float ecoute = clamp(1.0 - abs(uMode - 1.0), 0.0, 1.0);
  float parole = clamp(1.0 - abs(uMode - 3.0), 0.0, 1.0);
  float voix = uNiveau * (ecoute + parole);

  // La vitre vibre avec la voix : un frisson fin, horizontal.
  vec2 vibre = vec2(sin(uv.y * 90.0 + t * 40.0), cos(uv.x * 70.0 - t * 33.0)) * 0.0015 * voix;
  vec2 v = uv + vibre;

  // La pluie redouble en réflexion.
  float vitesse = 1.0 + 1.6 * reflexion;
  float tp = t * vitesse;
  vec3 a = couche(v * 1.0, tp, 1.0);
  vec3 b = couche(v * 1.85 + vec2(7.3, 1.1), tp * 0.9, 2.7);
  vec3 c = couche(v * 2.4 + vec2(3.1, 5.9), tp * 0.8, 5.3) * vec3(1.0, 1.0, 0.6);
  float pl = perles(v, t);
  vec2 decalage = a.xy + b.xy + c.xy + vec2(pl) * 0.3;
  float net = clamp(a.z + b.z + c.z * 0.8 + pl * 0.6, 0.0, 1.0);
  // L'intérieur d'une goutte : une lentille (fort décalage, image inversée).
  float lentille = clamp(length(decalage), 0.0, 1.0);

  // Le doigt essuie : un disque de buée enlevée, au bord doux.
  float doigt = 1.0 - smoothstep(0.06, 0.16, length((frag - uDoigt) / uSize.y));
  net = max(net, doigt * uEssuie);

  // La buée : la ville très floue, voilée de blanc (la condensation
  // diffuse la lumière).
  vec3 flou = ville(uv, 1.0);
  vec3 bue = flou * mix(0.9, 0.8, uSombre) + vec3(mix(0.16, 0.035, uSombre));
  // À travers la traînée : la ville nette. Dans une goutte : la ville
  // nette, vue à travers la lentille (décalée, à l'envers, plus large).
  vec3 nette = ville(uv - decalage * 0.05, 0.0);
  vec3 col = mix(bue, nette * 1.15 + vec3(0.02), net);
  // Le liseré d'une goutte (sombre en bas, clair en haut) et son éclat.
  float bordG = smoothstep(0.55, 0.95, lentille) * net;
  col *= 1.0 - 0.35 * bordG * smoothstep(-0.2, 0.6, decalage.y);
  col += vec3(1.0) * pow(clamp(-decalage.y * 1.2 - decalage.x * 0.4, 0.0, 1.0), 8.0) * 0.8 * net;

  // En réflexion, une lueur d'accent monte du bas de la vitre.
  col += uCouleur * reflexion * 0.10 * smoothstep(0.4, 1.0, uvEcran.y) * (0.6 + 0.4 * sin(t * 3.0));
  // Le vignetage : les bords de la fenêtre plus sombres.
  float vig = smoothstep(1.25, 0.35, length(uvEcran - 0.5) * 1.4);
  col *= mix(0.80, 1.0, vig);

  fragColor = vec4(col, 1.0);
}
