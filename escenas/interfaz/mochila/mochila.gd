extends CanvasLayer
## Ventana del inventario de la partida. El modelo es la única fuente de verdad.

const SlotMochila = preload("res://escenas/interfaz/mochila/slot_mochila.gd")
const ESCENA_SLOT = preload("res://escenas/interfaz/mochila/slot_mochila.tscn")

var abierta: bool:
	get:
		return is_instance_valid(_pantalla) and _pantalla.visible

var origen_seleccionado: int = -1
var _slots: Array[SlotMochila] = []
var _inventario: Inventario
var _stack_origen: ItemStack = null
var _indice_hover: int = -1
var _pausa_propia: bool = false

@onready var _pantalla: Control = %Pantalla
@onready var _barra_rapida: GridContainer = %BarraRapida
@onready var _reserva: GridContainer = %Reserva
@onready var _cerrar: Button = %Cerrar
@onready var _ocupacion: Label = %Ocupacion
@onready var _dinero: Label = %Dinero
@onready var _detalle: Label = %Detalle
@onready var _estado: Label = %Estado


func _ready() -> void:
	_inventario = InventarioJugador.inventario
	_cerrar.pressed.connect(cerrar)
	_pantalla.gui_input.connect(_entrada_fondo)
	_inventario.inventario_cambiado.connect(_al_cambiar_inventario)
	InventarioJugador.plata_cambiada.connect(_actualizar_dinero)
	InventarioJugador.seleccion_cambiada.connect(_al_cambiar_equipado)
	InventarioJugador.partida_reiniciada.connect(_al_reiniciar_partida)
	DialogueManager.dialogue_started.connect(_al_iniciar_dialogo)
	_actualizar_vista()


func abrir() -> bool:
	if not is_node_ready() or not is_inside_tree():
		return false
	if abierta:
		return true
	if get_tree().paused or PausaDialogo.dialogo_activo or InventarioJugador.ventana_abierta:
		return false
	_limpiar_origen()
	_indice_hover = -1
	_actualizar_vista()
	_estado.text = "Elegí un objeto para moverlo. Verde: espacio equipado."
	SonidosGlobales.detenerSonidoCaminar()
	SonidosGlobales.detenerSonidoRegar()
	# El resto de la interfaz debe ver el bloqueo antes de pausar el árbol.
	InventarioJugador.ventana_abierta = true
	_pausa_propia = true
	_pantalla.show()
	_habilitar_slots(true)
	get_tree().paused = true
	_cerrar.grab_focus()
	return true


func cerrar(reanudar: bool = true) -> void:
	# Una instancia oculta no debe limpiar el bloqueo de otra ventana.
	var era_propia := abierta or _pausa_propia
	_limpiar_origen()
	_indice_hover = -1
	_habilitar_slots(false)
	if is_instance_valid(_pantalla):
		_pantalla.hide()
	if is_instance_valid(_cerrar):
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


func pulsar_slot(indice: int) -> void:
	if not abierta or not _indice_valido(indice):
		return
	if origen_seleccionado == indice:
		_cancelar_seleccion()
		return
	if origen_seleccionado >= 0:
		# Nunca usar un origen que fue sustituido por una recompensa, reinicio, etc.
		if _inventario.obtener_stack(origen_seleccionado) != _stack_origen:
			_cancelar_seleccion()
			_estado.text = "El origen cambió. Elegí el objeto de nuevo."
			return
		mover_stack(origen_seleccionado, indice)
		return
	var stack := _inventario.obtener_stack(indice)
	if stack == null or stack.item == null or stack.cantidad <= 0:
		_estado.text = "Espacio vacío. Primero elegí el objeto que querés mover."
		return
	_elegir_origen(indice)


func mover_stack(origen: int, destino: int) -> bool:
	if not abierta or not _indice_valido(origen) or not _indice_valido(destino):
		return false
	if origen == destino:
		_cancelar_seleccion()
		return false
	var stack := _inventario.obtener_stack(origen)
	if stack == null or stack.item == null or stack.cantidad <= 0:
		_cancelar_seleccion()
		_estado.text = "El origen está vacío. Elegí otro objeto."
		return false
	var nombre := stack.item.obtener_nombre()
	# El modelo emite su señal dentro de la operación: limpiar ANTES de llamarlo.
	_limpiar_origen()
	var movido := _inventario.mover_o_intercambiar(origen, destino)
	if not movido and _inventario.obtener_stack(origen) == stack:
		origen_seleccionado = origen
		_stack_origen = stack
	_actualizar_vista()
	if movido:
		_estado.text = "%s: movimiento realizado." % nombre
	else:
		_estado.text = "No hay espacio en ese destino. Probá otro o cancelá con clic derecho."
	return movido


func obtener_slot(indice: int) -> SlotMochila:
	return _slots[indice] if indice >= 0 and indice < _slots.size() else null


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		if abierta:
			get_viewport().set_input_as_handled()
		return
	if InputMap.has_action("inventario") and event.is_action_pressed("inventario"):
		if abierta:
			cerrar()
			get_viewport().set_input_as_handled()
		elif abrir():
			get_viewport().set_input_as_handled()
		return
	if not abierta:
		return
	if event.is_action_pressed("pausar"):
		cerrar()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		_cancelar_seleccion()
		get_viewport().set_input_as_handled()


