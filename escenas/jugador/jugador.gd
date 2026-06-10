extends CharacterBody2D

var velocidad = 200.0

func _physics_process(delta: float) -> void:
	var direccionMovimiento = Input.get_vector("correrIzquierda", "correrDerecha", "correrArriba", "correrAbajo")
	velocity = velocidad * direccionMovimiento
	move_and_slide()
