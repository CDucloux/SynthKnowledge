# Moog Messenger : référence pour les fiches

Source : `manuals/moog-messenger-user-manual.pdf`. Monophonique, analogique, **aucun effet**, 32 touches (vélocité + aftertouch).
Le schéma de la fiche (`template/messenger.typ`) reprend cette liste ; les **clés YAML** sont entre parenthèses.

## Notation des boutons

Heures d'horloge : **7 = MIN** (butée gauche), **12 = midi**, **17 = MAX** (butée droite). Décimales : 10.5 = 10:30.
Bipolaires (0 à midi) : TUNE, OSC 2 FREQ, MOD AMOUNT, EG AMOUNT, LFO 1 DEPTH.

## Section par section

### LFO 1 (`lfo1`)
- RATE (`rate`) : 0,05-12 Hz (CONFIG 1.4 : jusqu'à 120 Hz ou 1,2 kHz). Avec SYNC : divisions d'horloge.
- DEPTH (`depth`) : bipolaire.
- WAVESHAPE (`wave`) : `tri` · `saw` · `ramp` · `sqr`.
- DESTINATION (`dest`) : `cutoff` · `osc2_freq` · `osc1_wave` · `sub_wave`.
- SYNC (`sync`), KB RESET (`kb_reset`) : booléens. KB RESET maintenu = [LFO 1 ASSIGN].

### Oscillators (`osc`)
- OCTAVE 1 / 2 (`oct1`, `oct2`) : `4` · `8` · `16` · `32` (pieds).
- TUNE (`tune`) : ±7 demi-tons, global.
- WAVESHAPE 1 / 2 (`wave1`, `wave2`) : < 11 = wavefold (plus on tourne à gauche, plus ça plie) · **11 = triangle** · **12 = scie** · **≈ 13-13.5 = carré** (le manuel dit 1:00 p.15 et 1:30 p.10 : à calibrer) · → 17 = pulse jusqu'à ~2 %.
- SUB WAVE (`sub_wave`) : 7 = triangle → ≈ 10.5-11 = carré → 17 = pulse ~2 %.
- OSC 2 FREQ (`osc2_freq`) : ±7 demi-tons autour de l'OSC 1.
- MOD AMOUNT (`mod_amount`) : bipolaire, agit selon MOD DESTINATION.
- MOD DESTINATION (`mod_dest`) : `fm` (1→2 FM) · `fenv_osc2_freq` · `fenv_osc2_wave` · `fenv_sub_wave`.
- SYNC 1→2 (`sync`).

### Mixer (`mixer`)
`osc1`, `osc2`, `sub`, `noise`, gain unitaire propre à fond (ce mixer **ne sature pas**, contrairement au Minimoog).

### Filter (`filter`)
- FB / EXT IN (`fb_ext`) : sans câble, réinjecte la sortie du mixer → saturation / grain.
- CUTOFF (`cutoff`), EG AMOUNT (`eg_amount`, bipolaire), OSC 2 → CUTOFF (`osc2_cutoff`, FM de filtre), RESONANCE (`resonance`, auto-oscillation au max).
- RES BASS (`res_bass`) : garde le grave quand la résonance monte. OFF = ladder classique.
- KB TRACKING (`kb_tracking`) : suivi 1 V/oct (ON/OFF ; autres valeurs via [KB ASSIGN]).
- MODE (`mode`) : `lp4` (24 dB) · `lp2` (12 dB) · `bp` (4 pôles) · `hp` (2 pôles).

### Envelopes (`fenv`, `aenv`, `env`)
- `fenv` / `aenv` : `a`, `d`, `s`, `r`.
- `env` : `multi_trig`, `f_vel`, `f_loop`, `a_vel`, `a_loop`.
- Par défaut : pas de redéclenchement en legato (comportement Minimoog).

### Left-Hand Controller (`perf`)
- GLIDE (`glide`) ; type de glide dans CONFIG 1.3.
- LFO 2 RATE (`lfo2_rate`) : triangle, 0,05-12 Hz, profondeur = molette.
- LFO 2 DESTINATION (`lfo2_dest`) : liste parmi `pitch`, `cutoff`, `amp`.
- Molette (`mod_wheel`, en %), KB OCTAVE (`kb_octave`, −2 à +2), PITCH bend ±7 par défaut.

## Séquenceur (YAML `sequence`)

Manuel p. 22-24 : une séquence de **64 pas** max par patch. *DIRECTION* sur SEQ, *RECORD*, jouer les notes (*HOLD* = liaison, *ADV* = silence), *RECORD* pour valider (la longueur = nombre de pas saisis), *PLAY*.
Une touche tenue pendant la lecture **transpose** la séquence par rapport au **C5** (2e Do du clavier, sans KB OCTAVE) : saisir le motif autour du C5.
SETTINGS : 3 *GATE LENGTH* (PGM 1 = 6,25 % … 8 = 50 % … 16 = 100 %), 7 *LENGTH*, 8 *SWING*, 9 *CLOCK DIV* ; *NOTE PROB* / *GATE PROB* (4, 6) pour l'aléatoire ; *PARAM RECORD* (SEQ clignotant) mémorise un réglage de potard par pas.
Utiliser `sequence` dès qu'un son est une séquence ou un ostinato relevé (tablature, partition) : la grille remplace l'encadré « Jeu » en page 1. YAML en notation anglaise (Bb4), affichage en solfège (Si♭4), octaves numérotées comme dans le manuel (C5 = Do5 = 2e Do du clavier).

## Modulations assignables (YAML `modulations`)

Une routing par source et par patch, vers n'importe quel contrôle :
LFO 1 (maintenir KB RESET), KEYBOARD (maintenir KB TRACKING), FILTER ENV (maintenir F ENV LOOP), AMP ENV (maintenir A ENV LOOP),
et via SETTINGS : KB S+H (PGM 11), VELOCITY (12), AFTERTOUCH (13), EXPRESSION (14).
Profondeur affichée sur PGM 1-16 (bipolaire : 8-9 = 0 %).

```yaml
modulations:
  - {source: aftertouch, dest: cutoff, depth: "+40 %"}
```

## Réglages SETTINGS / CONFIG utiles au son (YAML `settings`)

| Réglage | Accès | Options |
|---|---|---|
| LFO 1 FADE | SETTINGS → PGM 10 | < midi : fade-in jusqu'à 10 s ; > midi : fade-out |
| Pitch bend | CONFIG 1.1 / 1.2 | ±1 à 24 demi-tons |
| Glide Config | CONFIG 1.3 | PGM 1 legato glide, PGM 2 gated glide ; PGM 14 expo · 15 lin. vitesse const. · 16 lin. temps const. |
| LFO Range | CONFIG 1.4 | 0,05-12 Hz · 0,5-120 Hz · 5 Hz-1,2 kHz |
| Envelope Modes | CONFIG 1.5 | reset F ENV / A ENV, ampli cumulative |
| Note Priority | CONFIG 2.1 (global) | dernière · grave · aiguë |
| ARP PATTERN / OCTAVE / GATE / SWING / CLOCK DIV | SETTINGS 1, 2, 3, 8, 9 | voir manuel p.25-28 |

```yaml
settings:
  - {name: "LFO 1 Fade (SETTINGS 10)", value: "fade-in ≈ 1 s (TEMPO ≈ 11:00)"}
```

## Patch init

Maintenir **PANEL** 1 s → patch initialisé (une scie OSC 1). Les valeurs exactes de l'init usine ne sont pas toutes documentées :
la fiche affiche **tous** les contrôles (gris = valeur neutre Synther, définie dans `template/messenger.typ`).

## Inconnues à calibrer

Positions → Hz (CUTOFF, LFO RATE), → secondes (A/D/R), → cents (OSC 2 FREQ près de midi), → temps de glide. Voir `knowledge/calibration/`.
