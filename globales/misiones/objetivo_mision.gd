class_name ObjetivoMision
extends Resource
## Definición compartida: los métodos nunca escriben progreso en este recurso.
## Un nuevo subtipo implementa esta política; el gestor no necesita conocer su tipo.

@export var id: String = ""
@export_multiline var descripcion: String = ""


func es_valido() -> bool:
	# La base no representa por sí sola un requisito realizable.
	return false


func tiene_id_valido() -> bool:
	return not id.strip_edges().is_empty()


func obtener_requisitos_entrega() -> Dictionary:
	return {}


func obtener_progreso(_inventario: Inventario, contador: int, _requisitos_totales: Dictionary) -> Dictionary:
	return {
		"actual": contador,
		"requerido": 1,
		"completo": contador >= 1,
		"descripcion": descripcion,
	}


func aplicar_conversacion(contador: int, _npc_id: String, _conversacion_id: String) -> int:
	return contador


func aplicar_derrota(contador: int, _tipo_enemigo: String) -> int:
	return contador