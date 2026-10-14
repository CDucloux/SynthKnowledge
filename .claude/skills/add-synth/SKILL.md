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
   - `defaults` (valeurs neutres) + `_check` (clés inconnues = erreur),
   - `panel(params)` dans l'ordre physique de la façade, une `section` par bloc du panneau,
   - sections spécifiques (pour le XD : EFFECTS, VOICE MODE, MULTI ENGINE, menu PROGRAM EDIT),
   - `fiche(data)` réutilisant `header`, `textbox`, `footer-line`.
   - Enregistrer la machine dans `template/sheet.typ` (dictionnaire `machines`).
5. **Schéma YAML** `.claude/skills/sound-sheet/schema-<machine>.md`, et mettre à jour `sound-sheet/SKILL.md` §3 (choix de machine).
6. **Fiche de démo** (son bien documenté) + `scripts/build.sh` + vérification visuelle (une page, rien de coupé).
7. Mettre à jour `CLAUDE.md` (machines supportées) et `knowledge/README.md`. Commit.
