# Calibration — position de bouton → valeur réelle

But : passer de « cutoff assez fermé » à « CUTOFF ≈ 10:00 » avec des chiffres mesurés sur **ces** machines.
Statut : **aucune mesure pour l'instant** (l'analyse audio est mise de côté).

## Protocole (Messenger)

1. Laisser chauffer 15 min. Patch init (PANEL 1 s), note **C3 tenue** (KB OCTAVE 0, OCTAVE 8'), enregistrement WAV direct, sans effet.
2. Ne faire varier **qu'un seul paramètre**, aux positions 7, 8.5, 10, 11, 12, 13, 14, 15.5, 17.
3. Nommer les fichiers `messenger_<param>_<position>.wav` (ex. `messenger_cutoff_10.5.wav`).

| Paramètre | Ce qu'on mesure | Réglage du reste |
|---|---|---|
| CUTOFF | fréquence de coupure (Hz) | scie, résonance 0, EG AMOUNT midi, KB TRACK off |
| RESONANCE | hauteur du pic, seuil d'auto-oscillation | cutoff 12 |
| LFO 1 / LFO 2 RATE | Hz | LFO → pitch, depth fort |
| A / D / R (ampli) | secondes | sustain 0 pour D, note courte pour R |
| GLIDE | secondes pour une octave | deux notes à l'octave en legato |
| OSC 2 FREQ près de midi | cents / battements | 2 scies, mixer égal |
| WAVESHAPE | forme réelle (où est le carré exact ?) | balayage lent |

## Format des résultats

Un CSV par machine et paramètre : `messenger_cutoff.csv` → `position,valeur,unite,note`.
Une fois rempli, les fiches peuvent citer les valeurs réelles (et la confiance des réglages monte).
