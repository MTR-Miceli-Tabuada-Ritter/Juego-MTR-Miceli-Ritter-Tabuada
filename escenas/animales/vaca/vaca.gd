extends StaticBody2D

const DIALOGO_VACA = preload("res://escenas/animales/vaca/vaca.dialogue")

var veces_hablado := 0


func _on_interactuable_interaccionar() -> void:
	DialogueManager.show_dialogue_balloon(DIALOGO_VACA, clave_dialogo(), [self])
	veces_hablado += 1


func clave_dialogo() -> String:
	if veces_hablado == 0:
		return "primera_vez"
	if encargo_del_gallo_pendiente():
		return "encargo_gallo"
	return "otra_vez"


func encargo_del_gallo_pendiente() -> bool:
	if GestorMisiones.obtener_estado("gallo_vaca") != GestorMisiones.Estado.ACTIVA:
		return false
	var progreso: Dictionary = GestorMisiones.obtener_progreso("gallo_vaca")
	return not bool(progreso.get("hablar_vaca", {}).get("completo", false))


func registrar_encargo_del_gallo() -> void:
	# Solo se llama después de que se haya leído la respuesta al mensaje.
	if encargo_del_gallo_pendiente():
		GestorMisiones.registrar_conversacion("vaca", "encargo_gallo")
