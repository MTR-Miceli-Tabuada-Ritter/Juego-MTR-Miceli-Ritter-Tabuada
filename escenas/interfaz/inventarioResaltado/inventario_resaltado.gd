extends Node2D

var nodoInventario
var escenaPrincipal

var slotNombre = "slot"
var slotId = 1
var puedeSeleccionar = false

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	nodoInventario = get_node("/root/escenaPrincipal/Interfaz/inventario")
	cambiarPosicion()

func _input(event: InputEvent):
	if puedeSeleccionar and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			puedeSeleccionar = false
			moverSlotArriba()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			puedeSeleccionar = false
			moverSlotAbajo()


func cambiarPosicion():
	var slot = nodoInventario.get_node(slotNombre + str(slotId))
	self.global_position = Vector2(slot.global_position.x, slot.global_position.y)
	if slot.estaEnUso:
		escenaPrincipal.setearSlotEnUso(slot)
	else:
		escenaPrincipal.setearSlotEnUso(null)
	await get_tree().create_timer(0.025).timeout
	puedeSeleccionar = true
	

func moverSlotArriba() -> void:
	if slotId == 1:
		slotId = 10
	else:
		slotId -= 1
	cambiarPosicion()


func moverSlotAbajo() -> void:
	if slotId == 10:
		slotId = 1
	else:
		slotId += 1
	cambiarPosicion()
