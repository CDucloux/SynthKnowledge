// Synther : thème graphique commun (couleurs, police, espacements).
// Esthétique inspirée des manuels Moog : noir et blanc, sans-serif
// géométrique, titres en capitales grasses, vignettes encadrées.

/// Encre : tout ce qui est réglé par la fiche, textes, filets.
#let ink = black

/// Gris des valeurs neutres (non réglées par la fiche) et des filets discrets.
#let muted = luma(190)

/// Fond gris très clair : aires sous les courbes, pas de séquence silencieux.
#let soft = luma(242)

/// Gris nommés, du plus foncé au plus clair (`muted` et `soft` à part).
#let grey = (
  note: luma(40),         // texte des notes de bas de page
  strong: luma(60),       // petits signes (flèche ↗ des liens)
  annotation: luma(70),   // notes des sources, lettres A D S R des courbes
  caption: luma(80),      // légendes, détail des courbes d'enveloppe
  secondary: luma(90),    // pied de page, site et date des sources
  label: luma(110),       // octave des notes, numéros de pas
  underline: luma(130),   // soulignement des liens web
  rule: luma(150),        // pointillés des courbes, cases de silence
)

/// Police principale et repli si Montserrat manque (elle est dans fonts/).
#let font = ("Montserrat", "Gotham", "Helvetica Neue", "Arial")

/// Espacements partagés : une seule définition, tout le reste en découle.
#let ui = (
  gap: 1.6mm,            // espace entre blocs de la page
  section-gap: 2.6mm,    // espace minimal entre deux sections de façade (le reste se répartit)
  title-gap: 2.6mm,      // espace sous un titre de section de façade
  row-gap: 2.4mm,        // espace entre deux rangées de contrôles
  col-gap: 1mm,          // espace entre deux colonnes de contrôles
  aside: 90mm,           // largeur du cadre annexe sous la façade (contrôleur, PROGRAM EDIT)
)

/// Tailles de texte des fiches son, par rôle (deux rôles peuvent avoir la
/// même valeur sans être liés). La théorie a les siennes (`theory-size`).
#let font-size = (
  // Façade : commandes
  control-label: 5.6pt,     // nom sous un potard, un sélecteur…
  control-value: 6.6pt,     // valeur (« 10:30 », « 512 »)
  control-hint: 5pt,        // précision sous la valeur (forme d'onde…)
  option-label: 4.4pt,      // libellés des positions (LED, inverseur)
  option-label-compact: 4.3pt, // colonne de LED d'un inverseur XD
  screen: 5.6pt,            // texte d'un écran
  screen-sub: 4.6pt,        // seconde ligne d'un écran
  switch-state: 4.4pt,      // ON / OFF dans un bouton
  switch-note: 4.2pt,       // mention [F ENV ASSIGN] au-dessus d'un bouton
  pill: 4.8pt,              // bouton compact à libellé intégré
  section-title: 7.2pt,     // titre de section de façade
  row-label: 5.4pt,         // libellé de rangée (FILTER ENVELOPE…)
  row-label-compact: 5.2pt, // idem, façade à petits potards (XD)
  osc-number: 13pt,         // grand chiffre d'oscillateur (Messenger)
  effect-title: 5.4pt,      // MOD FX, REVERB, DELAY (XD)
  effect-state: 4.8pt,      // ON / OFF d'un effet (XD)
  settings: 6.4pt,          // tableau des modulations / PROGRAM EDIT
  // Pages
  body: 7.4pt,              // texte courant
  footer: 5.8pt,            // pied de page
  footnote: 6.6pt,          // notes de bas de page
  kicker: 7pt,              // « MOOG MESSENGER · FICHE SON »
  title: 20pt,              // titre du bandeau
  tags: 6.6pt,              // catégorie et tags du bandeau
  confidence: 7pt,          // libellé de l'indice de confiance
  reference: 8pt,           // ligne artiste | morceau | année…
  summary: 7.6pt,           // résumé sous la référence
  box-title: 7.2pt,         // titre d'encadré
  box-body: 6.9pt,          // texte d'encadré (page 1)
  box-body-wide: 7.4pt,     // encadrés pleine largeur de la page 2
  analysis: 8pt,            // encadrés d'analyse (page 2)
  sources-heading: 6.4pt,   // « SOURCES »
  // Courbes d'enveloppe (page 2)
  curve-title: 6.4pt,
  curve-detail: 6pt,        // valeurs à côté du titre
  curve-letter: 6pt,        // A D S R sous la courbe
  curve-note: 6pt,          // avertissement sous les courbes
  // Séquence
  sequence-settings: 6.2pt, // TEMPO, GATE… au-dessus de la grille
  step-number: 4.8pt,       // 1 / 16 en tête de rangée
  step-note: 5.4pt,         // note dans un pas
  step-chord: 4.8pt,        // notes d'un accord dans un pas
  note: 6pt,                // nom de note hors grille
)
