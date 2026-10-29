extends Node2D

var danioAtaque = 10
var fuerzaEmpujeAtaque = 200

@onready var areaAtaque: Area2D = $hurtboxComponente

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("atacar"):
		_atacar()

func _atacar() -> void:
	var atacante := _obtener_atacante()
	for area in areaAtaque.get_overlapping_areas():
		if area is hurtboxComponente:
			var ataque = Ataque.new()
			ataque.ataqueDanio = danioAtaque
			ataque.ataqueFuerzaEmpuje = fuerzaEmpujeAtaque
			ataque.ataquePosicion = global_position
			ataque.atacante = atacante

			area.danio(ataque)


func _obtener_atacante() -> Node:
	# Los hijos reciben _ready antes que el jugador: consultar al atacar evita
	# cachear null antes de que su propietario se agregue al grupo.
	var ancestro := get_parent()
	while ancestro != null:
		if ancestro.is_in_group("jugador"):
			return ancestro
		ancestro = ancestro.get_parent()
	return null