func _entrada_fondo(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_cancelar_seleccion()
	_pantalla.accept_event()


func _elegir_origen(indice: int) -> void:
	origen_seleccionado = indice
	_stack_origen = _inventario.obtener_stack(indice)
	_actualizar_resaltado()
	_actualizar_detalle()
	_estado.text = "Origen: %s · Elegí destino. Clic derecho: cancelar." % _stack_origen.item.obtener_nombre()


func _limpiar_origen() -> void:
	origen_seleccionado = -1
	_stack_origen = null


func _cancelar_seleccion() -> void:
	_limpiar_origen()
	_actualizar_resaltado()
	_actualizar_detalle()
	_estado.text = "Selección cancelada. Ningún objeto se quitó del inventario."


func _al_cambiar_inventario() -> void:
	var habia_origen := origen_seleccionado >= 0
	_limpiar_origen()
	_actualizar_vista()
	if abierta and habia_origen:
		_estado.text = "El inventario cambió. Elegí el origen de nuevo."


func _actualizar_vista() -> void:
	if _slots.size() != _inventario.capacidad:
		_reconstruir_slots()
	var ocupados := 0
	for i in range(_slots.size()):
		var stack := _inventario.obtener_stack(i)
		_slots[i].configurar(i, stack, i < 10)
		if stack != null and stack.cantidad > 0:
			ocupados += 1
	_ocupacion.text = "%d / %d espacios ocupados" % [ocupados, _inventario.capacidad]
	_actualizar_dinero()
	_actualizar_resaltado()
	_actualizar_detalle()


func _reconstruir_slots() -> void:
	for slot in _slots:
		# Quitarlos ahora; queue_free por sí solo conserva hijos hasta fin de frame.
		slot.get_parent().remove_child(slot)
		slot.queue_free()
	_slots.clear()
	_indice_hover = -1
	for i in range(_inventario.capacidad):
		var slot := ESCENA_SLOT.instantiate() as SlotMochila
		slot.name = "Slot%d" % i
		slot.inventario = _inventario
		slot.permite_interaccion = abierta
		slot.pulsado.connect(pulsar_slot)
		slot.sobre_slot.connect(_al_entrar_slot)
		slot.fuera_slot.connect(_al_salir_slot)
		slot.movimiento_solicitado.connect(_al_solicitar_movimiento)
		slot.arrastre_iniciado.connect(_al_iniciar_arrastre)
		slot.arrastre_finalizado.connect(_al_finalizar_arrastre)
		var contenedor: GridContainer = _barra_rapida if i < 10 else _reserva
		contenedor.add_child(slot)
		_slots.append(slot)


func _actualizar_dinero() -> void:
	_dinero.text = "$ %d" % InventarioJugador.plata


func _actualizar_resaltado() -> void:
	for slot in _slots:
		if is_instance_valid(slot):
			slot.resaltar(slot.indice == InventarioJugador.indice_seleccionado, slot.indice == origen_seleccionado)


func _actualizar_detalle() -> void:
	var indice := _indice_hover
	if not _indice_valido(indice):
		indice = origen_seleccionado if origen_seleccionado >= 0 else InventarioJugador.indice_seleccionado
	var stack := _inventario.obtener_stack(indice)
	if stack == null or stack.item == null:
		_detalle.text = "Espacio %d · Vacío" % (indice + 1) if _indice_valido(indice) else "Pasá sobre un objeto para ver sus detalles."
		return
	_detalle.text = "%s · Cantidad: %d" % [stack.item.obtener_nombre(), stack.cantidad]
	if stack.item.capacidad_carga > 0:
		_detalle.text += " · Cargas: %d / %d" % [stack.cargas, stack.item.capacidad_carga]
	_detalle.tooltip_text = _detalle.text


func _al_cambiar_equipado(_indice: int) -> void:
	_actualizar_resaltado()
	_actualizar_detalle()


func _al_entrar_slot(indice: int) -> void:
	_indice_hover = indice
	_actualizar_detalle()


func _al_salir_slot(indice: int) -> void:
	if _indice_hover == indice:
		_indice_hover = -1
		_actualizar_detalle()


func _al_iniciar_arrastre(indice: int) -> void:
	if abierta and _indice_valido(indice):
		_elegir_origen(indice)
		_estado.text = "Soltá en un espacio. Fuera de la mochila: cancelar sin perder objetos."


func _al_solicitar_movimiento(origen: int, destino: int) -> void:
	mover_stack(origen, destino)


func _al_finalizar_arrastre(exitoso: bool) -> void:
	if abierta and not exitoso:
		_cancelar_seleccion()


func _habilitar_slots(habilitados: bool) -> void:
	for slot in _slots:
		if is_instance_valid(slot):
			slot.permite_interaccion = habilitados


func _indice_valido(indice: int) -> bool:
	return _inventario != null and indice >= 0 and indice < _inventario.capacidad


func _al_iniciar_dialogo(_recurso: DialogueResource) -> void:
	if abierta:
		cerrar(false) # PausaDialogo ya tomó la pausa; nunca reanudar por encima.


func _al_reiniciar_partida() -> void:
	cerrar()
	_actualizar_vista()


func _exit_tree() -> void:
	cerrar()