extends Node2D
@export var velocidadCrecimiento = 1.5
@export var crop: AnimatedSprite2D
var cropCrecimientoId = 0
var cropRandom
var flagLista = false
var rango = RandomNumberGenerator.new()

func _ready() -> void:
	cropRandom = rango.randi_range(0,crop.vframes - 1)
	crop.visible=true
	crop.frame_cords= Vector2(cropCrecimientoId,cropRandom)
	_crecerCrop()
	
func _crecerCrop():
	if cropCrecimientoId < crop.hframes -1:
		await get_tree().create_timer(velocidadCrecimiento).timeout
		cropCrecimientoId= cropCrecimientoId+1
		crop.frame_cords = Vector2(cropCrecimientoId,cropRandom)
		_crecerCrop()
	else:
		flagLista= true
