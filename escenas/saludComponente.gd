extends Node2D
class_name saludComponente

signal danio_recibido(ataque: Ataque)
signal murio(ataque: Ataque)

const FRICCION_EMPUJE = 800.0

@export var SALUD_MAX = 10
var salud:float
var _muerto: bool = false

func _ready() -> void:
	salud = SALUD_MAX

func _physics_process(delta: float) -> void:
	var cuerpo := get_parent() as CharacterBody2D
	if cuerpo and cuerpo.velocity != Vector2.ZERO:
		cuerpo.velocity = cuerpo.velocity.move_toward(Vector2.ZERO, FRICCION_EMPUJE * delta)
		cuerpo.move_and_slide()

func danio(ataque: Ataque) -> void:
	if _muerto or ataque == null or not is_finite(ataque.ataqueDanio) or ataque.ataqueDanio <= 0.0:
		return
	salud -= ataque.ataqueDanio
	var golpe_mortal := salud <= 0.0
	# Antes de CUALQUIER señal: sus observadores pueden volver a llamar danio.
	if golpe_mortal:
		_muerto = true

	var propietario := get_parent()
	var cuerpo := propietario as CharacterBody2D
	if cuerpo:
		cuerpo.velocity = (cuerpo.global_position - ataque.ataquePosicion).normalized() * ataque.ataqueFuerzaEmpuje

	danio_recibido.emit(ataque)
	if golpe_mortal:
		murio.emit(ataque)
		if is_instance_valid(propietario) and not propietario.is_queued_for_deletion():
			propietario.queue_free()
