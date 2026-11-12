extends CanvasLayer

var abierta: bool:
	get:
		return is_instance_valid(_pantalla) and _pantalla.visible

var _completadas: bool = false
var _pausa_propia: bool = false
var _seleccion_id: String = ""
var _resumenes_por_id: Dictionary = {}

@onready var _pantalla: Control = %Pantalla
@onready var _cerrar: Button = %Cerrar
@onready var _tab_activas: Button = %Activas
@onready var _tab_completadas: Button = %Completadas
@onready var _lista: VBoxContainer = %Lista
@onready var _vacio: Label = %Vacio
@onready var _titulo: Label = %TituloMision
@onready var _estado: Label = %EstadoMision
@onready var _descripcion: Label = %Descripcion
@onready var _objetivos: VBoxContainer = %Objetivos


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cerrar.pressed.connect(cerrar)
	_tab_activas.pressed.connect(_mostrar_activas)
	_tab_completadas.pressed.connect(_mostrar_completadas)
	_pantalla.gui_input.connect(_entrada_fondo)
	GestorMisiones.mision_aceptada.connect(_al_cambiar_misiones)
	GestorMisiones.progreso_actualizado.connect(_al_cambiar_progreso)
	GestorMisiones.disponibilidad_finalizacion_cambiada.connect(_al_cambiar_disponibilidad)
	GestorMisiones.mision_completada.connect(_al_mision_completada)
	InventarioJugador.partida_reiniciada.connect(_al_reiniciar_partida)
	DialogueManager.dialogue_started.connect(_al_iniciar_dialogo)
	_refrescar()


func abrir() -> bool:
	if not is_node_ready() or not is_inside_tree():
		return false
	if abierta:
		return true
	if get_tree().paused or PausaDialogo.dialogo_activo or InventarioJugador.ventana_abierta:
		return false
	_refrescar()
	InventarioJugador.ventana_abierta = true
	_pausa_propia = true
	_pantalla.show()
	get_tree().paused = true
	_cerrar.grab_focus()
	return true


func cerrar(reanudar: bool = true) -> void:
	var era_propia := abierta or _pausa_propia
	if is_instance_valid(_pantalla):
		_pantalla.hide()
	if is_instance_valid(_cerrar) and _cerrar.is_inside_tree():
		_cerrar.release_focus()
	if not era_propia:
		return
	InventarioJugador.ventana_abierta = false
	var reanudar_arbol := _pausa_propia and reanudar and not PausaDialogo.dialogo_activo
	_pausa_propia = false
	if reanudar_arbol and is_inside_tree():
		get_tree().paused = false


func alternar() -> void:
	if abierta:
		cerrar()
	else:
		abrir()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		if abierta:
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("diario_misiones"):
		if abierta:
			cerrar()
		elif abrir():
			get_viewport().set_input_as_handled()
		return
	if abierta and event.is_action_pressed("pausar"):
		cerrar()
		get_viewport().set_input_as_handled()


func _mostrar_activas() -> void:
	_completadas = false
	_actualizar_filtros()
	_refrescar()


func _mostrar_completadas() -> void:
	_completadas = true
	_actualizar_filtros()
	_refrescar()


func _actualizar_filtros() -> void:
	_tab_activas.button_pressed = not _completadas
	_tab_completadas.button_pressed = _completadas


func _refrescar() -> void:
	_resumenes_por_id.clear()
	for child in _lista.get_children():
		if child == _vacio:
			continue
		_lista.remove_child(child)
		child.queue_free()
	var ids_visibles: Array[String] = []
	for resumen in GestorMisiones.obtener_resumen_misiones():
		var id: String = resumen["id"]
		var estado_actual: int = int(resumen["estado"])
		if estado_actual == GestorMisiones.Estado.DISPONIBLE:
			continue
		if (estado_actual == GestorMisiones.Estado.COMPLETADA) != _completadas:
			continue
		_resumenes_por_id[id] = resumen
		ids_visibles.append(id)
		var boton := Button.new()
		boton.text = String(resumen["titulo"])
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.toggle_mode = true
		boton.button_pressed = id == _seleccion_id
		boton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		boton.pressed.connect(_seleccionar_mision.bind(id))
		_lista.add_child(boton)
	_vacio.visible = ids_visibles.is_empty()
	_vacio.text = "No hay misiones completadas." if _completadas else "Todavía no aceptaste ninguna misión."
	if not ids_visibles.has(_seleccion_id):
		_seleccion_id = ids_visibles[0] if not ids_visibles.is_empty() else ""
	for indice in range(ids_visibles.size()):
		var boton := _lista.get_child(indice + 1) as Button
		boton.button_pressed = ids_visibles[indice] == _seleccion_id
	_actualizar_detalle()


func _seleccionar_mision(id: String) -> void:
	_seleccion_id = id
	_refrescar()


func _actualizar_detalle() -> void:
	for child in _objetivos.get_children():
		_objetivos.remove_child(child)
		child.queue_free()
	if not _resumenes_por_id.has(_seleccion_id):
		_titulo.text = "Seleccioná una misión"
		_estado.text = ""
		_descripcion.text = ""
		return
	var resumen: Dictionary = _resumenes_por_id[_seleccion_id]
	var estado_actual: int = int(resumen["estado"])
	_titulo.text = String(resumen["titulo"])
	_estado.text = "Completada" if estado_actual == GestorMisiones.Estado.COMPLETADA else "En curso"
	_descripcion.text = String(resumen["descripcion"])
	var progreso: Dictionary = resumen["progreso"]
	for objetivo_id in progreso:
		var objetivo: Dictionary = progreso[objetivo_id]
		var actual: int = int(objetivo.get("actual", 0))
		var requerido: int = int(objetivo.get("requerido_total", objetivo.get("requerido", 1)))
		var completado: bool = bool(objetivo.get("completo", false))
		var linea := Label.new()
		linea.text = "%s %s  %d / %d" % ["✓" if completado else "•", String(objetivo.get("descripcion", "")), actual, requerido]
		linea.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		linea.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_objetivos.add_child(linea)


func _al_cambiar_misiones(_id: String) -> void:
	_refrescar()


func _al_cambiar_progreso(_id: String, _progreso: Dictionary) -> void:
	_refrescar()


func _al_cambiar_disponibilidad(_id: String, _disponible: bool) -> void:
	_refrescar()


func _al_mision_completada(_id: String) -> void:
	_refrescar()


func _al_reiniciar_partida() -> void:
	_seleccion_id = ""
	_completadas = false
	_actualizar_filtros()
	_refrescar()
	if abierta:
		cerrar()


func _al_iniciar_dialogo(_recurso: DialogueResource) -> void:
	if abierta:
		cerrar(false)


func _entrada_fondo(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cerrar.grab_focus()
	_pantalla.accept_event()


func _exit_tree() -> void:
	cerrar()