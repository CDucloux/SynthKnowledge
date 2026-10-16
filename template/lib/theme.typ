// Synther : thème graphique commun (couleurs, police, espacements).
// Esthétique inspirée des manuels Moog : noir et blanc, sans-serif
// géométrique, titres en capitales grasses, vignettes encadrées.

/// Encre : tout ce qui est réglé par la fiche, textes, filets.
#let ink = black

/// Gris des valeurs neutres (non réglées par la fiche) et des filets discrets.
#let muted = luma(190)

/// Fond gris très clair : aires sous les courbes, pas de séquence silencieux.
#let soft = luma(242)

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
