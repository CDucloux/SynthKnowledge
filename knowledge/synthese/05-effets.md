# Effets : et comment s'en passer

Le **Messenger n'a aucun effet intégré**. Le **minilogue XD** a MOD FX, DELAY et REVERB.
Quand un son de référence dépend d'un effet, la fiche doit le dire, avec une alternative.

| Effet entendu | Indices à l'écoute | Sur minilogue XD | Sur Messenger |
|---|---|---|---|
| Chorus / ensemble | son large, « liquide », légèrement désaccordé | MOD FX chorus / ensemble | 2 osc désaccordés + LFO lent sur OSC 2 FREQ ; sinon chorus externe |
| Phaser / flanger | balayage « jet », creux mobiles | MOD FX phaser / flanger | LFO lent sur cutoff (approx.) ; externe |
| Delay | répétitions rythmiques | DELAY (time / depth) | séquence ou arp « écho » (notes répétées plus douces) ; externe |
| Reverb | queue, espace | REVERB | release long (approx.) ; externe |
| Distorsion / saturation | grain, compression, harmoniques en plus | DRIVE du filtre | *FB / EXT IN* (feedback du mixer) pour saturer |
| Unison / supersaw | énorme, épais, stéréo | VOICE MODE UNISON | 2 osc scie désaccordés (mono, plus étroit) |

Règle : **ne jamais prétendre qu'un réglage remplace exactement un effet**. Écrire « approximation sans effet, ajouter un chorus externe pour l'original ».

## Approfondir (Synth Secrets, index `knowledge/sources/synth-secrets.md`)

- **Réverbération** [SS22] : premières réflexions distinctes, puis une queue dense (des échos à moins de ~30 ms ne s'entendent plus séparément). Une spring à un ressort donne un « boing » métallique.
- **Le corps d'un instrument est une réverbération très courte** (1-4 ms) qui colore le son selon la note : c'est pourquoi un violon ne sonne pas comme une scie [SS22]. Les effets du minilogue XD sont en fin de chaîne : ils placent le son dans une salle mais ne remplacent pas une caisse de résonance.
- Pour un instrument acoustique imité : grande réverbération de salle en sortie (XD *REVERB* Hall) [SS22].
- **Vocodeur** [SS15] : banques de filtres passe-bande ; une dizaine de bandes plus du bruit pour les consonnes suffit (*Mr Blue Sky*). Aucune des deux machines n'en a : le dire dans la fiche.
- **Entrée externe** : Messenger *FB / EXT IN* permet de filtrer un son extérieur ; le VCA reste fermé tant qu'on ne joue pas [SS15].
