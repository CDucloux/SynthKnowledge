# Rechercher les sources d'une fiche

À lire avant toute recherche pour une fiche (nouvelle ou mise à jour). Choix de l'utilisateur : **aller chercher les sources de qualité d'abord**, les forums ensuite.

## 1. Hiérarchie des sources

| Rang | Type | Exemples | Ce que ça vaut |
|---|---|---|---|
| 1 | **Les gens qui ont fait le son** : programmeur, musicien, ingénieur, dans leurs propres mots | **Anthony Marinelli** (chaîne YouTube, anthonymarinellimusic.com : programmeur de *Thriller*, fiches de patch), interviews Sound On Sound, Keyboard, Electronic Musician (archives sur muzines.co.uk), podcast *Stories in the Room* | « Documenté » ; seule base pour la confiance 3 |
| 2 | **Tutoriels de reproduction de qualité** | **Imaginando** (imaginando.pt/media : vidéo + projet Ableton téléchargeable), **Anthony Marinelli** (reconstitutions), Reverb Machine, MusicRadar (séries « The synth sounds of… », « How to recreate… »), Gearnews (« How to sound like… »), Syntorial | recette chiffrée, à recouper ; « Recette [n] » dans `tracabilite` |
| 3 | **Transcriptions** | Songsterr (API, voir skill sound-sheet), projet MIDI d'un tutoriel (Imaginando) | notes et tempo ; deux relevés qui concordent valent mieux qu'un |
| 4 | **Encyclopédies et bases** | Wikipédia (crédits, tempo, tonalité), Equipboard, SongBPM | contexte ; estimations automatiques (tonalité, BPM) à prendre avec prudence |
| 5 | **Forums** | GearSpace, reddit r/synthesizers et r/synthrecipes, forum.moogmusic.com | hypothèses seulement (« Hypothèse [n] ») |

## 2. Requêtes obligatoires (dans le même tour)

Avant d'écrire le YAML, lancer au minimum :
- `"Anthony Marinelli" "<morceau>"` (et `"<artiste>"` si le morceau ne donne rien) ;
- `imaginando "<morceau>"` ;
- `"<morceau>" <artiste> synth interview` · `"<morceau>" synth sound how to recreate` ;
- recherche YouTube directe (ci-dessous) avec `<morceau> synth` et `Marinelli <morceau>`.
Dans la réponse à l'utilisateur, dire ce que les sources de rang 1 et 2 ont donné, **même quand elles n'ont rien donné**.

## 3. Techniques de lecture (testées dans cet environnement)

- **YouTube** : les vidéos et les sous-titres sont bloqués (connexion exigée). Ce qui marche avec `curl` :
  - recherche : `https://www.youtube.com/results?search_query=<mots>` puis extraire les paires `"videoId"` / `"title"` du HTML ;
  - page `watch?v=<id>` : la **description et les chapitres** sont dans `"attributedDescription":{"content":"…"}` (date : `"dateText"`). Les chapitres disent souvent ce que la vidéo montre (« Trying the sound on the Minimoog »).
  - Citer la vidéo en disant « description lue, vidéo non visionnée ». Ne jamais inventer son contenu.
- **Projet Ableton** (Imaginando) : `.zip` → `.als` = XML compressé gzip. Notes MIDI : `KeyTrack` / `MidiKey` / `MidiNoteEvent Time Duration` ; tempo : `<Tempo>` → `Manual` ; effets : `PluginDesc`, noms des paramètres dans `ParameterName`. Les réglages internes des plug-ins sont des paramètres numérotés sans nom : inutilisables sans la vidéo.
- **MusicRadar** : WebFetch renvoie souvent la page tronquée ; `curl` puis retirer les balises donne le texte complet de l'article.
- **Pages refusées (403)** : GearSpace, ask.audio… Ne citer que ce qu'on a lu (titre, résumé du moteur de recherche) et l'écrire dans `note`.
- **Fiches de patch réservées aux abonnés** (ex. Marinelli : PDF + preset Arturia contre inscription à sa lettre) : ne jamais s'inscrire avec l'adresse de l'utilisateur. Lui signaler le lien ; s'il dépose le fichier dans `original-sources/` (exclu de git), recaler la fiche dessus (confiance 3 possible).

## 4. Ressources déjà repérées

- Anthony Marinelli : *Thriller* (basse ARP 2600 « Tonus », vidéo jkJVim4X9C4 ; 7 parties de basse avec Greg Phillinganes, 4UqxOg3M-OM), *PYT* (ARP 2600), *Billie Jean* (4 couches de basse) ; fiches de patch : Thriller Bass (ARP 2600), Chameleon Bass (ARP Odyssey).
- Imaginando : *The Son of Flynn* (arpège, basse, nappe ; projet Ableton) ; *I Feel Love* (basse et nappe ; projet Ableton : piste « Bass arp », 130 BPM).
- Songsterr : *I Feel Love* (s1867855, piste Synth Bass, 128 BPM, écho noté en doubles croches).
- *Take On Me* (a-ha) : SOS Classic Tracks (mars 2011, Juno-60 de Tarney, DX7, PPG Wave) ; mu:zines « Sound Diving #2 » (analyse des pistes séparées : basse DX7 E.Bass 1, riff en couches Juno + PPG) ; Imaginando (projet Ableton : Bass, Keys, Organ, Lead) ; Songsterr s460755 (pistes Synth Bass et Keyboard, 169 BPM).
- mu:zines, série « Sound Diving » (muzines.co.uk/blog) : analyses de pistes séparées de tubes des années 80, source de rang 1-2.
