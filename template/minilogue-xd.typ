// Synther : façade du Korg minilogue XD.
// Référence : manuals/minilogue-xd-user-manual.pdf (p. 5 façade, p. 15-24
// paramètres, p. 32-36 PROGRAM EDIT, p. 53-54 effets).
// Valeurs = valeurs écran du manuel (0-1023 pour la plupart des potards).
// Toute clé absente du YAML prend sa valeur neutre et s'affiche en gris.

#import "style.typ": *

// Valeurs neutres et options : template/schema/minilogue-xd.yaml (source
// unique, aussi lue par scripts/build.py pour valider les YAML de sons).
#let schema = yaml("schema/minilogue-xd.yaml")
#let defaults = schema-defaults(schema)
#let options = schema.options

/// Affichage de VOICE MODE DEPTH selon le mode (manuel p. 15-16) ;
/// `label` (texte libre du YAML) l'emporte s'il est renseigné.
#let depth-display(mode, depth, label) = {
  if label != "" and label != none { return str(label) }
  if mode == "poly" { if depth == 0 { "POLY" } else { "DUO " + str(depth) } }
  else if mode == "unison" { str(calc.round(depth / 1023 * 50)) + " C" }
  else { str(depth) }
}

/// Façade en bande unique, fidèle au schéma du panneau (manuel p. 5) :
/// VOICE | VCO 1 · VCO 2 · MULTI ENGINE | MIXER | FILTER | AMP EG · EG · LFO
/// | EFFECTS, trois rangées alignées, inverseurs à levier.
#let panel(params) = {
  check-params(params, defaults)
  let read = param-reader(params, defaults)
  // Taille de référence : le potard. Largeur de case et « zone potard » en découlent.
  let knob-size = 7.6mm
  let zone = knob-size + 2 * 2.6mm
  let cell-width = zone + 0.2mm

  let knob-at(name, section, key, min: 0, max: 1023, bipolar: false, unit: "", label: none, hint: none) = {
    let (value, active) = read(section, key)
    value-knob(name, value, min: min, max: max, active: active, bipolar: bipolar, unit: unit,
      label: label, hint: hint, size: knob-size, width: cell-width)
  }
  let toggle-at(name, section, key, choices) = {
    let (value, active) = read(section, key)
    toggle-xd(name, choices, value, active: active, zone: zone)
  }
  let row-label(label) = box(height: zone,
    align(left + horizon, text(size: 5.2pt, weight: "extrabold", tracking: 0.04em, label)))

  // VOICE (pas de titre sur le panneau).
  let (mode, _) = read("voice", "mode")
  let (depth, depth-active) = read("voice", "depth")
  let (depth-label, depth-label-active) = read("voice", "depth_label")
  let (octave, octave-active) = read("voice", "octave")
  let (tempo, tempo-active) = read("voice", "tempo")
  let octave-glyph = {
    let color = control-color(octave-active)
    align(center, stack(spacing: 1mm,
      box(height: zone, align(horizon, box(octave-leds(octave, color, radius: 0.85mm, gap: 0.35mm)))),
      control-label("Octave", octave-active),
      control-value(signed(octave), octave-active),
    ))
  }
  // SYNC et RING : deux leviers ON / OFF côte à côte, comme sur le panneau.
  let on-off-lever(name, key) = {
    let (on, active) = read("vco2", key)
    align(center, stack(spacing: 1.2mm,
      box(height: zone, align(horizon, lever-slot(if on { 0 } else { 1 }, 1, control-color(active)))),
      control-label(name, active),
      control-value(if on { "ON" } else { "OFF" }, active),
    ))
  }
  let (engine-type, engine-type-active) = read("multi", "type")
  let (rate-label, _) = read("lfo", "rate_label")
  let (lfo-int, lfo-int-active) = read("lfo", "int")

  // Un effet = titre avec témoin ON / OFF et écran du type, puis TIME et DEPTH.
  let effect-width = 19mm
  let effect(title, section, with-subtype) = {
    let (on, on-active) = read(section, "on")
    let (effect-type, type-active) = read(section, "type")
    let subtype = if with-subtype { read(section, "subtype").first() } else { none }
    let active = on-active or type-active
    let color = control-color(active)
    let header = box(width: effect-width, {
      box(baseline: 0.15mm, circle(radius: 0.8mm, fill: if on { color } else { white }, stroke: 0.6pt + color))
      h(1mm)
      text(size: 5.4pt, weight: "extrabold", tracking: 0.06em, fill: color, title)
      h(1fr)
      text(size: 4.8pt, weight: "bold", fill: color, if on { "ON" } else { "OFF" })
    })
    let display = screen("", effect-type, active: active, width: effect-width,
      height: if with-subtype { 7.4mm } else { 6.4mm }, sub: subtype)
    (
      box(width: effect-width, height: zone, align(center + horizon, stack(spacing: 1.3mm, header, display))),
      knob-at("Time", section, "time"),
      knob-at("Depth", section, "depth", max: 100, unit: " %"),
    )
  }

  panel-frame(panel-band((
    (title: "Voice", cols: 2, cells: (
      value-knob("Tempo", tempo, min: 56, max: 240, active: tempo-active, label: str(tempo) + " BPM",
        size: knob-size, width: cell-width),
      knob-at("Portamento", "voice", "portamento", max: 127),
      octave-glyph,
      value-knob("V.M. Depth", depth, active: depth-active or depth-label-active,
        label: depth-display(mode, depth, depth-label), size: knob-size, width: cell-width + 2.5mm),
      [], toggle-at("Voice Mode", "voice", "mode", options.voice-mode),
    )),
    (title: "VCO 1 · VCO 2 · Multi Engine", cols: 6, cells: (
      row-label("VCO 1"), toggle-at("Wave", "vco1", "wave", options.wave), toggle-at("Octave", "vco1", "octave", options.octave),
      knob-at("Pitch", "vco1", "pitch", max: 1200, bipolar: true, unit: " C"), knob-at("Shape", "vco1", "shape"),
      stack(dir: ltr, spacing: 1.6mm, on-off-lever("Sync", "sync"), on-off-lever("Ring", "ring")),
      row-label("VCO 2"), toggle-at("Wave", "vco2", "wave", options.wave), toggle-at("Octave", "vco2", "octave", options.octave),
      knob-at("Pitch", "vco2", "pitch", max: 1200, bipolar: true, unit: " C"), knob-at("Shape", "vco2", "shape"),
      knob-at("Cross Mod", "vco2", "cross_mod"),
      row-label("MULTI\nENGINE"), toggle-at("Engine", "multi", "engine", options.engine),
      grid.cell(colspan: 2, box(height: zone, align(horizon,
        screen("Type", engine-type, active: engine-type-active, width: 22mm)))),
      knob-at("Shape", "multi", "shape"), [],
    )),
    (title: "Mixer", cols: 1, cells: (
      knob-at("VCO 1", "mixer", "vco1"), knob-at("VCO 2", "mixer", "vco2"), knob-at("Multi", "mixer", "multi"),
    )),
    (title: "Filter", cols: 2, cells: (
      grid.cell(colspan: 2, knob-at("Cutoff", "filter", "cutoff")),
      grid.cell(colspan: 2, knob-at("Resonance", "filter", "resonance")),
      toggle-at("Drive", "filter", "drive", options.three), toggle-at("Key Track", "filter", "keytrack", options.three),
    )),
    (title: "Amp EG · EG · LFO", cols: 6, cells: (
      row-label("AMP\nEG"), knob-at("Attack", "amp_eg", "a"), knob-at("Decay", "amp_eg", "d"),
      knob-at("Sustain", "amp_eg", "s"), knob-at("Release", "amp_eg", "r"), [],
      row-label("EG"), knob-at("Attack", "eg", "a"), knob-at("Decay", "eg", "d"),
      knob-at("EG Int", "eg", "int", max: 100, bipolar: true, unit: " %"),
      toggle-at("Target", "eg", "target", options.eg-target), [],
      row-label("LFO"), toggle-at("Wave", "lfo", "wave", options.wave), toggle-at("Mode", "lfo", "mode", options.lfo-mode),
      knob-at("Rate", "lfo", "rate", label: if rate-label != "" { rate-label } else { none }),
      value-knob("Int", lfo-int, max: 511, active: lfo-int-active, hint: if lfo-int < 0 { "INVERSÉ" },
        size: knob-size, width: cell-width),
      toggle-at("Target", "lfo", "target", options.lfo-target),
    )),
    (title: "Effects", cols: 3, cells: (
      ..effect("MOD FX", "mod_fx", true), ..effect("REVERB", "reverb", false), ..effect("DELAY", "delay", false),
    )),
  )))
}

