// SynthKnowledge : schéma de façade du Korg minilogue XD.
// Référence : manuals/minilogue-xd-user-manual.pdf (p. 5 façade, p. 15-24 paramètres, p. 32-36 PROGRAM EDIT, p. 53-54 effets).
// Valeurs = valeurs écran du manuel (0-1023 pour la plupart des potards).
// Toute clé absente du YAML prend la valeur neutre ci-dessous et s'affiche en gris.

#import "style.typ": *

#let defaults = (
  voice: (mode: "poly", depth: 0, depth_label: "", portamento: 0, octave: 0, tempo: 120),
  vco1: (wave: "saw", octave: 8, pitch: 0, shape: 0),
  vco2: (wave: "saw", octave: 8, pitch: 0, shape: 0, sync: false, ring: false, cross_mod: 0),
  multi: (engine: "noise", type: "High", shape: 0),
  mixer: (vco1: 1023, vco2: 0, multi: 0),
  filter: (cutoff: 1023, resonance: 0, drive: 0, keytrack: 0),
  amp_eg: (a: 0, d: 512, s: 1023, r: 0),
  eg: (a: 0, d: 512, int: 0, target: "cutoff"),
  lfo: (wave: "tri", mode: "normal", rate: 512, rate_label: "", int: 0, target: "pitch"),
  mod_fx: (on: false, type: "Chorus", subtype: "Stereo", time: 512, depth: 50),
  reverb: (on: false, type: "Hall", time: 512, depth: 50),
  delay: (on: false, type: "Stereo", time: 512, depth: 50),
)

#let options = (
  voice-mode: (("poly", "POLY"), ("unison", "UNISON"), ("chord", "CHORD"), ("arp", "ARP/LATCH")),
  wave: (("sqr", "SQR"), ("tri", "TRI"), ("saw", "SAW")),
  octave: ((16, "16'"), (8, "8'"), (4, "4'"), (2, "2'")),
  engine: (("noise", "NOISE"), ("vpm", "VPM"), ("usr", "USR")),
  three: ((100, "100 %"), (50, "50 %"), (0, "0 %")),
  eg-target: (("pitch", "PITCH"), ("pitch2", "PITCH 2"), ("cutoff", "CUTOFF")),
  lfo-mode: (("one_shot", "1-SHOT"), ("normal", "NORMAL"), ("bpm", "BPM")),
  lfo-target: (("cutoff", "CUTOFF"), ("shape", "SHAPE"), ("pitch", "PITCH")),
)

#let _check(params) = {
  for (sec, vals) in params {
    assert(sec in defaults, message: "Section inconnue « " + sec + " », attendu : " + defaults.keys().join(", "))
    for (k, _) in vals {
      assert(k in defaults.at(sec), message: "Paramètre inconnu « " + sec + "." + k + " », attendu : " + defaults.at(sec).keys().join(", "))
    }
  }
}

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
#let ov-title(t) = align(center + top, text(size: 7.2pt, weight: "extrabold", tracking: 0.16em, upper(t)))

