// Synther : pages d'une fiche son (A4 paysage).
// Page 1 : bandeau, référence, façade, cadre annexe, étapes, ajustements,
// jeu (ou séquence). Page 2 « Anatomie du son » : courbes d'enveloppe,
// analyse, puis « D'où ça vient » (confiance, traçabilité, sources).

#import "theme.typ": font, ink, muted, ui
#import "markup.typ": md, short-url
#import "icons.typ": auto-icon, icon-ear, icon-env, icon-keys, icon-knob, icon-source
#import "boxes.typ": bullets, confidence, numbered, textbox
#import "params.typ": field
#import "sequence.typ": sequence-box
#import "envelopes.typ": env-plot, env-units

/// Réglages communs des pages : format, police, pied de page, liens
/// soulignés, notes de bas de page numérotées a, b, c…
/// - `file` : chemin du YAML, rappelé en pied de page 2.
#let page-setup(body, file: none) = {
  set page(paper: "a4", flipped: true, margin: (x: 12mm, top: 10mm, bottom: 15mm), footer-descent: 4.5mm, footer: context {
    set text(size: 5.8pt, fill: luma(90))
    line(length: 100%, stroke: 0.5pt + muted)
    v(-1.2mm)
    if counter(page).get().first() == 1 {
      grid(
        columns: (1fr, auto), gutter: 3mm,
        [*ANATOMIE DU SON* #h(1mm) page 2 : analyse, courbes, sources],
        [SYNTHER · gris = valeur neutre (patch INIT), noir = réglage de la fiche],
      )
    } else {
      [SYNTHER · page 2 : anatomie du son. Les réglages sont en page 1#if file != none [ (fichier #file)].]
    }
  })
  set text(font: font, size: 7.4pt, lang: "fr", fill: ink)
  set par(justify: false, leading: 0.55em)
  // Liens web soulignés ; les renvois internes ([n] → source) restent nus.
  show link: element => if type(element.dest) == str {
    underline(stroke: 0.45pt + luma(130), offset: 1.6pt, element)
  } else { element }
  set footnote(numbering: "a")
  set footnote.entry(separator: line(length: 22%, stroke: 0.5pt + ink), clearance: 2.5mm, gap: 1.2mm, indent: 0mm)
  show footnote.entry: entry => {
    let letter = numbering("a", ..counter(footnote).at(entry.note.location()))
    set text(size: 6.6pt, fill: luma(40))
    grid(columns: (3.4mm, 1fr), text(weight: "extrabold", fill: ink, letter), entry.note.body)
  }
  show footnote: set text(weight: "bold")
  body
}

/// Bandeau noir commun aux pages 1 et 2 (même hauteur sur les deux) :
/// machine et type de page, titre ; confiance et catégorie / tags à droite.
#let title-bar(machine, kind, data) = block(width: 100%, fill: ink, inset: (x: 5mm, y: 3mm), grid(
  columns: (1fr, auto),
  align: (left + bottom, right + bottom),
  {
    text(white, size: 7pt, weight: "bold", tracking: 0.32em, upper(machine) + "  ·  " + upper(kind))
    v(1.2mm)
    text(white, size: 20pt, weight: "extrabold", tracking: 0.02em, upper(data.title))
  },
  {
    confidence(field(data, "confidence", 1))
    v(1.6mm)
    let category = field(data, "category", none)
    let labels = (if category != none { (category,) } else { () }) + field(data, "tags", ())
    text(white, size: 6.6pt, weight: "semibold", tracking: 0.12em, upper(labels.map(str).join("  ·  ")))
  },
))

/// En-tête de la page 1 : bandeau, ligne de référence (artiste | morceau |
/// année | partie | synthé d'origine), résumé.
#let header(machine, data) = {
  let reference = field(data, "reference", (:))
  title-bar(machine, "Fiche son", data)
  v(2mm)
  // (clé de `reference`, rendu) dans l'ordre d'affichage ; clé absente = omise.
  let reference-items = (
    ("artist", artist => text(weight: "extrabold", upper(artist))),
    ("song", song => song),
    ("year", year => str(year)),
    ("part", part => text(style: "italic", part)),
    ("original_synth", synth => [Original : #synth]),
  )
  let parts = reference-items
    .filter(((key, _)) => field(reference, key, none) != none)
    .map(((key, render)) => render(reference.at(key)))
  if parts.len() > 0 { text(size: 8pt, parts.join(h(1.2mm) + text(fill: muted, "|") + h(1.2mm))) }
  let summary = field(data, "summary", none)
  if summary != none {
    v(0.4mm)
    block(width: 100%, text(size: 7.6pt, md(summary)))
  }
  v(1.6mm)
}

/// Une source de la page 2 : titre en gras, site et date, lien abrégé,
/// note en italique. Une source peut aussi être un simple texte.
#let _source-entry(source) = {
  if type(source) != dictionary { return md(source) }
  let details = (field(source, "site", none), field(source, "date", none)).filter(detail => detail != none).map(str)
  text(weight: "bold", md(field(source, "title", "")))
  if details.len() > 0 { h(1.2mm); text(fill: luma(90), details.join(", ")) }
  let url = field(source, "url", none)
  let note = field(source, "note", none)
  if url != none or note != none { linebreak() }
  if url != none { link(url, text(size: 0.92em, short-url(url))); h(0.6mm); text(size: 0.85em, fill: luma(60), "↗") }
  if url != none and note != none { h(1.2mm); text(fill: muted, "·"); h(1.2mm) }
  if note != none { text(style: "italic", fill: luma(70), md(note)) }
}

