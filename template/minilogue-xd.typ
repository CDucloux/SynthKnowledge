// SynthKnowledge : schéma de façade du Korg minilogue XD.
// Référence : manuels/minilogue-xd-user-manual.pdf (p. 5 façade, p. 15-24 paramètres, p. 32-36 PROGRAM EDIT, p. 53-54 effets).
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

#let panel(params) = {
  _check(params)
  let g(sec, k) = {
    let s = params.at(sec, default: (:))
    if s == none { s = (:) }
    if k in s { (s.at(k), true) } else { (defaults.at(sec).at(k), false) }
  }
  let N(name, sec, k, min: 0, max: 1023, bipolar: false, unit: "", label: none, width: 15mm) = {
    let (v, a) = g(sec, k)
    knob-num(name, v, min: min, max: max, active: a, bipolar: bipolar, unit: unit, label: label, width: width)
  }
  let S(name, sec, k, opts, width: 16mm) = {
    let (v, a) = g(sec, k)
    selector(name, opts, v, active: a, width: width)
  }
  let B(name, sec, k) = {
    let (v, a) = g(sec, k)
    switch(name, v, active: a, width: 13mm)
  }
  let vsep(hh) = box(width: 1.5mm, height: hh, align(center, line(angle: 90deg, length: hh, stroke: 0.5pt + muted)))

  set block(spacing: 1.6mm)

  // Rangée 1 : MASTER / VOICE MODE | MIXER | FILTER
  grid(
    columns: (1fr, 50mm, 64mm), column-gutter: 1.6mm, rows: 30mm,
    section("Master · Voice Mode", {
      let (mode, ma) = g("voice", "mode")
      let (d, da) = g("voice", "depth")
      let (lbl, la) = g("voice", "depth_label")
      let (oct, oa) = g("voice", "octave")
      row(
        S("Voice Mode", "voice", "mode", options.voice-mode, width: 19mm),
        knob-num("V.M. Depth", d, active: da or la, label: depth-display(mode, d, lbl), width: 15mm),
        N("Portamento", "voice", "portamento", max: 127),
        {
          let col = if oa { ink } else { muted }
          box(width: 14mm, align(center, stack(spacing: 1mm,
            box(height: 3.6mm, align(horizon, for i in range(-2, 3) {
              box(circle(radius: 0.9mm, fill: if i == oct { col } else { white }, stroke: 0.6pt + col))
              h(0.5mm)
            })),
            ctl-label("Octave", oa),
            ctl-value(if oct > 0 { "+" + str(oct) } else { str(oct) }, oa),
          )))
        },
      )
    }),
    section("Mixer", row(N("VCO 1", "mixer", "vco1"), N("VCO 2", "mixer", "vco2"), N("Multi", "mixer", "multi"))),
    section("Filter", row(
      {
        let (v, a) = g("filter", "cutoff")
        knob-num("Cutoff", v, active: a, size: 11mm, width: 17mm)
      },
      N("Resonance", "filter", "resonance"),
      S("Drive", "filter", "drive", options.three, width: 14mm),
      S("Keytrack", "filter", "keytrack", options.three, width: 14mm),
    )),
  )

  // Rangée 2 : VCO 1 | VCO 2
  grid(
    columns: (66mm, 1fr), column-gutter: 1.6mm, rows: 30mm,
    section("VCO 1", row(
      S("Wave", "vco1", "wave", options.wave, width: 13mm),
      S("Octave", "vco1", "octave", options.octave, width: 13mm),
      N("Pitch", "vco1", "pitch", max: 1200, bipolar: true, unit: " C"),
      N("Shape", "vco1", "shape"),
    )),
    section("VCO 2", row(
      S("Wave", "vco2", "wave", options.wave, width: 13mm),
      S("Octave", "vco2", "octave", options.octave, width: 13mm),
      N("Pitch", "vco2", "pitch", max: 1200, bipolar: true, unit: " C"),
      N("Shape", "vco2", "shape"),
      stack(spacing: 2.4mm, B("Sync", "vco2", "sync"), B("Ring", "vco2", "ring")),
      N("Cross Mod", "vco2", "cross_mod", width: 17mm),
    )),
  )

  // Rangée 3 : MULTI ENGINE | AMP EG | EG
  grid(
    columns: (54mm, 1fr, 64mm), column-gutter: 1.6mm, rows: 30mm,
    section("Multi Engine", {
      let (t, ta) = g("multi", "type")
      row(
        S("Engine", "multi", "engine", options.engine, width: 15mm),
        screen("Type", t, active: ta, width: 19mm),
        N("Shape", "multi", "shape"),
      )
    }),
    section("Amp EG", row(
      N("Attack", "amp_eg", "a"), N("Decay", "amp_eg", "d"), N("Sustain", "amp_eg", "s"), N("Release", "amp_eg", "r"),
    )),
    section("EG", row(
      N("Attack", "eg", "a"), N("Decay", "eg", "d"),
      N("EG Int", "eg", "int", max: 100, bipolar: true, unit: " %"),
      S("Target", "eg", "target", options.eg-target, width: 17mm),
    )),
  )

  // Rangée 4 : LFO | EFFECTS
  grid(
    columns: (82mm, 1fr), column-gutter: 1.6mm, rows: 41mm,
    section("LFO", {
      let (rl, rla) = g("lfo", "rate_label")
      let (int, ia) = g("lfo", "int")
      row(
        S("Wave", "lfo", "wave", options.wave, width: 13mm),
        S("Mode", "lfo", "mode", options.lfo-mode, width: 15mm),
        N("Rate", "lfo", "rate", label: if rl != "" { rl } else { none }),
        knob-num("Int", int, max: 511, active: ia, hint: if int < 0 { "INVERSÉ (SHIFT)" }, width: 15mm),
        S("Target", "lfo", "target", options.lfo-target, width: 16mm),
      )
    }),
    section("Effects", {
      let fx(title, sec, show-sub) = {
        let (on, oa) = g(sec, "on")
        let (t, ta) = g(sec, "type")
        let txt = if show-sub {
          let (st, sa) = g(sec, "subtype")
          upper(t) + " " + st
        } else { t }
        box(width: 32mm, align(center, stack(spacing: 1mm,
          stack(dir: ltr, spacing: 1.2mm,
            box(height: 3.6mm, align(horizon, text(size: 5.8pt, weight: "extrabold", tracking: 0.08em, fill: if oa or ta { ink } else { muted }, title))),
            pill(if on { "ON" } else { "OFF" }, on, active: oa),
          ),
          screen("", txt, active: ta, width: 31mm),
          row(gap: 0mm, N("Time", sec, "time"), N("Depth", sec, "depth", max: 100, unit: " %")),
        )))
      }
      row(gap: 1mm, fx("MOD FX", "mod_fx", true), fx("REVERB", "reverb", false), fx("DELAY", "delay", false))
    }, inset: 1.4mm),
  )
}

