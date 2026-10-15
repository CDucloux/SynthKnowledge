// SynthKnowledge : composants graphiques communs.
// Esthétique inspirée des manuels Moog : noir & blanc, sans-serif géométrique,
// titres capitales grasses, vignettes encadrées.

#let ink = black
#let muted = luma(190)
#let soft = luma(242)
#let font = ("Montserrat", "Gotham", "Helvetica Neue", "Arial")

// ---------------------------------------------------------------------------
// Positions de bouton exprimées en heures d'horloge : 7 = MIN (butée gauche),
// 12 = midi, 17 = MAX (butée droite). Décimales autorisées : 10.5 = 10:30.
// ---------------------------------------------------------------------------

#let clock-label(h) = {
  if h <= 7 { return "MIN" }
  if h >= 17 { return "MAX" }
  let hh = calc.floor(h)
  let m = calc.round((h - hh) * 60)
  if m == 60 { hh += 1; m = 0 }
  let h12 = if hh > 12 { hh - 12 } else { hh }
  str(h12) + ":" + (if m < 10 { "0" } else { "" }) + str(m)
}

#let _pt(c, r, a) = (c + r * calc.sin(a), c - r * calc.cos(a))

#let _arc(c, r, from, to, stroke) = {
  let steps = calc.max(2, calc.ceil(calc.abs(to - from) * 6))
  let pts = range(steps + 1).map(i => {
    let h = from + (to - from) * i / steps
    _pt(c, r, (h - 12) * 30deg)
  })
  curve(stroke: stroke, curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p)))
}

/// Dessin d'un bouton rotatif façon Moog : couronne, disque, index blanc,
/// graduations et arc de valeur (depuis MIN, ou depuis midi si bipolaire).
#let knob-glyph(h, active: true, size: 9mm, bipolar: false) = {
  let col = if active { ink } else { muted }
  let r = size / 2
  let pad = 2.6mm
  let c = r + pad
  box(width: size + 2 * pad, height: size + 2 * pad, {
    for t in range(7, 18) {
      let a = (t - 12) * 30deg
      let long = t == 7 or t == 17 or (bipolar and t == 12)
      place(line(
        start: _pt(c, r + 0.5mm, a),
        end: _pt(c, r + (if long { 2.2mm } else { 1.4mm }), a),
        stroke: (if long { 0.9pt } else { 0.5pt }) + col,
      ))
    }
    if active {
      let from = if bipolar { 12 } else { 7 }
      if calc.abs(h - from) > 0.05 {
        place(_arc(c, r + 0.95mm, calc.min(from, h), calc.max(from, h), 1.6pt + ink))
      }
    }
    place(dx: c - r, dy: c - r, circle(radius: r, stroke: 1.1pt + col, fill: white))
    place(dx: c - 0.74 * r, dy: c - 0.74 * r, circle(radius: 0.74 * r, fill: col))
    let a = (h - 12) * 30deg
    place(line(start: _pt(c, 0.12 * r, a), end: _pt(c, 0.66 * r, a), stroke: (paint: white, thickness: 1.5pt, cap: "round")))
  })
}

#let ctl-label(name, active) = text(
  size: 5.6pt, weight: "bold", fill: if active { ink } else { muted }, tracking: 0.02em, upper(name),
)

#let ctl-value(v, active, hint: none) = {
  let c = if active { ink } else { muted }
  text(size: 6.6pt, weight: if active { "extrabold" } else { "medium" }, fill: c, v)
  if hint != none { linebreak(); text(size: 5pt, weight: "semibold", fill: c, hint) }
}

/// Cellule bouton rotatif : dessin + libellé + valeur.
#let knob(name, h, active: true, bipolar: false, hint: none, size: 9mm, width: 16mm) = box(
  width: width,
  align(center, stack(
    spacing: 0.9mm,
    knob-glyph(h, active: active, size: size, bipolar: bipolar),
    ctl-label(name, active),
    ctl-value(clock-label(h), active, hint: hint),
  )),
)

