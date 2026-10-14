# Modulation : le mouvement

## LFO : vitesses de référence

| Effet | Destination | Vitesse | Profondeur |
|---|---|---|---|
| Vibrato | pitch | 4,5-7 Hz | 10-40 cents (léger) |
| Trille / sirène | pitch (carré) | 4-10 Hz | ± demi-ton ou plus |
| Trémolo | amplitude | 3-8 Hz | moyenne |
| Wah lent / balayage | cutoff | 0,1-1 Hz | moyenne à forte |
| Wobble dubstep | cutoff | synchro tempo (1/4, 1/8, triolets) | forte |
| PWM (chorus naturel) | forme d'onde / largeur de pulse | 0,3-2 Hz | moyenne |
| Effet « drift » analogique | pitch | 0,1-0,5 Hz | très faible |

- **Délai / fade-in de LFO** (*LFO 1 FADE* sur le Messenger) : vibrato qui arrive après l'attaque, comme un chanteur ou un violoniste.
- **KB RESET / key sync** : le LFO repart du début à chaque note ; indispensable pour les effets rythmiques ou « wah » répétables.
- **Forme** : triangle = doux ; carré = alternance ; scie / rampe = montée ou descente cyclique ; S&H = aléatoire (bloops de SF).

## Sources expressives

- **Molette de modulation** : dose le vibrato en jeu (Messenger : LFO 2 → PITCH / CUTOFF / AMP).
- **Aftertouch** : vibrato ou ouverture du filtre à la pression ; très « instrument acoustique ».
- **Vélocité** : brillance et/ou volume.
- **Keyboard tracking** comme modulation : timbre qui change selon le registre.

## Glide / portamento

- **Exponentiel** (« log », Moog classique) : rapide au début, ralentit à l'arrivée ; naturel, vocal.
- **Linéaire à temps constant** : même durée quel que soit l'intervalle (slide 303).
- **Linéaire à vitesse constante** : grands intervalles = glissés plus longs (orgue-trombone).
- **Legato glide** : ne glisse que si les notes se chevauchent → contrôle du phrasé (acid, leads G-funk).

## Modulations audio-rate

LFO très rapide (> 20 Hz) ou OSC → cutoff (*OSC 2 → CUTOFF*) : grain, métal, « growl ».
Sur le Messenger, *LFO Range* dans CONFIG 1.4 étend le LFO jusqu'à 1,2 kHz.

## Approfondir (Synth Secrets, index `knowledge/sources/synth-secrets.md`)

### LFO sur le cutoff : trois effets selon la vitesse [SS10]

| Vitesse | Effet |
|---|---|
| ~0,1 Hz | balayage lent, ambient |
| 1-2 Hz | wah-wah |
| 10-20 Hz | **growl** (très bon pour les cuivres) |
| ~80 Hz, triangle, seulement à l'attaque | « rasp » des cuivres (Reid) [SS25] : Messenger *LFO 1* en CONFIG 1.4 = 0,5-120 Hz |

- **Vibrato réaliste** : retardé (absent pendant l'attaque), ~5 Hz, faible ; le faire à la main (molette, aftertouch) sonne souvent plus naturel qu'un LFO fixe [SS25, SS26].
- **Aléatoire** (sample & hold sur bruit) [SS16] : très atténué sur la hauteur = fluctuations qui humanisent ; sur le cutoff = timbre qui change à chaque pas (« bloops », ELP *Karn Evil 9*). Lissé par un slew, il donne des courbes « dent de requin ». Messenger : source KB S+H dans `modulations`.
- **Séquence d'octaves** façon *I Feel Love* (Donna Summer, Moroder) : séquenceur pas à pas sur la hauteur [SS16].
- Le **slew** (lissage) est un passe-bas lent : c'est le circuit du portamento [SS15].

### Priorité de note et jeu mono [SS18]

- **Grave** (Minimoog, ARP : synthés américains), **aiguë** (SH-09, MS-20, CS-20 : japonais), **dernière** (la note jouée sonne toujours à l'instant où on la joue).
- Messenger : CONFIG 2.1 (réglage global). Pour un patch « Minimoog », la priorité grave reproduit le comportement d'origine ; sinon la dernière note est la plus tolérante.
- Avec priorité grave, garder une note grave enfoncée retarde la suivante : jouer plus détaché.
- **Technique Emerson / Wakeman** : priorité aiguë, tenir une note grave, jouer staccato au-dessus avec un peu de glide → le son retombe sur la basse entre chaque note, solos qui « sautent » sur deux ou trois octaves.
