---
name: add-synth
description: Ajouter le support d'un nouveau synthé (Messenger et minilogue XD déjà faits) au système de fiches, fiche machine dans knowledge/, template Typst du schéma de façade, schéma YAML, fiche de démonstration. Utiliser quand l'utilisateur ajoute un manuel dans manuals/ ou demande « fais le template du minilogue ».
---

# Ajouter un synthé

Pré-requis : le **manuel PDF** dans `manuals/<machine>-user-manual.pdf`. Sans manuel, ne pas construire le template (risque de contrôles inventés) : le dire à l'utilisateur.

1. **Extraire les contrôles** : `pdftotext -layout manuals/<…>.pdf <scratchpad>/m.txt`, lire les sections panneau ; regarder les pages illustrées (Read avec `pages`) pour l'ordre physique des sections.
2. **Fiche machine** `knowledge/machines/<machine>.md`, sur le modèle de `messenger.md` : sections, contrôles, plages, clés YAML, menus d'édition utiles au son, inconnues à calibrer.
3. **Notation** : boutons à course continue sans affichage → heures (7-17) ; paramètres affichés à l'écran (cas du minilogue XD, 0-1023) → **valeur écran**. Ajouter si besoin un composant dans `template/lib/controls.typ` (ex. `value-knob(name, value, max: 1023)` qui dessine l'index proportionnellement et affiche la valeur) plutôt que de dupliquer ; il est réexporté par `style.typ`.
4. **Template** `template/<machine>.typ` sur le modèle de `messenger.typ` (heures d'horloge) ou `minilogue-xd.typ` (valeurs écran, composant `value-knob`) :
   - **schéma** `template/schema/<machine>.yaml` (modèle : `schema/messenger.yaml`) : `options` des sélecteurs, `params` avec pour chaque contrôle `default` (valeur neutre) et `type` / `min` / `max` / `options` / `choices`, `extra` (sections YAML propres à la machine, ex. `settings`). C'est la source unique : le template le charge (`schema-defaults`, `schema.options`), `scripts/build.py` valide les fiches avec,
   - dans le template : `check-params(params, defaults)`, `param-reader(params, defaults)`, `value-reader` et `field` (de `lib/params.typ`) plutôt que de réécrire ces aides ; helpers de façade nommés explicitement (`knob-at`, `selector-at`, `switch-at`…, jamais `K`, `S`, `g`),
   - `panel(params)` : un appel à `panel-frame(panel-band((sections…)))` (voir `messenger.typ`) : chaque section = `(title:, cols:, cells:)`, cellules lues ligne par ligne, fusions par `grid.cell(colspan/rowspan)` ; aucune largeur ni hauteur en dur, tailles dérivées du potard (`knob-size`, `zone`, `cell-width`). **Façade en une seule bande paysage**, fidèle au schéma du panneau du manuel (sections côte à côte dans l'ordre physique, titres centrés sans onglet, séparateurs verticaux fins, rangées alignées sur une « zone potard » commune). Dessiner les commandes comme sur la machine (potards, sélecteurs à flèches + LED, inverseurs à levier, boutons rectangulaires, écrans) avec les composants de `style.typ`, en en ajoutant si besoin.
   - `render-sheet(data)` = un appel à `sheet(machine, data, panel: …, aside: …, envs: (env-entry(…), …), sequence-spec: …)` de `lib/pages.typ` (bandeau, bas de page 1, page 2 paysage) ; pas de version portrait.
   - Nom affiché dans le schéma (`name: Korg minilogue XD`) : la liste des machines côté Python en découle (`machines()`), et la façade le passe à `sheet(schema.name, …)`. Enregistrer seulement la machine dans `template/sheet.typ` (dictionnaire `machines`, fonction `render-sheet`) : un test vérifie que ce dictionnaire et les schémas concordent.
   - Lancer `scripts/build.py check` : un schéma fautif (clé inconnue, liste d'options absente, valeur neutre hors plage…) est signalé ligne par ligne.
5. **Schéma YAML** `.claude/skills/sound-sheet/schema-<machine>.md`, et mettre à jour `sound-sheet/SKILL.md` §3 (choix de machine).
6. **Fiche de démo** (son bien documenté) + `scripts/build.py check` puis `scripts/build.py` + vérification visuelle (deux pages paysage, rien de coupé ni chevauché).
7. Mettre à jour `CLAUDE.md` (machines supportées) et `knowledge/README.md`. Commit.
