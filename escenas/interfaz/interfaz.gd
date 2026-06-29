extends CanvasLayer
@export var horaTexto: RichTextLabel
@export var mesTexto: RichTextLabel
@export var diaTexto: RichTextLabel
var esDeNoche = false
var tiempoEnSegundos = 0.0
var velocidadMultiplicador =10000.0
var centrar = "[center]"
var escenaPrincipal

func _ready() -> void:
	escenaPrincipal = get_node("/root/escenaPrincipal")
	escenaPrincipal.connect("cambioDia",_cambiarFecha)
	_cambiarFecha()
	
func _cambiarFecha():
	diaTexto.text = centrar + "%02d" % [escenaPrincipal.dia]
	mesTexto.text = centrar + "%02d" % [escenaPrincipal.mes]

func _process(delta: float) -> void:
	tiempoEnSegundos += delta * velocidadMultiplicador #para 
	var horas = int(tiempoEnSegundos / 3600) % 24
	var minutos = int(tiempoEnSegundos / 60) % 60
	if horas > 18 and esDeNoche == false:
		esDeNoche = true
		escenaPrincipal.arrancarNoche()
	if tiempoEnSegundos >= 86400: #lo q dura un dia
		tiempoEnSegundos = 0.0
		esDeNoche = false
		escenaPrincipal.terminarNoche()
	horaTexto.text = centrar + "%02d:%02d" % [horas,minutos]
