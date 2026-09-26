extends preciosGestor

@export var areaInteractuable: Area2D
@export var dialogoControl: Control
@export var dialogoTexto: RichTextLabel

const DIALOGO_TIENDA = preload("res://escenas/tienda/tienda.dialogue")

var escenaPrincipal
var lista

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	areaInteractuable.interaccionar.connect(abrirDialogoTienda)
	

func abrirDialogoTienda():
	DialogueManager.show_dialogue_balloon(DIALOGO_TIENDA, "", [self])

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

#region API usada por las líneas del diálogo de la tienda (tienda.dialogue)

func hay_objeto_para_vender() -> bool:
	return _stack_en_uso() != null

func es_objeto_vendible() -> bool:
	var stack = _stack_en_uso()
	return stack != null and stack.item.precio_venta >= 0

func nombre_objeto_actual() -> String:
	var stack = _stack_en_uso()
	return stack.item.id if stack != null else ""

func precio_objeto_actual() -> int:
	var stack = _stack_en_uso()
	return stack.item.precio_venta if stack != null else 0

func vender_objeto_actual() -> void:
	var stack = _stack_en_uso()
	if stack == null or stack.item.precio_venta < 0:
		return
	escenaPrincipal.agregarPlata(stack.item.precio_venta)
	stack.quitar(1)#vendemos 1 unidad del objeto, se resta.
	escenaPrincipal.slotEnUso.actualizar_visual()

func _stack_en_uso():
	return escenaPrincipal.slotEnUso.stack if escenaPrincipal.slotEnUso != null else null

#endregion


func _on_interactuable_2_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
