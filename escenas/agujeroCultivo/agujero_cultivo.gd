extends Node2D
@export var velocidadCrecimiento = 1.5
@export var spriteAgujero: Sprite2D
@export var spriteCrop: Sprite2D
@export var colisionArea: CollisionShape2D

var cropCrecimientoId = 0
var cropRandom
var cropListo = false #es true cuando el cultivo no puede crecer mas
var rango = RandomNumberGenerator.new()
var cropDesactivado = false
var plantado = false
var regado = false

var escenaPrincipal

func _ready() -> void:
	spriteCrop.visible = false
	colisionArea.disabled = true
	colisionArea.get_parent().interaccionar.connect(cosechar)
	escenaPrincipal = get_node("/root/escenaPrincipal")

func plantar(idSemilla):
	plantado = true
	cropRandom = idSemilla
	cropCrecimientoId = 1
	spriteCrop.visible = true
	spriteCrop.frame_coords = Vector2(cropCrecimientoId,cropRandom)
	escenaPrincipal.connect("cambioDia",_crecerCrop)

func _crecerCrop():
	if regado == false && cropListo == false: #no lo regaron y puede seguir creciendo
		spriteCrop.visible = false
		cropDesactivado = true
		cropCrecimientoId = 0
	
	spriteCrop.self_modulate = Color(1, 1, 1)
	regado = false
	if cropDesactivado == false && cropListo == false:
		if cropCrecimientoId < 5:
			cropCrecimientoId = cropCrecimientoId + 1
			spriteCrop.frame_coords = Vector2(cropCrecimientoId, cropRandom)
		else:
			cropListo = true
			colisionArea.disabled = false

func regar():
	regado = true
	spriteAgujero.self_modulate = Color(0.75, 0.75, 0.75)
	spriteCrop.self_modulate = Color(0.5, 0.5, 0.5)

func cosechar():
	if cropDesactivado == false:
		cropDesactivado = true
		colisionArea.disabled = true
		escenaPrincipal.cropRecolectado("icono_cultivo", cropRandom, 1)
		call_deferred("queue_free")