/// Bouton rotatif à valeur écran (minilogue XD…) : la position de l'index est
/// proportionnelle à `v` entre `min` et `max` ; `label` remplace l'affichage numérique.
#let knob-num(name, v, min: 0, max: 1023, active: true, bipolar: false, label: none, unit: "", hint: none, size: 9mm, width: 16mm) = {
  let pos = if type(v) in (int, float) { 7 + 10 * (calc.abs(v) - (if bipolar { 0 } else { min })) / (max - (if bipolar { 0 } else { min })) } else { 12 }
  if bipolar and type(v) in (int, float) { pos = 12 + 5 * v / max }
  pos = calc.clamp(pos, 7, 17)
  let shown = if label != none { str(label) } else if type(v) in (int, float) {
    (if bipolar and v > 0 { "+" } else { "" }) + str(v) + unit
  } else { str(v) }
  box(width: width, align(center, stack(
    spacing: 0.9mm,
    knob-glyph(pos, active: active, size: size, bipolar: bipolar),
    ctl-label(name, active),
    ctl-value(shown, active, hint: hint),
  )))
}

/// Petit écran (MULTI ENGINE, effets…) : cadre (lunette) puis dalle noire,
/// texte blanc centré ; `sub` = seconde ligne plus petite (sous-type…).
#let screen(name, txt, active: true, width: 20mm, height: 6.4mm, sub: none) = {
  let col = if active { ink } else { muted }
  box(width: width, align(center, stack(
    spacing: 1mm,
    box(width: width, height: height, radius: 1.3mm, stroke: 0.8pt + col, inset: 0.6mm,
      box(width: 100%, height: 100%, radius: 0.8mm, fill: col, align(center + horizon, {
        // Hauteur du texte = hauteur des capitales (pas de jambage) : centrage optique exact.
        set text(fill: white, top-edge: "cap-height", bottom-edge: "baseline")
        let main = text(size: 5.6pt, weight: "bold", str(txt))
        if sub == none { main } else { stack(spacing: 0.9mm, main, text(size: 4.6pt, weight: "medium", str(sub))) }
      }))),
    if name != "" { ctl-label(name, active) },
  )))
}

/// Sélecteur à flèches du Messenger (OCTAVE, WAVESHAPE, DESTINATION, MODE…) :
/// bouton arrondi avec ▲ / ▼, colonne de LED à droite (texte en petit), libellé dessous.
#let selector-updown(name, options, value, active: true, width: 14mm, zone: none) = {
  let col = if active { ink } else { muted }
  let tri(up) = polygon(
    stroke: (paint: col, thickness: 0.55pt, join: "round"),
    ..(if up { ((0mm, 1.5mm), (0.95mm, 0mm), (1.9mm, 1.5mm)) } else { ((0mm, 0mm), (0.95mm, 1.5mm), (1.9mm, 0mm)) }),
  )
  let btn = box(width: 4.6mm, height: 9mm, radius: 1.1mm, stroke: 0.8pt + col, inset: 0.55mm,
    box(width: 100%, height: 100%, radius: 0.7mm, stroke: 0.5pt + col,
      align(center + horizon, stack(spacing: 1.5mm, tri(true), tri(false)))))
  let leds = grid(
    columns: (1.6mm, auto), column-gutter: 0.6mm, row-gutter: 0.75mm, align: left + horizon,
    ..options.map(((k, lbl)) => {
      let on = k == value
      (
        circle(radius: 0.62mm, fill: if on { col } else { white }, stroke: 0.5pt + col),
        box(height: 1.8mm, align(horizon, text(size: 4.4pt, weight: if on { "extrabold" } else { "medium" }, fill: col, lbl))),
      )
    }).flatten(),
  )
  box(width: width, align(center, stack(
    spacing: 1.2mm,
    {
      let g = stack(dir: ltr, spacing: 1mm, align(horizon, btn), align(horizon, leds))
      if zone != none { box(height: zone, align(horizon, g)) } else { g }
    },
    ctl-label(name, active),
  )))
}