/// Page 2 « Anatomie du son » : courbes d'enveloppe et analyse 2 × 2, puis
/// « D'où ça vient » (confiance et traçabilité à gauche, sources à droite).
/// - `envs` : entrées `env-entry` préparées par la façade.
#let sources-page(machine, data, envs: ()) = {
  set page(flipped: true)
  pagebreak(weak: true)
  let reference = field(data, "reference", (:))
  let level = calc.clamp(field(data, "confidence", 1), 1, 3)
  let meanings = (
    "Rien de spécifique trouvé : reconstitution d'après le style, l'époque et le genre.",
    "Synthé d'origine et nature du son établis par les sources ; réglages reconstitués.",
    "Réglages ou patch publiés par une source fiable (manuel, interview, patch sheet).",
  )
  title-bar(machine, "Anatomie du son", data)
  v(2.4mm)

  // Échelle commune : la plus longue des enveloppes actives remplit la
  // largeur (une enveloppe sans effet, ex. EG AMOUNT à midi, ne la dicte pas).
  let active-envs = envs.filter(entry => not entry.inactive)
  if active-envs.len() == 0 { active-envs = envs }
  let span = calc.max(..active-envs.map(env-units), 0.1)
  let plot(entry) = env-plot(entry, width: 88mm, height: 19mm,
    span: if entry.inactive { none } else { span }, muted-curve: entry.inactive)
  let envelope-note = text(size: 6pt, fill: luma(80), style: "italic", "Allure dessinée d'après les réglages de la page 1, même échelle de temps pour les deux courbes (la plus longue occupe toute la largeur) ; durées non calibrées en secondes.")
  let analysis-boxes = field(data, "analysis", ()).map(analysis => textbox(size: 8pt, analysis.title,
    icon: auto-icon(analysis.title), { set par(leading: 0.6em); md(analysis.text) }))
  // Enveloppes empilées à gauche, analyse 2 × 2 à droite.
  grid(
    columns: (96mm, 1fr), column-gutter: 2mm,
    if envs.len() > 0 {
      textbox(size: 7.4pt, "Les enveloppes, en image", icon: icon-env, {
        stack(spacing: 2.4mm, ..envs.map(plot))
        v(0.4mm)
        envelope-note
      })
    },
    grid(columns: (1fr, 1fr), column-gutter: 2mm, row-gutter: 2mm, ..analysis-boxes),
  )
  v(2mm)

  let traceability = field(data, "traceability", ())
  let sources = field(data, "sources", ())
  let origin-part = {
    let facts = ()
    let original = field(reference, "original_synth", none)
    if original != none { facts.push([*Original :* #md(str(original))]) }
    facts.push([*Confiance :* #confidence(level, fill: ink) #h(1mm) #meanings.at(level - 1)])
    for fact in facts { block(above: 0pt, below: 1.4mm, fact) }
    if traceability.len() > 0 { bullets(traceability) }
  }
  let sources-part = {
    text(size: 6.4pt, weight: "extrabold", tracking: 0.1em, "SOURCES")
    v(0.4mm)
    set par(leading: 0.5em)
    if sources.len() == 0 {
      text(fill: luma(90), "Aucune source spécifique : reconstitution d'après les connaissances générales de synthèse.")
    } else {
      for (index, source) in sources.enumerate() {
        let number = str(index + 1)
        // Étiquette <src-n> : cible des renvois [n] des textes.
        [#grid(columns: (5mm, 1fr), gutter: 0.6mm, text(weight: "extrabold", "[" + number + "]"), _source-entry(source))#label("src-" + number)]
        v(1mm)
      }
    }
  }
  textbox(size: 7.4pt, "D'où ça vient", icon: icon-source,
    grid(columns: (1fr, 1fr), column-gutter: 5mm, origin-part,
      grid.cell(stroke: (left: 0.4pt + muted), inset: (left: 4mm), sources-part)))
}

/// Fiche complète (2 pages paysage).
/// - `machine` : nom affiché (« Moog Messenger »).
/// - `data` : YAML de la fiche (`_file` = chemin, ajouté par sheet.typ).
/// - `panel` : façade ; `aside` : cadre sous la façade, à gauche.
/// - `envs` : courbes de la page 2 ; `sequence-spec` : `extra.sequence` du
///   schéma (si la fiche a un bloc `sequence`).
#let sheet(machine, data, panel: none, aside: none, envs: (), sequence-spec: none) = {
  show: page-setup.with(file: field(data, "_file", none))
  header(machine, data)
  panel
  v(0.6mm)
  let sequence = field(data, "sequence", none)
  let playing = field(data, "playing", ())
  grid(
    columns: (ui.aside, 1fr, 1.12fr), column-gutter: ui.gap,
    aside,
    textbox("Pour l'obtenir", icon: icon-knob, numbered(field(data, "steps", ()))),
    stack(spacing: 1.6mm,
      textbox("Ajuster à l'oreille", icon: icon-ear, bullets(field(data, "tweaks", ()))),
      if sequence != none {
        sequence-box(sequence, sequence-spec, playing: playing)
      } else {
        textbox("Jeu", icon: icon-keys, bullets(playing))
      },
    ),
  )
  sources-page(machine, data, envs: envs)
}
