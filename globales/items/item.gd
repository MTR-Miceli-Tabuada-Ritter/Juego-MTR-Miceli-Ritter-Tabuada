class_name Item
extends Resource

@export var id: String = ""
@export var icono: Texture2D
@export var max_stack: int = 100
@export var precio_venta: int = -1 # -1 = no se puede vender
@export var oculta_contador: bool = false
@export var muestra_barra_progreso: bool = false
@export var nombre_animacion: String = "Hacha"
@export var se_elimina_al_agotarse: bool = false

func usar(_jugador, _agujero, _stack: ItemStack) -> void:
	pass

func sonido_al_usar() -> void:
	pass
