extends CanvasLayer

var _progreso_anterior: Dictionary = {}

@onready var _aviso: PanelContainer = %Aviso
@onready var _titulo: Label = %Titulo
@onready var _detalle: Label = %Detalle
@onready var _temporizador: Timer = %Temporizador


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GestorMisiones.mision_aceptada.connect(_al_aceptar_mision)
	GestorMisiones.progreso_actualizado.connect(_al_actualizar_progreso)
	GestorMisiones.disponibilidad_finalizacion_cambiada.connect(_al_cambiar_disponibilidad)
	GestorMisiones.mision_completada.connect(_al_completar_mision)
	_temporizador.timeout.connect(_ocultar)


func _al_aceptar_mision(id: String) -> void:
	_progreso_anterior[id] = GestorMisiones.obtener_progreso(id).duplicate(true)
	_mostrar("Misión aceptada", _nombre_mision(id))


func _al_actualizar_progreso(id: String, progreso: Dictionary) -> void:
	if GestorMisiones.obtener_estado(id) != GestorMisiones.Estado.ACTIVA:
		_progreso_anterior[id] = progreso.duplicate(true)
		return
	if not _progreso_anterior.has(id):
		_progreso_anterior[id] = progreso.duplicate(true)
		return
	var anterior: Dictionary = _progreso_anterior[id]
	for objetivo_id in progreso:
		var nuevo: Dictionary = progreso[objetivo_id]
		var previo: Dictionary = anterior.get(objetivo_id, {})
		var actual: int = int(nuevo.get("actual", 0))
		if actual == int(previo.get("actual", 0)):
			continue
		var descripcion: String = String(nuevo.get("descripcion", ""))
		var requerido: int = int(nuevo.get("requerido", 1))
		_mostrar("Progreso de misión", "%s\n%s: %d / %d" % [_nombre_mision(id), descripcion, actual, requerido])
		break
	_progreso_anterior[id] = progreso.duplicate(true)


func _al_cambiar_disponibilidad(id: String, disponible: bool) -> void:
	if disponible:
		_mostrar("Lista para entregar", _nombre_mision(id))


func _al_completar_mision(id: String) -> void:
	_mostrar("Misión completada", _nombre_mision(id))


func _nombre_mision(id: String) -> String:
	var titulo: String = GestorMisiones.obtener_titulo(id)
	return titulo if not titulo.is_empty() else id


func _mostrar(titulo: String, detalle: String) -> void:
	_titulo.text = titulo
	_detalle.text = detalle
	_aviso.show()
	_temporizador.start()


func _ocultar() -> void:
	_aviso.hide()