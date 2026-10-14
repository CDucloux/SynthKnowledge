# Enveloppes : l'articulation dans le temps

## ADSR

- **Attack** : temps de montée. 0 = percussif ; 50-300 ms = cuivre qui « s'ouvre » ; > 500 ms = nappe, swell.
- **Decay** : temps de chute vers le sustain. Court = pluck ; long = cloche, piano.
- **Sustain** : niveau tenu (et non pas un temps !). 0 = son qui meurt même touche enfoncée.
- **Release** : temps après relâchement. Court = sec, staccato ; long = queue, nappe, ambiance.

## Profils types

| Son | Env. ampli (A / D / S / R) | Env. filtre (A / D / S / R, amount) |
|---|---|---|
| Basse pluck | 0 / moyen / max / court | 0 / court / bas / court, amount + |
| Basse acid | 0 / moyen / haut / court | 0 / très court / 0, amount ++ |
| Lead | 0-court / - / max / court-moyen | 0 / moyen / moyen, amount modéré |
| Cuivre | court (50-150 ms) / moyen / haut / court | attack un peu plus lente que l'ampli, amount + |
| Cordes / nappe | lent / - / max / long | lent / long / moyen |
| Pluck / harpe / marimba | 0 / court-moyen / 0 / moyen (= decay) | 0 / court / 0, amount ++ |
| Cloche | 0 / long / 0 / long | (timbre via FM) |
| Kick / tom | 0 / court / 0 / court | + enveloppe de hauteur rapide |

## Règles utiles

- **L'enveloppe de filtre fait le timbre, l'enveloppe d'ampli fait le volume**. Un « pluck » est d'abord un decay de filtre court.
- Mettre le **release égal au decay** quand le sustain est à 0 (sons percussifs) → comportement naturel.
- **Legato / retrigger** : un mono façon Minimoog (Messenger par défaut) ne relance pas les enveloppes en legato → phrasé lié. *MULTI-TRIG* = attaque à chaque note.
- **Vélocité → enveloppe filtre** (*F ENV VEL*) : expressivité, émule l'« accent » de la 303.
- **Enveloppe en boucle** (*F ENV LOOP* / *A ENV LOOP*) = LFO à forme ADSR, pratique pour les pulsations rythmiques.

## Approfondir (Synth Secrets, index `knowledge/sources/synth-secrets.md`)

- **Contours types** [SS3] : orgue = rectangle (A 0, S max, R 0) ; trombone = attaque modérée, pic puis sustain plus bas, release court ; coup de tonnerre = montée lente, pas de sustain, longue chute.
- **L'enveloppe réelle d'un paramètre est une somme** : générateur d'enveloppe + LFO + vélocité + valeur de base. Deux enveloppes AD additionnées donnent des formes à 4 étapes impossibles en ADSR [SS7].
- **Cas particuliers d'un ADSR** [SS8] : S max = trapèze (A, plateau, R) ; S 0 et R = D = enveloppe AD/AR.
- **Limite de l'ADSR** : le pic est toujours à la fin de l'attaque et le sustain commence à la fin du decay. Un cuivre « spit » (souffle bref, retombée plus terne, puis gonflement) est impossible [SS8] : on le simule à la main (aftertouch, molette) ou on s'en passe.
- **Minimoog** : enveloppes ADS + switch DECAY (release = decay, ou instantané) [SS8, SS26]. Pour un patch Minimoog avec DECAY off, mettre le release du Messenger au minimum.
- **Gain initial > 0** (VCA ouvert sans enveloppe) = drone qui ne s'arrête jamais [SS9, SS27].
- **Release 0 « claque »** sur un synthé rapide : un release un peu au-dessus du minimum évite le clic [SS27].

### Déclenchement et legato [SS7, SS18]

- **Multi-trigger** (ARP Odyssey) : chaque note relance les enveloppes, même en legato → solos rapides percutants.
- **Single trigger** (Minimoog, Messenger par défaut) : en legato, la nouvelle note arrive au niveau de sustain → phrasé lié, plus réaliste pour flûte et cuivres à pistons ; pour réarticuler, relâcher la note précédente.
- **Reset à zéro** à chaque note : coupe le son (« glump »), défaut de certains string ensembles.
- Destinations utiles d'une enveloppe : **hauteur** (beaucoup d'instruments sont un peu trop hauts au début de la note), **vitesse et profondeur du LFO** (vibrato qui évolue, comme sur CS-80) [SS7].
- Raccourcir les enveloppes dans l'aigu (piano, guitare) : sur le Messenger, routing `modulations` KEYBOARD → *F ENV DECAY* / *A ENV DECAY* (profondeur négative) [SS7].
