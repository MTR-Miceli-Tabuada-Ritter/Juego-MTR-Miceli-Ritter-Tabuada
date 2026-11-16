extends "res://escenas/enemigo_misiones.gd"

enum Estado { QUIETO, AVISANDO, EMBISTIENDO, RECARGANDO }

@export var rango_vista: float = 120.0
@export var duracion_aviso: float = 0.3
@export var velocidad_embestida: float = 420.0
@export var duracion_recarga: float = 1.0
@export var danio_embestida: float = 10.0

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var rango_vista_area: Area2D = $rangoVista
@onready var area_ataque: Area2D = $areaAtaque

var _estado: Estado = Estado.QUIETO
var _objetivo: CharacterBody2D
var _direccion_embestida := Vector2.ZERO
var _tiempo_embestida := 0.0
var _tiempo_recarga := 0.0
var _danio_aplicado := false


func _ready() -> void:
	super._ready()
	(rango_vista_area.get_node("CollisionShape2D").shape as CircleShape2D).radius = rango_vista
	rango_vista_area.body_entered.connect(_al_detectar_cuerpo)


func _physics_process(delta: float) -> void:
	match _estado:
		Estado.EMBISTIENDO:
			velocity = _direccion_embestida * velocidad_embestida
			move_and_slide()
			_aplicar_danio_embestida()
			_tiempo_embestida -= delta
			if _tiempo_embestida <= 0.0:
				_iniciar_recarga()
		Estado.RECARGANDO:
			velocity = Vector2.ZERO
			_tiempo_recarga -= delta
			if _tiempo_recarga <= 0.0:
				_estado = Estado.QUIETO
				_buscar_jugador_en_rango()


func _al_detectar_cuerpo(cuerpo: Node2D) -> void:
	if _estado == Estado.QUIETO and cuerpo.is_in_group("jugador"):
		_iniciar_aviso(cuerpo as CharacterBody2D)


func _iniciar_aviso(jugador: CharacterBody2D) -> void:
	if jugador == null:
		return
	_estado = Estado.AVISANDO
	_objetivo = jugador
	animacion.modulate = Color.RED
	await get_tree().create_timer(duracion_aviso).timeout
	if not is_inside_tree() or _estado != Estado.AVISANDO:
		return

	animacion.modulate = Color.WHITE
	if not is_instance_valid(_objetivo) or _objetivo.is_queued_for_deletion():
		_iniciar_recarga()
		return

	var desplazamiento := _objetivo.global_position - global_position
	_direccion_embestida = desplazamiento.normalized()
	if _direccion_embestida == Vector2.ZERO:
		_iniciar_recarga()
		return

	_tiempo_embestida = clampf(desplazamiento.length() / velocidad_embestida, 0.1, 0.4)
	_danio_aplicado = false
	componente_salud.aplicar_friccion_empuje = false
	_estado = Estado.EMBISTIENDO


func _aplicar_danio_embestida() -> void:
	if _danio_aplicado:
		return
	for area in area_ataque.get_overlapping_areas():
		if area is hurtboxComponente:
			var ataque := Ataque.new()
			ataque.ataqueDanio = danio_embestida
			ataque.ataqueFuerzaEmpuje = 150.0
			ataque.ataquePosicion = global_position
			ataque.atacante = self
			area.danio(ataque)
			_danio_aplicado = true
			return


func _iniciar_recarga() -> void:
	_estado = Estado.RECARGANDO
	_tiempo_recarga = duracion_recarga
	velocity = Vector2.ZERO
	componente_salud.aplicar_friccion_empuje = true


func _buscar_jugador_en_rango() -> void:
	for cuerpo in rango_vista_area.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			_iniciar_aviso(cuerpo as CharacterBody2D)
			return
