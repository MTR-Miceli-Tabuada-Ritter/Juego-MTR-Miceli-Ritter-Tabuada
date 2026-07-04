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

var escenaPrincipal

func _ready() -> void:
	crop.visible = false
	colisionArea.disabled = true
	colisionArea.get_parent().interaccionar.connect(cosechar)
	escenaPrincipal = get_node("/root/escenaPrincipal")

func plantar(idSemilla):
	plantado = true
	cropRandom = idSemilla
	crop.visible = true
	crop.frame_coords = Vector2(cropCrecimientoId,cropRandom)
	escenaPrincipal.connect("cambioDia",_crecerCrop)

func _crecerCrop():
	if cropCrecimientoId < 5:
		cropCrecimientoId= cropCrecimientoId+1
		crop.frame_coords = Vector2(cropCrecimientoId,cropRandom)
	else:
		cropListo = true
		colisionArea.disabled = false

func cosechar():
	if cropDesactivado == false:
		cropDesactivado = true
		colisionArea.disabled = true
		escenaPrincipal.cropRecolectado("icono_cultivo", str(cropRandom), 1)
		call_deferred("queue_free")
