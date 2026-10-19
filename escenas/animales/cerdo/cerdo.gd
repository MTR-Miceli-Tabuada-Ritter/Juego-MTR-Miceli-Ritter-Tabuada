extends StaticBody2D

const DIALOGO_CERDO = preload("res://escenas/animales/cerdo/cerdo.dialogue")

var veces_hablado := 0

func _on_interactuable_interaccionar():
	if veces_hablado == 0:
		DialogueManager.show_dialogue_balloon(DIALOGO_CERDO, "primera_vez")
	else:
		DialogueManager.show_dialogue_balloon(DIALOGO_CERDO, "otra_vez")
	veces_hablado += 1
