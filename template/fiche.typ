// Point d'entrée : compile une fiche à partir d'un fichier YAML de son.
//   typst compile --root . --font-path fonts \
//     --input son=/sons/messenger/mon-son.yaml template/fiche.typ fiches/messenger/mon-son.pdf
// (chemin du YAML relatif à la racine du repo, commençant par « / »)

#import "messenger.typ" as messenger

#let path = sys.inputs.at("son", default: "/sons/messenger/chicago-house-bass.yaml")
#let data = yaml(path)

#let machines = (
  messenger: messenger.fiche,
)

#assert(
  data.synthe in machines,
  message: "synthe « " + str(data.synthe) + " » non pris en charge, disponibles : " + machines.keys().join(", "),
)
#(machines.at(data.synthe))(data)
