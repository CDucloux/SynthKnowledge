// SynthKnowledge : schéma de façade du Moog Messenger.
// Référence : manuels/moog-messenger-user-manual.pdf (pages 6-7 et 13-22).
// Toute clé absente du YAML prend la valeur INIT ci-dessous et s'affiche en gris.

#import "style.typ": *

// ---------------------------------------------------------------------------
// Valeurs neutres de référence (« INIT SynthKnowledge »).
// Ce ne sont PAS forcément les valeurs exactes du patch init usine :
// la fiche affiche tous les contrôles, il suffit de tout régler comme dessiné.
// ---------------------------------------------------------------------------
#let defaults = (
  lfo1: (rate: 12, depth: 12, wave: "tri", dest: "cutoff", sync: false, kb_reset: false),
  osc: (
    oct1: 8, oct2: 8, tune: 12, sub_wave: 7, wave1: 12, wave2: 12,
    osc2_freq: 12, mod_amount: 12, mod_dest: "fm", sync: false,
  ),
  mixer: (osc1: 17, osc2: 7, sub: 7, noise: 7),
  filter: (
    fb_ext: 7, cutoff: 17, eg_amount: 12, osc2_cutoff: 7, resonance: 7,
    res_bass: false, kb_tracking: false, mode: "lp4",
  ),
  fenv: (a: 7, d: 12, s: 17, r: 10),
  aenv: (a: 7, d: 12, s: 17, r: 10),
  env: (multi_trig: false, f_vel: false, f_loop: false, a_vel: false, a_loop: false),
  perf: (glide: 7, lfo2_rate: 12, lfo2_dest: (), mod_wheel: 0, kb_octave: 0),
)

#let options = (
  lfo1-wave: (("tri", "TRI"), ("saw", "SAW"), ("ramp", "RAMP"), ("sqr", "SQUARE")),
  lfo1-dest: (("cutoff", "CUTOFF"), ("osc2_freq", "OSC 2 FREQ"), ("osc1_wave", "OSC 1 WAVE"), ("sub_wave", "SUB WAVE")),
  octave: ((4, "4'"), (8, "8'"), (16, "16'"), (32, "32'")),
  mod-dest: (("fm", "1→2 FM"), ("fenv_osc2_freq", "F ENV→OSC 2 FREQ"), ("fenv_osc2_wave", "F ENV→OSC 2 WAVE"), ("fenv_sub_wave", "F ENV→SUB WAVE")),
  filter-mode: (("lp4", "4P LOW PASS"), ("lp2", "2P LOW PASS"), ("bp", "BAND PASS"), ("hp", "HIGH PASS")),
)

// Libellé de forme d'onde d'après la position de WAVESHAPE (manuel p. 10 & 15).
#let wave-hint(h) = {
  if h < 10.4 { "FOLD" + (if h < 8.5 { " +++" } else if h < 9.5 { " ++" } else { " +" }) }
  else if h < 11.4 { "TRIANGLE" }
  else if h < 12.4 { "SAW" }
  else if h < 13.75 { "SQUARE" }
  else { "PULSE " + (if h < 15 { "LARGE" } else if h < 16.3 { "ÉTROITE" } else { "FINE" }) }
}

#let sub-hint(h) = {
  if h < 8 { "TRIANGLE" } else if h < 10.2 { "TRI → SQR" } else if h < 11.6 { "SQUARE" } else { "PULSE" }
}

#let _check(params) = {
  for (sec, vals) in params {
    assert(sec in defaults, message: "Section inconnue « " + sec + " », attendu : " + defaults.keys().join(", "))
    for (k, _) in vals {
      assert(k in defaults.at(sec), message: "Paramètre inconnu « " + sec + "." + k + " », attendu : " + defaults.at(sec).keys().join(", "))
    }
  }
}

