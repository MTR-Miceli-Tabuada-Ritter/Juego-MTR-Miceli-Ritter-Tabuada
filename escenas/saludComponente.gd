extends Node2D
class_name saludComponente

@export var SALUD_MAX = 10
var salud:float

func _ready() -> void:
	salud = SALUD_MAX
	
func danio(ataque:Ataque):
	salud -= ataque.ataqueDanio
	if salud <= 0:
		get_parent().queue_free()
	
