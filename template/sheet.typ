// Point d'entrée : compile une fiche à partir d'un fichier YAML de son.
//   typst compile --root . --font-path fonts \
//     --input son=/sounds/messenger/mon-son.yaml template/sheet.typ sheets/messenger/mon-son.pdf
// (chemin du YAML relatif à la racine du dépôt, commençant par « / »)
// Une façade = un module qui expose `render-sheet(data)`.

#import "messenger.typ" as messenger
#import "minilogue-xd.typ" as minilogue-xd

#let machines = (
  messenger: messenger.render-sheet,
  minilogue-xd: minilogue-xd.render-sheet,
)

#let path = sys.inputs.at("son", default: "/sounds/messenger/closer-bass.yaml")
#let data = yaml(path)
#data.insert("_file", path.trim("/", at: start))

#assert(
  data.synth in machines,
  message: "synth « " + str(data.synth) + " » non pris en charge, disponibles : " + machines.keys().join(", "),
)
#(machines.at(data.synth))(data)
