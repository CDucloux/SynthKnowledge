# Korg minilogue XD : référence pour les fiches

Source : `manuals/minilogue-xd-user-manual.pdf` (p. 5 façade, p. 15-24 paramètres, p. 32-37 PROGRAM EDIT, p. 53-54 effets).
Polyphonique **4 voix**, 2 VCO analogiques + **MULTI ENGINE** numérique par voix, filtre passe-bas analogique, **effets** numériques (MOD, REVERB, DELAY).
Le schéma de la fiche (`template/minilogue-xd.typ`) reprend cette liste ; les **clés YAML** sont entre parenthèses.

## Notation

**Valeurs écran** du manuel (pas d'heures d'horloge) : la plupart des potards vont de **0 à 1023**.
Le dessin place l'index proportionnellement à la valeur.

## Master / Voice Mode (`voice`)

- VOICE MODE TYPE (`mode`) : `poly` · `unison` · `chord` · `arp` (ARP/LATCH).
- VOICE MODE DEPTH (`depth`, 0-1023), effet selon le mode :
  - POLY : 0 = POLY, au-delà = DUO (2 voix empilées, plus de detune en tournant).
  - UNISON : detune 0 à 50 cents (la fiche calcule l'affichage : 1023 = 50 C).
  - CHORD : Mono, 5th, sus2, m, Maj, sus4, m7, 7, 7sus4, Maj7, aug, dim, m7♭5, mMaj7, Maj7♭5.
  - ARP : MANUAL 1-2, RISE 1-2, FALL 1-2, RISE FALL 1-2, POLY 1-2, RANDOM 1-3.
  - Pour CHORD et ARP, écrire l'affichage dans `depth_label` (ex. `depth_label: Maj7`).
- PORTAMENTO (`portamento`, 0-127). Mode Auto/On dans PROGRAM EDIT bouton 9.
- OCTAVE clavier (`octave`, -2 à +2). TEMPO (`tempo`, 56-240 BPM, sert aussi à l'arpégiateur et au LFO en BPM).

## VCO 1 / VCO 2 (`vco1`, `vco2`)

- WAVE (`wave`) : `sqr` · `tri` · `saw`.
- OCTAVE (`octave`) : `16` · `8` · `4` · `2`.
- PITCH (`pitch`) : -1200 à +1200 cents (pas d'1 cent).
- SHAPE (`shape`, 0-1023) : complexité de la forme, ou largeur d'impulsion pour le carré.
- VCO 2 seulement : SYNC (`sync`), RING (`ring`, ring mod par le VCO 1), CROSS MOD DEPTH (`cross_mod`, 0-1023, FM du VCO 1 vers la hauteur du VCO 2).

## Multi Engine (`multi`)

- NOISE / VPM / USR (`engine`) : `noise` · `vpm` · `usr`.
- TYPE (`type`, texte de l'écran) :
  - NOISE : High (passe-haut), Low (passe-bas), Peak (passe-bande), Decim (décimateur).
  - VPM : Sin1-4, Saw1-2, Squ1-2, Fat1-2, Air1-2, Decay1-2, Creep, Throat.
  - USR : oscillateurs utilisateur (logue SDK).
- SHAPE (`shape`, 0-1023) : NOISE = cutoff / bande / taux ; VPM = MOD DEPTH (SHIFT + SHAPE = RATIO OFFSET).
- Réglages VPM fins : PROGRAM EDIT bouton 10 (Feedback, Noise Depth, Shape Mod Int, Mod Attack, Mod Decay, Mod Key Track).
- Octave et routage (Pre/Post VCF) du MULTI : PROGRAM EDIT bouton 9.

## Mixer (`mixer`)

`vco1`, `vco2`, `multi` : 0-1023.

## Filter (`filter`)

- CUTOFF (`cutoff`), RESONANCE (`resonance`) : 0-1023. Le manuel ne précise pas la pente du passe-bas.
- DRIVE (`drive`) : `0` · `50` · `100` (%).
- KEYTRACK (`keytrack`) : `0` · `50` · `100` (%), centré sur C4.

## Amp EG (`amp_eg`) et EG (`eg`)

- `amp_eg` : `a`, `d`, `s`, `r` (0-1023).
- `eg` : `a`, `d` (0-1023), EG INT (`int`, -100 à +100 %), TARGET (`target`) : `pitch` (VCO 1, 2 et MULTI) · `pitch2` (VCO 2 seul) · `cutoff`.
- L'EG n'a **pas de sustain ni de release** : c'est une enveloppe AD.
- Vélocité : PROGRAM EDIT bouton 8 (EG Velocity sur l'EG INT de cutoff, Amp Velocity).

## LFO (`lfo`)

- WAVE (`wave`) : `sqr` · `tri` · `saw`.
- MODE (`mode`) : `one_shot` (s'arrête après une demi-période) · `normal` (0,05-28 Hz) · `bpm` (synchro tempo).
- RATE (`rate`, 0-1023). En mode BPM l'écran affiche une division (4 … 1/64) : la mettre dans `rate_label`.
- INT (`int`, 0-511 ; SHIFT + INT inverse la forme : écrire une valeur négative).
- TARGET (`target`) : `cutoff` · `shape` · `pitch`. Pour SHAPE et PITCH, l'oscillateur visé se règle dans PROGRAM EDIT bouton 7 (LFO Target OSC : All, VCO1+2, VCO2, Multi), avec LFO Key Sync et Voice Sync.

## Effects (`mod_fx`, `reverb`, `delay`)

Chaque effet a : `on`, `type` (texte), `time` (0-1023, unité selon l'effet), `depth` (0-100 %). `mod_fx` a en plus `subtype`.
Sur le panneau : sélecteur DEL/REV/MOD, puis OFF/ON/SELECT (SELECT fait défiler les types ; SHIFT + SELECT les sous-types), TIME, DEPTH.

| Effet | Types |
|---|---|
| MOD (`type` / `subtype`) | Chorus : Stereo, Light, Deep, Triphase, Harmonic, Mono, Feedback, Vibrato · Ensemble : Stereo, Light, Mono · Phaser : Stereo, Fast, Orange, Small, Small Reso, Black, Formant, Twinkle · Flanger : Stereo, Light, Mono, High Sweep, Mid Sweep, Pan Sweep, Mono Sweep, Triphase |
| REVERB (`type`) | Hall, Smooth, Arena, Plate, Room, Early Ref, Space, Riser, Submarine, Horror |
| DELAY (`type`) | Stereo, Mono, Ping Pong, Hipass, Tape, One Tap, Stereo BPM, Mono BPM, Ping BPM, Hipass BPM, Tape BPM, Doubling |

SHIFT + DEPTH (DEL et REV) : balance wet/dry.

## PROGRAM EDIT utiles au son (YAML `settings`)

| Bouton | Réglages |
|---|---|
| 4 JOYSTICK | X+ / X- Bend Range (Off, 1-12 notes) ; Y+ / Y- Assign (CUTOFF, LFO INT…) et Range (-100 à +100 %) |
| 6 PITCH SETTINGS | Microtuning, Scale Key, Program Tuning, Transpose |
| 7 LFO | LFO Target OSC, LFO Key Sync, LFO Voice Sync |
| 8 MODULATION | EG Velocity (0-127), Amp Velocity (0-127) |
| 9 OTHER SETTINGS | Multi Octave, Multi Routing (Pre/Post VCF), EG Legato, Portamento Mode (Auto/On), Portamento BPM, Program Level |
| 10 MULTI ENGINE | 6 paramètres VPM |
| 13 INITIALIZE | initialiser le programme courant |

```yaml
settings:
  - {nom: "LFO Key Sync (bouton 7)", valeur: "On"}
```

## Programme init

Programmes **201 à 500** = programmes initialisés, ou PROGRAM EDIT bouton 13. Les valeurs exactes de l'init ne sont pas listées dans le manuel :
la fiche affiche **tous** les contrôles (gris = valeur neutre SynthKnowledge, définie dans `template/minilogue-xd.typ`).

## Inconnues à calibrer

Valeur → Hz (CUTOFF, LFO RATE), → secondes (EG, AMP EG), unité de TIME selon l'effet. Voir `knowledge/calibration/`.
