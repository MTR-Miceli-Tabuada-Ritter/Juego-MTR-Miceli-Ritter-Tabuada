extends CharacterBody2D
var agujeroPreload = preload("res://escenas/agujeroCultivo/agujeroCultivo.tscn")

@export var direccionVistaMarker: Marker2D
@export var animacion: AnimatedSprite2D 
@export var notificacion: Sprite2D
@export var accionablesArea: Area2D
@onready var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap_cultivable")#no me interesa cambiar desde el inspector entonces dejo onready
@onready var tilemapAgua: TileMapLayer = get_tree().get_first_node_in_group("tilemap_agua")
@onready var arma: Node2D = $Arma

enum Accion { NINGUNA, HERRAMIENTA, ATAQUE }
# Cuadro de las animaciones Espada* en el que se ve el corte.
const CUADRO_IMPACTO_ESPADA := 1
var velocidad = 200.0
var ultima_direccion = Vector2.DOWN
var esta_actuando = false
var masCercano = null
var _indice_accion: int = -1
var _accion_actual := Accion.NINGUNA
var _stack_accion: ItemStack = null
var _impacto_hecho := false

var escenaPrincipal

func _ready() -> void:
	add_to_group("jugador")
	escenaPrincipal = get_node("/root/escenaPrincipal")
	animacion.animation_finished.connect(_on_animation_finished)
	animacion.frame_changed.connect(_on_frame_changed)
	_actualizar_area_cultivo(ultima_direccion)

# K o clic izquierdo. Por evento y no por polling: los clics que consume la
# interfaz (mochila, diálogos, HUD) no llegan acá y no actúan.
func _unhandled_input(event: InputEvent) -> void:
	var ataca := event.is_action_pressed("atacar")
	var usa_herramienta := event.is_action_pressed("herramienta")
	if esta_actuando or not (ataca or usa_herramienta):
		return
	var stack := InventarioJugador.obtener_stack_seleccionado()
	if stack != null and stack.item is ItemEspada:
		intentar_atacar()
	elif usa_herramienta:
		_usar_herramienta()
	else:
		return
	get_viewport().set_input_as_handled()

# Solo con la espada seleccionada; durante otra acción o una pausa no hace nada.
func intentar_atacar() -> bool:
	var stack := InventarioJugador.obtener_stack_seleccionado()
	if esta_actuando or not can_process() or stack == null or not stack.item is ItemEspada:
		return false
	esta_actuando = true
	_accion_actual = Accion.ATAQUE
	_indice_accion = InventarioJugador.indice_seleccionado
	_stack_accion = stack
	_impacto_hecho = false
	var direccion := _direccion_cardinal(ultima_direccion)
	arma.preparar(direccion)
	_procesar_animacion(stack.item.nombre_animacion, direccion)
	stack.item.sonido_al_usar()
	return true

func _usar_herramienta() -> void:
	esta_actuando = true
	_accion_actual = Accion.HERRAMIENTA
	_indice_accion = InventarioJugador.indice_seleccionado
	var stack_en_uso := InventarioJugador.inventario.obtener_stack(_indice_accion)
	_procesar_animacion(stack_en_uso.item.nombre_animacion if stack_en_uso != null else "Hacha", ultima_direccion)
	if stack_en_uso != null:
		stack_en_uso.item.sonido_al_usar()

func _physics_process(_delta: float) -> void:
	var direccionMovimiento = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	if esta_actuando:
		velocity = Vector2.ZERO
	else:
		velocity = velocidad * direccionMovimiento
		if direccionMovimiento != Vector2.ZERO:
			ultima_direccion = direccionMovimiento
			_actualizar_area_cultivo(ultima_direccion)
	if not esta_actuando and direccionMovimiento != Vector2.ZERO:
		SonidosGlobales.reproducirSonidoCaminar()
	else:
		SonidosGlobales.detenerSonidoCaminar()
	if Input.is_action_just_pressed("interactuar") and _accion_actual != Accion.ATAQUE and masCercano != null and is_instance_valid(masCercano):
		masCercano.interaccionar.emit()
	if not esta_actuando:
		if direccionMovimiento != Vector2.ZERO:
			_procesar_animacion("correr", direccionMovimiento)
		else:
			_procesar_animacion("idle", ultima_direccion)
	move_and_slide()
	_chequearAccionables()
	_chequearAgua()

