// Synther : commandes de façade dessinées (potards, sélecteurs, inverseurs,
// boutons, écrans). Chaque commande prend `active` : true = réglée par la
// fiche (noir), false = valeur neutre (gris).

#import "theme.typ": ink, muted
#import "draw.typ": clock-arc, hour-angle, polar-point

/// Couleur d'une commande selon qu'elle est réglée par la fiche ou neutre.
#let control-color(active) = if active { ink } else { muted }

// ---------------------------------------------------------------------------
// Libellés
// ---------------------------------------------------------------------------

/// Position d'un potard en heures d'horloge, lisible : 7 = « MIN »,
/// 17 = « MAX », sinon « 10:30 » (décimales : 10.5 = 10:30).
#let clock-label(hour) = {
  if hour <= 7 { return "MIN" }
  if hour >= 17 { return "MAX" }
  let whole-hour = calc.floor(hour)
  let minutes = calc.round((hour - whole-hour) * 60)
  if minutes == 60 {
    whole-hour += 1
    minutes = 0
  }
  let dial-hour = if whole-hour > 12 { whole-hour - 12 } else { whole-hour }
  str(dial-hour) + ":" + (if minutes < 10 { "0" } else { "" }) + str(minutes)
}

/// Nom d'une commande, en capitales comme sur le panneau.
#let control-label(name, active) = text(
  size: 5.6pt, weight: "bold", fill: control-color(active), tracking: 0.02em, upper(name),
)

/// Valeur d'une commande ; `hint` = précision sur une seconde ligne (forme d'onde…).
#let control-value(value, active, hint: none) = {
  let color = control-color(active)
  text(size: 6.6pt, weight: if active { "extrabold" } else { "medium" }, fill: color, value)
  if hint != none {
    linebreak()
    text(size: 5pt, weight: "semibold", fill: color, hint)
  }
}

// ---------------------------------------------------------------------------
// Potards
// ---------------------------------------------------------------------------

/// Dessin d'un potard façon Moog : graduations, arc de valeur (depuis MIN, ou
/// depuis midi si `bipolar`), couronne, disque et index blanc.
/// - `hour` : position en heures d'horloge (7 à 17).
/// - `size` : diamètre de la couronne ; une marge de 2.6 mm l'entoure pour
///   les graduations.
#let knob-glyph(hour, active: true, size: 9mm, bipolar: false) = {
  let color = control-color(active)
  let radius = size / 2
  let tick-margin = 2.6mm
  let center = radius + tick-margin
  box(width: size + 2 * tick-margin, height: size + 2 * tick-margin, {
    // Une graduation par heure, longue aux butées (et à midi si bipolaire).
    for tick in range(7, 18) {
      let angle = hour-angle(tick)
      let long = tick == 7 or tick == 17 or (bipolar and tick == 12)
      place(line(
        start: polar-point(center, radius + 0.5mm, angle),
        end: polar-point(center, radius + (if long { 2.2mm } else { 1.4mm }), angle),
        stroke: (if long { 0.9pt } else { 0.5pt }) + color,
      ))
    }
    if active {
      let origin = if bipolar { 12 } else { 7 }
      if calc.abs(hour - origin) > 0.05 {
        let (start, end) = (calc.min(origin, hour), calc.max(origin, hour))
        place(clock-arc(center, radius + 0.95mm, start, end, 1.6pt + ink))
      }
    }
    place(dx: center - radius, dy: center - radius, circle(radius: radius, stroke: 1.1pt + color, fill: white))
    let cap-radius = 0.74 * radius
    place(dx: center - cap-radius, dy: center - cap-radius, circle(radius: cap-radius, fill: color))
    let angle = hour-angle(hour)
    place(line(
      start: polar-point(center, 0.12 * radius, angle),
      end: polar-point(center, 0.66 * radius, angle),
      stroke: (paint: white, thickness: 1.5pt, cap: "round"),
    ))
  })
}

/// Potard à position d'horloge (Messenger) : dessin, nom, position lisible.
/// - `hint` : précision sous la valeur (forme d'onde obtenue…).
/// - `width` : largeur de la case (pour aligner les colonnes).
#let knob(name, hour, active: true, bipolar: false, hint: none, size: 9mm, width: 16mm) = box(
  width: width,
  align(center, stack(
    spacing: 0.9mm,
    knob-glyph(hour, active: active, size: size, bipolar: bipolar),
    control-label(name, active),
    control-value(clock-label(hour), active, hint: hint),
  )),
)

