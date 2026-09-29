extends Node2D

var danioAtaque = 10
var fuerzaEmpujeAtaque = 200

@onready var areaAtaque: Area2D = $hurtboxComponente

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("atacar"):
		_atacar()

func _atacar() -> void:
	for area in areaAtaque.get_overlapping_areas():
		if area is hurtboxComponente:
			var ataque = Ataque.new()
			ataque.ataqueDanio = danioAtaque
			ataque.ataqueFuerzaEmpuje = fuerzaEmpujeAtaque
			ataque.ataquePosicion = global_position

			area.danio(ataque)
