---
name: adjust-sheet
description: Corriger une fiche son existante à partir du retour d'essai de l'utilisateur (« trop brillant », « l'attaque est molle », « ça ne glisse pas assez »…) et consigner la leçon dans knowledge/retours.md. Utiliser dès que l'utilisateur dit avoir essayé une fiche ou demande de modifier un son déjà fiché.
---

# Ajuster une fiche après essai

1. Ouvrir `sounds/<machine>/<slug>.yaml` et relire la fiche.
2. Traduire chaque remarque en paramètre avec `knowledge/synthesis/06-vocabulaire-ecoute.md`.
   - Un seul changement net par remarque, en **pas d'½ heure à 1 heure** (pas de grands sauts).
   - Si la remarque est ambiguë (« ça sonne pas pareil »), poser **une** question ciblée : brillance ? attaque ? mouvement ? grave ?
   - Demande de **mise à jour des sources** (« actualise avec des recherches sur… ») ou fiche à confiance 1-2 qu'on retouche : refaire la recherche selon `knowledge/recherche-sources.md` (sources de qualité d'abord), corriger les réglages d'après ce qui est documenté, réécrire `tracabilite` et `sources`.
   - Retour sur une **séquence** (« ce n'est pas la bonne », « on dirait la basse ») : reprendre la transcription selon la skill sound-sheet (étape 2, « Séquence ») plutôt que retoucher des notes à l'oreille.
3. Modifier le YAML : `params`, et si utile `etapes` / `oreille`. Si l'utilisateur confirme que le résultat est proche de l'original, la confiance peut monter d'un cran (jamais à 3 sans source documentée).
4. Recompiler : `scripts/build.sh sounds/<machine>/<slug>.yaml`, puis vérifier le rendu (image).
5. Ajouter une entrée dans `knowledge/retours.md` (format du fichier). Si la leçon est générale (ex. « sur le Messenger, le carré est plutôt à 1:30 qu'à 1:00 »), **mettre aussi à jour** le fichier de connaissance concerné (`archetypes.md`, `machines/messenger.md`…).
6. Commit sur `main` (YAML + PDF + connaissances) puis `git push origin main` ; résumer à l'utilisateur ce qui a changé et pourquoi.
