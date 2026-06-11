extends CharacterBody2D

@export var animacion: AnimatedSprite2D 

var velocidad = 200.0
var ultima_direccion = Vector2.DOWN #arranca para abajo

func _physics_process(_delta: float) -> void:
	var direccionMovimiento = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = velocidad * direccionMovimiento
	
	#controlamos estados de movimiento
	if direccionMovimiento != Vector2.ZERO:
		ultima_direccion = direccionMovimiento #guarda la ultima direccion antes de q frene
		_procesar_animacion("correr", direccionMovimiento)
	else:
		_procesar_animacion("idle", ultima_direccion)

	move_and_slide()


func _procesar_animacion(estado: String, direccion: Vector2) -> void:
	if direccion.x > 0:
		animacion.play(estado + "Derecha")
	elif direccion.x < 0:
		animacion.play(estado + "Izquierda")
	# si no pasa nada en x, vamos con y
	elif direccion.y > 0:
		animacion.play(estado + "Abajo")
	elif direccion.y < 0:
		animacion.play(estado + "Arriba")
