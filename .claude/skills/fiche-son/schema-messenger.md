# Schéma YAML : fiche Moog Messenger

Valeurs neutres et validation : `template/messenger.typ` (`defaults`). Toute clé inconnue fait échouer la compilation.

```yaml
synthe: messenger                 # obligatoire
titre: Nom Du Son                 # affiché en capitales
categorie: basse                  # basse | lead | pad | pluck | keys | cuivre | percussion | fx …
tags: [house, 80s]                # chaînes courtes (mettre "303" entre guillemets si numérique)
confiance: 2                      # 1 approximation · 2 déduit · 3 documenté
reference:
  artiste: Phuture
  morceau: Acid Tracks
  annee: 1987
  passage: ligne de basse, tout le morceau
  synthe_origine: Roland TB-303
resume: >-
  2-3 phrases : caractère du son et ce qui le fait.

params:                           # uniquement ce qui diffère du neutre (ou ce qu'on veut faire ressortir)
  lfo1:   {rate: 12, depth: 12, wave: tri|saw|ramp|sqr, dest: cutoff|osc2_freq|osc1_wave|sub_wave, sync: false, kb_reset: false}
  osc:    {oct1: 4|8|16|32, oct2: 8, tune: 12, sub_wave: 7, wave1: 12, wave2: 12,
           osc2_freq: 12, mod_amount: 12, mod_dest: fm|fenv_osc2_freq|fenv_osc2_wave|fenv_sub_wave, sync: false}
  mixer:  {osc1: 17, osc2: 7, sub: 7, noise: 7}
  filter: {fb_ext: 7, cutoff: 17, eg_amount: 12, osc2_cutoff: 7, resonance: 7,
           res_bass: false, kb_tracking: false, mode: lp4|lp2|bp|hp}
  fenv:   {a: 7, d: 12, s: 17, r: 10}
  aenv:   {a: 7, d: 12, s: 17, r: 10}
  env:    {multi_trig: false, f_vel: false, f_loop: false, a_vel: false, a_loop: false}
  perf:   {glide: 7, lfo2_rate: 12, lfo2_dest: [pitch, cutoff, amp], mod_wheel: 0, kb_octave: 0}
  # (les valeurs ci-dessus sont les neutres ; mod_wheel en %, kb_octave de -2 à 2)

modulations:                      # optionnel, assignations Quick Assign
  - {source: aftertouch, dest: cutoff, depth: "+40 %"}
settings:                         # optionnel, SETTINGS / CONFIG utiles au son
  - {nom: "Glide Config (CONFIG 1.3)", valeur: "PGM 14 *Exponential*"}

etapes: [ "...", ... ]            # 5-7 étapes
oreille: [ "...", ... ]           # 3-4 ajustements symptôme → geste
jeu: [ "...", ... ]               # 2-3 conseils de jeu
analyse:                          # page 2 « Anatomie du son » : 4 encadrés, 3-5 lignes chacun
  - {titre: "Les oscillateurs : ...", texte: "pourquoi ces formes d'onde, octaves, désaccord"}
  - {titre: "Le filtre : ...", texte: "..."}
  - {titre: "Les enveloppes : ...", texte: "lecture des courbes ADSR dessinées au-dessus"}
  - {titre: "Le mouvement / L'espace / Le jeu : ...", texte: "glide, LFO, arpégiateur, effets"}
tracabilite: [ "Documenté [1] : ...", "Reconstitué : ..." ]   # page 2, renvois aux sources
sources:                          # page 2, numérotées [1], [2]… dans l'ordre
  - titre: "Titre exact de l'article ou de la vidéo"
    site: Reverb News               # média, forum, manuel…
    date: avril 2024                # optionnel
    url: https://reverb.com/news/...   # URL complète (cliquable dans le PDF) ; omettre si inconnue, ne jamais l'inventer
    note: ce qu'on y a pris (OB-Xa, patch A1)   # optionnel, en italique

# Syntaxe dans tous les textes (resume, analyse, tracabilite, etapes…) :
#   [2] ou [1][3]           → renvoi cliquable en exposant vers la source
#   ^[texte]                → note de bas de page (a, b, c…), peut contenir [n]
#   [texte](https://…)      → lien intégré au texte
```

Repères WAVESHAPE : < 11 fold · 11 triangle · 12 scie · 13-13.5 carré · > 13.75 pulse.
SUB WAVE : 7 triangle · 10.5-11 carré · > 11.6 pulse.
