class_name ItemEspada
extends Item
## Arma de combate: con la espada seleccionada, K o clic izquierdo atacan.
## No trabaja la tierra; el jugador comprueba este tipo antes de golpear.

func _init() -> void:
	oculta_contador = true
	max_stack = 1
	nombre_animacion = "Espada"
