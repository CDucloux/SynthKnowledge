// Synther : fiches de théorie imprimables (d'après Synth Secrets, rédigé
// avec nos mots). Même esthétique que les fiches son. Les schémas sont
// calculés (formes d'onde, spectres, courbes) : aucune image copiée.

#import "style.typ": *

/// Tailles de texte des fiches de théorie, par rôle (A4 portrait, plus
/// grandes que les fiches son).
#let theory-size = (
  body: 8.4pt,            // texte courant
  number: 30pt,           // numéro de fiche dans le bandeau
  kicker: 7pt,            // « THÉORIE · SYNTH SECRETS »
  title: 19pt,
  subtitle: 8.4pt,
  articles: 6.6pt,        // SS1 · SS2 en haut à droite
  key-idea-label: 6.4pt,  // « IDÉE CLÉ »
  key-idea: 9.6pt,
  tab-title: 6.6pt,       // onglet noir des encadrés
  caption: 6.8pt,         // légende de schéma
  box-body: 7.6pt,        // « Essaie sur ton… », « À retenir »
  sources: 6pt,           // pied de fiche
  spectrum-rank: 4.8pt,   // numéros de rang sous un spectre
  tag: 6pt,               // étiquette de schéma
)

// ---------------------------------------------------------------------------
// Mise en page
// ---------------------------------------------------------------------------

/// Réglages de page d'une fiche de théorie (A4 portrait, pas de limite de pages).
#let theory-setup(body) = {
  set page(paper: "a4", margin: (x: 13mm, top: 11mm, bottom: 11mm))
  set text(font: font, size: theory-size.body, lang: "fr", fill: ink)
  set par(justify: false, leading: 0.62em)
  body
}

/// En-tête : bandeau noir avec numéro de fiche, titre, sous-titre et numéros
/// des articles Synth Secrets couverts (`articles` : liste d'entiers).
#let theory-header(number, title, subtitle, articles) = {
  block(width: 100%, fill: ink, inset: (x: 5mm, y: 3mm), grid(
    columns: (auto, 1fr, auto), column-gutter: 5mm, align: (left + horizon, left + horizon, right + bottom),
    text(white, size: theory-size.number, weight: "extrabold", number),
    {
      text(white, size: theory-size.kicker, weight: "bold", tracking: 0.32em, "THÉORIE  ·  SYNTH SECRETS")
      v(1mm)
      text(white, size: theory-size.title, weight: "extrabold", upper(title))
      v(0.6mm)
      text(white, size: theory-size.subtitle, weight: "medium", subtitle)
    },
    text(white, size: theory-size.articles, weight: "semibold", tracking: 0.1em, articles.map(article => "SS" + str(article)).join("  ·  ")),
  ))
  v(2.4mm)
}

/// Idée clé : encadré à barre noire, la phrase à retenir avant tout.
#let key-idea(body) = block(width: 100%, stroke: (left: 3.2pt + ink), inset: (left: 4mm, y: 1.6mm), {
  text(size: theory-size.key-idea-label, weight: "extrabold", tracking: 0.2em, "IDÉE CLÉ")
  v(0.6mm)
  text(size: theory-size.key-idea, weight: "semibold", body)
})

/// Bloc encadré avec onglet titre noir (hauteur libre), pour schémas et explications.
#let tab-box(title, body, inset: 3mm) = block(
  width: 100%, stroke: 0.9pt + ink, clip: true, breakable: false,
  stack(
    box(fill: ink, inset: (x: 2mm, y: 1.1mm), text(white, size: theory-size.tab-title, weight: "extrabold", tracking: 0.08em, upper(title))),
    block(width: 100%, inset: inset, body),
  ),
)

/// Légende de schéma (petite, en italique discret).
#let caption(body) = text(size: theory-size.caption, fill: grey.caption, style: "italic", body)

/// Encadré « Essaie sur ton <machine> » : manipulations numérotées.
#let try-it(machine, items) = tab-box("Essaie sur ton " + machine, {
  set text(size: theory-size.box-body)
  numbered(items)
}, inset: (x: 3mm, top: 2.4mm, bottom: 1.2mm))

/// Encadré « À retenir » : liste à puces.
#let takeaways(items) = tab-box("À retenir", {
  set text(size: theory-size.box-body)
  bullets(items)
}, inset: (x: 3mm, top: 2.4mm, bottom: 1.4mm))