#let panel(params) = {
  _check(params)
  let g(sec, k) = {
    let s = params.at(sec, default: (:))
    if s == none { s = (:) }
    if k in s { (s.at(k), true) } else { (defaults.at(sec).at(k), false) }
  }
  let K(name, sec, k, bipolar: false, hint: none) = {
    let (v, a) = g(sec, k)
    knob(name, v, active: a, bipolar: bipolar, hint: if hint != none { hint(v) })
  }
  let S(name, sec, k, opts, width: 22mm) = {
    let (v, a) = g(sec, k)
    selector(name, opts, v, active: a, width: width)
  }
  let B(name, sec, k) = {
    let (v, a) = g(sec, k)
    switch(name, v, active: a)
  }

  set block(spacing: 1.6mm)

  // Rangée 1 : OSCILLATORS (ordre du panneau)
  grid(
    columns: (1fr,), rows: 29mm,
    section("Oscillators", row(
      S("Octave 1", "osc", "oct1", options.octave, width: 14mm),
      K("Waveshape 1", "osc", "wave1", hint: wave-hint),
      K("Tune", "osc", "tune", bipolar: true),
      K("Sub Wave", "osc", "sub_wave", hint: sub-hint),
      box(width: 1.5mm, height: 20mm, align(center, line(angle: 90deg, length: 20mm, stroke: 0.5pt + muted))),
      S("Octave 2", "osc", "oct2", options.octave, width: 14mm),
      K("Waveshape 2", "osc", "wave2", hint: wave-hint),
      K("Osc 2 Freq", "osc", "osc2_freq", bipolar: true),
      K("Mod Amount", "osc", "mod_amount", bipolar: true),
      S("Mod Destination", "osc", "mod_dest", options.mod-dest, width: 27mm),
      B("Sync 1→2", "osc", "sync"),
    )),
  )

  // Rangée 2 : LFO 1 | MIXER
  grid(
    columns: (1fr, 72mm), column-gutter: 1.6mm, rows: 27mm,
    section("LFO 1", row(
      K("Rate", "lfo1", "rate"),
      K("Depth", "lfo1", "depth", bipolar: true),
      S("Wave", "lfo1", "wave", options.lfo1-wave, width: 17mm),
      S("Destination", "lfo1", "dest", options.lfo1-dest, width: 25mm),
      stack(spacing: 2.4mm, B("Sync", "lfo1", "sync"), B("KB Reset", "lfo1", "kb_reset")),
    )),
    section("Mixer", row(
      K("Osc 1", "mixer", "osc1"), K("Osc 2", "mixer", "osc2"),
      K("Sub Osc", "mixer", "sub"), K("Noise", "mixer", "noise"),
    )),
  )

  // Rangée 3 : FILTER
  grid(
    columns: (1fr,), rows: 30mm,
    section("Filter", row(
      K("FB / Ext In", "filter", "fb_ext"),
      {
        let (v, a) = g("filter", "cutoff")
        box(width: 21mm, align(center, stack(spacing: 0.9mm,
          knob-glyph(v, active: a, size: 13mm),
          ctl-label("Cutoff", a),
          ctl-value(clock-label(v), a),
        )))
      },
      K("EG Amount", "filter", "eg_amount", bipolar: true),
      K("Osc 2 → Cutoff", "filter", "osc2_cutoff"),
      K("Resonance", "filter", "resonance"),
      box(width: 3mm),
      stack(spacing: 2.4mm, B("Res Bass", "filter", "res_bass"), B("KB Tracking", "filter", "kb_tracking")),
      box(width: 3mm),
      S("Mode", "filter", "mode", options.filter-mode, width: 23mm),
    )),
  )

  // Rangée 4 : ENVELOPES (boutons sous chaque enveloppe)
  grid(
    columns: (1fr,), rows: 41mm,
    section("Envelopes", {
      let group(title, sec, b1, b2) = box(inset: (x: 1mm), stack(spacing: 2.2mm,
        align(center, text(size: 5.8pt, weight: "extrabold", tracking: 0.14em, title)),
        row(gap: 1.2mm, K("Attack", sec, "a"), K("Decay", sec, "d"), K("Sustain", sec, "s"), K("Release", sec, "r")),
        row(gap: 4mm, b1, b2),
      ))
      let vsep = box(width: 5mm, height: 31mm, align(center, line(angle: 90deg, length: 31mm, stroke: 0.5pt + muted)))
      v(0.6mm)
      row(gap: 0mm,
        group("FILTER ENVELOPE", "fenv", B("F Env Vel", "env", "f_vel"), B("F Env Loop", "env", "f_loop")),
        vsep,
        group("AMPLITUDE ENVELOPE", "aenv", B("A Env Vel", "env", "a_vel"), B("A Env Loop", "env", "a_loop")),
        vsep,
        box(height: 31mm, align(horizon, B("Multi-Trig", "env", "multi_trig"))),
      )
    }, inset: 2.4mm),
  )
}

