extends preciosGestor

@export var areaInteractuable: Area2D
@export var dialogoControl: Control
@export var dialogoTexto: RichTextLabel

var escenaPrincipal
var lista

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	areaInteractuable.interaccionar.connect(modoVenta)
	

func getPrecioPorId(txt, id):
	match (txt):
		"icono_cultivo":
			lista = preciosCultivos
		"icono_semilla":
			lista = preciosSemillas
		_:
			return null
	
	if id < lista.size():
		return lista[id]
	else:
		return null
	
func modoVenta():
	if escenaPrincipal.slotEnUso == null or escenaPrincipal.slotEnUso.estaEnUso == false:
		_mostrarDialogo("Joven, no dispone de nada para vender...")
		return
	
	var respuesta = getPrecioPorId(escenaPrincipal.slotEnUso.texturaNombre , escenaPrincipal.slotEnUso.texturaId)
	if respuesta == null:
		_mostrarDialogo("no me interesa ese objeto de mierda")
	else:
		_mostrarDialogo("Mhmm... por ese objeto te puedo dar: " + "%03d" % [respuesta])
		escenaPrincipal.plata += respuesta
		escenaPrincipal.plataGanada.emit()
		escenaPrincipal.slotEnUso.cambiarTexto(-1)#-1 porque vendemos 1 unidad del objeto, se resta.

func _mostrarDialogo(dialogoX):
	dialogoTexto.text = dialogoX
	dialogoControl.visible = true
	await get_tree().create_timer(1.5).timeout
	dialogoControl.visible = false
	
