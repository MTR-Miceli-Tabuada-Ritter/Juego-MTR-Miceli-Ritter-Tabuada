class_name ItemSemilla
extends Item

@export var cultivo_resultante: Item
@export var fila_sprite: int = 0

func _init() -> void:
	se_elimina_al_agotarse = true

func usar(jugador, agujero, _stack: ItemStack) -> void:
	if agujero != null and not agujero.plantado and jugador.consumir_item(1):
		agujero.plantar(self)
		SonidosGlobales.reproducirSonidoPlantar()
