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
	var stack = escenaPrincipal.slotEnUso.stack if escenaPrincipal.slotEnUso != null else null
	if stack == null:
		_mostrarDialogo("Joven, no dispone de nada para vender...")
		return

	if stack.item.precio_venta < 0:
		_mostrarDialogo("no me interesa ese objeto de mierda")
	else:
		_mostrarDialogo("Mhmm... por ese objeto te puedo dar: " + "%03d" % [stack.item.precio_venta])
		escenaPrincipal.plata += stack.item.precio_venta
		escenaPrincipal.plataGanada.emit()
		stack.quitar(1)#vendemos 1 unidad del objeto, se resta.
		escenaPrincipal.slotEnUso.actualizar_visual()

func _mostrarDialogo(dialogoX):
	dialogoTexto.text = dialogoX
	dialogoControl.visible = true
	await get_tree().create_timer(1.5).timeout
	dialogoControl.visible = false
	