/// Inverseur à levier du minilogue XD (WAVE, DRIVE, TARGET…) : fente arrondie et
/// levier à la position choisie (haut / milieu / bas), libellés à droite.
/// Au-delà de 3 options (OCTAVE, VOICE MODE), levier au centre et colonne de LED.
#let toggle-xd(name, options, value, active: true, width: 14mm, zone: none) = {
  let col = if active { ink } else { muted }
  let n = options.len()
  let idx = options.position(((k, _)) => k == value)
  if idx == none { idx = 0 }
  let leds = n > 3
  let h = 9mm
  let steps = if leds { 2 } else { calc.max(n - 1, 1) }
  let lever-pos = if leds { 1 } else { idx }
  let slot = box(width: 3.4mm, height: h, radius: 1.7mm, stroke: 0.8pt + col, {
    place(dx: 0.45mm, dy: 0.45mm + lever-pos * (h - 0.9mm - 3.1mm) / steps, box(width: 2.5mm, height: 3.1mm, radius: 1.1mm, fill: col))
  })
  let labels = if leds {
    grid(
      columns: (1.6mm, auto), column-gutter: 0.6mm, row-gutter: 0.6mm, align: left + horizon,
      ..options.map(((k, lbl)) => {
        let on = k == value
        (circle(radius: 0.62mm, fill: if on { col } else { white }, stroke: 0.5pt + col),
         box(height: 1.7mm, align(horizon, text(size: 4.3pt, weight: if on { "extrabold" } else { "medium" }, fill: col, lbl))))
      }).flatten(),
    )
  } else {
    box(height: h, grid(
      rows: (1fr,) * n, align: left + horizon,
      ..options.map(((k, lbl)) => text(size: 4.4pt, weight: if k == value { "extrabold" } else { "medium" }, fill: col, lbl)),
    ))
  }
  box(width: width, align(center, stack(
    spacing: 1.2mm,
    {
      let g = stack(dir: ltr, spacing: 0.9mm, align(horizon, slot), align(horizon, labels))
      if zone != none { box(height: zone, align(horizon, g)) } else { g }
    },
    ctl-label(name, active),
  )))
}

/// Bouton poussoir de façade : rectangle aux coins légèrement arrondis (comme sur
/// le Messenger), plein = engagé, contour = désengagé ; `note` = mention entre
/// crochets imprimée au-dessus sur le panneau ([F ENV ASSIGN]…).
#let switch(name, on, active: true, width: 16mm, note: none) = {
  let col = if active { ink } else { muted }
  box(width: width, align(center, stack(
    spacing: 1mm,
    box(height: 2mm, align(bottom, if note != none { text(size: 4.2pt, weight: "semibold", fill: col, note) })),
    box(
      width: 9.6mm, height: 4.8mm, radius: 1.1mm,
      stroke: 0.9pt + col, fill: if on { col } else { white },
      align(center + horizon, text(size: 4.4pt, weight: "bold", fill: if on { white } else { col }, if on { "ON" } else { "OFF" })),
    ),
    ctl-label(name, active),
  )))
}

/// Bouton poussoir compact avec libellé intégré (destinations LFO 2…).
#let pill(label, on, active: true) = {
  let col = if active { ink } else { muted }
  box(
    width: 12mm, height: 3.8mm, radius: 1.1mm,
    stroke: 0.9pt + col, fill: if on { col } else { white },
    align(center + horizon, text(size: 4.8pt, weight: "bold", fill: if on { white } else { col }, label)),
  )
}

/// Rangée de contrôles centrée verticalement.
#let row(..items, gap: 0.6mm) = align(center, stack(dir: ltr, spacing: gap, ..items.pos().map(i => box(i))))

