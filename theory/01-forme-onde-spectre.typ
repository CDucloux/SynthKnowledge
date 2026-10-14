#import "../template/theory.typ": *
#show: theory-setup

#theory-header("01", "Forme d'onde et spectre", "Deux façons de regarder le même son", (1,))

#idee[Tout son qui a une hauteur est une *somme de sinus* : la fondamentale (f) et ses harmoniques (2f, 3f, 4f…). La *forme d'onde* (le temps) et le *spectre* (les fréquences) décrivent exactement la même chose.]

#v(2mm)

#panneau("On construit une scie, sinus par sinus", {
  let ns = (1, 2, 3, 6, 30)
  grid(
    columns: (1fr,) * 5, column-gutter: 2mm, row-gutter: 1.2mm,
    ..ns.map(n => align(center, tag(if n == 1 { "1 sinus" } else { str(n) + " harmoniques" }))),
    ..ns.map(n => align(center, wave-plot(saw-partial(n), width: 31mm, height: 10.5mm, periods: 2, samples: 300))),
    ..ns.map(n => align(center, spectrum(s-saw(calc.min(n, 12)) + (0,) * calc.max(0, 12 - n), width: 31mm, height: 7mm, labels: true))),
  )
  v(1mm)
  legende[En haut : la forme d'onde obtenue. En bas : les harmoniques ajoutés (rang 1 = fondamentale, hauteur de barre = amplitude 1/n). Plus on en ajoute, plus l'arête de la scie devient raide, et plus le son devient brillant.]
})

#v(1.8mm)

#panneau("Les formes de base et leur spectre", {
  let row-h = 9mm
  let rows = (
    ("Sinus", w-sine, (1,) + (0,) * 15, "pur, flûté, « sub »", "*RESONANCE* au max (auto-oscillation)"),
    ("Triangle", w-tri, s-tri(16), "doux, creux, rond", "*WAVESHAPE* ≈ 11:00"),
    ("Scie", w-saw, s-saw(16), "brillant, plein, cuivré", "*WAVESHAPE* à midi"),
    ("Carré", w-square, s-square(16), "creux, boisé, clarinette", "*WAVESHAPE* ≈ 1:00-1:30"),
    ("Pulse 25 %", w-pulse(0.25), s-pulse(0.25, 16), "nasal, fin", "*WAVESHAPE* vers 3:00"),
  )
  grid(
    columns: (19mm, 33mm, 46mm, 1fr, 46mm), column-gutter: 3mm, row-gutter: 1.6mm, align: horizon,
    tag("Forme"), tag("Onde (2 périodes)"), tag("Spectre (rangs 1 à 16)"), tag("À l'oreille"), tag("Sur le Messenger"),
    grid.hline(stroke: 0.6pt),
    ..rows.map(((name, f, s, ear, msg)) => (
      text(size: 8.4pt, weight: "extrabold", upper(name)),
      wave-plot(f, width: 33mm, height: row-h, periods: 2),
      spectrum(s, width: 46mm, height: row-h - 3mm),
      text(size: 7.8pt, ear),
      text(size: 7.4pt, md(msg)),
    )).flatten(),
  )
  v(1mm)
  legende[Triangle et carré n'ont que des harmoniques *impairs* (1, 3, 5…) : c'est ce qui les rend « creux ». La scie a *tous* les harmoniques : c'est la plus riche. Un pulse de 25 % perd un harmonique sur quatre (4, 8, 12…).]
})

#v(1.8mm)

#grid(
  columns: (1fr, 1fr), column-gutter: 2.4mm,
  panneau("Pourquoi partir d'une scie ?", {
    set text(size: 7.8pt)
    grid(columns: (1fr, auto, 1fr), column-gutter: 1.5mm, align: center + horizon,
      stack(spacing: 1mm, spectrum(s-saw(12), width: 28mm, height: 11mm, labels: false), tag("Oscillateur : tout")),
      text(size: 14pt, weight: "extrabold", "→"),
      stack(spacing: 1mm, spectrum(s-saw(12).enumerate().map(((i, a)) => a / calc.sqrt(1 + calc.pow((i + 1) / 3, 8))), width: 28mm, height: 11mm, labels: false), tag("Après le filtre")),
    )
    v(1.6mm)
    [La synthèse *soustractive* part d'un son riche et *enlève* des harmoniques avec le filtre : plus la source est riche, plus le filtre a de matière à sculpter.]
  }),
  panneau("Bon à savoir", {
    set text(size: 7.8pt)
    bullets((
      "L'oreille entend surtout *quels* harmoniques sont présents et *à quel niveau*, beaucoup moins leur décalage (phase) : deux ondes de formes différentes peuvent sonner pareil.",
      "Un son *non périodique* (cloche, tambour) a des composantes qui ne sont pas des multiples entiers : il n'a pas de « forme d'onde » qui se répète.",
    ))
  }),
)

#v(1.8mm)

#grid(
  columns: (1.15fr, 1fr), column-gutter: 2.4mm,
  essai("Messenger", (
    "Patch init (maintenir *PANEL* 1 s). *MIXER* : seul *OSC 1*.",
    "*WAVESHAPE 1* de 11:00 à 5:00 : triangle → scie → carré → pulse. Les harmoniques apparaissent.",
    "Scie (midi), puis fermer *CUTOFF* de 5:00 à 9:00 : les harmoniques partent du haut vers le bas.",
    "*RESONANCE* vers 3:00, balayer lentement *CUTOFF* : chaque harmonique « chante » à son tour. On entend le spectre !",
  )),
  retenir((
    "Forme d'onde = spectre : deux vues d'une même réalité.",
    "Scie : tous les harmoniques (1/n). Carré : impairs (1/n). Triangle : impairs, très faibles (1/n²).",
    "Brillant = beaucoup d'harmoniques aigus. Creux = harmoniques pairs absents.",
    "Soustractif : source riche, puis on retire avec le filtre.",
  )),
)

#v(1fr)
#source-ss((
  [Gordon Reid, « Synth Secrets n°1 : What's In A Sound? », _Sound On Sound_, mai 1999],
  [Moog Messenger User's Manual, p. 10 et 15 (positions de *WAVESHAPE*)],
))
