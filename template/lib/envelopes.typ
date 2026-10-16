// Synther : courbes d'enveloppe de la page 2, dessinées d'après les réglages.
// Temps et niveaux sont normalisés de 0 à 1 (position du potard) : l'allure
// est juste, les durées ne sont pas calibrées en secondes.

#import "theme.typ": ink, muted, soft
#import "draw.typ": polyline

/// Entrée de courbe préparée par une façade.
/// - `attack`, `decay`, `release` : temps normalisés 0-1 ; `sustain` :
///   niveau 0-1.
/// - `sub` : détail affiché à côté du titre (valeurs des potards).
/// - `has-sustain` : false = enveloppe AD (pas de palier ni de release).
/// - `inactive` : enveloppe sans effet sur le son (courbe grise, hors échelle).
#let env-entry(title, attack, decay, sustain, release, sub: none, has-sustain: true, inactive: false) = (
  title: title, attack: attack, decay: decay, sustain: sustain, release: release,
  sub: sub, has-sustain: has-sustain, inactive: inactive,
)

/// Durée d'une phase en « unités » : jamais nulle, pour que la lettre de la
/// phase reste lisible.
#let _phase-units(time) = 0.04 + 0.96 * calc.clamp(time, 0, 1)

/// Palier de sustain dessiné, en unités.
#let _hold-units = 0.55

/// Durée d'une enveloppe en unités (A + D [+ palier + R]) : sert à mettre
/// plusieurs courbes à la même échelle, la plus longue remplissant la largeur.
#let env-units(entry) = (
  _phase-units(entry.attack) + _phase-units(entry.decay)
    + (if entry.has-sustain { _hold-units + _phase-units(entry.release) } else { 0 })
)

/// Courbe d'une enveloppe : aire grise, tracé, repères pointillés aux
/// changements de phase, lettres A D S R centrées dans leur phase.
/// - `span` : unités représentées par toute la largeur (none = cette courbe
///   seule remplit la largeur).
/// - `muted-curve` : tracé gris (enveloppe sans effet).
#let env-plot(entry, width: 84mm, height: 24mm, span: none, muted-curve: false) = {
  let span = if span == none { env-units(entry) } else { span }
  let unit-width = width * 0.97 / span
  let has-sustain = entry.has-sustain
  let attack-width = _phase-units(entry.attack) * unit-width
  let decay-width = _phase-units(entry.decay) * unit-width
  let hold-width = if has-sustain { unit-width * _hold-units } else { 0mm }
  let release-width = if has-sustain { _phase-units(entry.release) * unit-width } else { 0mm }
  let sustain = if has-sustain { calc.clamp(entry.sustain, 0, 1) } else { 0 }
  let y-of(level) = height * (1 - level)

  // Décroissances exponentielles approchées en 16 segments.
  let segments = 16
  let decay-end = attack-width + decay-width
  let hold-end = decay-end + hold-width
  let release-end = hold-end + release-width
  let points = ((0mm, y-of(0)), (attack-width, y-of(1)))
  for step in range(1, segments + 1) {
    let level = sustain + (1 - sustain) * calc.exp(-4.5 * step / segments)
    points.push((attack-width + decay-width * step / segments, y-of(if step == segments { sustain } else { level })))
  }
  if has-sustain {
    points.push((hold-end, y-of(sustain)))
    for step in range(1, segments + 1) {
      let level = sustain * calc.exp(-4.5 * step / segments)
      points.push((hold-end + release-width * step / segments, y-of(if step == segments { 0 } else { level })))
    }
  }

  box(width: width, {
    text(size: 6.4pt, weight: "extrabold", tracking: 0.08em, upper(entry.title))
    if entry.sub != none { h(1.5mm); text(size: 6pt, fill: luma(80), entry.sub) }
    v(0.6mm)
    box(width: width, height: height + 3mm, {
      place(line(start: (0mm, height), end: (width, height), stroke: 0.5pt + muted))
      place(polyline(points + ((release-end, height),), stroke: none, fill: soft, closed: true))
      // Repères pointillés gris aux changements de phase (début de D, de S, de R).
      let marks = if has-sustain { (attack-width, decay-end, hold-end) } else { (attack-width,) }
      for mark-x in marks {
        place(line(start: (mark-x, 0mm), end: (mark-x, height), stroke: (paint: luma(150), thickness: 0.5pt, dash: (1.2pt, 1.4pt))))
      }
      place(polyline(points, stroke: (paint: if muted-curve { muted } else { ink }, thickness: 1.2pt, join: "round")))
      // Lettres centrées dans leur phase ; décalées si deux phases sont trop étroites.
      let phases = if has-sustain {
        ((0mm, attack-width, "A"), (attack-width, decay-end, "D"), (decay-end, hold-end, "S"), (hold-end, release-end, "R"))
      } else {
        ((0mm, attack-width, "A"), (attack-width, decay-end, "D"))
      }
      let min-letter-gap = 3mm
      let previous-x = -10mm
      for (start, end, letter) in phases {
        let letter-x = calc.max((start + end) / 2, previous-x + min-letter-gap, 0.9mm)
        previous-x = letter-x
        place(dx: letter-x - 1.5mm, dy: height + 0.6mm,
          box(width: 3mm, align(center, text(size: 6pt, weight: "bold", fill: luma(70), letter))))
      }
    })
  })
}
