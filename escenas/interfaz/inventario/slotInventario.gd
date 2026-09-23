extends TextureRect

@export var textoCantidad: Label
@export var progreso: TextureProgressBar
var stack: ItemStack = null

func set_stack(nuevo_stack: ItemStack) -> void:
	stack = nuevo_stack
	actualizar_visual()

# vuelve a dibujar el slot a partir del stack actual; llamar despues de mutar su cantidad
func actualizar_visual() -> void:
	if stack != null and stack.esta_vacio() and stack.item.se_elimina_al_agotarse:
		stack = null
	# no ocultamos el slot (visible=true) para que el HBoxContainer no reordene los demas
	# y el resaltado de inventario no se desplace al lugar equivocado
	if stack == null:
		texture = null
		textoCantidad.text = "00"
		textoCantidad.visible = false
		if progreso:
			progreso.visible = false
		visible = true
		return
	texture = stack.item.icono
	textoCantidad.visible = not stack.item.oculta_contador
	# el coso raro "%02d" dice que tiene q ser un decimal de 2 digitos osea en vez de "2" sería "02"
	textoCantidad.text = "%02d" % stack.cantidad
	if progreso:
		progreso.visible = stack.item.muestra_barra_progreso
		progreso.value = stack.cantidad
	visible = true
