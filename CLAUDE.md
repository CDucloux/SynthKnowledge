# SynthKnowledge

Fiches synthétiques et visuelles (PDF Typst A4 : **page 1 = réglages**, **page 2 = anatomie du son** : analyse + sources) pour reproduire des sons de synthé sur les deux machines de l'utilisateur :
**Moog Messenger** et **Korg minilogue XD** (templates prêts).
Style graphique inspiré du manuel Moog Messenger : noir & blanc, Montserrat, capitales grasses, vignettes encadrées.

## Structure

```
manuals/            manuels PDF officiels (source de vérité sur les contrôles)
knowledge/          base de connaissances synthèse (synthesis/ : notions condensées), index : knowledge/README.md (sources/ : Synth Secrets, lus n°1-30)
sounds/<machine>/   un YAML par son  → données de la fiche
template/           style.typ (composants et mise en page communs) · messenger.typ / minilogue-xd.typ (façades) · sheet.typ (point d'entrée)
template/schema/    <machine>.yaml : paramètres de chaque synthé (valeurs neutres, plages, options), source unique template + validation
theory/             fiches de théorie imprimables (.typ, d'après Synth Secrets), gabarit template/theory.typ
sheets/<machine>/   PDF générés (versionnés), nommés « [Artiste] Morceau (Rôle).pdf » ; sheets/theory/ pour la théorie
fonts/              Montserrat (OFL), ne pas modifier
scripts/build.py    valide les YAML, compile en PDF (CLI typst, sinon paquet Python `typst`), vérifie les 2 pages, met à jour le README ; scripts/build.sh = raccourci
scripts/build-theory.sh  compile theory/*.typ (A4, pas de limite de pages)
.claude/skills/     sound-sheet · adjust-sheet · add-synth
```

## Noms

- **Dossiers en anglais** (sheets, sounds, manuals, theory, knowledge/synthesis…) ; contenus et textes en français.

## Git