#let program-edit(data) = {
  let settings = data.at("settings", default: ())
  if settings == none { settings = () }
  if settings.len() == 0 { return }
  section("Program Edit", {
    set text(size: 6.4pt)
    let rows = ()
    for s in settings {
      rows.push(text(weight: "extrabold", upper(s.nom)))
      rows.push(md(s.valeur))
    }
    table(
      columns: (auto, 1fr, auto, 1fr), stroke: none, inset: (x: 1mm, y: 0.8mm),
      ..rows,
      ..(if calc.odd(settings.len()) { ([], []) } else { () }),
    )
  }, inset: 1.6mm, height: auto)
}

#let fiche(data) = {
  let params = data.at("params", default: (:))
  if params == none { params = (:) }
  show: page-setup.with(fichier: data.at("_fichier", default: none))
  header("Korg minilogue XD", data)
  panel(params)
  block(width: 100%, program-edit(data))
  v(0.4mm)
  grid(
    columns: (1.25fr, 1fr), column-gutter: 1.6mm,
    textbox("Pour l'obtenir", numbered(data.at("etapes", default: ()))),
    stack(spacing: 1.6mm,
      textbox("Ajuster à l'oreille", bullets(data.at("oreille", default: ()))),
      textbox("Jeu", bullets(data.at("jeu", default: ()))),
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
