// Synther : encadrés et listes (étapes numérotées, puces « » »), indice de
// confiance.

#import "theme.typ": font-size, ink
#import "markup.typ": md

/// Indice de confiance : ●●● documenté, ●●○ déduit, ●○○ approximation.
/// - `level` : 1 à 3 (ramené dans cette plage).
/// - `fill` : couleur (blanc sur le bandeau noir, encre en page 2).
#let confidence(level, fill: white) = {
  let labels = ("APPROXIMATION", "DÉDUIT", "DOCUMENTÉ")
  let level = calc.clamp(level, 1, 3)
  box(baseline: 0.3mm, for dot in range(3) {
    box(circle(radius: 1.25mm, fill: if dot < level { fill } else { none }, stroke: 0.8pt + fill))
    h(0.8mm)
  })
  h(1.2mm)
  text(size: font-size.confidence, weight: "bold", fill: fill, tracking: 0.1em, labels.at(level - 1))
}

/// Encadré à filet noir, coins droits : titre en capitales (avec icône
/// facultative), puis le contenu en corps `size`.
#let textbox(title, body, size: font-size.box-body, icon: none) = block(
  width: 100%, stroke: 0.9pt + ink, inset: 0pt, breakable: false,
  stack(
    block(width: 100%, inset: (x: 2.4mm, top: 2mm, bottom: 2.6mm), {
      if icon != none { icon; h(1.4mm) }
      text(size: font-size.box-title, weight: "extrabold", tracking: 0.06em, upper(title))
    }),
    block(width: 100%, inset: (x: 2.4mm, bottom: 2mm), { set text(size: size); body }),
  ),
)

/// Liste numérotée 01, 02… (textes du YAML, markup enrichi).
#let numbered(items) = {
  set par(leading: 0.5em)
  for (index, item) in items.enumerate() {
    let number = index + 1
    grid(
      columns: (4.2mm, 1fr), gutter: 0.6mm,
      text(weight: "extrabold", if number < 10 { "0" + str(number) } else { str(number) }),
      md(item),
    )
    v(0.5mm)
  }
}

/// Puce double chevron, dans la ligne (alignée sur le texte).
#let bullet-mark = box(width: 3.4mm, text(size: 1.25em, weight: "extrabold", "»"))

/// Paragraphe à puce avec retrait suspendu pour les lignes suivantes.
#let bullet-item(body) = block(above: 0pt, below: 1.3mm, par(hanging-indent: 3.4mm, bullet-mark + body))

/// Liste à puces (textes du YAML, markup enrichi).
#let bullets(items) = {
  set par(leading: 0.5em)
  for item in items { bullet-item(md(item)) }
}
