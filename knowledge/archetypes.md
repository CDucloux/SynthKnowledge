# Archétypes : recettes de départ

Point de départ avant d'affiner avec les sources. Notation Messenger en heures (7 = MIN, 12 = midi, 17 = MAX).
Les valeurs sont des **départs raisonnables**, pas des vérités : toujours ajuster à l'oreille.

## Basses

Messenger : régler le corps au CUTOFF et l'attaque à l'EG AMOUNT, critère RES BASS : voir `machines/messenger.md` (« Régler le filtre d'une basse »). **Calibration à l'essai (2026-10-17) : sur le Messenger, ajouter ≈ 3 h aux cutoff de ce tableau** (corps d'une basse vers 1:00-2:00) et retirer ≈ 1 h 30 à l'EG.

| Archétype | Oscillateurs | Filtre | Env. filtre | Env. ampli | Divers |
|---|---|---|---|---|---|
| **Moog funk / pluck** | scie 16', sub carré | 4P, cutoff 9-10, EG 14-15, réso 9-10 | A 7, D 10-11, S 8, R 10 | A 7, D 12, S 17, R 9 | - |
| **House carrée** (manuel p.10-12) | carré 32', sub carré | 4P, cutoff 9, EG 15, réso 12, RES BASS | A 7, D 12, S 9, R 12 | A 7, D 9, S 17, R 12 | - |
| **Acid 303** | scie (ou carré) 16' seule | 4P, cutoff 10, EG 14, réso 14-15, RES BASS off | A 7, D 10-11, S 7 | A 7, D 13, S 15, R 8.5 | F ENV VEL, legato glide temps constant |
| **Sub-basse** | triangle 32' + sub triangle | 4P, cutoff 10-11, peu d'EG | - | A 7.5, S 17, R 9.5 | KB TRACKING off |
| **Reese** (DnB) | 2 scies 16' désaccordées (OSC 2 FREQ ~12.2) | 4P, cutoff 11, réso faible | lente ou nulle | S 17 | LFO lent sur OSC 2 FREQ |
| **Wobble** | scie + sub, FM légère | 4P / BP, réso 12-13 | - | S 17 | LFO 1 → CUTOFF, SYNC tempo, depth fort |
| **Basse Taurus** | 2 scies 16'/32' | 4P cutoff 10, EG 13 | D 14 | D 15, S 14, R 12 | - |

## Leads

| Archétype | Oscillateurs | Filtre | Env. | Divers |
|---|---|---|---|---|
| **Minimoog lead** | 2 scies (ou scie + carré), OSC 2 à +7 (quinte) ou désaccordé | 4P, cutoff 12-13, EG 13, KB track | F : D 13, S 14 · A : S 17 | glide 10-12, vibrato molette |
| **Lucky Man / carré chantant** | 2 carrés 8' désaccordés | 4P cutoff 12.5 | A : S 17 | glide 13 expo, vibrato |
| **Sync lead 80s** | OSC 2 synchronisé, une octave+ au-dessus | 2P ou 4P ouvert | MOD DEST : F ENV → OSC 2 FREQ, amount + | - |
| **G-funk sine lead** | triangle / sinus 4' | ouvert | A : A 7.5, S 17 | glide 11-12, legato glide, vibrato |
| **Lead nasal / hautbois** | pulse étroit (WAVESHAPE 15-16) | BP ou 2P, réso 11 | A courte | vibrato fade-in (LFO 1 FADE) |
| **Cuivre solo** (trompette, patch Minimoog de G. Reid [SS26]) | 1 scie 4' seule (trombone 8', tuba 16' + sub) | 4P, cutoff 7-8, EG ≈ 15, réso ≈ 9, KB track ON | F : A ≈ 11, D ≈ 11.5, S 12 · A : A ≈ 9, S 17, R 7.5-8 | growl LFO 1 ≈ 80 Hz → cutoff à l'attaque, vibrato faible à la molette ; détail dans `synthesis/07-imitation-instruments.md` |

## Polyphoniques (→ minilogue XD)

| Archétype | Recette |
|---|---|
| **Pad analogique** | 2 scies désaccordées, cutoff moyen, A/R ampli lents, env. filtre lente, chorus + reverb |
| **Strings 70s** (Solina-like) | scie + pulse, passe-bas moyen, attaque 100-300 ms, ensemble (MOD FX) |
| **Brass « Jump »** | 2 scies désaccordées, env. filtre A ~80 ms, D moyen, S moyen, unison léger |
| **Juno pad / chord** | pulse + PWM via LFO, chorus Juno, release moyen |
| **E-piano FM** | multi-engine VPM, decay long, sustain bas |

## Plucks, keys, percussions

| Archétype | Recette (Messenger sauf mention) |
|---|---|
| **Pluck / harpe** | scie ou carré, F ENV : D 10, S 7, EG 15 ; A ENV : D 11, S 7, R 11 |
| **Marimba / mallet** | triangle 8', FM légère, filtre fermé, decay court, sustain 0 |
| **Cloche** | 1→2 FM fort, OSC 2 FREQ non entier, decay long, sustain 0 |
| **Kick** | RESONANCE max (auto-osc.), cutoff bas, EG amount fort, F ENV D court ; KB TRACKING on |
| **Snare / hat** | NOISE dans le mixer, HP ou BP, decay court |
| **Zap / laser** | F ENV → OSC 2 FREQ (mod dest), descente rapide |
