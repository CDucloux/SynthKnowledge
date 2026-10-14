# Filtres : sculpter le timbre

## Types

| Mode | Effet | Quand |
|---|---|---|
| **Passe-bas 24 dB/oct (4 pôles)** | coupe net au-dessus du cutoff | Moog, basse ronde, pads chauds |
| **Passe-bas 12 dB/oct (2 pôles)** | coupe douce, garde de l'air et des aigus | Oberheim SEM, sons plus ouverts, cuivres |
| **Passe-haut** | retire le grave | nappes aériennes, cymbales, éclaircir une couche |
| **Passe-bande** | ne garde qu'une zone | sons nasaux, téléphoniques, « wah », voix |

## Résonance

- Accentue la zone du cutoff → caractère « liquide », « squelchy », « wah ».
- Haute résonance + enveloppe = **acid**. Haute résonance + LFO = **wobble/wah**.
- Au maximum : auto-oscillation (un sinus pur) → percussions accordées, sifflets, kicks.
- **Ladder Moog** : le grave diminue quand la résonance monte. Le Messenger peut compenser avec *RES BASS*.

## Cutoff : ordres de grandeur (passe-bas, note grave)

| Ressenti | Cutoff approx. |
|---|---|
| sourd, « dans une boîte » | 100-300 Hz |
| rond, chaud, basse sub | 300-800 Hz |
| présent, voix | 800 Hz-3 kHz |
| brillant | 3-8 kHz |
| ouvert, « crispy » | > 8 kHz |

> Correspondance position de bouton → Hz : **non documentée** ; à mesurer (voir `knowledge/calibration/`).

## Suivi de clavier (key tracking)

- OFF : les notes aiguës deviennent plus sombres → basse, son homogène en bas.
- 50 % : compromis naturel pour les leads.
- 100 % / ON : timbre constant sur tout le clavier ; indispensable si résonance auto-oscillante jouée mélodiquement.

## Familles de filtres (pour traduire un son)

| Filtre | Synthés | Caractère | Approche Messenger |
|---|---|---|---|
| Moog ladder 24 dB | Minimoog, Moog modulaire, Sub 37 | gras, rond, perte de grave en résonance | natif (4P LP) |
| Diode / 303 (~18 dB) | TB-303 | fin, « squelchy », résonance criarde | 4P LP, RES BASS OFF, résonance haute |
| Roland IR3109 24 dB | Juno, Jupiter, SH-101 | lisse, précis | 4P LP, résonance modérée |
| SEM 12 dB multimode | Oberheim | ouvert, « brassy » | 2P LP |
| Korg MS-20 (Sallen-Key) | MS-20, minilogue XD (2 pôles) | agressif, crie | 2P LP + résonance + FB/EXT IN |
| CEM / SSM | Prophet-5 | punchy, défini | 4P LP |
