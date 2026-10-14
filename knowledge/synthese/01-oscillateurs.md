# Oscillateurs — la matière première

## Formes d'onde et contenu harmonique

| Forme | Harmoniques | Pente | À l'oreille | Usages typiques |
|---|---|---|---|---|
| **Sinus** | fondamentale seule | — | pur, flûté, « sub » | sub-basse, sifflets, FM |
| **Triangle** | impairs seulement | −12 dB/oct (1/n²) | doux, creux, flûte/ocarina | leads doux, basses rondes, base pour FM / wavefold |
| **Dent de scie (saw)** | tous (pairs + impairs) | −6 dB/oct (1/n) | brillant, cuivré, « buzzy » | cordes, cuivres, basses, supersaw, acid |
| **Carré (50 %)** | impairs seulement | −6 dB/oct | creux, boisé, clarinette | basses house, leads 8-bit, clarinette, Lucky Man |
| **Pulse (< 50 %)** | tous sauf multiples de 1/largeur | −6 dB/oct | nasal, fin, « hautbois » à 10-25 % | leads nasaux, clavecin, Juno |
| **Bruit blanc** | spectre plat | — | souffle | percussions, vent, attaque, FX |
| **Wavefold** | ajoute des harmoniques hautes non monotones | — | métallique, « West Coast », vocal | leads agressifs, basses modernes |

**Règle d'or** : impairs seuls = creux (carré, triangle) ; tous les harmoniques = plein (scie).
Le *nasal* vient d'un pulse étroit ou d'un passe-bande.

## Combiner deux oscillateurs

- **Désaccord fin** (detune) : 2-10 cents = chorus/épaississement. 15-25 cents = « fat », vintage, désaccordé assumé.
  Fréquence de battement ≈ f × (2^(cents/1200) − 1) → à 440 Hz, 5 cents ≈ 1,3 battement/s.
- **Intervalles** : quinte (+7) = lead « organ/brass » (Minimoog), octave (+12) = épaisseur, quarte (+5) = son « hook » des années 90.
- **Sync** (hard sync) : l'OSC 2 redémarre à chaque cycle de l'OSC 1. Monter la hauteur de l'OSC 2 → résonance balayée, son « déchirant » (*Cars*, Gary Numan ; leads 80s). Le sync se joue en modulant la hauteur de l'OSC 2 (enveloppe ou LFO).
- **FM** (1→2 FM sur le Messenger, CROSS MOD sur le minilogue XD) : peu = enrichissement, beaucoup = cloches, métal, inharmonique. Rapports entiers = harmonique ; non entiers = cloche/métal.
- **Ring mod** : produit somme/différence, cloches, robot.
- **Sub-oscillateur** : 1 octave sous l'OSC 1 ; donne du poids sans ajouter de brillance (sub en triangle/sinus) ou du grain (sub carré).

## Octaves (pieds d'orgue)

32' = −2 oct · 16' = −1 oct · 8' = référence · 4' = +1 oct · 2' = +2 oct.
Basses : 16'/32'. Leads : 8'/4'. Le réglage dépend aussi de *KB OCTAVE* : noter les deux sur la fiche.

## Pièges

- Une basse « grosse » vient souvent du **sub + filtre**, pas d'un oscillateur plus grave.
- Les sons de piano/cordes réels sont **riches en harmoniques puis filtrés** : partir de la scie.
- Le carré à 50 % exact sonne « jeu vidéo » ; un pulse à 40-45 % plus vivant.
