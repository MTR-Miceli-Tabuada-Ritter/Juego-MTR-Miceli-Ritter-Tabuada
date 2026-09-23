extends "res://globales/selectorSlot.gd"

var nodoInventario

func _ready() -> void:
	nodoInventario = get_node("/root/escenaPrincipal/Interfaz/inventario")
	super._ready()

func obtenerContenedorSlots() -> Node:
	return nodoInventario

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
