---
name: add-synth
description: Ajouter le support d'un nouveau synthé (Messenger et minilogue XD déjà faits) au système de fiches, fiche machine dans knowledge/, template Typst du schéma de façade, schéma YAML, fiche de démonstration. Utiliser quand l'utilisateur ajoute un manuel dans manuals/ ou demande « fais le template du minilogue ».
---

# Ajouter un synthé

Pré-requis : le **manuel PDF** dans `manuals/<machine>-user-manual.pdf`. Sans manuel, ne pas construire le template (risque de contrôles inventés) : le dire à l'utilisateur.

1. **Extraire les contrôles** : `pdftotext -layout manuals/<…>.pdf <scratchpad>/m.txt`, lire les sections panneau ; regarder les pages illustrées (Read avec `pages`) pour l'ordre physique des sections.
2. **Fiche machine** `knowledge/machines/<machine>.md`, sur le modèle de `messenger.md` : sections, contrôles, plages, clés YAML, menus d'édition utiles au son, inconnues à calibrer.
3. **Notation** : boutons à course continue sans affichage → heures (7-17) ; paramètres affichés à l'écran (cas du minilogue XD, 0-1023) → **valeur écran**. Ajouter si besoin un composant dans `template/style.typ` (ex. `knob-value(name, v, max: 1023)` qui dessine l'index proportionnellement et affiche la valeur) plutôt que de dupliquer.
4. **Template** `template/<machine>.typ` sur le modèle de `messenger.typ` (heures d'horloge) ou `minilogue-xd.typ` (valeurs écran, composant `knob-num`) :
   - **schéma** `template/schema/<machine>.yaml` (modèle : `schema/messenger.yaml`) : `options` des sélecteurs, `params` avec pour chaque contrôle `default` (valeur neutre) et `type` / `min` / `max` / `options` / `choices`, `extra` (sections YAML propres à la machine, ex. `settings`). C'est la source unique : le template le charge (`schema-defaults`, `schema.options`), `scripts/build.py` valide les fiches avec,
   - dans le template : `check-params(params, defaults)` et `param-reader(params, defaults)` (de `style.typ`) plutôt que de réécrire ces aides,
   - `panel(params)` : **façade en une seule bande paysage**, fidèle au schéma du panneau du manuel (sections côte à côte dans l'ordre physique, titres centrés sans onglet, séparateurs verticaux fins, rangées alignées sur une « zone potard » commune). Dessiner les commandes comme sur la machine (potards, sélecteurs à flèches + LED, inverseurs à levier, boutons rectangulaires, écrans) avec les composants de `style.typ`, en en ajoutant si besoin.
   - `fiche(data)` = un appel à `sheet(machine, data, panel: …, aside: …, envs: (env-entry(…), …))` de `style.typ` (bandeau, bas de page 1, page 2 paysage) ; pas de version portrait.
   - Enregistrer la machine dans `template/sheet.typ` (dictionnaire `machines`) **et** dans `scripts/build.py` (`MACHINES`, nom affiché dans le README).
5. **Schéma YAML** `.claude/skills/sound-sheet/schema-<machine>.md`, et mettre à jour `sound-sheet/SKILL.md` §3 (choix de machine).
6. **Fiche de démo** (son bien documenté) + `scripts/build.sh --check` puis `scripts/build.sh` + vérification visuelle (deux pages paysage, rien de coupé ni chevauché).
7. Mettre à jour `CLAUDE.md` (machines supportées) et `knowledge/README.md`. Commit.