/// Potard à valeur écran (minilogue XD…) : l'index est placé
/// proportionnellement à `value` entre `min` et `max` (bipolaire : midi = 0,
/// butées = ±`max`).
/// - `label` : texte affiché à la place de la valeur numérique.
/// - `unit` : suffixe de la valeur (« % », « C »…).
#let value-knob(
  name, value, min: 0, max: 1023, active: true, bipolar: false,
  label: none, unit: "", hint: none, size: 9mm, width: 16mm,
) = {
  let is-number = type(value) in (int, float)
  let hour = if not is-number { 12 } else if bipolar {
    12 + 5 * value / max
  } else {
    7 + 10 * (calc.abs(value) - min) / (max - min)
  }
  hour = calc.clamp(hour, 7, 17)
  let shown = if label != none { str(label) } else if is-number {
    (if bipolar and value > 0 { "+" } else { "" }) + str(value) + unit
  } else { str(value) }
  box(width: width, align(center, stack(
    spacing: 0.9mm,
    knob-glyph(hour, active: active, size: size, bipolar: bipolar),
    control-label(name, active),
    control-value(shown, active, hint: hint),
  )))
}

// ---------------------------------------------------------------------------
// Écrans, LED, sélecteurs, inverseurs
// ---------------------------------------------------------------------------

/// Petit écran (MULTI ENGINE, effets…) : lunette puis dalle noire, texte
/// blanc centré ; `sub` = seconde ligne plus petite (sous-type…).
/// `name` vide = pas de libellé sous l'écran.
#let screen(name, value, active: true, width: 20mm, height: 6.4mm, sub: none) = {
  let color = control-color(active)
  box(width: width, align(center, stack(
    spacing: 1mm,
    box(width: width, height: height, radius: 1.3mm, stroke: 0.8pt + color, inset: 0.6mm,
      box(width: 100%, height: 100%, radius: 0.8mm, fill: color, align(center + horizon, {
        // Hauteur du texte = hauteur des capitales (pas de jambage) : centrage optique exact.
        set text(fill: white, top-edge: "cap-height", bottom-edge: "baseline")
        let main = text(size: 5.6pt, weight: "bold", str(value))
        if sub == none { main } else {
          stack(spacing: 0.9mm, main, text(size: 4.6pt, weight: "medium", str(sub)))
        }
      }))),
    if name != "" { control-label(name, active) },
  )))
}

/// Colonne de LED avec leur libellé, celle de `value` allumée.
/// `options` : liste de couples (clé, libellé), comme dans le schéma.
#let led-list(options, value, color, row-gap: 0.75mm, label-height: 1.8mm, text-size: 4.4pt) = grid(
  columns: (1.6mm, auto), column-gutter: 0.6mm, row-gutter: row-gap, align: left + horizon,
  ..options.map(((key, label)) => {
    let lit = key == value
    (
      circle(radius: 0.62mm, fill: if lit { color } else { white }, stroke: 0.5pt + color),
      box(height: label-height, align(horizon, text(
        size: text-size, weight: if lit { "extrabold" } else { "medium" }, fill: color, label,
      ))),
    )
  }).flatten(),
)

/// Rangée de 5 LED d'octave (-2 à +2), celle de `octave` allumée.
#let octave-leds(octave, color, radius: 0.9mm, gap: 0.5mm) = for position in range(-2, 3) {
  box(circle(radius: radius, fill: if position == octave { color } else { white }, stroke: 0.6pt + color))
  h(gap)
}

/// Octave signée pour l'affichage : « +1 », « 0 », « -2 ».
#let signed(number) = if number > 0 { "+" + str(number) } else { str(number) }

/// Fente d'inverseur à levier (minilogue XD) avec le levier en `position`
/// (0 = en haut) sur `steps` crans.
#let lever-slot(position, steps, color) = {
  let height = 9mm
  let lever-height = 3.1mm
  box(width: 3.4mm, height: height, radius: 1.7mm, stroke: 0.8pt + color, place(
    dx: 0.45mm,
    dy: 0.45mm + position * (height - 0.9mm - lever-height) / steps,
    box(width: 2.5mm, height: lever-height, radius: 1.1mm, fill: color),
  ))
}

/// Centre `body` verticalement dans la « zone potard » d'une rangée
/// (`zone` : none = pas de centrage).
#let _in-zone(body, zone) = if zone != none { box(height: zone, align(horizon, body)) } else { body }

