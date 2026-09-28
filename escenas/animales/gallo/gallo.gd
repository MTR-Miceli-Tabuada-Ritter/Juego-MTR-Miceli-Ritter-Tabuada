extends StaticBody2D

const DIALOGO_GALLO = preload("res://escenas/animales/gallo/gallo.dialogue")


func _on_interactuable_interaccionar() -> void:
	DialogueManager.show_dialogue_balloon(DIALOGO_GALLO)
