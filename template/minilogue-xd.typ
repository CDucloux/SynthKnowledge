// Synther : schéma de façade du Korg minilogue XD.
// Référence : manuals/minilogue-xd-user-manual.pdf (p. 5 façade, p. 15-24 paramètres, p. 32-36 PROGRAM EDIT, p. 53-54 effets).
// Valeurs = valeurs écran du manuel (0-1023 pour la plupart des potards).
// Toute clé absente du YAML prend la valeur neutre ci-dessous et s'affiche en gris.

#import "style.typ": *

// Valeurs neutres et options : template/schema/minilogue-xd.yaml (source unique,
// aussi lue par scripts/build.py pour valider les YAML de sons).
#let schema = yaml("schema/minilogue-xd.yaml")
#let defaults = schema-defaults(schema)
#let options = schema.options

// Affichage de VOICE MODE DEPTH selon le mode (manuel p. 15-16).
#let depth-display(mode, v, lbl) = {
  if lbl != "" and lbl != none { return str(lbl) }
  if mode == "poly" { if v == 0 { "POLY" } else { "DUO " + str(v) } }
  else if mode == "unison" { str(calc.round(v / 1023 * 50)) + " C" }
  else { str(v) }
}

// ---------------------------------------------------------------------------
// Façade en bande unique, fidèle au schéma du panneau (manuel p. 5) :
// MASTER / VOICE MODE | VCO 1 · VCO 2 · MULTI ENGINE | MIXER | FILTER |
// AMP EG · EG · LFO | EFFECTS. Trois rangées alignées, inverseurs à levier.
// ---------------------------------------------------------------------------
#let panel(params) = {
  check-params(params, defaults)
  let g = param-reader(params, defaults)
  // Taille de référence : le potard. Largeur de case et « zone potard » en découlent.
  let ks = 7.6mm
  let zone = ks + 2 * 2.6mm
  let kw = zone + 0.2mm
  let N(name, sec, k, min: 0, max: 1023, bipolar: false, unit: "", label: none, hint: none) = {
    let (v, a) = g(sec, k)
    knob-num(name, v, min: min, max: max, active: a, bipolar: bipolar, unit: unit, label: label, hint: hint, size: ks, width: kw)
  }
  let T(name, sec, k, opts) = {
    let (v, a) = g(sec, k)
    toggle-xd(name, opts, v, active: a, zone: zone)
  }
  let rlabel(t) = box(height: zone, align(left + horizon, text(size: 5.2pt, weight: "extrabold", tracking: 0.04em, t)))

  // VOICE (pas de titre sur le panneau)
  let (mode, ma) = g("voice", "mode")
  let (d, da) = g("voice", "depth")
  let (lbl, la) = g("voice", "depth_label")
  let (oct, oa) = g("voice", "octave")
  let (tempo, tma) = g("voice", "tempo")
  let oct-glyph = {
    let col = if oa { ink } else { muted }
    align(center, stack(spacing: 1mm,
      box(height: zone, align(horizon, box(for i in range(-2, 3) {
        box(circle(radius: 0.85mm, fill: if i == oct { col } else { white }, stroke: 0.6pt + col))
        h(0.35mm)
      }))),
      ctl-label("Octave", oa),
      ctl-value(if oct > 0 { "+" + str(oct) } else { str(oct) }, oa),
    ))
  }
  // SYNC et RING : deux leviers ON / OFF côte à côte, comme sur le panneau.
  let lever(name, k) = {
    let (v, a) = g("vco2", k)
    let col = if a { ink } else { muted }
    align(center, stack(spacing: 1.2mm,
      box(height: zone, align(horizon, box(width: 3.4mm, height: 9mm, radius: 1.7mm, stroke: 0.8pt + col,
        place(dx: 0.45mm, dy: if v { 0.45mm } else { 9mm - 0.45mm - 3.1mm }, box(width: 2.5mm, height: 3.1mm, radius: 1.1mm, fill: col))))),
      ctl-label(name, a),
      ctl-value(if v { "ON" } else { "OFF" }, a),
    ))
  }
  let (t, ta) = g("multi", "type")
  let (rl, rla) = g("lfo", "rate_label")
  let (int, ia) = g("lfo", "int")
  // Un effet = titre avec témoin ON / OFF et écran du type, puis TIME et DEPTH.
  let fx-w = 19mm
  let fx(title, sec, show-sub) = {
    let (on, oa) = g(sec, "on")
    let (t, ta) = g(sec, "type")
    let st = if show-sub { g(sec, "subtype").at(0) } else { none }
    let act = oa or ta
    let col = if act { ink } else { muted }
    (
      box(width: fx-w, height: zone, align(center + horizon, stack(spacing: 1.3mm,
        box(width: fx-w, {
          box(baseline: 0.15mm, circle(radius: 0.8mm, fill: if on { col } else { white }, stroke: 0.6pt + col))
          h(1mm)
          text(size: 5.4pt, weight: "extrabold", tracking: 0.06em, fill: col, title)
          h(1fr)
          text(size: 4.8pt, weight: "bold", fill: col, if on { "ON" } else { "OFF" })
        }),
        screen("", t, active: act, width: fx-w, height: if show-sub { 7.4mm } else { 6.4mm }, sub: if show-sub { st }),
      ))),
      N("Time", sec, "time"),
      N("Depth", sec, "depth", max: 100, unit: " %"),
    )
  }

  panel-frame(panel-band((
    (title: "Voice", cols: 2, cells: (
      knob-num("Tempo", tempo, min: 56, max: 240, active: tma, label: str(tempo) + " BPM", size: ks, width: kw),
      N("Portamento", "voice", "portamento", max: 127),
      oct-glyph,
      knob-num("V.M. Depth", d, active: da or la, label: depth-display(mode, d, lbl), size: ks, width: kw + 2.5mm),
      [], T("Voice Mode", "voice", "mode", options.voice-mode),
    )),
    (title: "VCO 1 · VCO 2 · Multi Engine", cols: 6, cells: (
      rlabel("VCO 1"), T("Wave", "vco1", "wave", options.wave), T("Octave", "vco1", "octave", options.octave),
      N("Pitch", "vco1", "pitch", max: 1200, bipolar: true, unit: " C"), N("Shape", "vco1", "shape"),
      stack(dir: ltr, spacing: 1.6mm, lever("Sync", "sync"), lever("Ring", "ring")),
      rlabel("VCO 2"), T("Wave", "vco2", "wave", options.wave), T("Octave", "vco2", "octave", options.octave),
      N("Pitch", "vco2", "pitch", max: 1200, bipolar: true, unit: " C"), N("Shape", "vco2", "shape"),
      N("Cross Mod", "vco2", "cross_mod"),
      rlabel("MULTI\nENGINE"), T("Engine", "multi", "engine", options.engine),
      grid.cell(colspan: 2, box(height: zone, align(horizon, screen("Type", t, active: ta, width: 22mm)))),
      N("Shape", "multi", "shape"), [],
    )),
    (title: "Mixer", cols: 1, cells: (
      N("VCO 1", "mixer", "vco1"), N("VCO 2", "mixer", "vco2"), N("Multi", "mixer", "multi"),
    )),
    (title: "Filter", cols: 2, cells: (
      grid.cell(colspan: 2, N("Cutoff", "filter", "cutoff")),
      grid.cell(colspan: 2, N("Resonance", "filter", "resonance")),
      T("Drive", "filter", "drive", options.three), T("Key Track", "filter", "keytrack", options.three),
    )),
    (title: "Amp EG · EG · LFO", cols: 6, cells: (
      rlabel("AMP\nEG"), N("Attack", "amp_eg", "a"), N("Decay", "amp_eg", "d"), N("Sustain", "amp_eg", "s"), N("Release", "amp_eg", "r"), [],
      rlabel("EG"), N("Attack", "eg", "a"), N("Decay", "eg", "d"), N("EG Int", "eg", "int", max: 100, bipolar: true, unit: " %"),
      T("Target", "eg", "target", options.eg-target), [],
      rlabel("LFO"), T("Wave", "lfo", "wave", options.wave), T("Mode", "lfo", "mode", options.lfo-mode),
      N("Rate", "lfo", "rate", label: if rl != "" { rl } else { none }),
      knob-num("Int", int, max: 511, active: ia, hint: if int < 0 { "INVERSÉ" }, size: ks, width: kw),
      T("Target", "lfo", "target", options.lfo-target),
    )),
    (title: "Effects", cols: 3, cells: (
      ..fx("MOD FX", "mod_fx", true), ..fx("REVERB", "reverb", false), ..fx("DELAY", "delay", false),
    )),
  )))
}

