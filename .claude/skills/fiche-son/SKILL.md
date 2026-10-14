---
name: fiche-son
description: Créer une fiche son SynthKnowledge (PDF Typst A4 une page) pour reproduire un son de synthé sur le Moog Messenger (ou le minilogue XD quand son template existera), à partir d'un titre + artiste, d'une description ou d'une référence. Utiliser dès que l'utilisateur demande « fais-moi la fiche de… », « comment faire le son de… », « reproduire le lead/la basse de… ».
---

# Créer une fiche son

## 0. Entrée attendue

Au minimum **titre + artiste**. Utile en plus : quel son dans le morceau (« lead de l'intro, 0:15 »), quelques mots de description, l'instrument cible souhaité.
Si l'utilisateur ne précise pas **quel son** du morceau et qu'il y en a plusieurs évidents, demander ; sinon prendre le plus emblématique et le dire.

## 1. Lire la base de connaissances

- `knowledge/retours.md` (leçons des essais précédents) — **toujours**.
- `knowledge/archetypes.md` → recette de départ de la famille.
- `knowledge/machines/messenger.md` → contrôles et clés YAML.
- Selon le cas : `knowledge/synthes-historiques.md`, `knowledge/synthese/*.md`.

## 2. Rechercher (WebSearch, mode standard ; plusieurs requêtes dans le même tour)

Requêtes types :
- `"<morceau>" <artiste> synth sound gear` · `"<morceau>" synth patch settings`
- `<artiste> interview synthesizer <album>` · `"<morceau>" how to make the sound tutorial`
- Sites utiles : gearspace, reddit r/synthesizers & r/synthrecipes, equipboard, syntorial (preset recipes), soundonsound, musicradar, muzines (archives), forum.moogmusic.com.

Retenir : **synthé d'origine**, forme d'onde, filtre, enveloppe, effets, glide, techniques de jeu. Noter chaque URL utile.
Ne jamais citer une source qu'on n'a pas réellement trouvée ; ne jamais présenter une hypothèse comme un fait documenté.

## 3. Choisir la machine

Règles dans `knowledge/synthes-historiques.md` (« Choisir la machine »). Aujourd'hui seul le template **Messenger** existe :
si le son exige de la polyphonie ou des effets, le dire, et proposer soit une version mono Messenger (approximation, confiance ≤ 2), soit d'attendre le template XD.

## 4. Fixer l'indice de confiance

| `confiance` | Sens | Critère |
|---|---|---|
| 3 — DOCUMENTÉ | réglages ou patch publiés par une source fiable (manuel, interview, patch sheet) | sources explicites sur le patch |
| 2 — DÉDUIT | synthé et nature du son connus, réglages reconstitués | sources sur le matériel / le caractère |
| 1 — APPROXIMATION | style, époque, genre seulement | rien de spécifique trouvé |

## 5. Écrire le YAML

Fichier `sons/<machine>/<slug>.yaml` (slug en kebab-case ASCII, ex. `acid-tracks-bass`). Schéma complet : `schema-messenger.md` (même dossier).
Règles :
- Ne mettre dans `params` **que les contrôles qui diffèrent de la valeur neutre** (ils s'affichent en noir, le reste en gris). Mais si un contrôle est important pour le son même à sa valeur neutre (ex. `res_bass: false` voulu), l'écrire quand même pour qu'il ressorte.
- Positions en heures (7-17, décimales 0.25 / 0.5).
- Textes en français, noms de contrôles en ANGLAIS et en gras via `*CONTROL*` (markup Typst).
- Dans les textes : pas de `#`, `$`, `@`, `<`, `_` nus (markup Typst) ; mettre entre guillemets YAML toute chaîne contenant `:`.
- `etapes` : 5-7 étapes, du patch init au son final, dans l'ordre du panneau. `oreille` : 3-4 ajustements « symptôme → geste ». `jeu` : 2-3 conseils.
- `sources` : texte court + domaine/chemin (pas d'URL avec `_` ou `#` non échappés).

## 6. Compiler et vérifier

```bash
scripts/build.sh sons/messenger/<slug>.yaml
```
- Le script échoue si la fiche dépasse **une page** → raccourcir les textes.
- Le template échoue sur une clé inconnue (faute de frappe) → corriger d'après le message.
- **Vérifier le rendu visuellement** : `pdftoppm -r 100 -png fiches/messenger/<slug>.pdf <scratchpad>/x` puis lire l'image. Contrôler : pas de chevauchement, valeurs lisibles, index des potards cohérents avec le texte.

## 7. Livrer

- Commit du YAML **et** du PDF (les PDF sont versionnés pour être consultables depuis le téléphone).
- Répondre à l'utilisateur : machine choisie, niveau de confiance et pourquoi, sources, compromis éventuels (effets absents, polyphonie), et l'inviter à faire un retour après essai (→ skill `ajuster-fiche`).