/// Indice de confiance : ●●● documenté, ●●○ déduit, ●○○ approximation.
#let confidence(n, fill: white) = {
  let labels = ("APPROXIMATION", "DÉDUIT", "DOCUMENTÉ")
  let n = calc.clamp(n, 1, 3)
  box(baseline: 0.3mm, for i in range(3) {
    box(circle(radius: 1.25mm, fill: if i < n { fill } else { none }, stroke: 0.8pt + fill))
    h(0.8mm)
  })
  h(1.2mm)
  text(size: 7pt, weight: "bold", fill: fill, tracking: 0.1em, labels.at(n - 1))
}

/// Texte libre venant du YAML : interprété comme du markup Typst
/// (`*CUTOFF*` → gras, comme les noms de contrôles dans les manuels Moog).
///
/// Syntaxe enrichie, convertie avant l'évaluation :
///   [3] ou [1][2]          → renvoi cliquable vers la source n (exposant)
///   [texte](https://…)    → lien intégré au texte
///   ^[texte de la note]    → note de bas de page (numérotée a, b, c…)
#let srcref(..ns) = {
  let ns = ns.pos()
  let parts = ns.map(n => context {
    let lbl = label("src-" + str(n))
    let t = text(weight: "extrabold", str(n))
    if query(lbl).len() > 0 { link(lbl, t) } else { t }
  })
  box(text(size: 0.72em, baseline: -0.42em, fill: ink, [\[] + parts.join(",") + [\]]))
}

#let _enrich(s) = {
  // liens [texte](url)
  s = s.replace(regex("\[([^\]\[]+)\]\((https?://[^)\s]+)\)"), m => {
    "#link(\"" + m.captures.at(1).replace("\"", "%22") + "\")[" + m.captures.at(0) + "]"
  })
  // renvois [1] / [1][2]
  s = s.replace(regex("( ?)((?:\[\d+\])+)"), m => {
    let nums = m.captures.at(1).matches(regex("\d+")).map(x => x.text)
    "#srcref(" + nums.join(", ") + ")"
  })
  // notes ^[...] (après les renvois : une note peut contenir [n] ou un lien)
  s = s.replace(regex("\^\[((?:[^\[\]]|\[[^\[\]]*\])*)\]"), m => "#footnote[" + m.captures.at(0).trim() + "]")
  s
}

#let md(s) = if s == none { [] } else { eval(_enrich(str(s)), mode: "markup", scope: (srcref: srcref)) }

/// Lien affiché proprement : sans https://, sans www., abrégé au milieu si trop long.
#let pretty-url(u, max: 92) = {
  let t = u.replace(regex("^https?://(www\.)?"), "").trim("/", at: end)
  if t.len() > max { t = t.slice(0, max - 22) + "…" + t.slice(t.len() - 20) }
  t
}

/// Encadré de texte en bas de fiche.
#let textbox(title, body, size: 6.9pt) = block(
  width: 100%, stroke: 0.9pt + ink, radius: 1.5pt, inset: 0pt, breakable: false,
  stack(
    block(width: 100%, inset: (x: 2.4mm, top: 1.8mm, bottom: 1.6mm), text(size: 7.2pt, weight: "extrabold", tracking: 0.06em, upper(title))),
    block(width: 100%, inset: (x: 2.4mm, bottom: 2mm), { set text(size: size); body }),
  ),
)

#let numbered(items) = {
  set par(leading: 0.5em)
  for (i, it) in items.enumerate() {
    grid(
      columns: (4.2mm, 1fr), gutter: 0.6mm,
      text(weight: "extrabold", if i < 9 { "0" + str(i + 1) } else { str(i + 1) }),
      md(it),
    )
    v(0.5mm)
  }
}

#let bullets(items) = {
  set par(leading: 0.5em)
  for it in items {
    // Puce dans la ligne : alignée sur la ligne de base ; retrait suspendu pour les lignes suivantes.
    block(above: 0pt, below: 1.3mm, par(hanging-indent: 3.4mm, box(width: 3.4mm, text(size: 1.25em, weight: "extrabold", "»")) + md(it)))
  }
}

