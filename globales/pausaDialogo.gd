extends Node
## Pausa el árbol de escena mientras hay un diálogo activo (cualquiera sea el balloon)

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(_resource: DialogueResource) -> void:
	get_tree().paused = true


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	get_tree().paused = false
