extends CharacterBody2D
## Adaptador de enemigos: salud no conoce misiones y salir del árbol no es morir.

@export var tipo_enemigo: String = ""

var _id_muerte: String
var _muerte_registrada: bool = false

@onready var componente_salud: saludComponente = $saludComponente


func _ready() -> void:
	# El InstanceID identifica esta vida, no una posición ni el nombre del nodo.
	_id_muerte = "enemigo:%d" % get_instance_id()
	componente_salud.murio.connect(_al_morir)


func _al_morir(ataque: Ataque) -> void:
	if _muerte_registrada:
		return
	_muerte_registrada = true
	# No pasar un objeto ya liberado a un parámetro tipado como Node.
	var responsable: Node = ataque.atacante if is_instance_valid(ataque.atacante) else null
	GestorMisiones.registrar_derrota(tipo_enemigo, _id_muerte, responsable)