# SynthKnowledge

Fiches son visuelles pour reproduire des sons de synthé sur **Moog Messenger** et **Korg minilogue XD**.
Chaque fiche fait deux pages A4. Page 1 : schéma complet de la façade avec la position de chaque contrôle, étapes depuis le patch init,
ajustements à l'oreille, conseils de jeu. Page 2 : traçabilité (référence, indice de confiance, ce qui est documenté ou reconstitué, sources).

## Fiches disponibles

| Fiche | Machine | Confiance |
|---|---|---|
| [\[Herbie Hancock\] Chameleon (Bass)](sheets/messenger/%5BHerbie%20Hancock%5D%20Chameleon%20%28Bass%29.pdf) | Messenger | ●●○ déduit |
| [\[Nine Inch Nails\] Closer (Bass)](sheets/messenger/%5BNine%20Inch%20Nails%5D%20Closer%20%28Bass%29.pdf) | Messenger | ●●○ déduit |
| [\[MGMT\] Little Dark Age (Bass)](sheets/messenger/%5BMGMT%5D%20Little%20Dark%20Age%20%28Bass%29.pdf) | Messenger | ●●○ déduit |
| [\[The Prodigy\] Omen (Bass)](sheets/messenger/%5BThe%20Prodigy%5D%20Omen%20%28Bass%29.pdf) | Messenger | ●○○ approximation |
| [\[The Prodigy\] Omen (Lead)](sheets/messenger/%5BThe%20Prodigy%5D%20Omen%20%28Lead%29.pdf) | Messenger | ●●○ déduit |
| [\[Bronski Beat\] Smalltown Boy (Bass)](sheets/messenger/%5BBronski%20Beat%5D%20Smalltown%20Boy%20%28Bass%29.pdf) | Messenger | ●●○ déduit |
| [\[Michael Jackson\] Thriller (Bass)](sheets/messenger/%5BMichael%20Jackson%5D%20Thriller%20%28Bass%29.pdf) | Messenger | ●●○ déduit |
| [\[The Black Eyed Peas\] I Gotta Feeling (Intro)](sheets/minilogue-xd/%5BThe%20Black%20Eyed%20Peas%5D%20I%20Gotta%20Feeling%20%28Intro%29.pdf) | minilogue XD | ●○○ approximation |
| [\[Van Halen\] Jump (Brass)](sheets/minilogue-xd/%5BVan%20Halen%5D%20Jump%20%28Brass%29.pdf) | minilogue XD | ●●○ déduit |
| [\[MGMT\] Little Dark Age (Intro)](sheets/minilogue-xd/%5BMGMT%5D%20Little%20Dark%20Age%20%28Intro%29.pdf) | minilogue XD | ●●○ déduit |
| [\[Liquido\] Narcotic (Lead)](sheets/minilogue-xd/%5BLiquido%5D%20Narcotic%20%28Lead%29.pdf) | minilogue XD | ●●○ déduit |
| [\[Depeche Mode\] Precious (Lead)](sheets/minilogue-xd/%5BDepeche%20Mode%5D%20Precious%20%28Lead%29.pdf) | minilogue XD | ●○○ approximation |
| [\[Bronski Beat\] Smalltown Boy (Lead)](sheets/minilogue-xd/%5BBronski%20Beat%5D%20Smalltown%20Boy%20%28Lead%29.pdf) | minilogue XD | ●●○ déduit |

## Créer une fiche

Demander à Claude : « fais-moi la fiche du son de *<morceau>* de *<artiste>* » (skill `sound-sheet`).
À la main : écrire `sounds/<machine>/<slug>.yaml` (schémas dans `.claude/skills/sound-sheet/`) puis (le PDF sort sous `sheets/<machine>/[Artiste] Morceau (Rôle).pdf`) :

```bash
scripts/build.sh sounds/<machine>/<slug>.yaml
```

Police : Montserrat (SIL Open Font License, `fonts/OFL.txt`).
