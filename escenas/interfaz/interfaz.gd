extends CanvasLayer
@export var horaTexto: RichTextLabel
@export var mesTexto: RichTextLabel
@export var diaTexto: RichTextLabel
@export var slot1: TextureRect
@export var slot2: TextureRect
@export var slot3: TextureRect
@export var slot4: TextureRect


var esDeNoche = false
var tiempoEnSegundos = 0.0
var velocidadMultiplicador = 100.0
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
	var esHoraDeNoche = horas >= 18 or horas < 5
	if esHoraDeNoche and esDeNoche == false:
		esDeNoche = true
		escenaPrincipal.arrancarNoche()
	if esHoraDeNoche == false and esDeNoche == true:
		esDeNoche = false
		escenaPrincipal.arrancarDia()
	if tiempoEnSegundos >= 86400: #lo q dura un dia
		tiempoEnSegundos = 0.0
		escenaPrincipal.terminarNoche()
	horaTexto.text = centrar + "%02d:%02d" % [horas,minutos]

func cropRecolectado(rutaObjeto, cantidad):
	var indice = rutaObjeto.find("_")
	var numeroRutaObjeto = rutaObjeto.substr(indice + 1)
	
	match numeroRutaObjeto:
		"0":
			if slot1.estaEnUso == true:
				slot1.cambiarTexto(cantidad)
			else:
				slot1.setearSlot(rutaObjeto,cantidad)
		"1":
			if slot2.estaEnUso:
				slot2.cambiarTexto(cantidad)
			else:
				slot2.setearSlot(rutaObjeto,cantidad)
		"3":
			if slot3.estaEnUso:
				slot3.cambiarTexto(cantidad)
			else:
				slot3.setearSlot(rutaObjeto,cantidad)
		"4":
			if slot4.estaEnUso:
				slot4.cambiarTexto(cantidad)
			else:
				slot4.setearSlot(rutaObjeto,cantidad)
