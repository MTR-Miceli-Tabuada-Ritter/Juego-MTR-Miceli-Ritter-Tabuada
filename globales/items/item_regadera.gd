class_name ItemRegadera
extends ItemHerramienta

func usar(_jugador, agujero, stack: ItemStack) -> void:
	if agujero != null and agujero.plantado and stack.cantidad > 0:
		stack.quitar(10)
		agujero.regar()

func sonido_al_usar() -> void:
	SonidosGlobales.reproducirSonidoRegar()

func recargar(stack: ItemStack) -> void:
	stack.cantidad = max_stack