/// Mise en page générique d'une fiche (pied de page, styles des liens et notes).
#let page-setup(body, fichier: none) = {
  set page(paper: "a4", flipped: true, margin: (x: 12mm, top: 10mm, bottom: 15mm), footer-descent: 4.5mm, footer: context {
    set text(size: 5.8pt, fill: luma(90))
    line(length: 100%, stroke: 0.5pt + muted)
    v(-1.2mm)
    if counter(page).get().first() == 1 {
      grid(
        columns: (1fr, auto), gutter: 3mm,
        [*ANATOMIE DU SON* #h(1mm) page 2 : analyse, courbes, sources],
        [SYNTHKNOWLEDGE · gris = valeur neutre (patch INIT), noir = réglage de la fiche],
      )
    } else {
      [SYNTHKNOWLEDGE · page 2 : anatomie du son. Les réglages sont en page 1#if fichier != none [ (fichier #fichier)].]
    }
  })
  set text(font: font, size: 7.4pt, lang: "fr", fill: ink)
  set par(justify: false, leading: 0.55em)
  show link: it => if type(it.dest) == str { underline(stroke: 0.45pt + luma(130), offset: 1.6pt, it) } else { it }
  set footnote(numbering: "a")
  set footnote.entry(separator: line(length: 22%, stroke: 0.5pt + ink), clearance: 2.5mm, gap: 1.2mm, indent: 0mm)
  show footnote.entry: it => {
    let num = numbering("a", ..counter(footnote).at(it.note.location()))
    set text(size: 6.6pt, fill: luma(40))
    grid(columns: (3.4mm, 1fr), text(weight: "extrabold", fill: ink, num), it.note.body)
  }
  show footnote: set text(weight: "bold")
  body
}

#let header(machine, data) = {
  let ref = data.at("reference", default: (:))
  block(width: 100%, fill: ink, inset: (x: 5mm, y: 3.4mm), radius: 1.5pt, {
    grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      {
        text(white, size: 7pt, weight: "bold", tracking: 0.32em, upper(machine) + "  ·  FICHE SON")
        v(1.2mm)
        text(white, size: 20pt, weight: "extrabold", tracking: 0.02em, upper(data.titre))
      },
      {
        confidence(data.at("confiance", default: 1))
        v(1.6mm)
        let cats = (data.at("categorie", default: none),).filter(x => x != none) + data.at("tags", default: ())
        text(white, size: 6.6pt, weight: "semibold", tracking: 0.12em, upper(cats.map(str).join("  ·  ")))
      },
    )
  })
  v(2mm)
  let parts = ()
  if ref.at("artiste", default: none) != none { parts.push(text(weight: "extrabold", upper(ref.artiste))) }
  if ref.at("morceau", default: none) != none { parts.push(ref.morceau) }
  if ref.at("annee", default: none) != none { parts.push(str(ref.annee)) }
  if ref.at("passage", default: none) != none { parts.push(text(style: "italic", ref.passage)) }
  if ref.at("synthe_origine", default: none) != none { parts.push([Original : #ref.synthe_origine]) }
  if parts.len() > 0 { text(size: 8pt, parts.join(h(1.2mm) + text(fill: muted, "|") + h(1.2mm))) }
  if data.at("resume", default: none) != none {
    v(0.4mm)
    block(width: 100%, text(size: 7.6pt, md(data.resume)))
  }
  v(1.6mm)
}

/// Courbe d'enveloppe dessinée d'après les réglages.
/// a, d, r : temps normalisés 0-1 (position du potard) ; s : niveau 0-1.
/// sustain: false → enveloppe AD (pas de palier ni de release).
/// Durée d'une enveloppe en « unités » (A + D [+ palier + R]) : sert à mettre
/// plusieurs courbes à la même échelle, la plus longue remplissant la largeur.
#let env-units(a, d, r, sustain: true) = {
  let u(x) = 0.04 + 0.96 * calc.clamp(x, 0, 1)
  u(a) + u(d) + (if sustain { 0.55 + u(r) } else { 0 })
}

#let env-plot(a, d, s, r, title, sub: none, sustain: true, width: 84mm, height: 24mm, span: none, muted-curve: false) = {
  // span : nombre d'unités représenté par toute la largeur (défaut : cette courbe seule).
  let span = if span == none { env-units(a, d, r, sustain: sustain) } else { span }
  let seg = width * 0.97 / span
  let hold = if sustain { seg * 0.55 } else { 0mm }
  let t(x) = (0.04 + 0.96 * calc.clamp(x, 0, 1)) * seg
  let ta = t(a)
  let td = t(d)
  let tr = if sustain { t(r) } else { 0mm }
  let s = if sustain { calc.clamp(s, 0, 1) } else { 0 }
  let y(l) = height * (1 - l)
  let n = 16
  let pts = ((0mm, y(0)), (ta, y(1)))
  for k in range(1, n + 1) {
    let l = s + (1 - s) * calc.exp(-4.5 * k / n)
    pts.push((ta + td * k / n, y(if k == n { s } else { l })))
  }
  let x1 = ta + td
  if sustain {
    pts.push((x1 + hold, y(s)))
    for k in range(1, n + 1) {
      pts.push((x1 + hold + tr * k / n, y(if k == n { 0 } else { s * calc.exp(-4.5 * k / n) })))
    }
  }
  let xend = x1 + hold + tr
  box(width: width, {
    text(size: 6.4pt, weight: "extrabold", tracking: 0.08em, upper(title))
    if sub != none { h(1.5mm); text(size: 6pt, fill: luma(80), sub) }
    v(0.6mm)
    box(width: width, height: height + 3mm, {
      place(line(start: (0mm, height), end: (width, height), stroke: 0.5pt + muted))
      place(curve(fill: soft, stroke: none, curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p)), curve.line((xend, height)), curve.close()))
      place(curve(stroke: (paint: if muted-curve { muted } else { ink }, thickness: 1.2pt, join: "round"), curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p))))
      let lab(x0, x1, l) = place(dx: x0, dy: height + 0.6mm, box(width: calc.max(x1 - x0, 2mm), align(center, text(size: 6pt, weight: "bold", fill: luma(70), l))))
      lab(0mm, ta, "A")
      lab(ta, x1, "D")
      if sustain {
        lab(x1, x1 + hold, "S")
        lab(x1 + hold, xend, "R")
      }
    })
  })
}

