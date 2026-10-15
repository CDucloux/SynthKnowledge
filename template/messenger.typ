// SynthKnowledge : schéma de façade du Moog Messenger.
// Référence : manuals/moog-messenger-user-manual.pdf (pages 6-7 et 13-22).
// Toute clé absente du YAML prend la valeur INIT ci-dessous et s'affiche en gris.

#import "style.typ": *

// Valeurs neutres et options : template/schema/messenger.yaml (source unique,
// aussi lue par scripts/build.py pour valider les YAML de sons).
#let schema = yaml("schema/messenger.yaml")
#let defaults = schema-defaults(schema)
#let options = schema.options

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

// ---------------------------------------------------------------------------
// Façade en bande unique, fidèle à l'overview du manuel (p. 6) :
// LFO 1 | OSCILLATORS | MIXER | FILTER | ENVELOPES, deux rangées de potards
// puis la rangée de boutons, titres centrés, séparateurs verticaux fins.
// ---------------------------------------------------------------------------
#let panel-overview(params) = {
  check-params(params, defaults)
  let g = param-reader(params, defaults)
  // Taille de référence : le potard standard. Largeur de case et « zone potard »
  // (hauteur sur laquelle tout ce qui est dans une rangée se centre) en découlent.
  let ks = 9mm
  let zone = ks + 2 * 2.6mm
  let kw = zone + 0.4mm
  let K(name, sec, k, bipolar: false, hint: none) = {
    let (v, a) = g(sec, k)
    knob(name, v, active: a, bipolar: bipolar, hint: if hint != none { hint(v) }, size: ks, width: kw)
  }
  let S(name, sec, k, opts, centered: true) = {
    let (v, a) = g(sec, k)
    selector-updown(name, opts, v, active: a, zone: if centered { zone } else { none })
  }
  let B(name, sec, k, note: none) = {
    let (v, a) = g(sec, k)
    switch(name, v, active: a, width: kw, note: note)
  }
  let num(n) = box(height: zone, inset: (x: 0.6mm), align(center + horizon, text(size: 13pt, weight: "extrabold", n)))
  let elabel(t) = box(height: zone, align(left + horizon, text(size: 5.4pt, weight: "extrabold", tracking: 0.04em, t)))
  let cut = {
    let (v, a) = g("filter", "cutoff")
    align(center, stack(spacing: 0.9mm,
      knob-glyph(v, active: a, size: 15mm),
      ctl-label("Cutoff", a),
      ctl-value(clock-label(v), a),
    ))
  }

  panel-frame(panel-band((
    (title: "LFO 1", cols: 2, cells: (
      K("LFO 1 Rate", "lfo1", "rate"), S("Waveshape", "lfo1", "wave", options.lfo1-wave),
      K("LFO 1 Depth", "lfo1", "depth", bipolar: true), S("Destination", "lfo1", "dest", options.lfo1-dest),
      B("Sync", "lfo1", "sync"), B("KB Reset", "lfo1", "kb_reset", note: "[LFO 1 ASSIGN]"),
    )),
    (title: "Oscillators", cols: 5, cells: (
      S("Octave", "osc", "oct1", options.octave), num("1"),
      K("Tune", "osc", "tune", bipolar: true), K("Sub Wave", "osc", "sub_wave", hint: sub-hint), K("Waveshape", "osc", "wave1", hint: wave-hint),
      S("Octave", "osc", "oct2", options.octave), num("2"),
      K("Osc 2 Freq", "osc", "osc2_freq", bipolar: true), K("Mod Amount", "osc", "mod_amount", bipolar: true), K("Waveshape", "osc", "wave2", hint: wave-hint),
      [], [], B("Sync 1→2", "osc", "sync"), grid.cell(colspan: 2, S("Mod Destination", "osc", "mod_dest", options.mod-dest, centered: false)),
    )),
    (title: "Mixer", cols: 2, cells: (
      K("Osc 1", "mixer", "osc1"), K("Sub Osc", "mixer", "sub"),
      K("Osc 2", "mixer", "osc2"), K("Noise", "mixer", "noise"),
    )),
    (title: "Filter", cols: 3, cells: (
      K("FB / Ext In", "filter", "fb_ext"), grid.cell(rowspan: 2, align: center + horizon, cut), K("EG Amount", "filter", "eg_amount", bipolar: true),
      K("Osc 2 → Cutoff", "filter", "osc2_cutoff"), K("Resonance", "filter", "resonance"),
      B("KB Tracking", "filter", "kb_tracking", note: "[KB ASSIGN]"), S("Mode", "filter", "mode", options.filter-mode, centered: false), B("Res Bass", "filter", "res_bass"),
    )),
    (title: "Envelopes", cols: 5, cells: (
      elabel("FILTER\nENVELOPE"), K("Attack", "fenv", "a"), K("Decay", "fenv", "d"), K("Sustain", "fenv", "s"), K("Release", "fenv", "r"),
      elabel("AMPLIFIER\nENVELOPE"), K("Attack", "aenv", "a"), K("Decay", "aenv", "d"), K("Sustain", "aenv", "s"), K("Release", "aenv", "r"),
      B("Multi-Trig", "env", "multi_trig"), B("F Env Vel", "env", "f_vel"), B("F Env Loop", "env", "f_loop", note: "[F ENV ASSIGN]"), B("A Env Vel", "env", "a_vel"), B("A Env Loop", "env", "a_loop", note: "[A ENV ASSIGN]"),
    )),
  )))
}

// Contrôleur main gauche + modulations assignées / réglages SETTINGS.
#let performance(params, data) = {
  let get = param-reader(params, defaults)
  let g(k) = get("perf", k)
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
    ..options.lfo2-dest.map(((k, l)) => pill(l, k in dests, active: da)),
  )

  let assigns = data.at("modulations", default: ())
  let settings = data.at("settings", default: ())
  if assigns == none { assigns = () }
  if settings == none { settings = () }

  let section(title, body) = block(width: 100%, stroke: 0.8pt + ink, inset: (x: 2mm, top: 1.2mm, bottom: 1.6mm),
    stack(spacing: 1mm, ov-title(title), body))
  let lay(a, b) = stack(spacing: 1.6mm, a, b)
  lay(
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
  let val(sec, k) = param-reader(params, defaults)(sec, k).at(0)
  let nrm(h) = (h - 7) / 10
  let env(sec, titre) = env-entry(titre,
    nrm(val(sec, "a")), nrm(val(sec, "d")), nrm(val(sec, "s")), nrm(val(sec, "r")),
    sub: "A " + clock-label(val(sec, "a")) + " · D " + clock-label(val(sec, "d")) + " · S " + clock-label(val(sec, "s")) + " · R " + clock-label(val(sec, "r")),
  )
  let fe = env("fenv", "Filter env")
  // EG AMOUNT à midi : l'enveloppe de filtre n'agit pas (courbe grise, hors échelle).
  if val("filter", "eg_amount") == 12 { fe.sub = "sans effet ici : EG AMOUNT à midi"; fe.inactive = true }
  sheet("Moog Messenger", data,
    panel: panel-overview(params),
    aside: performance(params, data),
    envs: (fe, env("aenv", "Amp env")),
    seq-spec: schema.extra.sequence,
  )
}
