extends StaticBody2D

const DIALOGO_VACA = preload("res://escenas/animales/vaca/vaca.dialogue")


func _on_interactuable_interaccionar() -> void:
	DialogueManager.show_dialogue_balloon(DIALOGO_VACA)
