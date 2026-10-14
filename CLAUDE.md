# SynthKnowledge

Fiches synthétiques et visuelles (PDF Typst, A4, **une page**) pour reproduire des sons de synthé sur les deux machines de l'utilisateur :
**Moog Messenger** (template prêt) et **Korg minilogue XD** (manuel présent, template à faire).
Style graphique inspiré du manuel Moog Messenger : noir & blanc, Montserrat, capitales grasses, vignettes encadrées.

## Structure

```
manuels/            manuels PDF officiels (source de vérité sur les contrôles)
knowledge/          base de connaissances synthèse, index : knowledge/README.md
sons/<machine>/     un YAML par son  → données de la fiche
template/           style.typ (composants) · messenger.typ (façade) · fiche.typ (point d'entrée)
fiches/<machine>/   PDF générés (versionnés)
fonts/              Montserrat (OFL), ne pas modifier
scripts/build.sh    compile les YAML en PDF (CLI typst, sinon paquet Python `typst`)
.claude/skills/     fiche-son · ajuster-fiche · ajouter-synthe
```

## Git

- **Toujours travailler directement sur `main`** : pas de branche de feature, pas de pull request. Commit puis `git push origin main`.
- Avant de commencer : `git pull origin main` (l'utilisateur ajoute aussi des fichiers, par exemple des manuels).

## Workflows → skills

- Nouveau son (« fais la fiche de… », titre + artiste) → skill **fiche-son**.
- Retour d'essai / correction d'une fiche → skill **ajuster-fiche**.
- Nouveau synthé ou manuel ajouté → skill **ajouter-synthe**.

## Règles du projet

- **Tirets quadratins (U+2014) INTERDITS**, partout : fiches, YAML, Markdown, code, commits, réponses. Utiliser « : », « , », des parenthèses ou une nouvelle phrase. Pas de demi-cadratin (U+2013) non plus. `scripts/build.sh` refuse un YAML qui en contient.
- **Langue** : textes en français ; noms de contrôles en ANGLAIS, tels qu'écrits sur le panneau, en gras (`*CUTOFF*`).
- **Notation Messenger** : positions en heures d'horloge, 7 = MIN, 12 = midi, 17 = MAX (décimales : 10.5 = 10:30).
- **Le schéma est l'élément central** de la fiche : tous les contrôles du panneau sont dessinés ; noir = réglé par la fiche, gris = valeur neutre.
- **Honnêteté** : chaque fiche porte un indice de confiance (3 documenté · 2 déduit · 1 approximation) et ses sources.
  Ne jamais inventer une source, un réglage « d'origine » ou une citation. Dire clairement quand un son dépend d'un effet ou de la polyphonie que la machine n'a pas.
- **Entrée par défaut = titre + artiste** + recherche web. Le WAV est un bonus (analyse audio : mise de côté pour l'instant).
- **Une page** : `scripts/build.sh` échoue au-delà ; raccourcir les textes plutôt que réduire le schéma.
- Après toute modification du template ou d'un YAML : recompiler et **vérifier visuellement** le PNG du rendu (`pdftoppm -r 100 -png`).
- Les leçons tirées des essais vont dans `knowledge/retours.md` et, si elles sont générales, dans le fichier de connaissance concerné.
- Committer les YAML **et** les PDF générés.

## Commandes

```bash
scripts/build.sh                                  # toutes les fiches
scripts/build.sh sons/messenger/<slug>.yaml       # une fiche
# équivalent CLI :
typst compile --root . --font-path fonts --input son=/sons/messenger/<slug>.yaml template/fiche.typ fiches/messenger/<slug>.pdf
```

Dépendances : `typst` (CLI ≥ 0.13, ou `pip install typst`), `poppler-utils` pour la vérification visuelle.

## État / à faire

- [x] Template Messenger + 3 fiches de démo.
- [ ] Template minilogue XD (skill ajouter-synthe) : le manuel est dans `manuels/minilogue-xd-user-manual.pdf`. `knowledge/machines/minilogue-xd.md` est provisoire et non vérifié.
- [ ] Calibration position → valeur (`knowledge/calibration/`).
- [ ] Analyse audio de WAV (reportée à la demande de l'utilisateur).
