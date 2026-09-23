extends Node2D
class_name selectorSlot

var nombreSlot = "slot"
var indiceSlot = 1
var puedeSeleccionar = false
var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	cambiarPosicion()

func _input(event: InputEvent) -> void:
	if puedeSeleccionar and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			puedeSeleccionar = false
			moverSlotArriba()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			puedeSeleccionar = false
			moverSlotAbajo()

func obtenerContenedorSlots() -> Node:
	return get_parent()

func cambiarPosicion() -> void:
	var slot = obtenerContenedorSlots().get_node(nombreSlot + str(indiceSlot))
	global_position = slot.global_position
	if slot.stack != null:
		escenaPrincipal.setearSlotEnUso(slot)
	else:
		escenaPrincipal.setearSlotEnUso(null)
	_alCambiarSlot()
	await get_tree().create_timer(0.025).timeout
	puedeSeleccionar = true

func _alCambiarSlot() -> void:
	pass

func moverSlotArriba() -> void:
	pass

func moverSlotAbajo() -> void:
	pass
