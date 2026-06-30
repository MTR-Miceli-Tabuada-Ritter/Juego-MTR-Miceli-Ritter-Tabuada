extends TextureRect

@export var textoCantidad = Label
var rutaIconos = "res://recursos/iconos/"
var estaEnUso = false
var cantidad = 0

#cada icono esta guardado en la ruta de arriba, se llamarian "icono_numero" y asi con todos, la 
#idea es que sean .tres de tipo atlasTexture, q sacamos de una hoja de sprite
func setearSlot(tipoItem, valor):
	estaEnUso = true
	texture = load(rutaIconos + tipoItem + ".tres")
	cambiarTexto(valor)
	visible = true

func cambiarTexto(valor):
	cantidad += valor 
	# el coso raro "%02d" dice que tiene q ser un decimal de 2 digitos osea en vez de "2" sería "02" 
	textoCantidad.text = "%02d" % cantidad
