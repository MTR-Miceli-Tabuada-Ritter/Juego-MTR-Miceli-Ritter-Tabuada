extends CharacterBody2D
var agujeroPreload = preload("res://escenas/agujeroCultivo/agujeroCultivo.tscn")
@export var direccionVistaMarker: Marker2D
@export var animacion: AnimatedSprite2D 
@export var notificacion: Sprite2D
@export var accionablesArea: Area2D
@onready var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap_cultivable")#no me interesa cambiar desde el inspector entonces dejo onready
@onready var tilemapAgua: TileMapLayer = get_tree().get_first_node_in_group("tilemap_agua")
var velocidad = 200.0
var ultima_direccion = Vector2.DOWN
var esta_actuando = false
var masCercano = null

var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	animacion.animation_finished.connect(_on_animation_finished)
	_actualizar_area_cultivo(ultima_direccion)

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
	if Input.is_action_just_pressed("herramienta") and not esta_actuando:
		esta_actuando = true
		_procesar_animacion("Hacha", ultima_direccion)
		if escenaPrincipal.slotEnUso != null and escenaPrincipal.slotEnUso.texturaId == 1:
			SonidosGlobales.reproducirSonidoRegar()
		elif escenaPrincipal.slotEnUso != null and escenaPrincipal.slotEnUso.texturaId == 0:
			SonidosGlobales.reproducirSonidoCortar()
	if Input.is_action_just_pressed("interactuar") and masCercano != null and is_instance_valid(masCercano):
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
		if escenaPrincipal.slotEnUso == null:
			return
		var nombreAgujero = "agujero_" + str(int(round(direccionVistaMarker.global_position.x))) + "_" + str(int(round(direccionVistaMarker.global_position.y)))
		var escenario = escenaPrincipal.get_node("escenario")
		var agujeroExistente = escenario.get_node_or_null(nombreAgujero)
		if escenaPrincipal.slotEnUso.texturaNombre == "icono_herramienta" and escenaPrincipal.slotEnUso.texturaId == 0:
			if agujeroExistente == null:
				print("suelo fertilizado")
				var agujeroInstancia = agujeroPreload.instantiate()
				agujeroInstancia.position = direccionVistaMarker.global_position
				agujeroInstancia.name = nombreAgujero
				agujeroInstancia.z_index = -1
				escenario.call_deferred("add_child",agujeroInstancia)
		elif escenaPrincipal.slotEnUso.texturaNombre == "icono_semilla":
			if agujeroExistente != null and not agujeroExistente.plantado:
				agujeroExistente.plantar(escenaPrincipal.slotEnUso.texturaId)
				escenaPrincipal.slotEnUso.cambiarTexto(-1)
				SonidosGlobales.reproducirSonidoPlantar()
		elif escenaPrincipal.slotEnUso.texturaNombre == "icono_herramienta" and escenaPrincipal.slotEnUso.texturaId == 1:
			if agujeroExistente != null and agujeroExistente.plantado and escenaPrincipal.slotEnUso.cantidad > 0:
				escenaPrincipal.slotEnUso.cambiarTexto(-10)
				agujeroExistente.regar()
	else:
		print("no hay suelo cultivable acá")

func _chequearAgua():
	var pos_tile = tilemapAgua.local_to_map(tilemapAgua.to_local(direccionVistaMarker.global_position))
	var adyacentes = [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	for offset in adyacentes:
		var tile_data = tilemapAgua.get_cell_tile_data(pos_tile + offset)
		if tile_data and tile_data.get_collision_polygons_count(2) > 0:
			if escenaPrincipal.slotEnUso != null and escenaPrincipal.slotEnUso.texturaNombre == "icono_herramienta" and escenaPrincipal.slotEnUso.texturaId == 1:
				escenaPrincipal.slotEnUso.cambiarTexto(100 - escenaPrincipal.slotEnUso.cantidad)
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

func _on_animation_finished():
	if esta_actuando:
		esta_actuando = false
		SonidosGlobales.detenerSonidoRegar()
		_intentar_cultivar()

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
			
