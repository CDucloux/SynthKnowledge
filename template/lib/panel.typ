// Synther : mise en page des façades, sans cotes en dur.
// Une façade = `panel-frame(panel-band((section, …)))` ; chaque section =
// (title: …, cols: n, cells: (…)). Les tailles d'une façade dérivent de la
// taille de son potard, les espacements du dictionnaire `ui`.

#import "theme.typ": ink, ui

/// Titre de section de façade : centré, sans onglet, comme sur le panneau.
#let section-title(title) = align(center + top, text(size: 7.2pt, weight: "extrabold", tracking: 0.16em, upper(title)))

/// Cellules d'une section placées dans la grille de la façade, à partir de
/// la colonne `first-column` : le titre sur la rangée 0, puis les cellules
/// ligne par ligne (comme une grille Typst), fusions colspan / rowspan
/// comprises, sur `rows` rangées.
#let _section-cells(section, first-column, rows) = {
  let cells = (grid.cell(x: first-column, y: 0, colspan: section.cols, inset: (bottom: ui.title-gap),
    section-title(section.title)),)
  let occupied = range(rows).map(_ => range(section.cols).map(_ => false))
  let (row, column) = (0, 0)
  for item in section.cells {
    // Première case libre (une fusion précédente a pu la prendre).
    while row < rows and occupied.at(row).at(column) {
      column += 1
      if column >= section.cols { column = 0; row += 1 }
    }
    assert(row < rows, message: "Section « " + section.title + " » : trop de cellules pour "
      + str(rows) + " rangées de " + str(section.cols) + " colonnes")
    let fields = if type(item) == content and item.func() == grid.cell { item.fields() } else { (body: item) }
    let colspan = fields.at("colspan", default: 1)
    let rowspan = fields.at("rowspan", default: 1)
    for row-offset in range(rowspan) {
      for column-offset in range(colspan) { occupied.at(row + row-offset).at(column + column-offset) = true }
    }
    cells.push(grid.cell(x: first-column + column, y: row + 1, colspan: colspan, rowspan: rowspan,
      align: fields.at("align", default: center + top), fields.body))
    column += colspan
    if column >= section.cols { column = 0; row += 1 }
  }
  cells
}

/// Façade en une seule grille : sections côte à côte, séparées par un filet.
/// Colonnes à la largeur de leur contenu, rangées à la hauteur du plus grand
/// contenu (l'alignement entre sections est donc automatique) ; l'espace
/// restant se répartit entre les sections.
/// Si la façade ne tient pas en largeur, la compilation échoue en donnant la
/// largeur de chaque section.
/// - `sections` : liste de (title:, cols:, cells:).
/// - `rows` : rangées de commandes par section.
#let panel-band(sections, rows: 3) = layout(size => {
  let available = size.width
  let widths = sections.map(section => measure(grid(
    columns: (auto,) * section.cols, column-gutter: ui.col-gap, .._section-cells(section, 0, rows),
  )).width)
  let needed = widths.sum() + sections.len() * ui.section-gap
  if needed > available {
    let mm(length) = str(calc.round(length.mm(), digits: 1)) + " mm"
    let detail = sections.zip(widths).map(((section, width)) => upper(section.title) + " " + mm(width)).join(", ")
    panic("Façade trop large de " + mm(needed - available) + " (place : " + mm(available) + ") : "
      + detail + ". Réduire une section ou la taille des potards.")
  }
  // Colonnes : marge souple, puis pour chaque section ses colonnes, séparées
  // de la suivante par deux colonnes souples avec le filet entre les deux.
  let columns = (1fr,)
  let cells = ()
  let separators = ()
  let next-column = 1
  for (index, section) in sections.enumerate() {
    if index > 0 {
      columns += (1fr, 1fr)
      separators.push(next-column + 1)
      next-column += 2
    }
    cells += _section-cells(section, next-column, rows)
    columns += (auto,) * section.cols
    next-column += section.cols
  }
  columns.push(1fr)
  grid(
    columns: columns, rows: (auto,) * (rows + 1), column-gutter: ui.col-gap,
    row-gutter: (0mm,) + (ui.row-gap,) * (rows - 1), align: center + top,
    ..separators.map(column => grid.vline(x: column, stroke: 0.6pt + ink)),
    ..cells,
  )
})

/// Cadre de la façade (filet noir, coins droits).
#let panel-frame(body) = block(width: 100%, stroke: 0.8pt + ink, inset: (x: 0mm, top: 2.6mm, bottom: 1.6mm), body)

/// Encadré annexe sous la façade (contrôleur main gauche, PROGRAM EDIT…).
#let aside-section(title, body) = block(width: 100%, stroke: 0.8pt + ink, inset: (x: 2mm, top: 1.2mm, bottom: 1.6mm),
  stack(spacing: 1mm, section-title(title), body))

/// Tableau de réglages entre deux filets (modulations, SETTINGS, PROGRAM
/// EDIT) ; `rows` est la liste plate des cellules, `columns` leurs largeurs.
#let settings-table(columns, rows) = table(
  columns: columns, stroke: none, inset: (x: 1mm, y: 0.9mm),
  table.hline(stroke: 0.5pt), ..rows, table.hline(stroke: 0.5pt),
)
