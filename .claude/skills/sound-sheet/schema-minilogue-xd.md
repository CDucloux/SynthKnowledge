# Schéma YAML : fiche Korg minilogue XD

Référence exhaustive des paramètres (clés, valeurs neutres, plages, options, types d'effets autorisés) : **`template/schema/minilogue-xd.yaml`**, source unique lue par le template et par la validation. `scripts/build.py check <yaml>` signale toute clé inconnue, valeur hors plage, option invalide, renvoi [n] sans source ou tiret interdit.
Valeurs = **valeurs écran** du manuel (détails : `knowledge/machines/minilogue-xd.md`).

```yaml
synth: minilogue-xd              # obligatoire
title: Nom Du Son
category: cuivre
tags: [poly, "80s"]
confidence: 2
reference: {artist: ..., song: ..., year: 1984, part: ..., original_synth: ..., original_synth_short: ...}   # original_synth_short optionnel (tableau du README)
summary: >-
  2-3 phrases.

params:                           # uniquement ce qui diffère du neutre (ou ce qu'on veut faire ressortir)
  voice:  {mode: poly|unison|chord|arp, depth: 0, depth_label: "", portamento: 0, octave: 0, tempo: 120}
  vco1:   {wave: sqr|tri|saw, octave: 16|8|4|2, pitch: 0, shape: 0}
  vco2:   {wave: saw, octave: 8, pitch: 0, shape: 0, sync: false, ring: false, cross_mod: 0}
  multi:  {engine: noise|vpm|usr, type: High, shape: 0}
  mixer:  {vco1: 1023, vco2: 0, multi: 0}
  filter: {cutoff: 1023, resonance: 0, drive: 0|50|100, keytrack: 0|50|100}
  amp_eg: {a: 0, d: 512, s: 1023, r: 0}
  eg:     {a: 0, d: 512, int: 0, target: pitch|pitch2|cutoff}
  lfo:    {wave: tri, mode: one_shot|normal|bpm, rate: 512, rate_label: "", int: 0, target: cutoff|shape|pitch}
  mod_fx: {on: false, type: Chorus, subtype: Stereo, time: 512, depth: 50}
  reverb: {on: false, type: Hall, time: 512, depth: 50}
  delay:  {on: false, type: Stereo, time: 512, depth: 50}
  # (les valeurs ci-dessus sont les neutres ; pitch en cents ±1200, eg.int en % ±100, lfo.int 0-511 (négatif = inversé), depth des effets en %)

settings:                         # optionnel : réglages PROGRAM EDIT (bouton : valeur)
  - {name: "Amp Velocity (bouton 8)", value: "0"}

sequence:                         # optionnel : séquenceur pas à pas (manuel p. 25-27, SEQ EDIT p. 37), remplace l'encadré « Jeu » en page 1
  tempo: 105                      # BPM (10-300), mettre la même valeur dans params.voice.tempo
  resolution: 1/16                # Step Resolution : 1/16, 1/8, 1/4, 1/2, 1/1
  gate: 50                        # Default Gate Time en % ; swing: 0 optionnel (-75 à +75 %)
  steps: >-                       # 16 pas max ; note (Bb4), accord (G3+Bb3+D4, 4 notes max), « . » silence (REST), « _ » liaison
    G3 Bb3 D4 G4 Bb4 D5 G3 Bb3 D4 G4 Bb4 D5 G3 Bb3 D4 D4
# Pas de `transpose` : le XD ne transpose pas la séquence au clavier. Notation standard des octaves (C4 = Do central).
# Avec une séquence, garder `playing` à 1-2 puces courtes et `tweaks` à 3 puces : la page 1 doit tenir.

steps: [ ... ]                   # 5-7 étapes
tweaks: [ ... ]                  # 3-4 ajustements symptôme → geste
playing: [ ... ]                      # 2-3 conseils
analysis:                          # page 2 « Anatomie du son » : 4 encadrés, 3-5 lignes chacun
  - {title: "Les oscillateurs : ...", text: "pourquoi ces formes d'onde, octaves, désaccord"}
  - {title: "Le filtre : ...", text: "..."}
  - {title: "Les enveloppes : ...", text: "lecture des courbes ADSR dessinées au-dessus"}
  - {title: "Le mouvement / L'espace / Le jeu : ...", text: "glide, LFO, arpégiateur, effets"}
traceability: [ "Documenté [1] : ...", "Reconstitué : ..." ]   # page 2, renvois aux sources
sources:                          # page 2, numérotées [1], [2]… dans l'ordre
  - title: "Titre exact de l'article ou de la vidéo"
    site: Reverb News               # média, forum, manuel…
    date: avril 2024                # optionnel
    url: https://reverb.com/news/...   # URL complète (cliquable dans le PDF) ; omettre si inconnue, ne jamais l'inventer
    note: ce qu'on y a pris (OB-Xa, patch A1)   # optionnel, en italique

# Syntaxe dans tous les textes (resume, analyse, tracabilite, etapes…) :
#   [2] ou [1][3]           → renvoi cliquable en exposant vers la source
#   ^[texte]                → note de bas de page (a, b, c…), peut contenir [n]
#   [texte](https://…)      → lien intégré au texte
```
