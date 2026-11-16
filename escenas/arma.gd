extends Node2D

var danioAtaque = 10
var fuerzaEmpujeAtaque = 200

@onready var areaAtaque: Area2D = $hurtboxComponente

var _ultimo_frame_ataque := -1

# K o clic izquierdo. Sin polling: los clics que consume la interfaz
# (diálogos, mochila, HUD) no llegan acá y no atacan.
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("atacar"):
		return
	# K y clic en el mismo fotograma cuentan como un solo golpe.
	var frame := Engine.get_process_frames()
	if frame == _ultimo_frame_ataque:
		return
	_ultimo_frame_ataque = frame
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