- **Toujours travailler directement sur `main`** : pas de branche de feature, pas de pull request. Commit puis `git push origin main`.
- Avant de commencer : `git pull origin main` (l'utilisateur ajoute aussi des fichiers, par exemple des manuels).

## Workflows → skills

- Nouveau son (« fais la fiche de… », titre + artiste) → skill **sound-sheet**.
- Retour d'essai / correction d'une fiche → skill **adjust-sheet**.
- Nouveau synthé ou manuel ajouté → skill **add-synth**.

## Règles du projet

- **Tirets quadratins (U+2014) INTERDITS**, partout : fiches, YAML, Markdown, code, commits, réponses. Utiliser « : », « , », des parenthèses ou une nouvelle phrase. Pas de demi-cadratin (U+2013) non plus. `scripts/build.py` refuse un YAML qui en contient.
- **Langue** : textes en français ; noms de contrôles en ANGLAIS, tels qu'écrits sur le panneau, en gras (`*CUTOFF*`).
- **Notation Messenger** : positions en heures d'horloge, 7 = MIN, 12 = midi, 17 = MAX (décimales : 10.5 = 10:30).
- **Notation minilogue XD** : valeurs écran du manuel (0-1023 pour la plupart des potards, cents pour PITCH, % pour EG INT et DEPTH des effets).
- **Choix de la machine** : polyphonie ou effets → minilogue XD ; mono, basse, lead, acid, glide → Messenger.
- **Le schéma est l'élément central** de la fiche : tous les contrôles du panneau sont dessinés ; noir = réglé par la fiche, gris = valeur neutre.
- **Honnêteté** : chaque fiche porte un indice de confiance (3 documenté · 2 déduit · 1 approximation), ses sources et une liste `tracabilite` qui sépare ce qui vient des sources de ce qui est reconstitué.
  Ne jamais inventer une source, un réglage « d'origine » ou une citation. Dire clairement quand un son dépend d'un effet ou de la polyphonie que la machine n'a pas.
- **Entrée par défaut = titre + artiste** + recherche web. Le WAV est un bonus (analyse audio : mise de côté pour l'instant).
- **Deux pages exactement** : page 1 = schéma, étapes, ajustements, jeu ; page 2 = « Anatomie du son » : courbes des enveloppes (dessinées automatiquement d'après les params), `analyse` (4 encadrés : oscillateurs, filtre, enveloppes, mouvement/espace/jeu : pourquoi chaque réglage donne ce son) puis « D'où ça vient » (confiance, `tracabilite`, sources structurées avec liens cliquables). Dans tous les textes : `[n]` = renvoi cliquable en exposant, `^[...]` = note de bas de page, `[texte](url)` = lien intégré. Ne jamais réintituler la page « sources et traçabilité » (choix de l'utilisateur). `scripts/build.py` échoue si la page 1 déborde ; raccourcir les textes plutôt que réduire le schéma.
- Après toute modification du template ou d'un YAML : recompiler et **vérifier visuellement** le PNG du rendu (`pdftoppm -r 100 -png`).
- Les leçons tirées des essais vont dans `knowledge/retours.md` et, si elles sont générales, dans le fichier de connaissance concerné.
- Committer les YAML **et** les PDF générés.
- **Code** : les paramètres d'une machine ne se décrivent qu'à un seul endroit, `template/schema/<machine>.yaml` (jamais de `defaults` en dur dans un template). Ce qui est commun aux façades vit dans `style.typ` (`param-reader`, `check-params`, `sheet`, `env-entry`, `ov-title`…). **Mise en page sans cotes en dur** : une façade = un appel à `panel-band((sections…))` (une seule grille : colonnes à la largeur du contenu, rangées à la hauteur du plus grand contenu, espace restant réparti entre sections) ; les espacements viennent du dictionnaire `ui` de `style.typ`, les tailles d'une façade dérivent de la taille du potard (`ks` → `zone`, `kw`). Pas de hauteur de rangée ni de largeur de colonne fixée à la main. Si la façade ne tient pas en largeur, la compilation échoue en donnant la largeur de chaque section : réduire la section en cause plutôt que de forcer.
- **Test de non-régression visuelle (comparaison des pages au pixel avec une référence) : uniquement sur demande explicite de l'utilisateur** (coûteux en tokens). Par défaut, après un changement de template, vérifier à l'œil un ou deux rendus PNG.
- **README** : vitrine du projet. Le tableau des fiches (Groupe, Morceau, Année, Type de son, Synthé, Son d'origine, Confiance, lien PDF) et les compteurs sont **générés** par `scripts/build.py` à chaque compilation entre les marqueurs `<!-- fiches -->` / `<!-- compteurs -->` : ne pas les éditer à la main. Option `reference.synthe_court` dans un YAML pour raccourcir la colonne « Son d'origine ». Aperçus PNG dans `docs/` : `scripts/build.sh --previews`. Committer README.md avec chaque nouvelle fiche.

## Fiches de théorie (theory/)

- **Objectif : l'appropriation de la théorie** à partir du contenu réel des articles Synth Secrets (pas des résumés condensés utilisés pour les fiches son).
- **Pas de limite de pages** : une fiche suit le fil de l'article (ou des articles) qu'elle couvre, avec beaucoup de schémas et de pédagogie. Imprimable en A4.
- Éléments : idée clé, schémas calculés (formes d'onde, spectres, courbes), tableaux de synthèse, encadrés « Essaie sur ton Messenger » (positions réelles) et « À retenir », sources en pied.
- La fiche 01 (`theory/01-forme-onde-spectre.typ`) est un **prototype en une page** fait avant les notes complètes : à réécrire en version longue à partir de `synth-secrets-01.md`.
- Contenu **rédigé avec nos mots** d'après Synth Secrets (textes protégés : ne jamais recopier) ; schémas **recalculés** avec les primitives de `template/theory.typ`, jamais d'image copiée.
- Pas de paquet Typst externe (CeTZ non téléchargeable ici) : dessin natif (`curve`, `place`, `rect`).

## Notes d'étude Synth Secrets (knowledge/sources/)

- Un fichier par article : `knowledge/sources/synth-secrets-01.md`, `-02.md`, etc. (`synth-secrets.md` reste l'index).
- **Notes complètes** qui suivent le plan de l'article section par section : tous les concepts, raisonnements, chiffres, exemples de patchs, description de chaque schéma (pour pouvoir le redessiner), lien vers l'article original.
- **Rédigées avec nos mots**, au plus quelques citations courtes : le texte intégral est protégé, ne jamais le recopier.
- **Jamais de mémoire** : rédiger uniquement à partir de l'article lu (soundonsound.com, ou PDF déposé par l'utilisateur dans `original-sources/`, exclu de git).
- Ces notes sont la matière première des fiches de théorie, distinctes des connaissances condensées (`knowledge/synthesis/`) utilisées pour les fiches son.
- **Périmètre actuel : n°1 à 3 seulement.** Ne pas aller plus loin sans demande de l'utilisateur.

## Choix de design validés par l'utilisateur (ne pas changer sans demander)

- Esthétique du manuel Moog Messenger : noir & blanc, Montserrat, bandeau titre noir, encadrés à filet noir.
- **Icônes vectorielles** (dessinées en Typst, noir et blanc, JAMAIS d'emoji) devant les titres des encadrés d'explication : Pour l'obtenir (potard), Ajuster à l'oreille (ondes), Jeu (clavier), Les enveloppes (ADSR), analyse (choisie d'après le titre : oscillateurs = scie, filtre = passe-bas, enveloppes = ADSR, espace = ondes, mouvement = sinus, jeu = clavier, sinon i cerclé), D'où ça vient (loupe). Pas d'icône sur les sections de façade. Bandeau noir identique en hauteur sur les pages 1 et 2 (`title-bar`).
- **Containers à coins droits** (encadrés, bandeaux titre, cadre de façade, PROGRAM EDIT…) : pas d'arrondi. Seules les commandes dessinées (boutons, écrans, leviers, sélecteurs) gardent leur forme arrondie, fidèle au panneau.
- Schéma de façade complet = élément central ; potards avec index + arc de valeur, sélecteurs à LED, boutons ON/OFF.
- Section ENVELOPES aérée : pas de cadres pointillés, séparateurs verticaux fins.
- Puces des encadrés : double chevron « » » en gras, dans la ligne (aligné sur le texte), retrait suspendu.
- **Messenger = A4 paysage, toujours (choix de l'utilisateur, plus de version portrait)** : page 1 = façade en une seule bande fidèle à l'overview du manuel (p. 6) : LFO 1 | OSCILLATORS | MIXER | FILTER | ENVELOPES, titres centrés sans onglet, séparateurs verticaux, deux rangées de potards puis la rangée de boutons, sélecteurs dessinés comme sur le panneau (bouton arrondi ▲ ▼ + colonne de LED en petit texte) (boutons : rectangles à coins légèrement arrondis, mentions [F ENV ASSIGN]… au-dessus comme sur le panneau) ; page 2 aussi en paysage (enveloppes à gauche, analyse 2 × 2 à droite, « D'où ça vient » en deux colonnes). **minilogue XD = A4 paysage aussi**, même principe d'après le schéma du panneau (manuel p. 5) : VOICE (TEMPO, PORTAMENTO, OCTAVE, V.M. DEPTH, VOICE MODE) | VCO 1 · VCO 2 · MULTI ENGINE | MIXER | FILTER | AMP EG · EG · LFO | EFFECTS (MOD FX, REVERB, DELAY sur trois rangées), inverseurs à levier dessinés (fente + levier, ou levier + LED pour OCTAVE et VOICE MODE ; SYNC et RING en deux leviers ON/OFF côte à côte), écrans avec lunette et dalle noire (TYPE du MULTI ENGINE, type de chaque effet avec témoin ON/OFF), cadre PROGRAM EDIT en bas à gauche. **Plus aucune version portrait** (ni Messenger ni XD) : le template ne sait faire que du paysage.
- Page 2 intitulée « Anatomie du son » : analyse pédagogique du son d'abord, sources ensuite ; jamais de sources en page 1.

## Commandes

```bash
scripts/build.sh                                  # toutes les fiches
scripts/build.sh sounds/messenger/<slug>.yaml       # une fiche
scripts/build.sh --check [yaml…]                  # valider seulement (schéma template/schema/<machine>.yaml)
scripts/build.sh --previews                       # + aperçus PNG du README (docs/)
# équivalent CLI :
typst compile --root . --font-path fonts --input son=/sounds/messenger/<slug>.yaml template/sheet.typ "sheets/messenger/[Artiste] Morceau (Rôle).pdf"
```

Dépendances : `typst` (CLI ≥ 0.13, ou `pip install typst`), `poppler-utils` pour la vérification visuelle.

## État / à faire

- [x] Template Messenger + 3 fiches de démo.
- [x] Template minilogue XD + 1 fiche de démo (Jump Brass).
- [ ] Notes d'étude Synth Secrets n°1 à 3 (`knowledge/sources/synth-secrets-01.md` à `-03.md`). Bloqué le 2026-10-14 : `www.soundonsound.com` refusé par le proxy ; l'utilisateur a mis à jour l'environnement, à vérifier dans une nouvelle session.
- [ ] Puis réécrire la fiche de théorie 01 en version longue à partir de `synth-secrets-01.md`.
- [ ] Calibration position → valeur (`knowledge/calibration/`).
- [ ] Analyse audio de WAV (reportée à la demande de l'utilisateur).
