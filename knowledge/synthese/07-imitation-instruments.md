# Imiter un instrument acoustique

Méthode et recettes tirées de Synth Secrets [SS24-30] (index : `knowledge/sources/synth-secrets.md`).
À lire quand la fiche vise un son « réaliste » (cuivre, vent, corde pincée, guitare) ou un preset 70s/80s qui imite un instrument.

## Méthode générale

1. **Trois attributs suffisent pour beaucoup de timbres** : la forme d'onde (contenu harmonique), le contour de **brillance** (filtre) et le contour de **volume** (ampli) [SS20].
   Il faut les analyser séparément : ils n'évoluent presque jamais ensemble [SS7].
2. **Les premières millisecondes identifient l'instrument** [SS7, SS25] : le soin va d'abord à l'attaque (vitesse, ordre d'arrivée des harmoniques, instabilité, bruit).
3. **Un son statique sonne « orgue »**, quelle que soit la richesse de l'onde [SS14] : il faut que quelque chose bouge (filtre, vibrato, growl).
4. **Choisir l'onde selon la physique** [SS2, SS24] :

| Instrument | Pourquoi | Onde de départ |
|---|---|---|
| Cuivres (trompette, trombone, tuba), saxophones | tube conique ou pavillon → tous les harmoniques | **scie** |
| Cordes frottées (violon…) | la corde au chevalet est proche d'une scie | **scie** (la caisse fait le reste) |
| Clarinette | tube cylindrique fermé (anche) → harmoniques impairs, octave plus grave | **carré** |
| Hautbois, basson | anche double, son nasal | **pulse étroit** (5-10 %) [SS10] |
| Flûte à bec, flûte | tube ouvert → tous les harmoniques, peu d'aigus | **triangle** ou scie très filtrée, + un peu de bruit [SS7] |
| Corde pincée au milieu | triangle au départ (impairs en 1/n²) | **triangle** ; pincée à 1/n de la longueur → chaque n-ième harmonique manque [SS28] |
| Peaux (tambours) | modes non harmoniques serrés | **bruit filtré** [SS2] |
| Métal (cymbale, gong, cloche) | plaques 2D, partiels inharmoniques | **ring mod / FM non entière** [SS2, SS13] |

5. **Règles physiques réutilisables** :
   - plus fort = plus brillant et fondamentale moins dominante → vélocité sur l'enveloppe de filtre [SS24] ;
   - plus aigu = moins d'harmoniques → suivi de clavier un peu **inférieur à 100 %** [SS24] ;
   - les harmoniques aigus arrivent **après** les graves → enveloppe de filtre plus lente que celle de l'ampli [SS25] ;
   - un vrai instrument contient un peu de **bruit filtré** (souffle, turbulence) [SS14, SS25] ; un bruit blanc non filtré sonne faux, mieux vaut l'omettre [SS26] ;
   - de légères fluctuations aléatoires de hauteur humanisent [SS16] ; un seul LFO régulier sur tout sonne « électronique » [SS14] ;
   - le **jeu** compte autant que le patch : notes liées ou détachées, vibrato à la main [SS26].

## Cuivres (le cas le mieux documenté)

### Ce que fait une vraie trompette [SS24, SS25]