/// Sélecteur à flèches du Messenger (OCTAVE, WAVESHAPE, DESTINATION, MODE…) :
/// bouton arrondi avec ▲ / ▼, colonne de LED à droite, nom dessous.
/// - `options` : couples (clé, libellé) ; `value` : clé choisie.
/// - `zone` : hauteur sur laquelle centrer le dessin (alignement de rangée).
#let selector-updown(name, options, value, active: true, width: auto, zone: none) = {
  let color = control-color(active)
  let arrow(up) = polygon(
    stroke: (paint: color, thickness: 0.55pt, join: "round"),
    ..if up { ((0mm, 1.5mm), (0.95mm, 0mm), (1.9mm, 1.5mm)) } else { ((0mm, 0mm), (0.95mm, 1.5mm), (1.9mm, 0mm)) },
  )
  let button = box(width: 4.6mm, height: 9mm, radius: 1.1mm, stroke: 0.8pt + color, inset: 0.55mm,
    box(width: 100%, height: 100%, radius: 0.7mm, stroke: 0.5pt + color,
      align(center + horizon, stack(spacing: 1.5mm, arrow(true), arrow(false)))))
  let leds = led-list(options, value, color)
  box(width: width, align(center, stack(
    spacing: 1.2mm,
    _in-zone(stack(dir: ltr, spacing: 1mm, align(horizon, button), align(horizon, leds)), zone),
    control-label(name, active),
  )))
}

/// Inverseur à levier du minilogue XD (WAVE, DRIVE, TARGET…) : levier à la
/// position choisie (haut / milieu / bas), libellés à droite. Au-delà de
/// 3 options (OCTAVE, VOICE MODE) : levier au centre et colonne de LED.
#let toggle-xd(name, options, value, active: true, width: auto, zone: none) = {
  let color = control-color(active)
  let count = options.len()
  let with-leds = count > 3
  let index = options.position(((key, _)) => key == value)
  if index == none { index = 0 }
  let slot = if with-leds { lever-slot(1, 2, color) } else {
    lever-slot(index, calc.max(count - 1, 1), color)
  }
  let labels = if with-leds {
    led-list(options, value, color, row-gap: 0.6mm, label-height: 1.7mm, text-size: 4.3pt)
  } else {
    box(height: 9mm, grid(
      rows: (1fr,) * count, align: left + horizon,
      ..options.map(((key, label)) => text(
        size: 4.4pt, weight: if key == value { "extrabold" } else { "medium" }, fill: color, label,
      )),
    ))
  }
  box(width: width, align(center, stack(
    spacing: 1.2mm,
    _in-zone(stack(dir: ltr, spacing: 0.9mm, align(horizon, slot), align(horizon, labels)), zone),
    control-label(name, active),
  )))
}

// ---------------------------------------------------------------------------
// Boutons
// ---------------------------------------------------------------------------

/// Bouton poussoir de façade : rectangle aux coins légèrement arrondis, plein
/// = engagé (ON), contour = désengagé (OFF).
/// - `note` : mention entre crochets imprimée au-dessus sur le panneau
///   ([F ENV ASSIGN]…).
#let switch(name, on, active: true, width: 16mm, note: none) = {
  let color = control-color(active)
  box(width: width, align(center, stack(
    spacing: 1mm,
    box(height: 2mm, align(bottom, if note != none { text(size: 4.2pt, weight: "semibold", fill: color, note) })),
    box(
      width: 9.6mm, height: 4.8mm, radius: 1.1mm,
      stroke: 0.9pt + color, fill: if on { color } else { white },
      align(center + horizon, text(
        size: 4.4pt, weight: "bold", fill: if on { white } else { color }, if on { "ON" } else { "OFF" },
      )),
    ),
    control-label(name, active),
  )))
}

/// Bouton poussoir compact avec libellé intégré (destinations LFO 2…).
#let pill(label, on, active: true) = {
  let color = control-color(active)
  box(
    width: 12mm, height: 3.8mm, radius: 1.1mm,
    stroke: 0.9pt + color, fill: if on { color } else { white },
    align(center + horizon, text(size: 4.8pt, weight: "bold", fill: if on { white } else { color }, label)),
  )
}

/// Rangée de commandes côte à côte, centrée.
#let control-row(..controls, gap: 0.6mm) = align(center, stack(
  dir: ltr, spacing: gap, ..controls.pos().map(control => box(control)),
))