// Contrôleur main gauche + modulations assignées / réglages SETTINGS.
#let performance(params, data) = {
  let p = params.at("perf", default: (:))
  if p == none { p = (:) }
  let g(k) = if k in p { (p.at(k), true) } else { (defaults.perf.at(k), false) }
  let (dests, da) = g("lfo2_dest")
  if type(dests) == str { dests = (dests,) }
  let (wheel, wa) = g("mod_wheel")
  let (oct, oa) = g("kb_octave")
  let (glide, ga) = g("glide")
  let (rate, ra) = g("lfo2_rate")

  let wheel-glyph = {
    let col = if wa { ink } else { muted }
    box(width: 12mm, align(center, stack(spacing: 0.9mm,
      box(width: 4.2mm, height: 12mm, stroke: 0.9pt + col, radius: 1pt, clip: true,
        align(bottom, box(width: 100%, height: wheel * 1% , fill: col))),
      ctl-label("Mod Wheel", wa),
      ctl-value(str(wheel) + " %", wa),
    )))
  }
  let oct-glyph = {
    let col = if oa { ink } else { muted }
    box(width: 14mm, align(center, stack(spacing: 1mm,
      box(height: 3.6mm, align(horizon, for i in range(-2, 3) {
        box(circle(radius: 0.9mm, fill: if i == oct { col } else { white }, stroke: 0.6pt + col))
        h(0.5mm)
      })),
      ctl-label("KB Octave", oa),
      ctl-value(if oct > 0 { "+" + str(oct) } else { str(oct) }, oa),
    )))
  }
  let dest-btns = stack(spacing: 1.1mm,
    ..(("pitch", "PITCH"), ("cutoff", "CUTOFF"), ("amp", "AMP")).map(((k, l)) => pill(l, k in dests, active: da)),
  )

  let assigns = data.at("modulations", default: ())
  let settings = data.at("settings", default: ())
  if assigns == none { assigns = () }
  if settings == none { settings = () }

  grid(
    columns: (92mm, 1fr), column-gutter: 1.6mm, rows: 29mm,
    section("Left-Hand Controller", {
      v(0.6mm)
      row(
        knob("Glide", glide, active: ga),
        knob("LFO 2 Rate", rate, active: ra),
        box(width: 15mm, align(center, stack(spacing: 1mm, dest-btns, ctl-label("LFO 2 Dest", da)))),
        wheel-glyph,
        oct-glyph,
      )
    }),
    section("Modulations & Settings", {
      set text(size: 6.4pt)
      if assigns.len() == 0 and settings.len() == 0 {
        align(center + horizon, box(height: 18mm, align(horizon, text(fill: muted, weight: "semibold", "AUCUNE MODULATION ASSIGNÉE"))))
      } else {
        let rows = ()
        for m in assigns {
          rows.push(text(weight: "extrabold", upper(m.source)))
          rows.push([→ #text(weight: "bold", upper(m.dest))])
          rows.push(text(weight: "extrabold", str(m.at("depth", default: ""))))
        }
        for s in settings {
          rows.push(text(weight: "extrabold", upper(s.nom)))
          rows.push(md(s.valeur))
          rows.push([])
        }
        table(
          columns: (auto, 1fr, auto), stroke: none, inset: (x: 1mm, y: 0.9mm),
          table.hline(stroke: 0.5pt),
          ..rows,
          table.hline(stroke: 0.5pt),
        )
      }
    }),
  )
}

#let fiche(data) = {
  let params = data.at("params", default: (:))
  if params == none { params = (:) }
  show: page-setup
  header("Moog Messenger", data)
  panel(params)
  performance(params, data)
  v(0.4mm)
  grid(
    columns: (1.25fr, 1fr), column-gutter: 1.6mm,
    textbox("Pour l'obtenir", numbered(data.at("etapes", default: ()))),
    stack(spacing: 1.6mm,
      textbox("Ajuster à l'oreille", bullets(data.at("oreille", default: ()))),
      textbox("Jeu", bullets(data.at("jeu", default: ()))),
    ),
  )
  v(1fr)
  footer-line(data)
  let val(sec, k) = {
    let x = params.at(sec, default: (:))
    if x == none { x = (:) }
    x.at(k, default: defaults.at(sec).at(k))
  }
  let nrm(h) = (h - 7) / 10
  let env(sec, titre) = (
    titre: titre, a: nrm(val(sec, "a")), d: nrm(val(sec, "d")), s: nrm(val(sec, "s")), r: nrm(val(sec, "r")),
    sub: "A " + clock-label(val(sec, "a")) + " · D " + clock-label(val(sec, "d")) + " · S " + clock-label(val(sec, "s")) + " · R " + clock-label(val(sec, "r")),
  )
  sources-page("Moog Messenger", data, envs: (env("fenv", "Filter env"), env("aenv", "Amp env")))
}
