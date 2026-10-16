// Synther : primitives de dessin (géométrie des potards, lignes brisées).

/// Angle d'une position en heures d'horloge : 12 = vers le haut, 30° par heure.
#let hour-angle(hour) = (hour - 12) * 30deg

/// Point à `radius` d'un centre (`center`, `center`) ; l'angle part du haut
/// et tourne dans le sens horaire (comme `hour-angle`).
#let polar-point(center, radius, angle) = (
  center + radius * calc.sin(angle),
  center - radius * calc.cos(angle),
)

/// Ligne brisée passant par `points` (liste de couples (x, y)).
/// - `closed` : referme la forme, pour la remplir avec `fill`.
#let polyline(points, stroke: auto, fill: none, closed: false) = curve(
  stroke: stroke,
  fill: fill,
  curve.move(points.first()),
  ..points.slice(1).map(point => curve.line(point)),
  ..if closed { (curve.close(),) } else { () },
)

/// Arc de cercle entre deux positions d'horloge (`from-hour` < `to-hour`),
/// approché par des segments (6 par heure, 2 au moins).
#let clock-arc(center, radius, from-hour, to-hour, stroke) = {
  let steps = calc.max(2, calc.ceil(calc.abs(to-hour - from-hour) * 6))
  let points = range(steps + 1).map(step => {
    let hour = from-hour + (to-hour - from-hour) * step / steps
    polar-point(center, radius, hour-angle(hour))
  })
  polyline(points, stroke: stroke)
}
