extends CanvasLayer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pausar"):
		alternar_pausa()

func alternar_pausa():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
