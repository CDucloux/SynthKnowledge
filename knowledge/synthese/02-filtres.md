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
| Korg MS-20 (Sallen-Key) | MS-20 | agressif, crie | M : 2P LP + résonance + FB/EXT IN ; XD : DRIVE 100 % + résonance |
| CEM / SSM | Prophet-5 | punchy, défini | 4P LP |

## Approfondir (Synth Secrets, index `knowledge/sources/synth-secrets.md`)

- **Le cutoff n'est pas l'endroit où le filtre « commence »** : le signal y est déjà atténué de 3 dB, ce qui s'entend [SS5].
- **6 dB/oct** = simple correcteur de tonalité (plus terne, timbre inchangé) : insuffisant pour la synthèse [SS5].
- Un **4 pôles** tend vers 24 dB/oct mais traverse des zones à 6, 12 et 18 dB/oct : deux « 24 dB » (Minimoog, ARP) ne sonnent pas pareil, deux « 12 dB » (MS-20, SEM) non plus [SS5].
- Un filtre **déphase** chaque harmonique : la forme d'onde est déformée en plus d'être atténuée [SS4].
- Le **filtre fait le caractère du synthé** : un oscillateur Moog dans un filtre Korg sonne Korg [SS6].
- Passe-bande = passe-bas + passe-haut en série ; réjecteur (notch) = les deux en parallèle [SS6].

### Usages de la résonance [SS6]

| Résonance | Usage |
|---|---|
| filtre **statique**, résonance moyenne | faire ressortir une zone, faire « passer » un son dans le mix |
| moyenne + **keytrack 100 %** | qualité « accentuée » identique sur tout le clavier |
| au bord de l'auto-oscillation | le filtre « chante » avec certains harmoniques : distorsion typique, sons bizarres |
| max + keytrack | sinus jouable comme un oscillateur ; vibrato en modulant le cutoff |

### Formants (voix, caisses d'instrument) [SS23]

- Un formant est un **pic fixe** : il ne suit pas la note. En montant d'une octave, ce ne sont plus les mêmes harmoniques qui sont accentués, d'où le changement de caractère selon le registre (contrairement à un filtre qui suit le clavier).
- Trois formants suffisent pour reconnaître une voyelle ; le **2e formant** est celui qui bouge le plus quand on parle. Source riche (scie).

| Voyelle (voix d'homme) | F1 | F2 | F3 |
|---|---|---|---|
| « i » (*leap*) | 270 | 2300 | 3000 |
| « ou » (*loop*) | 300 | 870 | 2250 |
| « i » ouvert (*lip*) | 400 | 2000 | 2550 |
| « è » (*let*) | 530 | 1850 | 2500 |
| ≈ « eu » (*lug*) | 640 | 1200 | 2400 |
| « a » (*lap*) | 660 | 1700 | 2400 |

Avec un seul filtre (Messenger, XD), on n'obtient qu'**un** formant : *BP* résonant (Messenger) placé vers F1 ou F2 donne une couleur « voyelle » approximative ; balayer le cutoff entre deux valeurs = « wah » parlant. Le reste se fait à l'EQ externe.
