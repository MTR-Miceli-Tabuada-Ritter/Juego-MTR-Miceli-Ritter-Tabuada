extends CanvasLayer
@export var horaTexto: RichTextLabel
@export var mesTexto: RichTextLabel
@export var diaTexto: RichTextLabel
var esDeNoche = false
var tiempoEnSegundos = 0.0
var velocidadMultiplicador =1000.0
var centrar = "[center]"
var escenaPrincipalNodo

func _ready() -> void:
	escenaPrincipalNodo = get_node("/root/escenaPrincipal")
	escenaPrincipalNodo.connect("cambioDia",_cambiarDia)
	_cambiarDia()
	
func _cambiarDia():
	diaTexto.text = centrar + "%02d" % [escenaPrincipalNodo.dia]
	
