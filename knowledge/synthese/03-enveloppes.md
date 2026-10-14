# Enveloppes — l'articulation dans le temps

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
| Lead | 0-court / – / max / court-moyen | 0 / moyen / moyen, amount modéré |
| Cuivre | court (50-150 ms) / moyen / haut / court | attack un peu plus lente que l'ampli, amount + |
| Cordes / nappe | lent / – / max / long | lent / long / moyen |
| Pluck / harpe / marimba | 0 / court-moyen / 0 / moyen (= decay) | 0 / court / 0, amount ++ |
| Cloche | 0 / long / 0 / long | — (timbre via FM) |
| Kick / tom | 0 / court / 0 / court | + enveloppe de hauteur rapide |

## Règles utiles

- **L'enveloppe de filtre fait le timbre, l'enveloppe d'ampli fait le volume**. Un « pluck » est d'abord un decay de filtre court.
- Mettre le **release égal au decay** quand le sustain est à 0 (sons percussifs) → comportement naturel.
- **Legato / retrigger** : un mono façon Minimoog (Messenger par défaut) ne relance pas les enveloppes en legato → phrasé lié. *MULTI-TRIG* = attaque à chaque note.
- **Vélocité → enveloppe filtre** (*F ENV VEL*) : expressivité, émule l'« accent » de la 303.
- **Enveloppe en boucle** (*F ENV LOOP* / *A ENV LOOP*) = LFO à forme ADSR, pratique pour les pulsations rythmiques.
