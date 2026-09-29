extends Node2D
class_name saludComponente

signal danio_recibido(ataque: Ataque)

const FRICCION_EMPUJE = 800.0

@export var SALUD_MAX = 10
var salud:float

func _ready() -> void:
	salud = SALUD_MAX

func _physics_process(delta: float) -> void:
	var cuerpo := get_parent() as CharacterBody2D
	if cuerpo and cuerpo.velocity != Vector2.ZERO:
		cuerpo.velocity = cuerpo.velocity.move_toward(Vector2.ZERO, FRICCION_EMPUJE * delta)
		cuerpo.move_and_slide()

func danio(ataque:Ataque):
	salud -= ataque.ataqueDanio
	danio_recibido.emit(ataque)

	var cuerpo := get_parent() as CharacterBody2D
	if cuerpo:
		cuerpo.velocity = (cuerpo.global_position - ataque.ataquePosicion).normalized() * ataque.ataqueFuerzaEmpuje

	if salud <= 0:
		get_parent().queue_free()
	
