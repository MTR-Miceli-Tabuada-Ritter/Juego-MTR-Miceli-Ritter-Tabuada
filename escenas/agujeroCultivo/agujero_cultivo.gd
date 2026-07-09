extends Node2D
@export var velocidadCrecimiento = 1.5
@export var crop: Sprite2D
@export var colisionArea: CollisionShape2D

var cropCrecimientoId = 0
var cropRandom
var cropListo = false
var rango = RandomNumberGenerator.new()
var cropDesactivado = false
var plantado = false
var regado = false

var escenaPrincipal

func _ready() -> void:
	crop.visible = false
	colisionArea.disabled = true
	colisionArea.get_parent().interaccionar.connect(cosechar)
	escenaPrincipal = get_node("/root/escenaPrincipal")

func plantar(idSemilla):
	plantado = true
	cropRandom = idSemilla
	cropCrecimientoId = 1
	crop.visible = true
	crop.frame_coords = Vector2(cropCrecimientoId,cropRandom)
	escenaPrincipal.connect("cambioDia",_crecerCrop)

func _crecerCrop():
	crop.self_modulate = Color(1, 1, 1)
	regado = false
	if cropCrecimientoId < 5:
		cropCrecimientoId= cropCrecimientoId+1
		crop.frame_coords = Vector2(cropCrecimientoId,cropRandom)
		if cropCrecimientoId == 5:
			cropListo = true
			colisionArea.disabled = false
	else:
		cropListo = true
		colisionArea.disabled = false

func regar():
	regado = true
	crop.self_modulate = Color(0.75, 0.75, 0.75)

func cosechar():
	if cropDesactivado == false:
		cropDesactivado = true
		colisionArea.disabled = true
		escenaPrincipal.cropRecolectado("icono_cultivo", cropRandom, 1)
		call_deferred("queue_free")
