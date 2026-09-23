class_name ItemSemilla
extends Item

@export var cultivo_resultante: Item
@export var fila_sprite: int = 0

func _init() -> void:
	se_elimina_al_agotarse = true

func usar(_jugador, agujero, stack: ItemStack) -> void:
	if agujero != null and not agujero.plantado:
		agujero.plantar(self)
		stack.quitar(1)
		SonidosGlobales.reproducirSonidoPlantar()