- **Volume** : attaque courte mais pas instantanée (plus rapide si on souffle fort), sustain, **release très court** dès qu'on arrête de souffler.
- **Brillance** : les harmoniques aigus « parlent » plus tard que les graves ; un coup de langue donne un « parp » (pic de brillance) avant le régime établi.
- **Instabilité initiale** : la hauteur met ~50 ms (une douzaine de cycles) à se stabiliser. Reid ne module **pas** la hauteur (la FM détruirait le timbre) : il module le **filtre** par un triangle à ~80 Hz, seulement pendant l'attaque. C'est le **growl**.
- **Vibrato** : retardé (absent pendant l'attaque), ~5 Hz, **très faible** sinon il sonne électronique.
- Une enveloppe ADSR ne peut pas faire le cuivre « spit » complet (pic, retombée plus terne, puis gonflement) [SS8] : on se contente de l'ADSR, comme les grands cuivres Prophet-5, OB-X, Memorymoog [SS25].

### Le patch Minimoog de Reid [SS26]

| Section | Réglage |
|---|---|
| Oscillateur | **une seule scie**, 4' pour trompette ou sax alto (plusieurs oscillateurs qui dérivent ne ressemblent pas à l'instrument) |
| Mixer | 5/10 (pas de saturation du filtre) |
| Ampli | A ≈ 100 ms, S = 10/10, release instantané (switch DECAY off) |
| Filtre | cutoff **fermé**, EG amount 6,5/10, F env A ≈ 600 ms, D ≈ 800 ms, S 5/10, emphasis 2/10, **keytrack 100 %** |
| Growl | OSC 3 en triangle très grave (32', fine -1, sans suivi clavier) → filtre, dosé à la molette au début de chaque note |
| Vibrato | à la main, à la molette de pitch |

Variantes publiées dans *Minimoog Sound Charts* (Tom Rhea, 1977), analysées par Reid [SS26] :
- *Trumpet* : 3 oscillateurs à l'unisson (son « tutti » plus gras), filtre plus ouvert, moins d'enveloppe, keytrack 66 %. Reid le trouve terne.
- *Tuba* : une scie, enveloppes plus douces, filtre **modulé par le bruit** (rugosité) : très efficace.
- *Jazz Trombone* : scie, LFO lent sur le filtre, vibrato.
- Sur SH-101, Reid ajoute que le *Tuba* d'usine (scie 60 % + **sub carré** 100 %) gagne du corps grâce au mélange d'ondes [SS27].

**À ne pas faire** (le son cesse d'être cuivré) : autre onde que la scie, attaque instantanée, forte résonance [SS26].
Le résultat est plus convaincant dans le grave (trombone, tuba), avec EQ et réverbération [SS26].

### Traduction Messenger (déduit, positions non calibrées)

| Contrôle | Réglage | Origine |
|---|---|---|
| *WAVESHAPE 1* | 12 (scie), *OCTAVE 1* 4' (trompette) · 8' (trombone) · 16' (tuba) | [SS26] |
| *MIXER* | OSC 1 seul, autour de 12-13 ; tuba : ajouter *SUB* (carré) | [SS26, SS27] |
| *CUTOFF* | 7-8 (presque fermé) ; *KB TRACKING* ON | [SS26] |
| *EG AMOUNT* | ≈ 15 (6,5/10 de l'excursion positive) | [SS26] |
| *RESONANCE* | ≈ 9 | [SS26] |
| F ENV | A ≈ 11, D ≈ 11.5, S 12, R 8 (temps du Minimoog : 600 / 800 ms, à calibrer) | [SS26] |
| A ENV | A ≈ 9, D indifférent, S 17, R 7.5-8 | [SS26] |
| *MULTI-TRIG* | OFF pour les notes liées (pistons) ; jouer détaché pour les notes « coup de langue » | [SS27] |
| Growl | *LFO 1* triangle, CONFIG 1.4 = 0,5-120 Hz, RATE ≈ 80 Hz, DEST *CUTOFF* ; profondeur via `modulations` (aftertouch → *LFO 1 DEPTH*) pour l'appliquer à la pression | adaptation de [SS25, SS26] |
| Vibrato | *LFO 2* → PITCH ≈ 5 Hz à la molette, très peu | [SS25] |
| *F ENV VEL* | ON : jouer fort = plus brillant | [SS24, SS25] |

### Traduction minilogue XD (déduit)

- VCO 1 *SAW*, VCO 2 éventuel à l'unisson très léger (section de cuivres) ou coupé (soliste).
- *CUTOFF* bas, *KEYTRACK* 100 %, *RESONANCE* faible.
- L'*EG* est un AD (pas de sustain) : il fait le « parp » d'attaque, le *CUTOFF* fixe la brillance du sustain. *EG Velocity* (PROGRAM EDIT 8) pour la dynamique.
- *AMP EG* : A court mais non nul, S max, R court.
- Le LFO plafonne à 28 Hz : pas de growl à 80 Hz (même limite que l'ARP Axxe, où Reid remplace le growl par un vibrato à ~5 Hz à la pression [SS27]). Mettre le vibrato sur le joystick Y.
- *REVERB* Hall pour placer l'instrument [SS22].

## Bois (premières règles, à compléter avec SS52-54)

- **Clarinette** : carré (impairs), filtre passe-bas modéré ; l'octaviation saute à la douzième [SS24].
- **Hautbois** : pulse étroit, passe-bande ou résonance moyenne [SS10].
- **Flûte** : scie filtrée ou triangle + **un peu de bruit** ; un « chiff » d'attaque par enveloppe ; jeu **legato sans redéclenchement** (le flûtiste ne « chiffe » pas chaque note : le comportement Minimoog est plus réaliste que le multi-trigger) [SS7].

## Cordes pincées et guitares [SS28-30]

Verdict de Reid : **une guitare réaliste est hors de portée de la synthèse soustractive analogique**. Les fiches doivent viser le *caractère* et le dire (confiance 1 ou 2).

Ce qui rend la guitare impossible : le point d'attaque retire des harmoniques ; la caisse a des résonances serrées qu'aucun filtre simple ne reproduit ; les harmoniques sont légèrement « étirés » (plus aigus) au début de la note ; sur une électrique, le micro est un **filtre en peigne qui dépend de la note jouée** ; les cordes interagissent entre elles.

Ce qui marche quand même (patchs historiques analysés par Reid) :
- **Pulse ~25 %** plutôt que scie : les trous du spectre évoquent grossièrement les résonances (ARP Axxe *Jazz Guitar*) [SS30].
- **Pulse dont la largeur suit l'enveloppe** + un peu de scie (SH-101 *Fuzz Guitar*) : imite le glissement des nœuds sous le micro [SS30].
- **Sustain 0** et **decay du filtre plus court que celui de l'ampli** : la queue s'assombrit naturellement (Minimoog *Electric Guitar* de Tom Rhea, pulse + rampe) [SS30].
- Pluck générique : même enveloppe AD sur filtre et ampli, filtre qui suit la hauteur [SS29] ; dureté du médiator = plus ou moins d'aigus à l'attaque [SS28].
- Seule une **forte distorsion** rend un patch « guitare » crédible, parce qu'on entend alors surtout la distorsion [SS30].
- Polyphonie (XD) : une nouvelle note sur la même « corde » coupe la précédente, alors qu'un arpège laisse sonner : le synthé ne le sait pas, c'est au jeu de le faire [SS29].

## Polyphonie et machines à cordes [SS20]

- **Paraphonie** (Solina, ARP Omni, Roland RS-202/505, Polymoog en usage courant) : une seule enveloppe de filtre et d'ampli pour toutes les notes ; une note jouée pendant qu'une autre tient arrive directement au niveau de sustain, sans attaque.
  Pour imiter fidèlement un string ensemble, ce défaut fait partie du son.
- Le minilogue XD est **vraiment polyphonique** (filtre et enveloppes par voix) : il ne reproduit pas ce comportement paraphonique.