/// Pied de fiche : sources, et rappel que le texte est rédigé avec nos mots.
#let theory-sources(items) = {
  set text(size: theory-size.sources, fill: grey.secondary)
  line(length: 100%, stroke: 0.5pt + muted)
  v(-1mm)
  grid(
    columns: (1fr, auto), gutter: 3mm,
    [*SOURCES* #h(1mm) #items.join([ #h(0.8mm)·#h(0.8mm) ])],
    [SYNTHER · résumé rédigé avec nos mots, schémas recalculés],
  )
}

// ---------------------------------------------------------------------------
// Schémas calculés
// ---------------------------------------------------------------------------

/// Trace une forme d'onde `wave(phase)` (phase dans [0, 1), valeur dans
/// [-1, 1]) répétée `periods` fois, avec `samples` points.
#let wave-plot(wave, width: 40mm, height: 14mm, periods: 2, samples: 240, stroke: 1.3pt + ink, axis: true) = box(width: width, height: height, {
  let middle = height / 2
  if axis {
    place(line(start: (0pt, middle), end: (width, middle), stroke: 0.4pt + muted))
  }
  let points = range(samples + 1).map(sample => {
    let progress = sample / samples
    let value = calc.clamp(wave(calc.rem(progress * periods, 1.0)), -1.2, 1.2)
    (progress * width, middle - value * (height / 2) * 0.9)
  })
  place(polyline(points, stroke: (paint: stroke.paint, thickness: stroke.thickness, join: "round")))
})

/// Spectre : une barre par harmonique (`amplitudes`, 1 = fondamentale),
/// numéro de rang dessous si `labels` (un sur deux au-delà de 12 rangs).
#let spectrum(amplitudes, width: 40mm, height: 14mm, labels: true) = box(width: width, height: height + (if labels { 3mm } else { 0mm }), {
  let count = amplitudes.len()
  let step = width / count
  let bar-width = calc.min(step * 0.42, 2.2mm)
  place(line(start: (0pt, height), end: (width, height), stroke: 0.6pt + ink))
  for (index, amplitude) in amplitudes.enumerate() {
    let rank = index + 1
    let bar-height = calc.max(amplitude, 0) * height * 0.95
    let bar-center = step * index + step / 2
    if bar-height > 0.05pt {
      place(dx: bar-center - bar-width / 2, dy: height - bar-height, rect(width: bar-width, height: bar-height, fill: ink))
    }
    if labels and (count <= 12 or calc.rem(rank, 2) == 1) {
      place(dx: bar-center - 2mm, dy: height + 0.6mm, box(width: 4mm, align(center, text(size: theory-size.spectrum-rank, fill: grey.secondary, str(rank)))))
    }
  }
})

// Formes d'onde usuelles, phase dans [0, 1).
#let wave-sine(phase) = calc.sin(2 * calc.pi * phase)
#let wave-saw(phase) = 1 - 2 * phase
#let wave-square(phase) = if phase < 0.5 { 1 } else { -1 }
#let wave-triangle(phase) = if phase < 0.25 { 4 * phase } else if phase < 0.75 { 2 - 4 * phase } else { 4 * phase - 4 }
#let wave-pulse(duty) = phase => if phase < duty { 1 } else { -1 }

// Spectres théoriques (amplitudes relatives des rangs 1 à `ranks`).
#let spectrum-saw(ranks) = range(1, ranks + 1).map(rank => 1 / rank)
#let spectrum-square(ranks) = range(1, ranks + 1).map(rank => if calc.odd(rank) { 1 / rank } else { 0 })
#let spectrum-triangle(ranks) = range(1, ranks + 1).map(rank => if calc.odd(rank) { 1 / (rank * rank) } else { 0 })
#let spectrum-pulse(duty, ranks) = {
  let fundamental = calc.abs(calc.sin(calc.pi * duty))
  range(1, ranks + 1).map(rank => calc.abs(calc.sin(rank * calc.pi * duty)) / rank / fundamental)
}

/// Scie approchée par ses `harmonics` premiers harmoniques (somme de
/// Fourier partielle), normalisée.
#let saw-partial(harmonics) = phase => {
  let sum = 0.0
  for rank in range(1, harmonics + 1) { sum += calc.sin(2 * calc.pi * rank * phase) / rank }
  sum * 2 / calc.pi * 0.92
}

/// Étiquette de schéma en petites capitales.
#let tag(body) = text(size: theory-size.tag, weight: "extrabold", tracking: 0.1em, upper(body))
