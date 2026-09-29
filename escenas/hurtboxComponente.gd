extends Area2D
class_name hurtboxComponente

@export var componenteSalud:saludComponente

func danio(ataque: Ataque):
	if componenteSalud:
		componenteSalud.danio(ataque)
