// Synther : façade du Moog Messenger.
// Référence : manuals/moog-messenger-user-manual.pdf (p. 6-7 et 13-22).
// Positions en heures d'horloge (7 = MIN, 12 = midi, 17 = MAX). Toute clé
// absente du YAML prend sa valeur neutre et s'affiche en gris.

#import "style.typ": *

// Valeurs neutres et options : template/schema/messenger.yaml (source
// unique, aussi lue par scripts/build.py pour valider les YAML de sons).
#let schema = yaml("schema/messenger.yaml")
#let defaults = schema-defaults(schema)
#let options = schema.options

/// Forme d'onde obtenue selon la position de WAVESHAPE (manuel p. 10 et 15).
#let wave-hint(hour) = {
  if hour < 10.4 { "FOLD" + (if hour < 8.5 { " +++" } else if hour < 9.5 { " ++" } else { " +" }) }
  else if hour < 11.4 { "TRIANGLE" }
  else if hour < 12.4 { "SAW" }
  else if hour < 13.75 { "SQUARE" }
  else { "PULSE " + (if hour < 15 { "LARGE" } else if hour < 16.3 { "ÉTROITE" } else { "FINE" }) }
}

/// Forme d'onde du sub-oscillateur selon la position de SUB WAVE.
#let sub-hint(hour) = {
  if hour < 8 { "TRIANGLE" } else if hour < 10.2 { "TRI → SQR" } else if hour < 11.6 { "SQUARE" } else { "PULSE" }
}

/// Façade en bande unique, fidèle à l'overview du manuel (p. 6) :
/// LFO 1 | OSCILLATORS | MIXER | FILTER | ENVELOPES, deux rangées de potards
/// puis la rangée de boutons.
#let panel(params) = {
  check-params(params, defaults)
  let read = param-reader(params, defaults)
  // Taille de référence : le potard standard. Largeur de case et « zone
  // potard » (hauteur sur laquelle se centre tout ce qui est dans une
  // rangée) en découlent.
  let knob-size = 9mm
  let zone = knob-size + 2 * 2.6mm
  let cell-width = zone + 0.4mm

  let knob-at(name, section, key, bipolar: false, hint: none) = {
    let (value, active) = read(section, key)
    knob(name, value, active: active, bipolar: bipolar, hint: if hint != none { hint(value) },
      size: knob-size, width: cell-width)
  }
  let selector-at(name, section, key, choices, centered: true) = {
    let (value, active) = read(section, key)
    selector-updown(name, choices, value, active: active, zone: if centered { zone } else { none })
  }
  let switch-at(name, section, key, note: none) = {
    let (value, active) = read(section, key)
    switch(name, value, active: active, width: cell-width, note: note)
  }
  // Grand chiffre de l'oscillateur (1, 2), comme sérigraphié sur le panneau.
  let osc-number(number) = box(height: zone, inset: (x: 0.6mm),
    align(center + horizon, text(size: font-size.osc-number, weight: "extrabold", number)))
  let row-label(label) = box(height: zone,
    align(left + horizon, text(size: font-size.row-label, weight: "extrabold", tracking: 0.04em, label)))
  // CUTOFF : grand potard sur deux rangées.
  let cutoff = {
    let (value, active) = read("filter", "cutoff")
    align(center, stack(spacing: 0.9mm,
      knob-glyph(value, active: active, size: 15mm),
      control-label("Cutoff", active),
      control-value(clock-label(value), active),
    ))
  }

  panel-frame(panel-band((
    (title: "LFO 1", cols: 2, cells: (
      knob-at("LFO 1 Rate", "lfo1", "rate"), selector-at("Waveshape", "lfo1", "wave", options.lfo1-wave),
      knob-at("LFO 1 Depth", "lfo1", "depth", bipolar: true), selector-at("Destination", "lfo1", "dest", options.lfo1-dest),
      switch-at("Sync", "lfo1", "sync"), switch-at("KB Reset", "lfo1", "kb_reset", note: "[LFO 1 ASSIGN]"),
    )),
    (title: "Oscillators", cols: 5, cells: (
      selector-at("Octave", "osc", "oct1", options.octave), osc-number("1"),
      knob-at("Tune", "osc", "tune", bipolar: true), knob-at("Sub Wave", "osc", "sub_wave", hint: sub-hint),
      knob-at("Waveshape", "osc", "wave1", hint: wave-hint),
      selector-at("Octave", "osc", "oct2", options.octave), osc-number("2"),
      knob-at("Osc 2 Freq", "osc", "osc2_freq", bipolar: true), knob-at("Mod Amount", "osc", "mod_amount", bipolar: true),
      knob-at("Waveshape", "osc", "wave2", hint: wave-hint),
      [], [], switch-at("Sync 1→2", "osc", "sync"),
      grid.cell(colspan: 2, selector-at("Mod Destination", "osc", "mod_dest", options.mod-dest, centered: false)),
    )),
    (title: "Mixer", cols: 2, cells: (
      knob-at("Osc 1", "mixer", "osc1"), knob-at("Sub Osc", "mixer", "sub"),
      knob-at("Osc 2", "mixer", "osc2"), knob-at("Noise", "mixer", "noise"),
    )),
    (title: "Filter", cols: 3, cells: (
      knob-at("FB / Ext In", "filter", "fb_ext"), grid.cell(rowspan: 2, align: center + horizon, cutoff),
      knob-at("EG Amount", "filter", "eg_amount", bipolar: true,
        hint: hour => if hour != 12 { bipolar-percent(hour) }),
      knob-at("Osc 2 → Cutoff", "filter", "osc2_cutoff"), knob-at("Resonance", "filter", "resonance"),
      switch-at("KB Tracking", "filter", "kb_tracking", note: "[KB ASSIGN]"),
      selector-at("Mode", "filter", "mode", options.filter-mode, centered: false),
      switch-at("Res Bass", "filter", "res_bass"),
    )),
    (title: "Envelopes", cols: 5, cells: (
      row-label("FILTER\nENVELOPE"), knob-at("Attack", "fenv", "a"), knob-at("Decay", "fenv", "d"),
      knob-at("Sustain", "fenv", "s"), knob-at("Release", "fenv", "r"),
      row-label("AMPLIFIER\nENVELOPE"), knob-at("Attack", "aenv", "a"), knob-at("Decay", "aenv", "d"),
      knob-at("Sustain", "aenv", "s"), knob-at("Release", "aenv", "r"),
      switch-at("Multi-Trig", "env", "multi_trig"), switch-at("F Env Vel", "env", "f_vel"),
      switch-at("F Env Loop", "env", "f_loop", note: "[F ENV ASSIGN]"), switch-at("A Env Vel", "env", "a_vel"),
      switch-at("A Env Loop", "env", "a_loop", note: "[A ENV ASSIGN]"),
    )),
  )))
}

