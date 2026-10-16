// Synther : texte libre venant du YAML, interprété comme du markup Typst
// (`*CUTOFF*` → gras, comme les noms de commandes dans les manuels Moog).
//
// Syntaxe enrichie, convertie avant l'évaluation :
//   [3] ou [1][2]          → renvoi cliquable vers la source n (exposant)
//   [texte](https://…)    → lien intégré au texte
//   ^[texte de la note]    → note de bas de page (numérotée a, b, c…)

#import "theme.typ": ink

/// Renvoi en exposant vers une ou plusieurs sources : « [1,2] ». Chaque
/// numéro est cliquable si la page 2 porte l'étiquette `<src-n>`.
#let source-ref(..numbers) = {
  let parts = numbers.pos().map(number => context {
    let target = label("src-" + str(number))
    let shown = text(weight: "extrabold", str(number))
    if query(target).len() > 0 { link(target, shown) } else { shown }
  })
  box(text(size: 0.72em, baseline: -0.42em, fill: ink, [\[] + parts.join(",") + [\]]))
}

/// Convertit la syntaxe enrichie en appels Typst (`#link`, `#source-ref`,
/// `#footnote`). Ordre important : les notes en dernier, car une note peut
/// contenir un renvoi ou un lien.
#let _to-typst(source) = {
  source = source.replace(regex("\[([^\]\[]+)\]\((https?://[^)\s]+)\)"), found => {
    let (label, url) = found.captures
    "#link(\"" + url.replace("\"", "%22") + "\")[" + label + "]"
  })
  source = source.replace(regex("( ?)((?:\[\d+\])+)"), found => {
    let numbers = found.captures.at(1).matches(regex("\d+")).map(number => number.text)
    "#source-ref(" + numbers.join(", ") + ")"
  })
  source.replace(
    regex("\^\[((?:[^\[\]]|\[[^\[\]]*\])*)\]"),
    found => "#footnote[" + found.captures.at(0).trim() + "]",
  )
}

/// Texte du YAML rendu en markup Typst (none → rien).
#let md(source) = if source == none { [] } else {
  eval(_to-typst(str(source)), mode: "markup", scope: (source-ref: source-ref))
}

/// Lien affiché proprement : sans https:// ni www., abrégé au milieu au-delà
/// de `max` caractères.
#let short-url(url, max: 92) = {
  let shown = url.replace(regex("^https?://(www\.)?"), "").trim("/", at: end)
  if shown.len() > max { shown = shown.slice(0, max - 22) + "…" + shown.slice(shown.len() - 20) }
  shown
}
