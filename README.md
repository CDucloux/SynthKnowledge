# SynthKnowledge

Fiches son visuelles pour reproduire des sons de synthé sur **Moog Messenger** et **Korg minilogue XD**.
Chaque fiche fait deux pages A4. Page 1 : schéma complet de la façade avec la position de chaque contrôle, étapes depuis le patch init,
ajustements à l'oreille, conseils de jeu. Page 2 : traçabilité (référence, indice de confiance, ce qui est documenté ou reconstitué, sources).

## Fiches disponibles

| Fiche | Machine | Confiance |
|---|---|---|
| [Chicago House Bass](sheets/messenger/chicago-house-bass.pdf) | Messenger | ●●● documenté (manuel Moog) |
| [Lucky Man Lead](sheets/messenger/lucky-man-lead.pdf) | Messenger | ●●○ déduit |
| [Acid Tracks Bass](sheets/messenger/acid-tracks-bass.pdf) | Messenger | ●●○ déduit |
| [Jump Brass](sheets/minilogue-xd/jump-brass.pdf) | minilogue XD | ●●○ déduit |

## Créer une fiche

Demander à Claude : « fais-moi la fiche du son de *<morceau>* de *<artiste>* » (skill `sound-sheet`).
À la main : écrire `sounds/<machine>/<slug>.yaml` (schémas dans `.claude/skills/sound-sheet/`) puis :

```bash
scripts/build.sh sounds/<machine>/<slug>.yaml
```

Police : Montserrat (SIL Open Font License, `fonts/OFL.txt`).