/// Cadre PROGRAM EDIT sous la façade : réglages `settings` de la fiche.
#let program-edit(data) = {
  let settings = field(data, "settings", ())
  aside-section("Program Edit", {
    set text(size: 6.4pt)
    if settings.len() == 0 {
      align(center, box(height: 12mm, align(horizon,
        text(fill: muted, weight: "semibold", "AUCUN RÉGLAGE PROGRAM EDIT"))))
    } else {
      settings-table((auto, 1fr), settings.map(setting => (
        text(weight: "extrabold", upper(setting.name)), md(setting.value),
      )).flatten())
    }
  })
}

/// Fiche complète du minilogue XD (appelée par sheet.typ).
#let render-sheet(data) = {
  let params = field(data, "params", (:))
  let value = value-reader(params, defaults)
  let normalized(screen-value) = screen-value / 1023
  let phases(section, keys) = keys.map(key => value(section, key))
  let summary(letters, values) = letters.zip(values).map(((letter, number)) => letter + " " + str(number)).join(" · ")

  let amp = phases("amp_eg", ("a", "d", "s", "r"))
  let (eg-attack, eg-decay) = phases("eg", ("a", "d"))
  let eg-int = value("eg", "int")
  sheet("Korg minilogue XD", data,
    panel: panel(params),
    aside: program-edit(data),
    envs: (
      env-entry("Amp EG", ..amp.map(normalized), sub: summary(("A", "D", "S", "R"), amp)),
      env-entry("EG → " + upper(value("eg", "target")), normalized(eg-attack), normalized(eg-decay), 0, 0,
        has-sustain: false,
        sub: summary(("A", "D"), (eg-attack, eg-decay)) + " · INT " + (if eg-int > 0 { "+" } else { "" }) + str(eg-int) + " %"),
    ),
    sequence-spec: schema.extra.sequence,
  )
}
