extends Node
## Propietario de inventario, selección y dinero; sobrevive a las vistas.

signal seleccion_cambiada(indice: int)
signal plata_cambiada
signal partida_reiniciada

var inventario := Inventario.new(30)
var indice_seleccionado: int = 0
var plata: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	reiniciar()


func reiniciar() -> void:
	inventario.reiniciar()
	indice_seleccionado = 0
	plata = 0
	# Mismo equipo inicial que antes, sin depender de que exista la interfaz.
	inventario.establecer_stack(4, ItemStack.new(preload("res://recursos/items/semilla_0.tres"), 14))
	inventario.establecer_stack(5, ItemStack.new(preload("res://recursos/items/semilla_1.tres"), 15))
	inventario.establecer_stack(6, ItemStack.new(preload("res://recursos/items/semilla_2.tres"), 15))
	inventario.establecer_stack(7, ItemStack.new(preload("res://recursos/items/semilla_3.tres"), 1))
	inventario.establecer_stack(8, ItemStack.new(preload("res://recursos/items/hacha.tres"), 1))
	inventario.establecer_stack(9, ItemStack.new(preload("res://recursos/items/regadera.tres"), 1))
	seleccion_cambiada.emit(indice_seleccionado)
	plata_cambiada.emit()
	partida_reiniciada.emit()


func seleccionar(indice: int) -> void:
	if indice >= 0 and indice < inventario.capacidad:
		indice_seleccionado = indice
		seleccion_cambiada.emit(indice)


func obtener_stack_seleccionado() -> ItemStack:
	return inventario.obtener_stack(indice_seleccionado)


func consumir_seleccion(cantidad: int) -> bool:
	return inventario.quitar_de_slot(indice_seleccionado, cantidad)


func agregar_plata(monto: int) -> void:
	if monto > 0:
		plata += monto
		plata_cambiada.emit()