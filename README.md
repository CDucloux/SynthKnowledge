# SynthKnowledge

Fiches son visuelles pour reproduire des sons de synthé sur **Moog Messenger** (et bientôt **Korg minilogue XD**).
Chaque fiche tient sur une page A4 : schéma complet de la façade avec la position de chaque contrôle, étapes depuis le patch init,
ajustements à l'oreille, conseils de jeu, sources et indice de confiance.

## Fiches disponibles

| Fiche | Machine | Confiance |
|---|---|---|
| [Chicago House Bass](fiches/messenger/chicago-house-bass.pdf) | Messenger | ●●● documenté (manuel Moog) |
| [Lucky Man Lead](fiches/messenger/lucky-man-lead.pdf) | Messenger | ●●○ déduit |
| [Acid Tracks Bass](fiches/messenger/acid-tracks-bass.pdf) | Messenger | ●●○ déduit |

## Créer une fiche

Demander à Claude : « fais-moi la fiche du son de *<morceau>* de *<artiste>* » (skill `fiche-son`).
À la main : écrire `sons/messenger/<slug>.yaml` (voir `.claude/skills/fiche-son/schema-messenger.md`) puis :

```bash
scripts/build.sh sons/messenger/<slug>.yaml
```

Police : Montserrat (SIL Open Font License, `fonts/OFL.txt`).
