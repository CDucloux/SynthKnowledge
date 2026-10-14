# Oscillateurs : la matière première

## Formes d'onde et contenu harmonique

| Forme | Harmoniques | Pente | À l'oreille | Usages typiques |
|---|---|---|---|---|
| **Sinus** | fondamentale seule | - | pur, flûté, « sub » | sub-basse, sifflets, FM |
| **Triangle** | impairs seulement | −12 dB/oct (1/n²) | doux, creux, flûte/ocarina | leads doux, basses rondes, base pour FM / wavefold |
| **Dent de scie (saw)** | tous (pairs + impairs) | −6 dB/oct (1/n) | brillant, cuivré, « buzzy » | cordes, cuivres, basses, supersaw, acid |
| **Carré (50 %)** | impairs seulement | −6 dB/oct | creux, boisé, clarinette | basses house, leads 8-bit, clarinette, Lucky Man |
| **Pulse (< 50 %)** | tous sauf multiples de 1/largeur | −6 dB/oct | nasal, fin, « hautbois » à 10-25 % | leads nasaux, clavecin, Juno |
| **Bruit blanc** | spectre plat | - | souffle | percussions, vent, attaque, FX |
| **Wavefold** | ajoute des harmoniques hautes non monotones | - | métallique, « West Coast », vocal | leads agressifs, basses modernes |

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

## Approfondir (Synth Secrets, index `knowledge/sources/synth-secrets.md`)

### Pulse : quelle largeur pour quel timbre [SS10]

- Règle exacte : une pulse de rapport **1:n** a le spectre d'une scie **sans chaque n-ième harmonique**. 50 % → pas de pairs (carré) ; 33 % → pas de 3, 6, 9… ; 25 % → pas de 4, 8, 12…
- Entre deux rapports entiers (ex. 28 %), les harmoniques concernés sont atténués sans disparaître.
- 5-10 % = fin, nasal (hautbois) ; vers 50 % le son s'épaissit ; 50 % exact = creux, boisé (clarinette).
- Une largeur > 50 % sonne comme son symétrique (60 % = 40 %).
- **PWM** par LFO lent = chorus « à la source » (cordes ensemble, leads riches). Ce n'est pas un chorus d'effet : la PWM fait varier les harmoniques eux-mêmes.

### Modulations audio : AM, ring, FM

- **AM** (oscillateur audio sur le volume) : on entend la porteuse + la **somme** + la **différence** des fréquences, le modulateur disparaît [SS11].
  Modulateur fixe = timbre inharmonique qui change selon la note (agressif). Modulateur qui suit le clavier = timbre stable (rapport 2:1 → composantes à 50/100/150 %, musical).
- **Ring mod** = AM sans la porteuse : seulement somme et différence → cloches, métal, robot [SS11]. Minilogue XD : *RING* sur le VCO 2.
- **Oscillateur audio sur le cutoff** = chaque harmonique est modulé en amplitude : c'est le « growl » à fréquence audio [SS11]. Messenger : *OSC 2 → CUTOFF*.
- **FM** : bandes latérales à porteuse ± n × modulateur [SS12]. La **quantité** de modulation fixe la brillance (peu = proche de l'AM ; beaucoup = spectre large, la fondamentale s'affaiblit) ; la **fréquence** du modulateur fixe la position des partiels.
- **Rapports porteuse:modulateur** [SS13] : 1:1 ≈ scie filtrée ; 1:2 ≈ carré filtré ; 1:3 ≈ pulse 33 % ; non entier = inharmonique, métallique (la porteuse n'est plus la composante la plus grave).
- En pratique sur deux VCO : même hauteur, puis doser la FM (Messenger *MOD AMOUNT* en `fm`, XD *CROSS MOD*) ; une **enveloppe sur la quantité de FM** donne des changements de timbre radicaux, « sci-fi » [SS13].
- Rapports non entiers + enveloppe d'ampli percussive = très bonnes percussions [SS13].
- En jouant sur tout le clavier, la FM analogique change de couleur (l'indice baisse quand le modulateur monte) : la régler pour le registre joué [SS12].

### Additif simple [SS14]

Deux oscillateurs accordés en quinte ou en octave, c'est déjà de l'additif. Un Hammond est un additif à 9 tirettes : il sonne « orgue » parce que son timbre ne change pas dans le temps.
