# Schéma YAML : fiche Korg minilogue XD

Valeurs neutres et validation : `template/minilogue-xd.typ` (`defaults`). Toute clé inconnue fait échouer la compilation.
Valeurs = **valeurs écran** du manuel (détails : `knowledge/machines/minilogue-xd.md`).

```yaml
synthe: minilogue-xd              # obligatoire
titre: Nom Du Son
categorie: cuivre
tags: [poly, "80s"]
confiance: 2
reference: {artiste: ..., morceau: ..., annee: 1984, passage: ..., synthe_origine: ...}
resume: >-
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
  - {nom: "Amp Velocity (bouton 8)", valeur: "0"}

etapes: [ ... ]                   # 5-7 étapes
oreille: [ ... ]                  # 3-4 ajustements symptôme → geste
jeu: [ ... ]                      # 2-3 conseils
sources: [ ... ]
```
