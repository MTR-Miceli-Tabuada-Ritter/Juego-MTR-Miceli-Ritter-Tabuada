extends StaticBody2D

const DIALOGO_GALLO = preload("res://escenas/animales/gallo/gallo.dialogue")

var presentacion_realizada: bool = false
# Resultado de la última mutación, nunca una condición con efectos secundarios.
var ultima_operacion_exitosa: bool = false


func _on_interactuable_interaccionar() -> void:
	DialogueManager.show_dialogue_balloon(DIALOGO_GALLO, clave_dialogo(), [self])


func clave_dialogo() -> String:
	return "misiones" if presentacion_realizada else "start"


func terminar_presentacion() -> void:
	presentacion_realizada = true


func mision_disponible(id: String) -> bool:
	return GestorMisiones.obtener_estado(id) == GestorMisiones.Estado.DISPONIBLE


func mision_activa(id: String) -> bool:
	return GestorMisiones.obtener_estado(id) == GestorMisiones.Estado.ACTIVA


func mision_completada(id: String) -> bool:
	return GestorMisiones.obtener_estado(id) == GestorMisiones.Estado.COMPLETADA


func puede_entregar_mision(id: String) -> bool:
	return GestorMisiones.puede_finalizar(id, "gallo")


func papas_disponibles() -> int:
	var progreso := GestorMisiones.obtener_progreso("gallo_papas")
	return int(progreso.get("entregar_papas", {}).get("actual", 0))


func aceptar_mision(id: String) -> void:
	ultima_operacion_exitosa = GestorMisiones.aceptar_mision(id)


func entregar_mision(id: String) -> void:
	ultima_operacion_exitosa = GestorMisiones.intentar_finalizar(id, "gallo")
