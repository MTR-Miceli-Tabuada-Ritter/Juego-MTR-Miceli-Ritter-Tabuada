class_name ItemStack
extends RefCounted

var item: Item
var cantidad: int

func _init(item_inicial: Item, cantidad_inicial: int = 0) -> void:
	item = item_inicial
	cantidad = cantidad_inicial

func agregar(cantidad_a_sumar: int) -> int:
	cantidad += cantidad_a_sumar
	if cantidad > item.max_stack:
		var sobrante = cantidad - item.max_stack
		cantidad = item.max_stack
		return sobrante
	return 0

func quitar(cantidad_a_restar: int) -> void:
	cantidad = max(cantidad - cantidad_a_restar, 0)

func esta_vacio() -> bool:
	return cantidad <= 0
