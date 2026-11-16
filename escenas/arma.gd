extends Node2D
## Área del corte de la espada. El jugador la orienta al empezar el golpe y
## pide el impacto en el cuadro visible del corte; el arma no lee la entrada.

var danioAtaque = 10
var fuerzaEmpujeAtaque = 300

@onready var areaAtaque: Area2D = $areaAtaque

var _frame_preparado := -1
var _impacto_pendiente := false

func _ready() -> void:
	set_physics_process(false)

# Gira el área hacia la dirección cardinal del golpe (el rectángulo mira a +X).
func preparar(direccion: Vector2) -> void:
	rotation = direccion.angle()
	_frame_preparado = Engine.get_physics_frames()
	cancelar()

func impactar() -> void:
	if _solapamientos_actualizados():
		_atacar()
	else:
		_impacto_pendiente = true
		set_physics_process(true)

func cancelar() -> void:
	_impacto_pendiente = false
	set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if _impacto_pendiente and _solapamientos_actualizados():
		cancelar()
		_atacar()

# Godot calcula los solapamientos en un paso físico y los publica al inicio
# del siguiente: dos pasos después de girar, la lista ya refleja el área nueva.
func _solapamientos_actualizados() -> bool:
	return _frame_preparado >= 0 and Engine.get_physics_frames() >= _frame_preparado + 2

func _atacar() -> void:
	var atacante := _obtener_atacante()
	var golpeados: Array[saludComponente] = []
	for area in areaAtaque.get_overlapping_areas():
		if not area is hurtboxComponente or area.componenteSalud == null:
			continue
		# Varias hurtboxes del mismo objetivo reciben un solo golpe.
		if golpeados.has(area.componenteSalud):
			continue
		if atacante != null and atacante.is_ancestor_of(area):
			continue
		golpeados.append(area.componenteSalud)
		var ataque = Ataque.new()
		ataque.ataqueDanio = danioAtaque
		ataque.ataqueFuerzaEmpuje = fuerzaEmpujeAtaque
		ataque.ataquePosicion = global_position
		ataque.atacante = atacante

		area.danio(ataque)


func _obtener_atacante() -> Node:
	# Los hijos reciben _ready antes que el jugador: consultar al atacar evita
	# cachear null antes de que su propietario se agregue al grupo.
	var ancestro := get_parent()
	while ancestro != null:
		if ancestro.is_in_group("jugador"):
			return ancestro
		ancestro = ancestro.get_parent()
	return null
