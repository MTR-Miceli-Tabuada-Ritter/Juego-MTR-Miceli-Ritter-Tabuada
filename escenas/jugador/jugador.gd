extends CharacterBody2D

@export var animacion: AnimatedSprite2D 
@export var direccionVista: Marker2D

var velocidad = 200.0
var ultima_direccion = Vector2.DOWN
var esta_actuando = false
var posicionBase = "abajo"

func _ready() -> void:
	animacion.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	var direccionMovimiento = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = velocidad * direccionMovimiento
	
	# agarramos la última dirección si se está moviendo
	if direccionMovimiento != Vector2.ZERO:
		ultima_direccion = direccionMovimiento

	# si no usa la herramienta, mandamos la cosa
	if Input.is_action_just_pressed("herramienta") and not esta_actuando:
		esta_actuando = true
		_procesar_animacion("herramienta", ultima_direccion)

	# si no usa herramienta ahi hace correr o idle
	if not esta_actuando:
		if direccionMovimiento != Vector2.ZERO:
			_procesar_animacion("correr", direccionMovimiento)
		else:
			_procesar_animacion("idle", ultima_direccion)

	move_and_slide()

func _procesar_animacion(estado: String, direccion: Vector2) -> void:
	if abs(direccion.x) > abs(direccion.y):
		if direccion.x > 0:
			animacion.play(estado + "Derecha")
		else:
			animacion.play(estado + "Izquierda")
	else:
		if direccion.y > 0:
			animacion.play(estado + "Abajo")
		else:
			animacion.play(estado + "Arriba")

func _on_animation_finished() -> void:
	if esta_actuando:
		esta_actuando = false
