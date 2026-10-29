class_name ItemRegadera
extends ItemHerramienta

func _init() -> void:
	super._init()
	capacidad_carga = 100
	muestra_barra_progreso = true

func usar(jugador, agujero, _stack: ItemStack) -> void:
	if agujero != null and agujero.plantado and jugador.consumir_cargas(10):
		agujero.regar()

func sonido_al_usar() -> void:
	SonidosGlobales.reproducirSonidoRegar()
