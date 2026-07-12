extends TextureRect

@export var textoCantidad: Label
@export var progreso: TextureProgressBar
var rutaIconos = "res://recursos/iconos/"
var estaEnUso = false
var cantidad = 0
var maxCantidad = 100
var texturaNombre = ""
var texturaId = 0
var valorTipoSlot = 0 #0 = semilla, 1 = cultivo, 2 = herramienta, 3 = fertilizante, 4 = comida, 5 = otro

#cada icono esta guardado en la ruta de arriba, se llamarian "icono_numero" y asi con todos, la 
#idea es que sean .tres de tipo atlasTexture, q sacamos de una hoja de sprite
func setearSlot(tipoItem, idObjeto, valor, tipoValor = 0):
	estaEnUso = true
	valorTipoSlot = tipoValor
	texturaNombre = tipoItem
	texturaId = idObjeto
	texture = load(rutaIconos + tipoItem + "_" + str(idObjeto) + ".tres")
	elegirTipoObjeto()
	cambiarTexto(valor)
	visible = true

func elegirTipoObjeto():
	# herramienta (tipo 2): sin contador
	if valorTipoSlot == 2:
		textoCantidad.visible = false
	# cultivo (tipo 1): muestra barra de progreso
	if valorTipoSlot == 1:
		textoCantidad.visible = false
		if progreso: #esto es opcional, porque no todos los slots tienen barra de progreso
			progreso.visible = true

func cambiarTexto(valor):
	if estaEnUso == false:
		return
	cantidad += valor
	if cantidad <= 0:
		cantidad = 0
		textoCantidad.text = "%02d" % cantidad
		if valorTipoSlot == 0:
			borrarSlot()
		return
	if cantidad > maxCantidad:
		cantidad = maxCantidad
	# el coso raro "%02d" dice que tiene q ser un decimal de 2 digitos osea en vez de "2" sería "02"
	textoCantidad.text = "%02d" % cantidad
	if progreso:
		progreso.value = cantidad

func borrarSlot():
	estaEnUso = false
	cantidad = 0
	texturaNombre = ""
	texturaId = 0
	texture = null
	textoCantidad.text = "00"
	textoCantidad.visible = false
	if progreso:
		progreso.visible = false
	# no ocultamos el slot para que el HBoxContainer no reordene los demas slots
	# y el resaltado de inventario no se desplace al lugar equivocado
