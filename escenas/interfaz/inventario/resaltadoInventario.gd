extends Node2D

var escenaPrincipal
var puedeSeleccionar = false
var nombreSlot = "slot"
var indiceSlot = 1

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	cambiarPosicion()

func cambiarPosicion() -> void:
	var slot = get_parent().get_node(nombreSlot + str(indiceSlot))
	global_position = slot.global_position
	if slot.estaEnUso:
		escenaPrincipal.setearSlotEnUso(slot)
	else:
		escenaPrincipal.setearSlotEnUso(null)
	queue_redraw()
	await get_tree().create_timer(0.025).timeout
	puedeSeleccionar = true

func _input(event: InputEvent) -> void:
	if puedeSeleccionar and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			puedeSeleccionar = false
			moverSlotArriba()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			puedeSeleccionar = false
			moverSlotAbajo()

func moverSlotArriba() -> void:
	if indiceSlot == 4:
		indiceSlot = 1
	else:
		indiceSlot += 1
	cambiarPosicion()

func moverSlotAbajo() -> void:
	if indiceSlot == 1:
		indiceSlot = 4
	else:
		indiceSlot -= 1
	cambiarPosicion()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(32, 32)), Color(1, 1, 1), false, 2.0)
