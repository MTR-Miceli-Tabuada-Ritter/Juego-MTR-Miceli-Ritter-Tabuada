extends StaticBody2D

const DIALOGO_VACA = preload("res://escenas/animales/vaca/vaca.dialogue")

var veces_hablado := 0


func _on_interactuable_interaccionar():
	if veces_hablado == 0:
		DialogueManager.show_dialogue_balloon(DIALOGO_VACA, "primera_vez")
	else:
		DialogueManager.show_dialogue_balloon(DIALOGO_VACA, "otra_vez")
	veces_hablado += 1