/// Page 2 : anatomie du son (courbes d'enveloppes, analyse par bloc), puis
/// d'où viennent les infos (confiance, documenté / reconstitué, sources).
/// envs : liste de (titre, a, d, s, r, sub, sustain) calculée par la façade.
#let sources-page(machine, data, envs: ()) = {
  set page(flipped: true)
  pagebreak(weak: true)
  let ref = data.at("reference", default: (:))
  if ref == none { ref = (:) }
  let n = calc.clamp(data.at("confiance", default: 1), 1, 3)
  let meaning = (
    "Rien de spécifique trouvé : reconstitution d'après le style, l'époque et le genre.",
    "Synthé d'origine et nature du son établis par les sources ; réglages reconstitués.",
    "Réglages ou patch publiés par une source fiable (manuel, interview, patch sheet).",
  )
  block(width: 100%, fill: ink, inset: (x: 5mm, y: 3.4mm), radius: 1.5pt, grid(
    columns: (1fr, auto), align: (left + bottom, right + bottom),
    {
      text(white, size: 7pt, weight: "bold", tracking: 0.32em, upper(machine) + "  ·  ANATOMIE DU SON")
      v(1.2mm)
      text(white, size: 16pt, weight: "extrabold", tracking: 0.02em, upper(data.titre))
    },
    confidence(n),
  ))
  v(2.4mm)
  let note-env = text(size: 6pt, fill: luma(80), style: "italic", "Allure dessinée d'après les réglages de la page 1, même échelle de temps pour les deux courbes (la plus longue occupe toute la largeur) ; durées non calibrées en secondes.")
  // Échelle commune : la plus longue des enveloppes remplit la largeur.
  // (une enveloppe sans effet, ex. EG AMOUNT à midi, ne dicte pas l'échelle)
  let live = envs.filter(e => not e.at("inactive", default: false))
  if live.len() == 0 { live = envs }
  let span = calc.max(..live.map(e => env-units(e.a, e.d, e.r, sustain: e.at("sustain", default: true))), 0.1)
  let plot(e, w, h) = {
    let off = e.at("inactive", default: false)
    env-plot(e.a, e.d, e.s, e.r, e.titre, sub: e.at("sub", default: none), sustain: e.at("sustain", default: true), width: w, height: h, span: if off { none } else { span }, muted-curve: off)
  }
  let an = data.at("analyse", default: ())
  if an == none { an = () }
  let boxes = an.map(x => textbox(size: 8pt, x.titre, { set par(leading: 0.6em); md(x.texte) }))
  // Paysage : enveloppes empilées à gauche, analyse 2 × 2 à droite.
  grid(
    columns: (96mm, 1fr), column-gutter: 2mm,
    if envs.len() > 0 {
      textbox(size: 7.4pt, "Les enveloppes, en image", {
        stack(spacing: 2.4mm, ..envs.map(e => plot(e, 88mm, 19mm)))
        v(0.4mm)
        note-env
      })
    },
    grid(columns: (1fr, 1fr), column-gutter: 2mm, row-gutter: 2mm, ..boxes),
  )
  v(2mm)

  let notes = data.at("tracabilite", default: ())
  if notes == none { notes = () }
  let src = data.at("sources", default: ())
  if src == none { src = () }
  let origin-part = {
    let bits = ()
    if ref.at("synthe_origine", default: none) != none { bits.push([*Original :* #md(str(ref.synthe_origine))]) }
    bits.push([*Confiance :* #confidence(n, fill: ink) #h(1mm) #meaning.at(n - 1)])
    for b in bits { block(above: 0pt, below: 1.4mm, b) }
    if notes.len() > 0 { bullets(notes) }
  }
  let sources-part = {    text(size: 6.4pt, weight: "extrabold", tracking: 0.1em, "SOURCES")
    v(0.4mm)
    set par(leading: 0.5em)
    if src.len() == 0 {
      text(fill: luma(90), "Aucune source spécifique : reconstitution d'après les connaissances générales de synthèse.")
    } else {
      for (i, s) in src.enumerate() {
        let body = if type(s) == dictionary {
          let meta = (s.at("site", default: none), s.at("date", default: none)).filter(x => x != none).map(str)
          text(weight: "bold", md(s.at("titre", default: "")))
          if meta.len() > 0 { h(1.2mm); text(fill: luma(90), meta.join(", ")) }
          let u = s.at("url", default: none)
          let note = s.at("note", default: none)
          if u != none or note != none { linebreak() }
          if u != none { link(u, text(size: 0.92em, pretty-url(u))); h(0.6mm); text(size: 0.85em, fill: luma(60), "↗") }
          if u != none and note != none { h(1.2mm); text(fill: muted, "·"); h(1.2mm) }
          if note != none { text(style: "italic", fill: luma(70), md(note)) }
        } else { md(s) }
        [#grid(columns: (5mm, 1fr), gutter: 0.6mm, text(weight: "extrabold", "[" + str(i + 1) + "]"), body)#label("src-" + str(i + 1))]
        v(1mm)
      }
    }
  }
  textbox(size: 7.4pt, "D'où ça vient",
    grid(columns: (1fr, 1fr), column-gutter: 5mm, origin-part, grid.cell(stroke: (left: 0.4pt + muted), inset: (left: 4mm), sources-part)))
}
