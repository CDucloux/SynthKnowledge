// Synther : encadré « Séquence » (grille de pas à la place de l'encadré
// « Jeu » en page 1).
//
// `steps` est un texte de jetons séparés par des espaces : note (« Bb4 »,
// « C5 », « F#3 ») ou accord (« G3+Bb3+D4 »), « . » = silence, « _ » =
// liaison avec le pas précédent, « | » = séparateur ignoré.

#import "theme.typ": font-size, grey, ink, muted, soft
#import "markup.typ": md
#import "icons.typ": icon-steps
#import "boxes.typ": bullet-mark, bullets, textbox

/// Pas 16 par rangée, comme les boutons 1-16 du séquenceur.
#let _steps-per-row = 16

/// Jetons d'une séquence (séparateurs « | » retirés).
#let sequence-tokens(steps) = str(steps).split(regex("\\s+")).filter(token => token != "" and token != "|")

/// Nom de note en solfège français, octave en petit : « Bb4 » → « Si♭ 4 ».
/// La numérotation des octaves est celle du YAML (voir
/// knowledge/machines/<machine>.md). Un jeton inconnu est affiché tel quel.
#let french-note(note, size: font-size.note) = {
  let parsed = str(note).match(regex("^([A-G])([b#]?)(-?\\d)$"))
  if parsed == none { return text(weight: "extrabold", str(note)) }
  let (letter, accidental, octave) = parsed.captures
  let name = ("C": "Do", "D": "Ré", "E": "Mi", "F": "Fa", "G": "Sol", "A": "La", "B": "Si").at(letter)
  box(text(size: size, weight: "extrabold", name)
    + (if accidental != "" { text(size: size * 0.8, weight: "extrabold", accidental) } else { [] })
    + text(size: size * 0.72, weight: "semibold", fill: grey.label, octave))
}

/// Encadré « Séquence » : réglages de lecture, grille des pas (une rangée
/// par 16 pas, petit écart entre les temps), transpositions au clavier,
/// puis les conseils de jeu.
/// - `sequence` : bloc `sequence` du YAML.
/// - `spec` : `extra.sequence` du schéma de la machine (libellé, unité et
///   valeur neutre des réglages, aide à la transposition).
/// - `playing` : textes de jeu, en puces sous la grille.
#let sequence-box(sequence, spec, playing: ()) = {
  let tokens = sequence-tokens(sequence.steps)
  let count = tokens.len()
  // Accord : notes empilées, la plus aiguë en haut ; la case grandit avec
  // le plus gros accord.
  let chord-notes(token) = token.split("+").rev()
  let max-notes = calc.max(1, ..tokens.map(token => chord-notes(token).len()))
  let note-size = if max-notes == 1 { font-size.step-note } else { font-size.step-chord }
  let cell-height = if max-notes == 1 { 4.6mm } else { max-notes * 2.3mm + 1mm }

  let cell-content(token) = {
    if token == "." { return [] }
    if token == "_" { return align(horizon, line(length: 100%, stroke: 1.4pt + ink)) }
    place(center + horizon, stack(spacing: 0.45mm,
      ..chord-notes(token).map(note => french-note(note, size: note-size))))
  }
  let step-cell(token) = {
    let beyond-end = token == none
    let silent = token == "."
    box(width: 100%, height: cell-height,
      fill: if silent { soft } else { white },
      stroke: if beyond-end { 0.4pt + muted } else if silent { 0.4pt + grey.rule } else { 0.7pt + ink },
      inset: (x: if token == "_" { 0mm } else { 0.2mm }),
      if beyond-end { [] } else { cell-content(token) })
  }
  let step-row(row) = {
    let first = row * _steps-per-row
    let cells = ()
    for column in range(_steps-per-row) {
      cells.push(step-cell(tokens.at(first + column, default: none)))
      if column in (3, 7, 11) { cells.push([]) }  // écart entre les temps
    }
    grid(
      columns: (5mm,) + ((1fr,) * 4 + (0.8mm,)) * 3 + (1fr,) * 4, column-gutter: 0.35mm,
      align(left + horizon, text(size: font-size.step-number, weight: "extrabold", fill: grey.label,
        str(first + 1) + "\n" + str(first + _steps-per-row))),
      ..cells,
    )
  }

  let setting(label, value) = text(weight: "extrabold", upper(label)) + " " + value
  let settings = ()
  for (key, field-spec) in spec.fields {
    let value = sequence.at(key, default: field-spec.default)
    if field-spec.at("hide", default: false) and value == field-spec.default { continue }
    settings.push(setting(field-spec.label, str(value) + field-spec.unit))
    if key == "tempo" { settings.push(setting("Length", str(count))) }
  }

  textbox("Séquence", icon: icon-steps, {
    set par(leading: 0.45em)
    text(size: font-size.sequence-settings, settings.join(h(1.2mm) + "·" + h(1.2mm)))
    v(0.2mm)
    stack(spacing: 0.7mm, ..range(calc.ceil(count / _steps-per-row)).map(step-row))
    v(1mm)
    let transpose = sequence.at("transpose", default: none)
    if transpose != none and transpose.len() > 0 {
      let hint = spec.at("transpose_hint", default: "touche tenue")
      block(below: 1.2mm, par(hanging-indent: 3.4mm, bullet-mark
        + text(weight: "extrabold", "TRANSPOSER") + " (" + hint + ") : "
        + transpose.map(item => french-note(item.key, size: 1em) + " " + md(item.text)).join(" · ")))
    }
    bullets(playing)
  })
}
