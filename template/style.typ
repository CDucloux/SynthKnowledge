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

/// Petit écran (affichage OLED du MULTI ENGINE, types d'effets…).
#let screen(name, txt, active: true, width: 20mm) = {
  let col = if active { ink } else { muted }
  box(width: width, align(center, stack(
    spacing: 1mm,
    box(width: width - 3mm, height: 6mm, radius: 1pt, fill: col,
      align(center + horizon, text(size: 6pt, weight: "bold", fill: white, str(txt)))),
    ctl-label(name, active),
  )))
}

/// Sélecteur à LED (comme OCTAVE / MODE / DESTINATION sur le Messenger).
/// `options` : tableau de (clé, libellé) dans l'ordre vertical du panneau.
#let selector(name, options, value, active: true, width: 22mm) = {
  let col = if active { ink } else { muted }
  box(width: width, align(center, stack(
    spacing: 1.2mm,
    box(stroke: 0.7pt + col, radius: 1.2pt, inset: (x: 1.6mm, y: 1.3mm), align(left, stack(
      spacing: 1.05mm,
      ..options.map(((k, lbl)) => {
        let on = k == value
        box(height: 2.1mm, {
          box(baseline: 0.15mm, circle(
            radius: 0.85mm,
            fill: if on { col } else { white },
            stroke: 0.6pt + col,
          ))
          h(1.2mm)
          text(size: 5.2pt, weight: if on { "extrabold" } else { "medium" }, fill: col, lbl)
        })
      }),
    ))),
    ctl-label(name, active),
  )))
}

/// Bouton poussoir lumineux : plein = engagé, contour = désengagé.
#let switch(name, on, active: true, width: 16mm) = {
  let col = if active { ink } else { muted }
  box(width: width, align(center, stack(
    spacing: 1mm,
    box(
      width: 10mm, height: 3.6mm, radius: 1.8mm,
      stroke: 0.9pt + col, fill: if on { col } else { white },
      align(center + horizon, text(size: 4.6pt, weight: "bold", fill: if on { white } else { col }, if on { "ON" } else { "OFF" })),
    ),
    ctl-label(name, active),
  )))
}

/// Bouton poussoir compact avec libellé intégré (destinations LFO 2…).
#let pill(label, on, active: true) = {
  let col = if active { ink } else { muted }
  box(
    width: 12mm, height: 3.6mm, radius: 1.8mm,
    stroke: 0.9pt + col, fill: if on { col } else { white },
    align(center + horizon, text(size: 4.8pt, weight: "bold", fill: if on { white } else { col }, label)),
  )
}

/// Section de panneau encadrée, avec onglet titre noir.
#let section(title, body, inset: 2.2mm, height: 100%) = block(
  width: 100%, height: height, stroke: 0.9pt + ink, radius: 1.5pt, inset: 0pt, clip: true,
  stack(
    box(fill: ink, inset: (x: 2mm, y: 1.1mm), text(white, size: 6.4pt, weight: "extrabold", tracking: 0.08em, upper(title))),
    block(width: 100%, inset: inset, body),
  ),
)

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
#let md(s) = if s == none { [] } else { eval(str(s), mode: "markup") }

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

/// Mise en page générique d'une fiche (en-tête, schéma, encadrés, pied).
#let page-setup(body) = {
  set page(paper: "a4", margin: (x: 12mm, top: 10mm, bottom: 10mm))
  set text(font: font, size: 7.4pt, lang: "fr", fill: ink)
  set par(justify: false, leading: 0.55em)
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

#let footer-line(data) = {
  set text(size: 5.8pt, fill: luma(90))
  line(length: 100%, stroke: 0.5pt + muted)
  v(-1mm)
  grid(
    columns: (1fr, auto), gutter: 3mm,
    [*SOURCES ET TRAÇABILITÉ* #h(1mm) page 2],
    [SYNTHKNOWLEDGE · gris = valeur neutre (patch INIT), noir = réglage de la fiche],
  )
}

/// Page 2 : traçabilité (référence, niveau de confiance, sources numérotées).
#let sources-page(machine, data) = {
  pagebreak()
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
      text(white, size: 7pt, weight: "bold", tracking: 0.32em, upper(machine) + "  ·  SOURCES ET TRAÇABILITÉ")
      v(1.2mm)
      text(white, size: 16pt, weight: "extrabold", tracking: 0.02em, upper(data.titre))
    },
    confidence(n),
  ))
  v(3mm)
  let field(k, v) = (text(weight: "extrabold", size: 7.6pt, upper(k)), if v == none { text(fill: muted, "non renseigné") } else { md(str(v)) })
  textbox(size: 8pt, "Référence", table(
    columns: (32mm, 1fr), stroke: none, inset: (x: 0mm, y: 1mm),
    ..field("Artiste", ref.at("artiste", default: none)),
    ..field("Morceau", ref.at("morceau", default: none)),
    ..field("Année", ref.at("annee", default: none)),
    ..field("Passage", ref.at("passage", default: none)),
    ..field("Synthé d'origine", ref.at("synthe_origine", default: none)),
    ..field("Fichier", data.at("_fichier", default: none)),
  ))
  v(2mm)
  textbox(size: 8pt, "Niveau de confiance", {
    confidence(n, fill: ink)
    h(3mm)
    meaning.at(n - 1)
  })
  v(2mm)
  let notes = data.at("tracabilite", default: ())
  if notes != none and notes.len() > 0 {
    textbox(size: 8pt, "Ce qui est documenté, ce qui est reconstitué", bullets(notes))
    v(2mm)
  }
  let src = data.at("sources", default: ())
  if src == none { src = () }
  textbox(size: 8pt, "Sources", if src.len() == 0 {
    text(fill: luma(90), "Aucune source spécifique : reconstitution d'après les connaissances générales de synthèse.")
  } else {
    set par(leading: 0.55em)
    for (i, s) in src.enumerate() {
      grid(columns: (6mm, 1fr), gutter: 0.6mm, text(weight: "extrabold", "[" + str(i + 1) + "]"), md(s))
      v(1.2mm)
    }
  })
  v(1fr)
  set text(size: 5.8pt, fill: luma(90))
  line(length: 100%, stroke: 0.5pt + muted)
  v(-1mm)
  [SYNTHKNOWLEDGE · page 2 : traçabilité. Les réglages sont en page 1.]
}
