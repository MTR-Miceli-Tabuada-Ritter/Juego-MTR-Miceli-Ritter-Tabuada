extends Node2D
class_name saludComponente

signal danio_recibido(ataque: Ataque)
signal murio(ataque: Ataque)
signal salud_cambiada(salud: float, salud_max: float)

const FRICCION_EMPUJE = 800.0

@export var SALUD_MAX = 10
@export var aplicar_friccion_empuje: bool = true
## Si es false, el dueño decide qué pasa al morir (el jugador no desaparece).
@export var liberar_al_morir: bool = true
## Vida recuperada por segundo; 0 desactiva la regeneración.
@export var regeneracion_por_segundo: float = 0.0
## Segundos sin recibir daño antes de empezar a regenerar.
@export var espera_regeneracion: float = 5.0
var salud:float
var _muerto: bool = false
var _tiempo_sin_danio := 0.0

func _ready() -> void:
	salud = SALUD_MAX

func _physics_process(delta: float) -> void:
	_regenerar(delta)
	if not aplicar_friccion_empuje:
		return
	var cuerpo := get_parent() as CharacterBody2D
	if cuerpo and cuerpo.velocity != Vector2.ZERO:
		cuerpo.velocity = cuerpo.velocity.move_toward(Vector2.ZERO, FRICCION_EMPUJE * delta)
		cuerpo.move_and_slide()

func danio(ataque: Ataque) -> void:
	if _muerto or ataque == null or not is_finite(ataque.ataqueDanio) or ataque.ataqueDanio <= 0.0:
		return
	salud -= ataque.ataqueDanio
	_tiempo_sin_danio = 0.0
	var golpe_mortal := salud <= 0.0
	# Antes de CUALQUIER señal: sus observadores pueden volver a llamar danio.
	if golpe_mortal:
		_muerto = true

	var propietario := get_parent()
	var cuerpo := propietario as CharacterBody2D
	if cuerpo:
		cuerpo.velocity = (cuerpo.global_position - ataque.ataquePosicion).normalized() * ataque.ataqueFuerzaEmpuje

	salud_cambiada.emit(salud, SALUD_MAX)
	danio_recibido.emit(ataque)
	if golpe_mortal:
		murio.emit(ataque)
		if liberar_al_morir and is_instance_valid(propietario) and not propietario.is_queued_for_deletion():
			propietario.queue_free()

func curar(cantidad: float) -> void:
	if _muerto or not is_finite(cantidad) or cantidad <= 0.0:
		return
	var anterior := salud
	salud = minf(salud + cantidad, SALUD_MAX)
	if salud != anterior:
		salud_cambiada.emit(salud, SALUD_MAX)

func _regenerar(delta: float) -> void:
	if _muerto or regeneracion_por_segundo <= 0.0 or salud >= SALUD_MAX:
		return
	_tiempo_sin_danio += delta
	if _tiempo_sin_danio >= espera_regeneracion:
		curar(regeneracion_por_segundo * delta)
