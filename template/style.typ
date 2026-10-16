// Synther : composants communs des fiches, importés d'un bloc par les
// façades et la théorie (`#import "style.typ": *`).
//
// Modules (template/lib/) :
//   theme      couleurs (ink, muted, soft), police, espacements `ui`
//   draw       géométrie : hour-angle, polar-point, polyline, clock-arc
//   controls   commandes dessinées : knob, value-knob, selector-updown,
//              toggle-xd, lever-slot, switch, pill, screen, led-list…
//   markup     texte du YAML : md ([n], [texte](url), ^[note]), short-url
//   icons      icônes des encadrés, auto-icon
//   boxes      textbox, numbered, bullets, confidence
//   params     field, schema-defaults, check-params, param-reader
//   panel      panel-band, panel-frame, section-title, aside-section
//   envelopes  env-entry, env-plot (courbes de la page 2)
//   sequence   sequence-box (grille de pas)
//   pages      page-setup, title-bar, sources-page, sheet (fiche complète)
//
// Convention : un nom commençant par « _ » est interne à son module.

#import "lib/theme.typ": *
#import "lib/draw.typ": *
#import "lib/controls.typ": *
#import "lib/markup.typ": *
#import "lib/icons.typ": *
#import "lib/boxes.typ": *
#import "lib/params.typ": *
#import "lib/panel.typ": *
#import "lib/envelopes.typ": *
#import "lib/sequence.typ": *
#import "lib/pages.typ": *
