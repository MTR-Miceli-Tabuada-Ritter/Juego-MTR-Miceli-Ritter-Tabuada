extends Button

func _ready() -> void:
	pressed.connect(_reanudar)

func _reanudar():
	owner.alternar_pausa()
