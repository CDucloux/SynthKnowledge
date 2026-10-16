// Synther : icônes vectorielles des encadrés (dessin natif, noir et blanc,
// jamais d'emoji). Toutes dans une case de 4.2 × 3 mm, trait de 0.8 pt.

#import "theme.typ": ink
#import "draw.typ": polyline

#let _width = 4.2mm
#let _height = 3mm
#let _stroke = (paint: ink, thickness: 0.8pt, join: "round", cap: "round")

/// Case d'icône, alignée sur la ligne de base du titre.
#let _icon(body) = box(width: _width, height: _height, baseline: 0.35mm, body)

/// Ligne brisée au trait des icônes.
#let _line(..points) = polyline(points.pos(), stroke: _stroke)

/// Oscillateur : dents de scie.
#let icon-wave = _icon({
  place(_line((0mm, 3mm), (1.4mm, 0mm), (1.4mm, 3mm), (2.8mm, 0mm), (2.8mm, 3mm), (4.2mm, 0mm)))
})

/// Filtre passe-bas : plateau puis pente, petite bosse de résonance.
#let icon-filter = _icon({
  place(curve(stroke: _stroke, curve.move((0mm, 1.1mm)), curve.line((1.7mm, 1.1mm)),
    curve.quad((2.3mm, 1.1mm), (2.5mm, 0.3mm)), curve.quad((2.75mm, 0.9mm), (4.2mm, 3mm))))
})

/// Enveloppe ADSR.
#let icon-env = _icon({
  place(_line((0mm, 3mm), (0.7mm, 0mm), (1.6mm, 1.3mm), (3mm, 1.3mm), (4.2mm, 3mm)))
})

/// Espace, effets : ondes qui rayonnent depuis un point.
#let icon-space = _icon({
  place(dx: 0mm, dy: 1.1mm, circle(radius: 0.4mm, fill: ink))
  for radius in (1.3mm, 2.3mm, 3.3mm) {
    place(dx: 0.4mm, dy: 1.5mm, curve(stroke: _stroke,
      curve.move((radius * 0.6, -radius * 0.8)), curve.quad((radius * 1.25, 0mm), (radius * 0.6, radius * 0.8))))
  }
})

/// Mouvement, modulation : sinusoïde (une période et demie).
#let icon-motion = _icon({
  let points = range(0, 25).map(step => (
    _width * step / 24,
    1.5mm - 1.3mm * calc.sin(2 * calc.pi * step / 24 * 1.5),
  ))
  place(polyline(points, stroke: _stroke))
})

/// Jeu : touches de clavier.
#let icon-keys = _icon({
  place(rect(width: 4.2mm, height: 3mm, stroke: 0.7pt + ink))
  for gap-x in (1.05mm, 2.1mm, 3.15mm) { place(line(start: (gap-x, 0mm), end: (gap-x, 3mm), stroke: 0.5pt + ink)) }
  for black-key-x in (0.75mm, 1.8mm, 3.15mm - 0.3mm) { place(dx: black-key-x, rect(width: 0.6mm, height: 1.7mm, fill: ink)) }
})

/// Séquence : rangée de pas, certains allumés.
#let icon-steps = _icon({
  for step in range(4) {
    place(dx: step * 1.1mm, dy: 0.6mm, rect(
      width: 0.85mm, height: 1.8mm, stroke: 0.6pt + ink, fill: if step in (0, 2) { ink } else { white },
    ))
  }
})

/// Réglage : potard.
#let icon-knob = _icon({
  place(dx: 0.6mm, dy: 0mm, circle(radius: 1.5mm, stroke: 0.8pt + ink))
  place(line(start: (2.1mm, 1.5mm), end: (3.1mm, 0.5mm), stroke: _stroke))
})

/// À l'oreille : arcs d'écoute autour d'un point.
#let icon-ear = _icon({
  place(dx: 0.2mm, dy: 1.1mm, circle(radius: 0.4mm, fill: ink))
  place(curve(stroke: _stroke, curve.move((1.3mm, 0.2mm)), curve.quad((2.5mm, 1.5mm), (1.3mm, 2.8mm))))
  place(curve(stroke: _stroke, curve.move((2.5mm, 0mm)), curve.quad((4mm, 1.5mm), (2.5mm, 3mm))))
})

/// Sources : loupe.
#let icon-source = _icon({
  place(dx: 0.3mm, circle(radius: 1.15mm, stroke: 0.8pt + ink))
  place(line(start: (2.3mm, 2.0mm), end: (3.6mm, 3mm), stroke: (paint: ink, thickness: 1.1pt, cap: "round")))
})

/// Contexte : i cerclé.
#let icon-info = _icon({
  place(dx: 0.6mm, circle(radius: 1.5mm, stroke: 0.8pt + ink))
  place(dx: 2.1mm - 0.25mm, dy: 0.55mm, circle(radius: 0.25mm, fill: ink))
  place(line(start: (2.1mm, 1.3mm), end: (2.1mm, 2.4mm), stroke: _stroke))
})

/// Icône d'un encadré d'analyse, choisie d'après les mots de son titre.
#let auto-icon(title) = {
  let words = lower(str(title))
  let has(..keys) = keys.pos().any(key => words.contains(key))
  if has("oscillat") { icon-wave }
  else if has("filtre") { icon-filter }
  else if has("enveloppe") { icon-env }
  else if has("espace", "effet", "reverb", "delay") { icon-space }
  else if has("jeu") { icon-keys }
  else if has("mouvement", "glide", "lfo", "séquence") { icon-motion }
  else { icon-info }
}
