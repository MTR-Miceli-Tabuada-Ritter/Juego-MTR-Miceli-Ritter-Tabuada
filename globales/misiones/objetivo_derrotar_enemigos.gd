class_name ObjetivoDerrotarEnemigos
extends ObjetivoMision

@export var tipo_enemigo: String = ""
@export var cantidad_requerida: int = 1


func es_valido() -> bool:
	return tiene_id_valido() and not tipo_enemigo.strip_edges().is_empty() and cantidad_requerida > 0


func obtener_progreso(_inventario: Inventario, contador: int, _requisitos_totales: Dictionary) -> Dictionary:
	var actual := clampi(contador, 0, cantidad_requerida)
	return {
		"tipo": "derrotar_enemigos",
		"descripcion": descripcion,
		"tipo_enemigo": tipo_enemigo,
		"actual": actual,
		"requerido": cantidad_requerida,
		"completo": actual >= cantidad_requerida,
	}


func aplicar_derrota(contador: int, tipo: String) -> int:
	if tipo == tipo_enemigo and contador < cantidad_requerida:
		return contador + 1
	return contador