#aca metemos una logica para que el marker este siempre en un tile en especifico
#y que sea mas preciso todo para cultivar
func _actualizar_area_cultivo(direccion: Vector2) -> void:
	# obtenemos el tile donde está el jugador
	var tile_jugador = tilemap.local_to_map(tilemap.to_local(global_position))
	# le sumamos la dirección redondeada para obtener el tile de enfrente
	var tile_enfrente = tile_jugador + Vector2i(round(direccion.normalized().x), round(direccion.normalized().y))
	# convertimos ese tile de vuelta a posición en el mundo y la asignamos al marker
	direccionVistaMarker.global_position = tilemap.to_global(tilemap.map_to_local(tile_enfrente))

func _intentar_cultivar():
	# agarramos la posición global del Marker, la convertimos a coordenadas locales del tilemap
	# y dsp a coordenadas de grilla (columna, fila porque asi se manejan). Con eso le preguntamos al tilemap
	# qué tile hay ahí y si tiene el physics layer "cultivable" (layer 1) asignado y chau
	var pos_tile = tilemap.local_to_map(tilemap.to_local(direccionVistaMarker.global_position))
	var tile_data = tilemap.get_cell_tile_data(pos_tile)

	if tile_data and tile_data.get_collision_polygons_count(1) > 0:
		var stack := InventarioJugador.inventario.obtener_stack(_indice_accion)
		if stack == null:
			return
		var nombreAgujero = bloqueCultivable.obtenerNombre(pos_tile)
		var escenario = escenaPrincipal.get_node("escenario")
		var agujeroExistente = escenario.get_node_or_null(nombreAgujero)
		# el item decide que hacer con el agujero (cavar, plantar, regar); jugador solo detecta el entorno
		stack.item.usar(self, agujeroExistente, stack)
	else:
		print("no hay suelo cultivable acá")
		var stack_fuera_de_rango := InventarioJugador.inventario.obtener_stack(_indice_accion)
		if stack_fuera_de_rango != null:
			stack_fuera_de_rango.item.sonido_al_fallar()

func _chequearAgua():
	var pos_tile = tilemapAgua.local_to_map(tilemapAgua.to_local(direccionVistaMarker.global_position))
	var adyacentes = [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for offset in adyacentes:
		var tile_data = tilemapAgua.get_cell_tile_data(pos_tile + offset)
		if tile_data and tile_data.get_collision_polygons_count(2) > 0:
			var stack := InventarioJugador.obtener_stack_seleccionado()
			if stack != null and stack.item is ItemRegadera:
				InventarioJugador.inventario.recargar_cargas(InventarioJugador.indice_seleccionado)
			return

func _procesar_animacion(estado: String, direccion: Vector2):
	if abs(direccion.x) > abs(direccion.y):
		animacion.play(estado + "Derecha")
		animacion.flip_h = direccion.x < 0
	else:
		animacion.flip_h = false
		if direccion.y > 0:
			animacion.play(estado + "Abajo")
		else:
			animacion.play(estado + "Arriba")

# Misma regla que _procesar_animacion: eje dominante y empate vertical.
func _direccion_cardinal(direccion: Vector2) -> Vector2:
	if abs(direccion.x) > abs(direccion.y):
		return Vector2.RIGHT if direccion.x > 0 else Vector2.LEFT
	return Vector2.DOWN if direccion.y > 0 else Vector2.UP

func _on_frame_changed() -> void:
	if _accion_actual != Accion.ATAQUE or _impacto_hecho or animacion.frame != CUADRO_IMPACTO_ESPADA:
		return
	_impacto_hecho = true
	# Cambiar o perder la espada antes del corte cancela el daño de este golpe.
	if InventarioJugador.indice_seleccionado == _indice_accion and InventarioJugador.inventario.obtener_stack(_indice_accion) == _stack_accion:
		arma.impactar()

func _on_animation_finished():
	if not esta_actuando:
		return
	var accion := _accion_actual
	esta_actuando = false
	_accion_actual = Accion.NINGUNA
	if accion == Accion.ATAQUE:
		# Un golpe nunca trabaja la tierra.
		_stack_accion = null
	else:
		SonidosGlobales.detenerSonidoRegar()
		_intentar_cultivar()
	_indice_accion = -1

func consumir_item(cantidad: int) -> bool:
	return InventarioJugador.inventario.quitar_de_slot(_indice_accion, cantidad)

func consumir_cargas(cantidad: int) -> bool:
	return InventarioJugador.inventario.consumir_cargas(_indice_accion, cantidad)

func _chequearAccionables():
	var areasColisionantes: Array[Area2D] = accionablesArea.get_overlapping_areas()
	var distanciaCorta = INF
	var proximo = null
	for area in areasColisionantes:
		var distancia = area.global_position.distance_to(global_position)
		if distancia < distanciaCorta:
			distanciaCorta = distancia
			proximo = area
	if proximo != null:
		masCercano = proximo
		notificacion.visible = true
	else:
		masCercano = null
		notificacion.visible = false
			
