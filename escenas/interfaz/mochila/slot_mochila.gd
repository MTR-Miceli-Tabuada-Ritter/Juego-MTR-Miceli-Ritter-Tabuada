extends Button
## Vista de un espacio: nunca modifica cantidades, cargas ni la selección equipada.

signal pulsado(indice: int)
signal sobre_slot(indice: int)
signal fuera_slot(indice: int)
signal movimiento_solicitado(origen: int, destino: int)
signal arrastre_iniciado(indice: int)
signal arrastre_finalizado(exitoso: bool)

var indice: int = -1
var stack: ItemStack = null
var es_rapido: bool = false
var inventario: Inventario = null
var permite_interaccion: bool = false

var _equipado: bool = false
var _origen: bool = false
var _arrastrando: bool = false
var _estilo_base: StyleBoxFlat

@onready var _icono: TextureRect = %Icono
@onready var _cantidad: Label = %Cantidad
@onready var _numero: Label = %Numero
@onready var _cargas: ProgressBar = %Cargas
@onready var _marca_equipado: ColorRect = %Equipado
@onready var _vacio: Label = %Vacio


func _ready() -> void:
	_estilo_base = get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	pressed.connect(_al_pulsar)
	mouse_entered.connect(func() -> void: sobre_slot.emit(indice))
	mouse_exited.connect(func() -> void: fuera_slot.emit(indice))
	_actualizar_visual()


func configurar(nuevo_indice: int, nuevo_stack: ItemStack, rapido: bool) -> void:
	indice = nuevo_indice
	stack = nuevo_stack
	es_rapido = rapido
	if is_node_ready():
		_actualizar_visual()


func resaltar(equipado: bool, origen: bool) -> void:
	_equipado = equipado
	_origen = origen
	if is_node_ready():
		_actualizar_estilo()


func _actualizar_visual() -> void:
	var ocupado := stack != null and stack.item != null and stack.cantidad > 0
	_icono.texture = stack.item.icono if ocupado else null
	_vacio.visible = not ocupado
	_numero.visible = es_rapido
	_numero.text = str((indice + 1) % 10)
	_cantidad.visible = ocupado and (not stack.item.oculta_contador or stack.cantidad > 1)
	_cantidad.text = str(stack.cantidad) if ocupado else ""
	_cargas.visible = ocupado and stack.item.capacidad_carga > 0
	if _cargas.visible:
		_cargas.max_value = stack.item.capacidad_carga
		_cargas.value = stack.cargas
	tooltip_text = "Espacio %d · Vacío" % (indice + 1)
	if ocupado:
		tooltip_text = "%s\nCantidad: %d" % [stack.item.obtener_nombre(), stack.cantidad]
		if stack.item.capacidad_carga > 0:
			tooltip_text += "\nCargas: %d / %d" % [stack.cargas, stack.item.capacidad_carga]
	if es_rapido:
		tooltip_text += "\nBarra rápida · Tecla %s" % _numero.text
	if _equipado:
		tooltip_text += "\nEspacio equipado"
	_actualizar_estilo()


func _actualizar_estilo() -> void:
	_marca_equipado.visible = _equipado
	var normal := _estilo_base.duplicate() as StyleBoxFlat
	if _origen:
		normal.bg_color = Color("654722")
		normal.border_color = Color("ffd58a")
	elif _equipado:
		normal.bg_color = Color("394b35")
		normal.border_color = Color("99b87c")
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = normal.bg_color.lightened(0.15)
	hover.border_color = Color("ffe2ac")
	var presionado := normal.duplicate() as StyleBoxFlat
	presionado.bg_color = normal.bg_color.darkened(0.12)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", presionado)


func _al_pulsar() -> void:
	if permite_interaccion and not _arrastrando and not get_viewport().gui_is_dragging():
		pulsado.emit(indice)


func _get_drag_data(_posicion: Vector2) -> Variant:
	if not permite_interaccion or not is_visible_in_tree() or inventario == null:
		return null
	var actual := inventario.obtener_stack(indice)
	if actual == null or actual != stack or actual.item == null or actual.cantidad <= 0:
		return null
	_arrastrando = true
	arrastre_iniciado.emit(indice)
	var vista := Control.new()
	vista.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icono := TextureRect.new()
	icono.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icono.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icono.texture = actual.item.icono
	icono.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icono.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icono.position = Vector2(-16, -16)
	icono.size = Vector2(32, 32)
	vista.add_child(icono)
	set_drag_preview(vista)
	return {"tipo": "slot_mochila", "inventario": inventario, "origen": indice, "stack": actual}


func _can_drop_data(_posicion: Vector2, datos: Variant) -> bool:
	return _arrastre_valido(datos)


func _drop_data(_posicion: Vector2, datos: Variant) -> void:
	# Volver a comprobar: el modelo pudo cambiar después de _can_drop_data.
	if _arrastre_valido(datos):
		movimiento_solicitado.emit(int(datos["origen"]), indice)


func _arrastre_valido(datos: Variant) -> bool:
	if not permite_interaccion or not is_visible_in_tree() or inventario == null or not datos is Dictionary:
		return false
	if datos.get("tipo") != "slot_mochila" or datos.get("inventario") != inventario:
		return false
	var origen: Variant = datos.get("origen")
	if not origen is int or origen < 0 or origen >= inventario.capacidad:
		return false
	if indice < 0 or indice >= inventario.capacidad or origen == indice:
		return false
	var actual := inventario.obtener_stack(origen)
	return actual != null and actual.item != null and actual.cantidad > 0 and actual == datos.get("stack")


func _notification(que: int) -> void:
	if que == NOTIFICATION_DRAG_END and _arrastrando:
		var exitoso := get_viewport().gui_is_drag_successful()
		# Diferir evita que el mouse-up de un arrastre también cuente como clic.
		_finalizar_arrastre.call_deferred(exitoso)


func _finalizar_arrastre(exitoso: bool) -> void:
	_arrastrando = false
	arrastre_finalizado.emit(exitoso)