extends Node2D
class_name bloqueCultivable

@export var spriteAgujero: Sprite2D

var posTile: Vector2i
var fertilizado = false

func fertilizar(tile: Vector2i):
	posTile = tile
	fertilizado = true

static func obtenerNombre(tile: Vector2i) -> String:
	return "agujero_" + str(tile.x) + "_" + str(tile.y)
