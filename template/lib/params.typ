// Synther : lecture des données d'une fiche et des paramètres de façade.
// Les paramètres d'une machine sont décrits une seule fois, dans
// template/schema/<machine>.yaml ; scripts/build.py en fait la validation
// complète (types, plages), le template ne garde qu'un garde-fou.

/// Valeur d'un champ d'un dictionnaire YAML ; `default` s'il est absent ou
/// vide (`key:` sans valeur donne none en YAML).
#let field(data, key, default) = {
  let value = data.at(key, default: none)
  if value == none { default } else { value }
}

/// Valeurs neutres d'une machine, tirées de son schéma :
/// (section: (paramètre: valeur neutre, …), …).
#let schema-defaults(schema) = {
  let defaults = (:)
  for (section, specs) in schema.params {
    let section-defaults = (:)
    for (key, spec) in specs { section-defaults.insert(key, spec.default) }
    defaults.insert(section, section-defaults)
  }
  defaults
}

/// Garde-fou : une section ou un paramètre inconnu arrête la compilation
/// avec la liste des noms attendus.
#let check-params(params, defaults) = {
  for (section, values) in params {
    assert(section in defaults,
      message: "Section inconnue « " + section + " », attendu : " + defaults.keys().join(", "))
    for (key, _) in values {
      assert(key in defaults.at(section),
        message: "Paramètre inconnu « " + section + "." + key + " », attendu : "
          + defaults.at(section).keys().join(", "))
    }
  }
}

/// Lecteur de paramètres : `read(section, key)` renvoie (valeur, réglé ?).
/// Une clé absente du YAML prend la valeur neutre et « réglé » vaut false
/// (la commande s'affiche alors en gris).
#let param-reader(params, defaults) = (section, key) => {
  let values = field(params, section, (:))
  if key in values { (values.at(key), true) } else { (defaults.at(section).at(key), false) }
}

/// Lecteur de valeurs seules : `value(section, key)` (neutre si absente).
#let value-reader(params, defaults) = {
  let read = param-reader(params, defaults)
  (section, key) => read(section, key).first()
}