#let panel(params) = {
  _check(params)
  let g(sec, k) = {
    let s = params.at(sec, default: (:))
    if s == none { s = (:) }
    if k in s { (s.at(k), true) } else { (defaults.at(sec).at(k), false) }
  }
  let ks = 7.6mm
  let kw = 12.8mm
  let zone = ks + 2 * 2.6mm
  let N(name, sec, k, min: 0, max: 1023, bipolar: false, unit: "", label: none, hint: none) = {
    let (v, a) = g(sec, k)
    knob-num(name, v, min: min, max: max, active: a, bipolar: bipolar, unit: unit, label: label, hint: hint, size: ks, width: kw)
  }
  let T(name, sec, k, opts, width: 12.8mm) = {
    let (v, a) = g(sec, k)
    toggle-xd(name, opts, v, active: a, width: width, zone: zone)
  }
  let B(name, sec, k) = {
    let (v, a) = g(sec, k)
    switch(name, v, active: a, width: kw)
  }
  let rows = (7mm, 21mm, 21mm, 21mm)
  let sec(title, cols, ..cells) = grid(
    columns: cols, rows: rows, align: center + top, column-gutter: 0.3mm,
    grid.cell(colspan: cols.len(), ov-title(title)),
    ..cells.pos(),
  )
  let rlabel(t) = box(height: zone, align(left + horizon, text(size: 5.2pt, weight: "extrabold", tracking: 0.04em, t)))

  // MASTER / VOICE MODE (sans titre sur le panneau)
  let (mode, ma) = g("voice", "mode")
  let (d, da) = g("voice", "depth")
  let (lbl, la) = g("voice", "depth_label")
  let (oct, oa) = g("voice", "octave")
  let (tempo, tma) = g("voice", "tempo")
  let oct-glyph = {
    let col = if oa { ink } else { muted }
    box(width: kw, align(center, stack(spacing: 1mm,
      box(height: zone, align(horizon, box(for i in range(-2, 3) {
        box(circle(radius: 0.85mm, fill: if i == oct { col } else { white }, stroke: 0.6pt + col))
        h(0.35mm)
      }))),
      ctl-label("Octave", oa),
      ctl-value(if oct > 0 { "+" + str(oct) } else { str(oct) }, oa),
    )))
  }
  let master = sec("Voice", (kw, 15.5mm),
    knob-num("Tempo", tempo, min: 56, max: 240, active: tma, label: str(tempo) + " BPM", size: ks, width: kw),
    N("Portamento", "voice", "portamento", max: 127),
    oct-glyph,
    knob-num("V.M. Depth", d, active: da or la, label: depth-display(mode, d, lbl), size: ks, width: 15.5mm),
    [],
    T("Voice Mode", "voice", "mode", options.voice-mode, width: 15.5mm),
  )

  // VCO 1 · VCO 2 · MULTI ENGINE
  let (t, ta) = g("multi", "type")
  let vco = sec("VCO 1 · VCO 2 · Multi Engine", (7.5mm, 11mm, 13mm, kw, kw, 13mm),
    rlabel("VCO 1"), T("Wave", "vco1", "wave", options.wave, width: 11mm), T("Octave", "vco1", "octave", options.octave, width: 13mm),
    N("Pitch", "vco1", "pitch", max: 1200, bipolar: true, unit: " C"), N("Shape", "vco1", "shape"),
    {
      // SYNC et RING : deux leviers ON / OFF côte à côte, comme sur le panneau.
      let lever(name, k) = {
        let (v, a) = g("vco2", k)
        let col = if a { ink } else { muted }
        box(width: 6.4mm, align(center, stack(spacing: 1.2mm,
          box(height: zone, align(horizon, box(width: 3.4mm, height: 9mm, radius: 1.7mm, stroke: 0.8pt + col,
            place(dx: 0.45mm, dy: if v { 0.45mm } else { 9mm - 0.45mm - 3.1mm }, box(width: 2.5mm, height: 3.1mm, radius: 1.1mm, fill: col))))),
          ctl-label(name, a),
          ctl-value(if v { "ON" } else { "OFF" }, a),
        )))
      }
      stack(dir: ltr, spacing: 0.2mm, lever("Sync", "sync"), lever("Ring", "ring"))
    },
    rlabel("VCO 2"), T("Wave", "vco2", "wave", options.wave, width: 11mm), T("Octave", "vco2", "octave", options.octave, width: 13mm),
    N("Pitch", "vco2", "pitch", max: 1200, bipolar: true, unit: " C"), N("Shape", "vco2", "shape"),
    N("Cross Mod", "vco2", "cross_mod"),
    rlabel("MULTI\nENGINE"), T("Engine", "multi", "engine", options.engine, width: 11mm),
    grid.cell(colspan: 2, box(height: zone, align(horizon, screen("Type", t, active: ta, width: 22mm)))),
    N("Shape", "multi", "shape"), [],
  )

  let mix = sec("Mixer", (kw,),
    N("VCO 1", "mixer", "vco1"), N("VCO 2", "mixer", "vco2"), N("Multi", "mixer", "multi"),
  )

  let flt = sec("Filter", (12mm, 12mm),
    grid.cell(colspan: 2, N("Cutoff", "filter", "cutoff")),
    grid.cell(colspan: 2, N("Resonance", "filter", "resonance")),
    T("Drive", "filter", "drive", options.three, width: 12mm), T("Key Track", "filter", "keytrack", options.three, width: 12mm),
  )

  let (rl, rla) = g("lfo", "rate_label")
  let (int, ia) = g("lfo", "int")
  let env = sec("Amp EG · EG · LFO", (7mm, kw, kw, kw, kw, kw),
    rlabel("AMP\nEG"), N("Attack", "amp_eg", "a"), N("Decay", "amp_eg", "d"), N("Sustain", "amp_eg", "s"), N("Release", "amp_eg", "r"), [],
    rlabel("EG"), N("Attack", "eg", "a"), N("Decay", "eg", "d"), N("EG Int", "eg", "int", max: 100, bipolar: true, unit: " %"),
    T("Target", "eg", "target", options.eg-target), [],
    rlabel("LFO"), T("Wave", "lfo", "wave", options.wave), T("Mode", "lfo", "mode", options.lfo-mode),
    N("Rate", "lfo", "rate", label: if rl != "" { rl } else { none }),
    knob-num("Int", int, max: 511, active: ia, hint: if int < 0 { "INVERSÉ" }, size: ks, width: kw),
    T("Target", "lfo", "target", options.lfo-target),
  )

  let fx(title, sec, show-sub) = {
    let (on, oa) = g(sec, "on")
    let (t, ta) = g(sec, "type")
    let st = if show-sub { g(sec, "subtype").at(0) } else { none }
    let act = oa or ta
    let col = if act { ink } else { muted }
    (
      box(width: 19mm, height: zone, align(center + horizon, stack(spacing: 1.3mm,
        box(width: 19mm, {
          box(baseline: 0.15mm, circle(radius: 0.8mm, fill: if on { col } else { white }, stroke: 0.6pt + col))
          h(1mm)
          text(size: 5.4pt, weight: "extrabold", tracking: 0.06em, fill: col, title)
          h(1fr)
          text(size: 4.8pt, weight: "bold", fill: col, if on { "ON" } else { "OFF" })
        }),
        screen("", t, active: act, width: 19mm, height: if show-sub { 7.4mm } else { 6.4mm }, sub: if show-sub { st }),
      ))),
      N("Time", sec, "time"),
      N("Depth", sec, "depth", max: 100, unit: " %"),
    )
  }
  let efx = sec("Effects", (19.5mm, kw, kw),
    ..fx("MOD FX", "mod_fx", true), ..fx("REVERB", "reverb", false), ..fx("DELAY", "delay", false),
  )

  block(width: 100%, stroke: 0.8pt + ink, inset: (x: 1mm, top: 2.6mm, bottom: 1.4mm), align(center, grid(
    columns: 6, column-gutter: 0mm, inset: (x: 1.1mm),
    stroke: (x, y) => if x > 0 { (left: 0.6pt + ink) },
    master, vco, mix, flt, env, efx,
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
          rows.push(text(weight: "extrabold", upper(s.nom)))
          rows.push(md(s.valeur))
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
  show: page-setup.with(fichier: data.at("_fichier", default: none))
  header("Korg minilogue XD", data)
  panel(params)
  v(0.6mm)
  grid(
    columns: (92mm, 1fr, 1fr), column-gutter: 1.6mm,
    program-edit(data),
    textbox("Pour l'obtenir", icon: icon-knob, numbered(data.at("etapes", default: ()))),
    stack(spacing: 1.6mm,
      textbox("Ajuster à l'oreille", icon: icon-ear, bullets(data.at("oreille", default: ()))),
      textbox("Jeu", icon: icon-keys, bullets(data.at("jeu", default: ()))),
    ),
  )
  let val(sec, k) = {
    let x = params.at(sec, default: (:))
    if x == none { x = (:) }
    x.at(k, default: defaults.at(sec).at(k))
  }
  let nrm(v) = v / 1023
  let ia = val("eg", "int")
  let eg-target = val("eg", "target")
  sources-page("Korg minilogue XD", data, envs: (
    (titre: "Amp EG", a: nrm(val("amp_eg", "a")), d: nrm(val("amp_eg", "d")), s: nrm(val("amp_eg", "s")), r: nrm(val("amp_eg", "r")),
     sub: "A " + str(val("amp_eg", "a")) + " · D " + str(val("amp_eg", "d")) + " · S " + str(val("amp_eg", "s")) + " · R " + str(val("amp_eg", "r"))),
    (titre: "EG → " + upper(eg-target), a: nrm(val("eg", "a")), d: nrm(val("eg", "d")), s: 0, r: 0, sustain: false,
     sub: "A " + str(val("eg", "a")) + " · D " + str(val("eg", "d")) + " · INT " + (if ia > 0 { "+" } else { "" }) + str(ia) + " %"),
  ))
}
