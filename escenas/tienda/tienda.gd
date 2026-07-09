extends preciosGestor

@export var areaInteractuable: Area2D
@export var dialogo: Control
@export var dialogoTexto: RichTextLabel

var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	areaInteractuable.actionated.connect(modoVenta)
	
func modoVenta():
	return
