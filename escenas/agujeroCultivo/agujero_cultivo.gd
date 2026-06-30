extends Node2D
@export var velocidadCrecimiento = 1.5
@export var crop: Sprite2D
@export var colisionArea: CollisionShape2D

var cropCrecimientoId = 0
var cropRandom
var cropListo = false
var rango = RandomNumberGenerator.new()
var cropDesactivado = false

var escenaPrincipal


func _ready() -> void:
	cropRandom = rango.randi_range(0,crop.vframes - 1)
	crop.visible=true
	crop.frame_coords= Vector2(cropCrecimientoId,cropRandom)
	escenaPrincipal = get_node("/root/escenaPrincipal")
	escenaPrincipal.connect("cambioDia",_crecerCrop)
	
func _crecerCrop():
	if cropCrecimientoId < 5:
		cropCrecimientoId= cropCrecimientoId+1
		crop.frame_coords = Vector2(cropCrecimientoId,cropRandom)
	else:
		cropListo= true

func cosechar():
	if cropDesactivado == false:
		cropDesactivado = true
		colisionArea.disabled = true
		escenaPrincipal.cropRecolectado("icono_" + str(cropRandom), 1)
		call_deferred("queue_free")