#let program-edit(data) = {
  let settings = data.at("settings", default: ())
  if settings == none { settings = () }
  block(width: 100%, stroke: 0.8pt + ink, inset: (x: 2mm, top: 1.2mm, bottom: 1.6mm), stack(spacing: 1mm,
    ov-title("Program Edit"),
    {
      set text(size: 6.4pt)
      if settings.len() == 0 {
        align(center, box(height: 12mm, align(horizon, text(fill: muted, weight: "semibold", "AUCUN RÉGLAGE PROGRAM EDIT"))))
      } else {
        let rows = ()
        for s in settings {
          rows.push(text(weight: "extrabold", upper(s.name)))
          rows.push(md(s.value))
        }
        table(
          columns: (auto, 1fr), stroke: none, inset: (x: 1mm, y: 0.9mm),
          table.hline(stroke: 0.5pt), ..rows, table.hline(stroke: 0.5pt),
        )
      }
    },
  ))
}

#let fiche(data) = {
  let params = data.at("params", default: (:))
  if params == none { params = (:) }
  let val(sec, k) = param-reader(params, defaults)(sec, k).at(0)
  let nrm(v) = v / 1023
  let ia = val("eg", "int")
  sheet("Korg minilogue XD", data,
    panel: panel(params),
    aside: program-edit(data),
    envs: (
      env-entry("Amp EG", nrm(val("amp_eg", "a")), nrm(val("amp_eg", "d")), nrm(val("amp_eg", "s")), nrm(val("amp_eg", "r")),
        sub: "A " + str(val("amp_eg", "a")) + " · D " + str(val("amp_eg", "d")) + " · S " + str(val("amp_eg", "s")) + " · R " + str(val("amp_eg", "r"))),
      env-entry("EG → " + upper(val("eg", "target")), nrm(val("eg", "a")), nrm(val("eg", "d")), 0, 0, sustain: false,
        sub: "A " + str(val("eg", "a")) + " · D " + str(val("eg", "d")) + " · INT " + (if ia > 0 { "+" } else { "" }) + str(ia) + " %"),
    ),
    seq-spec: schema.extra.sequence,
  )
}
