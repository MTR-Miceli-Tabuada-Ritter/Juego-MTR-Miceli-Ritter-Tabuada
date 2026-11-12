class_name ObjetivoEntregarItems
extends ObjetivoMision

@export var item_id: String = ""
@export var cantidad_requerida: int = 1


func es_valido() -> bool:
	return tiene_id_valido() and not item_id.strip_edges().is_empty() and cantidad_requerida > 0


func obtener_requisitos_entrega() -> Dictionary:
	return {item_id: cantidad_requerida}


func obtener_progreso(inventario: Inventario, _contador: int, requisitos_totales: Dictionary) -> Dictionary:
	var disponibles := inventario.contar_item(item_id) if inventario != null else 0
	var total: int = requisitos_totales.get(item_id, cantidad_requerida)
	return {
		"tipo": "entregar_items",
		"descripcion": descripcion,
		"item_id": item_id,
		# Existencias actuales, no un contador histórico ni una reserva de objetos.
		"actual": disponibles,
		"requerido": cantidad_requerida,
		"requerido_total": total,
		# Varios objetivos del mismo ítem se evalúan contra el total agregado.
		"completo": disponibles >= total,
	}