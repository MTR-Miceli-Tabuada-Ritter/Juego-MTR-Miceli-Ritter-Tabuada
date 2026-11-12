class_name ObjetivoHablarConNPC
extends ObjetivoMision

@export var npc_id: String = ""
@export var conversacion_id: String = ""


func es_valido() -> bool:
	return tiene_id_valido() and not npc_id.strip_edges().is_empty() and not conversacion_id.strip_edges().is_empty()


func obtener_progreso(_inventario: Inventario, contador: int, _requisitos_totales: Dictionary) -> Dictionary:
	var actual := clampi(contador, 0, 1)
	return {
		"tipo": "hablar_con_npc",
		"descripcion": descripcion,
		"npc_id": npc_id,
		"conversacion_id": conversacion_id,
		"actual": actual,
		"requerido": 1,
		"completo": actual == 1,
	}


func aplicar_conversacion(contador: int, npc: String, conversacion: String) -> int:
	if npc == npc_id and conversacion == conversacion_id:
		return 1
	return contador