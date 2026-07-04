extends CharacterBody2D
var agujeroPreload = preload("res://escenas/agujeroCultivo/agujeroCultivo.tscn")
@export var direccionVistaMarker: Marker2D
@export var animacion: AnimatedSprite2D 
@export var notificacion: Sprite2D
@export var accionablesArea: Area2D
@onready var tilemap: TileMapLayer = get_tree().get_first_node_in_group("tilemap_cultivable")#no me interesa cambiar desde el inspector entonces dejo onready
var velocidad = 200.0
var ultima_direccion = Vector2.DOWN
var esta_actuando = false

var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	animacion.animation_finished.connect(_on_animation_finished)
	_actualizar_area_cultivo(ultima_direccion)

func _physics_process(_delta: float) -> void:
	var direccionMovimiento = Input.get_vector("izquierda", "derecha", "arriba", "abajo")
	velocity = velocidad * direccionMovimiento
	if direccionMovimiento != Vector2.ZERO:
		ultima_direccion = direccionMovimiento
		_actualizar_area_cultivo(ultima_direccion)
	if Input.is_action_just_pressed("herramienta") and not esta_actuando:
		esta_actuando = true
		_procesar_animacion("Hacha", ultima_direccion)
	if not esta_actuando:
		if direccionMovimiento != Vector2.ZERO:
			_procesar_animacion("correr", direccionMovimiento)
		else:
			_procesar_animacion("idle", ultima_direccion)
	move_and_slide()
	_chequearAccionables()

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
		if escenaPrincipal.slotEnUso == null or escenaPrincipal.slotEnUso.texturaNombre != "icono_semilla":
			return
		print("suelo fertilizado")
		var agujeroInstancia = agujeroPreload.instantiate()
		agujeroInstancia.position = direccionVistaMarker.global_position
		agujeroInstancia.cropRandom = escenaPrincipal.slotEnUso.texturaId
		get_parent().call_deferred("add_child",agujeroInstancia)
	else:
		print("no hay suelo cultivable acá")

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
		_intentar_cultivar() 

func _chequearAccionables():
	var areasColisionantes: Array[Area2D] = accionablesArea.get_overlapping_areas() #devuelve todas las areas que esten colisionando con el pj
	if areasColisionantes.size() > 0:
		for area in areasColisionantes:
			if area.get_parent().cropListo == true:
				notificacion.visible = true
				if escenaPrincipal.slotEnUso != null and escenaPrincipal.slotEnUso.texturaNombre == "icono_semilla":
					area.get_parent().cosechar()
	else:
		notificacion.visible = false
			
