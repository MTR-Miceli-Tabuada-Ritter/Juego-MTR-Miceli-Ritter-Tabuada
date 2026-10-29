class_name Inventario
extends RefCounted
## Almacén de una partida. No conoce nodos de interfaz ni escenas.

signal inventario_cambiado

var _slots: Array[ItemStack] = []
var capacidad: int = 30:
	set(valor):
		valor = maxi(valor, 1)
		for i in range(valor, _slots.size()):
			if _slots[i] != null:
				return # Reducir capacidad nunca descarta objetos.
		capacidad = valor
		_slots.resize(capacidad)
		notificar_cambio()


func _init(capacidad_inicial: int = 30) -> void:
	capacidad = capacidad_inicial


func obtener_stack(indice: int) -> ItemStack:
	return _slots[indice] if indice >= 0 and indice < _slots.size() else null


func contar_item(item_id: String) -> int:
	var cantidad := 0
	for stack in _slots:
		if stack != null and stack.item.id == item_id:
			cantidad += stack.cantidad
	return cantidad


func agregar_item(item: Item, cantidad: int) -> int:
	if not _item_valido(item) or cantidad <= 0:
		return cantidad
	var sobrante := _agregar_en(_slots, item, cantidad)
	if sobrante != cantidad:
		notificar_cambio()
	return sobrante


func intentar_quitar_item(item_id: String, cantidad: int) -> bool:
	return intentar_quitar_items({item_id: cantidad})


func intentar_quitar_items(requisitos: Dictionary) -> bool:
	var premios: Array[ItemStack] = []
	return intentar_intercambio(requisitos, premios)


func puede_intercambiar(requisitos: Dictionary, recompensas: Array[ItemStack]) -> bool:
	return not _simular_intercambio(requisitos, recompensas).is_empty()


func intentar_intercambio(requisitos: Dictionary, recompensas: Array[ItemStack], notificar: bool = true) -> bool:
	var resultado := _simular_intercambio(requisitos, recompensas)
	if resultado.is_empty():
		return false
	_slots = resultado
	if notificar:
		notificar_cambio()
	return true


func quitar_de_slot(indice: int, cantidad: int) -> bool:
	var stack := obtener_stack(indice)
	if stack == null or cantidad <= 0 or stack.cantidad < cantidad:
		return false
	stack.quitar(cantidad)
	if stack.esta_vacio():
		_slots[indice] = null
	notificar_cambio()
	return true


func consumir_cargas(indice: int, cantidad: int) -> bool:
	var stack := obtener_stack(indice)
	if stack == null or stack.item.capacidad_carga <= 0 or cantidad <= 0 or stack.cargas < cantidad:
		return false
	stack.cargas -= cantidad
	notificar_cambio()
	return true


func recargar_cargas(indice: int) -> void:
	var stack := obtener_stack(indice)
	if stack != null and stack.item.capacidad_carga > 0 and stack.cargas != stack.item.capacidad_carga:
		stack.cargas = stack.item.capacidad_carga
		notificar_cambio()


func establecer_stack(indice: int, stack: ItemStack) -> bool:
	if indice < 0 or indice >= capacidad:
		return false
	if stack != null and (not _item_valido(stack.item) or stack.cantidad <= 0 or stack.cantidad > stack.item.max_stack):
		return false
	_slots[indice] = _copiar_stack(stack)
	notificar_cambio()
	return true


func mover_o_intercambiar(origen: int, destino: int) -> bool:
	if origen < 0 or destino < 0 or origen >= capacidad or destino >= capacidad or origen == destino:
		return false
	var anterior := _slots[destino]
	_slots[destino] = _slots[origen]
	_slots[origen] = anterior
	notificar_cambio()
	return true


func reiniciar() -> void:
	_slots.clear()
	_slots.resize(capacidad)
	notificar_cambio()


func notificar_cambio() -> void:
	inventario_cambiado.emit()


func _simular_intercambio(requisitos: Dictionary, recompensas: Array[ItemStack]) -> Array[ItemStack]:
	var copia: Array[ItemStack] = []
	for id in requisitos:
		if not id is String or id.is_empty() or typeof(requisitos[id]) != TYPE_INT or requisitos[id] <= 0:
			return []
		if contar_item(id) < requisitos[id]:
			return []
	for premio in recompensas:
		if premio == null or not _item_valido(premio.item) or premio.cantidad <= 0:
			return []
	for stack in _slots:
		copia.append(_copiar_stack(stack))
	for id in requisitos:
		var pendiente: int = requisitos[id]
		for i in range(copia.size()):
			var stack := copia[i]
			if stack == null or stack.item.id != id:
				continue
			var quitar := mini(pendiente, stack.cantidad)
			stack.quitar(quitar)
			pendiente -= quitar
			if stack.esta_vacio():
				copia[i] = null
			if pendiente == 0:
				break
	for premio in recompensas:
		if _agregar_en(copia, premio.item, premio.cantidad) > 0:
			return []
	return copia


func _agregar_en(slots: Array[ItemStack], item: Item, cantidad: int) -> int:
	var pendiente := cantidad
	for stack in slots:
		if stack != null and stack.item.id == item.id and stack.cantidad < stack.item.max_stack:
			pendiente = stack.agregar(pendiente)
			if pendiente == 0:
				return 0
	for i in range(slots.size()):
		if slots[i] != null:
			continue
		var agregar := mini(pendiente, item.max_stack)
		slots[i] = ItemStack.new(item, agregar)
		pendiente -= agregar
		if pendiente == 0:
			break
	return pendiente


func _copiar_stack(stack: ItemStack) -> ItemStack:
	if stack == null:
		return null
	var copia := ItemStack.new(stack.item, stack.cantidad)
	copia.cargas = stack.cargas
	return copia


func _item_valido(item: Item) -> bool:
	return item != null and not item.id.strip_edges().is_empty() and item.max_stack > 0