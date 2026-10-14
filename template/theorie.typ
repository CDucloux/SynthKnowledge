// SynthKnowledge : fiches de théorie imprimables (d'après Synth Secrets, rédigé avec nos mots).
// Même esthétique que les fiches son : noir & blanc, Montserrat, onglets noirs, vignettes encadrées.
// Les schémas sont calculés (formes d'onde, spectres, courbes) : aucune image copiée.

#import "style.typ": *

// ---------------------------------------------------------------------------
// Mise en page
// ---------------------------------------------------------------------------

#let theorie-setup(body) = {
  set page(paper: "a4", margin: (x: 13mm, top: 11mm, bottom: 11mm))
  set text(font: font, size: 8.4pt, lang: "fr", fill: ink)
  set par(justify: false, leading: 0.62em)
  body
}

/// En-tête : bandeau noir avec numéro de fiche, titre, références Synth Secrets.
#let theorie-header(num, titre, sous-titre, refs) = {
  block(width: 100%, fill: ink, inset: (x: 5mm, y: 3mm), radius: 1.5pt, grid(
    columns: (auto, 1fr, auto), column-gutter: 5mm, align: (left + horizon, left + horizon, right + bottom),
    text(white, size: 30pt, weight: "extrabold", num),
    {
      text(white, size: 7pt, weight: "bold", tracking: 0.32em, "THÉORIE  ·  SYNTH SECRETS")
      v(1mm)
      text(white, size: 19pt, weight: "extrabold", upper(titre))
      v(0.6mm)
      text(white, size: 8.4pt, weight: "medium", sous-titre)
    },
    text(white, size: 6.6pt, weight: "semibold", tracking: 0.1em, refs.map(r => "SS" + str(r)).join("  ·  ")),
  ))
  v(2.4mm)
}

/// Idée clé : grand encadré à barre noire, la phrase à retenir avant tout.
#let idee(body) = block(width: 100%, stroke: (left: 3.2pt + ink), inset: (left: 4mm, y: 1.6mm), {
  text(size: 6.4pt, weight: "extrabold", tracking: 0.2em, "IDÉE CLÉ")
  v(0.6mm)
  text(size: 9.6pt, weight: "semibold", body)
})

/// Bloc encadré avec onglet titre (hauteur libre), pour schémas et explications.
#let panneau(title, body, inset: 3mm) = block(
  width: 100%, stroke: 0.9pt + ink, radius: 1.5pt, clip: true, breakable: false,
  stack(
    box(fill: ink, inset: (x: 2mm, y: 1.1mm), text(white, size: 6.6pt, weight: "extrabold", tracking: 0.08em, upper(title))),
    block(width: 100%, inset: inset, body),
  ),
)

/// Légende de schéma (petite, en italique discret).
#let legende(body) = text(size: 6.8pt, fill: luma(80), style: "italic", body)

/// Encadré pratique : à faire sur la machine, étapes numérotées.
#let essai(machine, items) = panneau("Essaie sur ton " + machine, {
  set text(size: 7.6pt)
  numbered(items)
}, inset: (x: 3mm, top: 2.4mm, bottom: 1.2mm))

#let retenir(items) = panneau("À retenir", {
  set text(size: 7.6pt)
  bullets(items)
}, inset: (x: 3mm, top: 2.4mm, bottom: 1.4mm))

#let source-ss(items) = {
  set text(size: 6pt, fill: luma(90))
  line(length: 100%, stroke: 0.5pt + muted)
  v(-1mm)
  grid(
    columns: (1fr, auto), gutter: 3mm,
    [*SOURCES* #h(1mm) #items.join([ #h(0.8mm)·#h(0.8mm) ])],
    [SYNTHKNOWLEDGE · résumé rédigé avec nos mots, schémas recalculés],
  )
}

// ---------------------------------------------------------------------------
// Primitives de schéma (unités : longueurs Typst ; fonctions calculées)
// ---------------------------------------------------------------------------

/// Trace une fonction f(t), t ∈ [0, 1] répété `periods` fois, valeurs dans [-1, 1].
#let wave-plot(f, width: 40mm, height: 14mm, periods: 2, samples: 240, stroke: 1.3pt + ink, axis: true, fill: none) = box(width: width, height: height, {
  let mid = height / 2
  if axis {
    place(line(start: (0pt, mid), end: (width, mid), stroke: 0.4pt + muted))
  }
  let pts = range(samples + 1).map(i => {
    let x = i / samples
    let t = calc.rem(x * periods, 1.0)
    let y = calc.clamp(f(t), -1.2, 1.2)
    (x * width, mid - y * (height / 2) * 0.9)
  })
  place(curve(stroke: (paint: stroke.paint, thickness: stroke.thickness, join: "round"), curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p))))
})

/// Spectre : barres d'amplitude (liste de nombres, 1 = fondamentale), étiquettes de rang.
#let spectrum(amps, width: 40mm, height: 14mm, labels: true, highlight: ()) = box(width: width, height: height + (if labels { 3mm } else { 0mm }), {
  let n = amps.len()
  let step = width / n
  let bw = calc.min(step * 0.42, 2.2mm)
  place(line(start: (0pt, height), end: (width, height), stroke: 0.6pt + ink))
  for (i, a) in amps.enumerate() {
    let hgt = calc.max(a, 0) * height * 0.95
    let x = step * i + step / 2
    let col = if (i + 1) in highlight { ink } else { ink }
    if hgt > 0.05pt {
      place(dx: x - bw / 2, dy: height - hgt, rect(width: bw, height: hgt, fill: col))
    }
    if labels and (n <= 12 or calc.rem(i + 1, 2) == 1) {
      place(dx: x - 2mm, dy: height + 0.6mm, box(width: 4mm, align(center, text(size: 4.8pt, fill: luma(90), str(i + 1)))))
    }
  }
})

// Formes d'onde usuelles, t ∈ [0, 1).
#let w-sine(t) = calc.sin(2 * calc.pi * t)
#let w-saw(t) = 1 - 2 * t
#let w-square(t) = if t < 0.5 { 1 } else { -1 }
#let w-tri(t) = if t < 0.25 { 4 * t } else if t < 0.75 { 2 - 4 * t } else { 4 * t - 4 }
#let w-pulse(d) = t => if t < d { 1 } else { -1 }

// Spectres théoriques (amplitudes relatives, rangs 1..n).
#let s-saw(n) = range(1, n + 1).map(k => 1 / k)
#let s-square(n) = range(1, n + 1).map(k => if calc.odd(k) { 1 / k } else { 0 })
#let s-tri(n) = range(1, n + 1).map(k => if calc.odd(k) { 1 / (k * k) } else { 0 })
#let s-pulse(d, n) = {
  let a1 = calc.abs(calc.sin(calc.pi * d))
  range(1, n + 1).map(k => calc.abs(calc.sin(k * calc.pi * d)) / k / a1)
}

/// Somme partielle de Fourier d'une scie (N premiers harmoniques), normalisée.
#let saw-partial(nmax) = t => {
  let s = 0.0
  for k in range(1, nmax + 1) { s += calc.sin(2 * calc.pi * k * t) / k }
  s * 2 / calc.pi * 0.92
}

/// Étiquette de schéma en petites capitales.
#let tag(body) = text(size: 6pt, weight: "extrabold", tracking: 0.1em, upper(body))
