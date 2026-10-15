---
name: sound-sheet
description: Créer une fiche son SynthKnowledge (PDF Typst A4 : page 1 réglages, page 2 anatomie du son) pour reproduire un son de synthé sur le Moog Messenger ou le Korg minilogue XD, à partir d'un titre + artiste, d'une description ou d'une référence. Utiliser dès que l'utilisateur demande « fais-moi la fiche de… », « comment faire le son de… », « reproduire le lead/la basse de… ».
---

# Créer une fiche son

## 0. Entrée attendue

Au minimum **titre + artiste**. Utile en plus : quel son dans le morceau (« lead de l'intro, 0:15 »), quelques mots de description, l'instrument cible souhaité.
Si l'utilisateur ne précise pas **quel son** du morceau et qu'il y en a plusieurs évidents, demander ; sinon prendre le plus emblématique et le dire.

## 1. Lire la base de connaissances

- `knowledge/retours.md` (leçons des essais précédents), **toujours**.
- `knowledge/archetypes.md` → recette de départ de la famille.
- `knowledge/machines/messenger.md` ou `knowledge/machines/minilogue-xd.md` → contrôles et clés YAML.
- Selon le cas : `knowledge/synthes-historiques.md`, `knowledge/synthesis/*.md`.

## 2. Rechercher (WebSearch, mode standard ; plusieurs requêtes dans le même tour)

Requêtes types :
- `"<morceau>" <artiste> synth sound gear` · `"<morceau>" synth patch settings`
- `<artiste> interview synthesizer <album>` · `"<morceau>" how to make the sound tutorial`
- Sites utiles : gearspace, reddit r/synthesizers & r/synthrecipes, equipboard, syntorial (preset recipes), soundonsound, musicradar, muzines (archives), forum.moogmusic.com.

Retenir : **synthé d'origine**, forme d'onde, filtre, enveloppe, effets, glide, techniques de jeu. Noter chaque URL utile.
Ne jamais citer une source qu'on n'a pas réellement trouvée ; ne jamais présenter une hypothèse comme un fait documenté.

## 3. Choisir la machine

Règles dans `knowledge/synthes-historiques.md` (« Choisir la machine ») :
- accords, nappes, son qui dépend d'un chorus, d'un delay ou d'une reverb, FM type DX → **minilogue XD** (`synthe: minilogue-xd`) ;
- basse, lead mono, acid, glide, gros son Moog → **Messenger** (`synthe: messenger`).
Dire à l'utilisateur pourquoi cette machine, et les compromis.

## 4. Fixer l'indice de confiance

| `confiance` | Sens | Critère |
|---|---|---|
| 3 : DOCUMENTÉ | réglages ou patch publiés par une source fiable (manuel, interview, patch sheet) | sources explicites sur le patch |
| 2 : DÉDUIT | synthé et nature du son connus, réglages reconstitués | sources sur le matériel / le caractère |
| 1 : APPROXIMATION | style, époque, genre seulement | rien de spécifique trouvé |

## 5. Écrire le YAML

Fichier `sounds/<machine>/<slug>.yaml` (slug en kebab-case ASCII, ex. `closer-bass`) ; le PDF est nommé automatiquement `[Artiste] Morceau (Rôle).pdf`. Schéma complet : `schema-messenger.md` ou `schema-minilogue-xd.md` (même dossier).
Règles :
- Ne mettre dans `params` **que les contrôles qui diffèrent de la valeur neutre** (ils s'affichent en noir, le reste en gris). Mais si un contrôle est important pour le son même à sa valeur neutre (ex. `res_bass: false` voulu), l'écrire quand même pour qu'il ressorte.
- Messenger : positions en heures (7-17, décimales 0.25 / 0.5). minilogue XD : valeurs écran du manuel (0-1023, cents, %).
- Textes en français, noms de contrôles en ANGLAIS et en gras via `*CONTROL*` (markup Typst).
- Dans les textes : pas de `#`, `$`, `@`, `<`, `_` nus (markup Typst) ; mettre entre guillemets YAML toute chaîne contenant `:`.
- `etapes` : 5-7 étapes, du patch init au son final, dans l'ordre du panneau. `oreille` : 3-4 ajustements « symptôme → geste ». `jeu` : 2-3 conseils.
- `analyse` (page 2, « Anatomie du son ») : 4 encadrés `{titre, texte}` dans l'ordre oscillateurs, filtre, enveloppes, puis mouvement / espace / jeu. Expliquer **pourquoi** chaque réglage produit le son (harmoniques de l'onde, pente du filtre, forme des enveloppes, rôle des effets), 3-5 lignes chacun, titre accrocheur (« Le filtre : la résonance qui chante »). Les courbes ADSR sont dessinées automatiquement d'après `params`.
- `tracabilite` : 2-4 puces « Documenté [n] : … », « Hypothèse [n] : … », « Reconstitué : … ». Les [n] renvoient à l'ordre de `sources`.
- `sources` : entrées structurées `{titre, site, date, url, note}` (voir schéma). `url` = URL complète et vérifiée (cliquable, affichée abrégée) ; si on ne la retrouve pas, l'omettre et le dire dans `note`. Numérotées [1], [2]… en page 2.
- Renvois et notes dans les textes : `[n]` → exposant cliquable vers la source n ; `^[...]` → note de bas de page (définir un terme technique, préciser une nuance) ; `[texte](https://…)` → lien intégré. Utiliser les renvois dans `analyse` dès qu'une affirmation vient d'une source.

## 6. Compiler et vérifier

```bash
scripts/build.sh sounds/<machine>/<slug>.yaml
```
- Le script exige **2 pages** (fiche + anatomie du son) : s'il en trouve 3, la page 1 déborde → raccourcir les textes.
- Le template échoue sur une clé inconnue (faute de frappe) → corriger d'après le message.
- **Vérifier le rendu visuellement** : `pdftoppm -r 100 -png sheets/<machine>/<slug>.pdf <scratchpad>/x` puis lire l'image. Contrôler : pas de chevauchement, valeurs lisibles, index des potards cohérents avec le texte.

## 7. Livrer

- Commit sur `main` puis `git push origin main` (pas de branche, pas de PR). Commit du YAML, du PDF **et du README.md** (son tableau est régénéré par `build.sh`) (les PDF sont versionnés pour être consultables depuis le téléphone).
- Répondre à l'utilisateur : machine choisie, niveau de confiance et pourquoi, sources, compromis éventuels (effets absents, polyphonie), et l'inviter à faire un retour après essai (→ skill `adjust-sheet`). Pas de tiret quadratin dans les textes.
