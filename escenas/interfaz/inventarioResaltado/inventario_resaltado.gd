extends "res://globales/selectorSlot.gd"

var nodoInventario

func _ready() -> void:
	nodoInventario = get_parent().get_node("inventario")
	super._ready()

func obtenerContenedorSlots() -> Node:
	return nodoInventario

func _unhandled_key_input(event: InputEvent) -> void:
	if not puedeSeleccionar or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var nuevoIndice := 0
	if event.keycode >= KEY_1 and event.keycode <= KEY_9:
		nuevoIndice = event.keycode - KEY_0
	elif event.keycode == KEY_0:
		nuevoIndice = 10
	if nuevoIndice == 0 or nuevoIndice == indiceSlot:
		return
	indiceSlot = nuevoIndice
	SonidosGlobales.reproducirSonidoSeleccionar()
	cambiarPosicion()

func moverSlotArriba() -> void:
	if indiceSlot == 1:
		indiceSlot = 10
	else:
		indiceSlot -= 1
	SonidosGlobales.reproducirSonidoSeleccionar()
	cambiarPosicion()

func moverSlotAbajo() -> void:
	if indiceSlot == 10:
		indiceSlot = 1
	else:
		indiceSlot += 1
	SonidosGlobales.reproducirSonidoSeleccionar()
	cambiarPosicion()
