extends "res://escenas/enemigo_misiones.gd"

enum Estado { QUIETO, AVISANDO, PERSIGUIENDO, PREPARANDO, EMBISTIENDO, RECARGANDO, MUERTO }

@export var rango_vista: float = 270.0
@export var duracion_aviso: float = 0.8
@export var velocidad_persecucion: float = 100.0
@export var distancia_embestida: float = 120.0
@export var duracion_preparacion: float = 0.5
@export var velocidad_embestida: float = 420.0
@export var duracion_recarga: float = 0.5
@export var danio_embestida: float = 10.0

@onready var animacion: AnimatedSprite2D = $AnimatedSprite2D
@onready var rango_vista_area: Area2D = $rangoVista
@onready var area_ataque: Area2D = $areaAtaque
@onready var barra_salud: ProgressBar = $BarraSalud

var _estado: Estado = Estado.QUIETO
var _objetivo: CharacterBody2D
var _direccion_embestida := Vector2.ZERO
var _tiempo_preparacion := 0.0
var _tiempo_embestida := 0.0
var _tiempo_recarga := 0.0
var _danio_aplicado := false
var _empuje := Vector2.ZERO
var _temblor: Tween
var _offset_temblor := Vector2.ZERO


func _ready() -> void:
	super._ready()
	componente_salud.salud_cambiada.connect(_actualizar_barra_salud)
	_actualizar_barra_salud(componente_salud.salud, componente_salud.SALUD_MAX)
	(rango_vista_area.get_node("CollisionShape2D").shape as CircleShape2D).radius = rango_vista
	rango_vista_area.body_entered.connect(_al_detectar_cuerpo)
	# La IA reescribe velocity en cada paso y anularía el empuje que deja
	# saludComponente: el esqueleto lo guarda aparte y lo aplica él mismo.
	componente_salud.aplicar_friccion_empuje = false
	componente_salud.liberar_al_morir = false
	componente_salud.danio_recibido.connect(_al_recibir_danio)


func _actualizar_barra_salud(salud: float, salud_max: float) -> void:
	barra_salud.max_value = salud_max
	barra_salud.value = salud


func _physics_process(delta: float) -> void:
	match _estado:
		Estado.PERSIGUIENDO:
			_perseguir_jugador()
		Estado.PREPARANDO:
			velocity = Vector2.ZERO
			_tiempo_preparacion -= delta
			if _tiempo_preparacion <= 0.0:
				_detener_temblor()
				_danio_aplicado = false
				_estado = Estado.EMBISTIENDO
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
				if _objetivo_en_rango():
					_estado = Estado.PERSIGUIENDO
					_perseguir_jugador()
				else:
					_estado = Estado.QUIETO
					_buscar_jugador_en_rango()
	_deslizar_por_empuje(delta)


func _al_recibir_danio(ataque: Ataque) -> void:
	_empuje = (global_position - ataque.ataquePosicion).normalized() * ataque.ataqueFuerzaEmpuje
	velocity = Vector2.ZERO


func _al_morir(ataque: Ataque) -> void:
	if _estado == Estado.MUERTO:
		return
	_estado = Estado.MUERTO
	barra_salud.hide()
	set_physics_process(false)
	velocity = Vector2.ZERO
	_empuje = Vector2.ZERO
	_detener_temblor()
	animacion.pause()
	animacion.modulate = Color.WHITE
	# El golpe puede llegar mientras el motor procesa los solapamientos.
	for forma in [$cuerpo, $hurtboxComponente/CollisionShape2D,
			$rangoVista/CollisionShape2D, $areaAtaque/CollisionShape2D]:
		forma.set_deferred("disabled", true)
	super._al_morir(ataque)

	var caida := create_tween()
	caida.tween_property(animacion, "rotation_degrees", 90.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	caida.tween_interval(1)
	caida.tween_callback(queue_free)


func _deslizar_por_empuje(delta: float) -> void:
	if _empuje == Vector2.ZERO:
		return
	var propia := velocity
	velocity = _empuje
	move_and_slide()
	velocity = propia
	_empuje = _empuje.move_toward(Vector2.ZERO, componente_salud.FRICCION_EMPUJE * delta)


func _al_detectar_cuerpo(cuerpo: Node2D) -> void:
	if _estado == Estado.QUIETO and cuerpo.is_in_group("jugador"):
		_iniciar_aviso(cuerpo as CharacterBody2D)


func _iniciar_aviso(jugador: CharacterBody2D) -> void:
	if jugador == null:
		return
	_estado = Estado.AVISANDO
	_objetivo = jugador
	velocity = Vector2.ZERO
	animacion.modulate = Color.RED
	await get_tree().create_timer(duracion_aviso).timeout
	if not is_inside_tree() or _estado != Estado.AVISANDO:
		return

	animacion.modulate = Color.WHITE
	if not _objetivo_en_rango():
		_iniciar_recarga()
		return

	_estado = Estado.PERSIGUIENDO


func _iniciar_temblor() -> void:
	_detener_temblor()
	_offset_temblor = animacion.offset
	_temblor = create_tween().set_loops()
	_temblor.tween_property(animacion, "offset:x", _offset_temblor.x + 2.0, 0.025)
	_temblor.tween_property(animacion, "offset:x", _offset_temblor.x - 2.0, 0.05)
	_temblor.tween_property(animacion, "offset:x", _offset_temblor.x, 0.025)


func _detener_temblor() -> void:
	if _temblor != null:
		_temblor.kill()
		_temblor = null
		animacion.offset = _offset_temblor


func _objetivo_en_rango() -> bool:
	return (is_instance_valid(_objetivo)
		and not _objetivo.is_queued_for_deletion()
		and rango_vista_area.overlaps_body(_objetivo))


func _perseguir_jugador() -> void:
	if not _objetivo_en_rango():
		_iniciar_recarga()
		return

	var desplazamiento := _objetivo.global_position - global_position
	if desplazamiento.length() <= distancia_embestida:
		_preparar_embestida(desplazamiento)
	elif _empuje == Vector2.ZERO:
		# Mientras lo empujan no camina; si no, la persecución anula el empuje.
		velocity = desplazamiento.normalized() * velocidad_persecucion
		move_and_slide()


func _preparar_embestida(desplazamiento: Vector2) -> void:
	# Apuntar al empezar la pausa: moverse durante ella permite esquivar.
	_direccion_embestida = desplazamiento.normalized()
	if _direccion_embestida == Vector2.ZERO:
		_iniciar_recarga()
		return

	_tiempo_embestida = clampf(desplazamiento.length() / velocidad_embestida, 0.1, 0.4)
	_tiempo_preparacion = duracion_preparacion
	velocity = Vector2.ZERO
	_estado = Estado.PREPARANDO
	_iniciar_temblor()


func _aplicar_danio_embestida() -> void:
	if _danio_aplicado:
		return
	for area in area_ataque.get_overlapping_areas():
		if area is hurtboxComponente and area.componenteSalud != null:
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


func _buscar_jugador_en_rango() -> void:
	for cuerpo in rango_vista_area.get_overlapping_bodies():
		if cuerpo.is_in_group("jugador"):
			_iniciar_aviso(cuerpo as CharacterBody2D)
			return