/// Cadre sous la façade : contrôleur main gauche, puis modulations
/// assignées (`modulations`) et réglages SETTINGS (`settings`) de la fiche.
#let performance(params, data) = {
  let read = param-reader(params, defaults)
  let (destinations, destinations-active) = read("perf", "lfo2_dest")
  if type(destinations) == str { destinations = (destinations,) }
  let (wheel, wheel-active) = read("perf", "mod_wheel")
  let (octave, octave-active) = read("perf", "kb_octave")
  let (glide, glide-active) = read("perf", "glide")
  let (rate, rate-active) = read("perf", "lfo2_rate")

  let wheel-glyph = {
    let color = control-color(wheel-active)
    box(width: 12mm, align(center, stack(spacing: 0.9mm,
      box(width: 4.2mm, height: 12mm, stroke: 0.9pt + color, radius: 1pt, clip: true,
        align(bottom, box(width: 100%, height: wheel * 1%, fill: color))),
      control-label("Mod Wheel", wheel-active),
      control-value(str(wheel) + " %", wheel-active),
    )))
  }
  let octave-glyph = box(width: 14mm, align(center, stack(spacing: 1mm,
    box(height: 3.6mm, align(horizon, octave-leds(octave, control-color(octave-active)))),
    control-label("KB Octave", octave-active),
    control-value(signed(octave), octave-active),
  )))
  let destination-buttons = stack(spacing: 1.1mm,
    ..options.lfo2-dest.map(((key, label)) => pill(label, key in destinations, active: destinations-active)),
  )

  let modulations = field(data, "modulations", ())
  let settings = field(data, "settings", ())
  stack(spacing: 1.6mm,
    aside-section("Left-Hand Controller", {
      v(0.6mm)
      control-row(
        knob("Glide", glide, active: glide-active),
        knob("LFO 2 Rate", rate, active: rate-active),
        box(width: 15mm, align(center, stack(spacing: 1mm, destination-buttons, control-label("LFO 2 Dest", destinations-active)))),
        wheel-glyph,
        octave-glyph,
      )
    }),
    aside-section("Modulations & Settings", {
      set text(size: font-size.settings)
      if modulations.len() == 0 and settings.len() == 0 {
        align(center + horizon, box(height: 18mm, align(horizon,
          text(fill: muted, weight: "semibold", "AUCUNE MODULATION ASSIGNÉE"))))
      } else {
        let rows = ()
        for modulation in modulations {
          rows.push(text(weight: "extrabold", upper(modulation.source)))
          rows.push([→ #text(weight: "bold", upper(modulation.dest))])
          rows.push(text(weight: "extrabold", str(modulation.at("depth", default: ""))))
        }
        for setting in settings {
          rows += (text(weight: "extrabold", upper(setting.name)), md(setting.value), [])
        }
        settings-table((auto, 1fr, auto), rows)
      }
    }),
  )
}

/// Fiche complète du Messenger (appelée par sheet.typ).
#let render-sheet(data) = {
  let params = field(data, "params", (:))
  let value = value-reader(params, defaults)
  let normalized(hour) = (hour - 7) / 10
  let envelope(section, title) = {
    let (attack, decay, sustain, release) = ("a", "d", "s", "r").map(key => value(section, key))
    env-entry(title, normalized(attack), normalized(decay), normalized(sustain), normalized(release),
      sub: ("A", "D", "S", "R").zip((attack, decay, sustain, release))
        .map(((letter, hour)) => letter + " " + clock-label(hour)).join(" · "))
  }
  let filter-envelope = envelope("fenv", "Filter env")
  // EG AMOUNT à midi : l'enveloppe de filtre n'agit pas (courbe grise, hors échelle).
  if value("filter", "eg_amount") == 12 {
    filter-envelope.sub = "sans effet ici : EG AMOUNT à midi"
    filter-envelope.inactive = true
  }
  sheet(schema.name, data,
    panel: panel(params),
    aside: performance(params, data),
    envs: (filter-envelope, envelope("aenv", "Amp env")),
    sequence-spec: schema.extra.sequence,
  )
}
