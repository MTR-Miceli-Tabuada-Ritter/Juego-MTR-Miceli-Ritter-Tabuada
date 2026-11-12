extends Node2D
class_name selectorSlot

var nombreSlot = "slot"
var indiceSlot = 1
var puedeSeleccionar = false

func _ready() -> void:
	InventarioJugador.seleccion_cambiada.connect(_sincronizar_seleccion)
	_sincronizar_seleccion(InventarioJugador.indice_seleccionado)
	puedeSeleccionar = true

func _input(event: InputEvent) -> void:
	if puedeSeleccionar and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			puedeSeleccionar = false
			moverSlotArriba()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			puedeSeleccionar = false
			moverSlotAbajo()

func obtenerContenedorSlots() -> Node:
	return get_parent()

func cambiarPosicion() -> void:
	InventarioJugador.seleccionar(indiceSlot - 1)
	await get_tree().create_timer(0.025).timeout
	puedeSeleccionar = true

func _sincronizar_seleccion(indice: int) -> void:
	indiceSlot = indice + 1
	var slot = obtenerContenedorSlots().get_node_or_null(nombreSlot + str(indiceSlot))
	visible = slot != null
	if slot != null:
		global_position = slot.global_position
	_alCambiarSlot()

func _alCambiarSlot() -> void:
	pass

func moverSlotArriba() -> void:
	pass

func moverSlotAbajo() -> void:
	pass
